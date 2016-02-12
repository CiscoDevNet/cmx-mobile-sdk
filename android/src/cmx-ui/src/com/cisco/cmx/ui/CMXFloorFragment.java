package com.cisco.cmx.ui;

import it.sephiroth.android.library.imagezoom.ImageViewTouchBase.DisplayType;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.content.LocalBroadcastManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.AlphaAnimation;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;

import com.cisco.cmx.R;
import com.cisco.cmx.model.CMXBanner;
import com.cisco.cmx.model.CMXClientLocation;
import com.cisco.cmx.model.CMXFloor;
import com.cisco.cmx.model.CMXPath;
import com.cisco.cmx.model.CMXPoi;
import com.cisco.cmx.network.CMXBannersResponseHandler;
import com.cisco.cmx.network.CMXClient;
import com.cisco.cmx.network.CMXImageResponseHandler;
import com.cisco.cmx.network.CMXPathResponseHandler;
import com.cisco.cmx.network.CMXPoisResponseHandler;

/**
 * A fragment that displays a floor with POIs, and exposes event handlers when
 * the user selects a poi.
 */
public class CMXFloorFragment extends Fragment implements CMXFloorView.SelectionHandler, CMXFloorView.ActiveSelectionHandler, CMXFloorView.FeedbackViewHandler, SensorEventListener {

    private static String FLOOR_KEY = "FLOOR";

    private static String POIS_KEY = "POIS";

    private static int DEFAULT_BANNER_DURATION = 5; // in seconds

    private ProgressListener mProgressListener;

    private PathProgressListener mPathProgressListener;

    private OnPoiSelectedListener mSelectedListener;

    private OnActivePoiSelectedListener mActiveSelectedListener;

    private OnFeedbackViewListener mOnFeedbackViewListener;

    private View mRootView;

    private CMXFloorView mMapView;

    private ImageView mBannerView;

    private ProgressBar mLoadingView;

    private Bitmap mBitmap;

    private List<CMXPoi> mPois;

    private HashMap<String, CMXPoi> mPoiById; // map of poi, key = poi
                                              // identifier

    private HashMap<String, Bitmap> mPoiImageById; // map of poi image, key =
                                                   // poi identifier

    private String mActivePoiId;

    private String mTargetPoiId;

    private int mBannerDuration;

    private String mActiveZoneId;

    private List<CMXBanner> mBanners;

    private int mActiveBannerIndex;

    private Timer mBannerRefreshTimer;

    private SensorManager mSensorManager;

    private Sensor mAccelerometer;

    private Sensor mMagnetometer;

    private float[] mGravity;

    private float[] mGeomagnetic;

    private int mShortAnimationDuration;

    private UserLocationBroadcastReceiver mLocationReceiver;

    /**
     * Classes wishing to be notified of poi selection implement this.
     */
    public interface OnPoiSelectedListener {

        /**
         * Callback method to be invoked when a poi has been selected
         * 
         * @param poi
         *            selected poi
         */
        void onPoiSelected(CMXPoi poi);
    }

    /**
     * Classes wishing to be notified of active poi selection implement this.
     */
    public interface OnActivePoiSelectedListener {

        /**
         * Callback method to be invoked when an active poi has been selected
         * 
         * @param poi
         *            selected active poi
         */
        void onActivePoiSelected(CMXPoi poi);
    }

    /**
     * Classes wishing to be notified of feedback view implement this.
     */
    public interface OnFeedbackViewListener {

        /**
         * Callback method to be invoked when a feedback view has been chosen
         * 
         * @param x
         *            x position of the feedback view
         * @param y
         *            y position of the feedback view
         */
        void onFeedbackViewListener(float x, float y);
    }

    /**
     * Classes wishing to be notified of loading progress/completion implement
     * this.
     */
    public interface ProgressListener {

        /**
         * Notifies that the task has started.
         */
        public void onStart();

        /**
         * Notifies that the task has completed.
         * 
         * @param mapBitmap
         *            image of the map.
         * @param pois
         *            pois of the map.
         */
        public void onSuccess(Bitmap mapBitmap, List<CMXPoi> pois);

        /**
         * Notifies that the task has failed.
         * 
         * @param error
         *            an error
         */
        public void onFailure(Throwable error);
    }

    /**
     * Classes wishing to be notified of path progress/completion implement
     * this.
     */
    public interface PathProgressListener {

        /**
         * Notifies that the task has started.
         */
        public void onStart();

        /**
         * Notifies that the task has completed
         * 
         * @param path
         *            result
         */
        public void onSuccess(CMXPath path);

        /**
         * Notifies that the task has failed.
         * 
         * @param error
         *            an error
         */
        public void onFailure(Throwable error);

    }

    /**
     * Create a new instance of CMXMapFragment, initialized with a map
     * 
     * @param map
     *            a map
     * @param pois
     *            a pois list
     * @return a new instance of CMXMapFragment
     */
    public static CMXFloorFragment newInstance(CMXFloor map, List<CMXPoi> pois) {
        CMXFloorFragment f = new CMXFloorFragment();

        // Supply index input as an argument.
        Bundle args = new Bundle();
        args.putParcelable(FLOOR_KEY, map);
        args.putParcelableArrayList(POIS_KEY, new ArrayList<CMXPoi>(pois));
        f.setArguments(args);

        return f;
    }

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);

        // Keep this Fragment around even during config changes
        setRetainInstance(true);

        mShortAnimationDuration = getResources().getInteger(android.R.integer.config_shortAnimTime);

    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mPoiImageById = new HashMap<String, Bitmap>();

        mBannerDuration = DEFAULT_BANNER_DURATION;

        mSensorManager = (SensorManager) getActivity().getSystemService(Context.SENSOR_SERVICE);
        mAccelerometer = mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
        mMagnetometer = mSensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD);

        mLocationReceiver = new UserLocationBroadcastReceiver();
        LocalBroadcastManager.getInstance(getActivity()).registerReceiver(mLocationReceiver, new IntentFilter(CMXMainActivity.USER_LOCATION_UPDATE_ACTION));
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        mRootView = inflater.inflate(R.layout.cmx_floor_layout, container, false);

        mLoadingView = (ProgressBar) mRootView.findViewById(R.id.cmx_floor_view_progressBar);

        mBannerView = (ImageView) mRootView.findViewById(R.id.cmx_floor_banner_imageview);
        mBannerView.setVisibility(View.GONE);

        mMapView = (CMXFloorView) mRootView.findViewById(R.id.cmx_floor_view);
        mMapView.setSelectionHandler(this);
        mMapView.setActiveSelectionHandler(this);
        mMapView.setFeedbackViewHandler(this);

        mMapView.setTargetLocationBitmap(BitmapFactory.decodeResource(getResources(), R.drawable.cmx_user_location_on_map));
        mMapView.setLocationFeedbackBitmap(BitmapFactory.decodeResource(getResources(), R.drawable.cmx_feedback_user_location));
        mMapView.setArrowLocationBitmap(BitmapFactory.decodeResource(getResources(), R.drawable.arrow_location));
        mMapView.setArrowLocationBitmapScaling(0.8f);
        mMapView.setEndPointBitmap(BitmapFactory.decodeResource(getResources(), R.drawable.cmx_target_location_on_map));

        // Set the default image display type
        mMapView.setDisplayType(DisplayType.FIT_IF_BIGGER);

        return mRootView;
    }

    @Override
    public void onResume() {
        super.onResume();

        // TODO: Harvey Delery add back the sensor listeners later when working better
        //if (mAccelerometer != null && mMagnetometer != null) {
        //    mSensorManager.registerListener(this, mAccelerometer, SensorManager.SENSOR_DELAY_UI);
        //    mSensorManager.registerListener(this, mMagnetometer, SensorManager.SENSOR_DELAY_UI);
        //}

    }

    @Override
    public void onPause() {
        super.onPause();

        if (mAccelerometer != null && mMagnetometer != null) {
            mSensorManager.unregisterListener(this, mAccelerometer);
            mSensorManager.unregisterListener(this, mMagnetometer);
        }

        if (mBannerRefreshTimer != null) {
            mBannerRefreshTimer.cancel();
        }
    }

    @Override
    public void onDestroy() {
        if (mLocationReceiver != null) {
            LocalBroadcastManager.getInstance(getActivity()).unregisterReceiver(mLocationReceiver);
        }

        super.onDestroy();
    }

    @Override
    public void onPoiSelected(String poiIdentifier) {
        if (mSelectedListener != null) {
            mSelectedListener.onPoiSelected(mPoiById.get(poiIdentifier));
        }
    }

    @Override
    public void onActivePoiSelected(String poiIdentifier) {
        if (poiIdentifier == null) {
            mActivePoiId = null;
        }
        else {
            if (mActiveSelectedListener != null) {
                mActiveSelectedListener.onActivePoiSelected(mPoiById.get(poiIdentifier));
            }
        }
    }

    @Override
    public void onFeedbackViewChosen(float x, float y) {
        if (mOnFeedbackViewListener != null) {
            mOnFeedbackViewListener.onFeedbackViewListener(x, y);
        }
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {

    }

    @Override
    public void onSensorChanged(SensorEvent event) {
        if (event.sensor.getType() == Sensor.TYPE_ACCELEROMETER)
            mGravity = lowPass(event.values, mGravity, 0.25f);
        else if (event.sensor.getType() == Sensor.TYPE_MAGNETIC_FIELD)
            mGeomagnetic = lowPass(event.values, mGeomagnetic, 0.25f);

        if (mGravity != null && mGeomagnetic != null) {
            // Log.v("App", "Gravity : " + mGravity[0] + "  " + mGravity[1] +
            // "  " + mGravity[2]);
            // Log.v("App", "Geomagnetic : " + mGeomagnetic[0] + "  " +
            // mGeomagnetic[1] + "  " + mGeomagnetic[2]);
            float R[] = new float[9];
            float I[] = new float[9];
            boolean success = SensorManager.getRotationMatrix(R, I, mGravity, mGeomagnetic);
            if (success) {
                float newOrientation[] = new float[3];
                SensorManager.getOrientation(R, newOrientation);
                float azimut = newOrientation[0];
                float pitch = newOrientation[1];

                if (mMapView != null) {
                    // Log.v("App", "Orientation : " +
                    // Math.toDegrees(newOrientation[0]) + "  " +
                    // Math.toDegrees(newOrientation[1]) + "  " +
                    // Math.toDegrees(newOrientation[2]));
                    // Log.v("App", "Low pass Orientation : " +
                    // Math.toDegrees(mOrientation[0]) + "  " +
                    // Math.toDegrees(mOrientation[1]) + "  " +
                    // Math.toDegrees(mOrientation[2]));
                    if (Math.abs(Math.toDegrees(pitch)) < 30) {
                        mMapView.setClientDirection((float) Math.toDegrees(azimut));
                        // Log.v("App", "Azimut : " + Math.toDegrees(azimut));
                    }
                    else {
                        mMapView.disableClientDirection();
                    }
                    mMapView.invalidate();
                }
            }
        }
    }

    /**
     * Set the active poi.
     * 
     * @param poiId
     *            ID of the active poi.
     * @param centerOnMap
     *            true to center the POI on map, false otherwise.
     */
    public void setActivePoi(String poiId, boolean centerOnMap) {

        if (mActivePoiId == null || !mActivePoiId.equals(poiId)) {
            mActivePoiId = poiId;
            if (poiId != null && mPoiById != null) {
                CMXPoi poi = mPoiById.get(poiId);
                mMapView.setActivePoi(poi);

                if (centerOnMap && mMapView != null && poi != null) {
                    mMapView.centerOnPoi(poi);
                }
            }
        }
        else {
            mActivePoiId = null;
            mMapView.setActivePoi(null);
        }

    }

    /**
     * Returns the current active poi
     * 
     * @return poi the active poi
     */
    public CMXPoi getActivePoi() {
        if (mActivePoiId != null) {
            return getPoi(mActivePoiId);
        }
        return null;
    }

    /**
     * Returns the current active poi id
     * 
     * @return poiId the active poiId
     */
    public String getActivePoiId() {
        if (mActivePoiId != null) {
            return mActivePoiId;
        }
        return null;
    }

    /**
     * Set the poi ID of the target. It will show the path on map from the
     * current user location to the target.
     * 
     * @param poiId
     *            poi ID of the target.
     */
    public void setTargetPoi(String poiId) {

        mTargetPoiId = poiId;

        if (mTargetPoiId != null) {
            loadPath(mTargetPoiId);
        }
    }

    /**
     * Returns true if fragments already has an image map and a poi list
     * 
     * @return true or false
     */
    public boolean hasResult() {
        return mBitmap != null && mPois != null;
    }

    /**
     * Returns the map of the framgent
     * 
     * @return CMXFloor, a map
     */
    public CMXFloor getMap() {
        return getArguments().getParcelable(FLOOR_KEY);
    }

    /**
     * Returns the bitmap, the map image
     * 
     * @return a bitmap
     */
    public Bitmap getMapBitmap() {
        return mBitmap;
    }

    /**
     * Returns the pois list of this map
     * 
     * @return a list of CMXPoi
     */
    public List<CMXPoi> getPois() {
        if (mPois != null)
            return mPois;
        else
            return getArguments().getParcelableArrayList(POIS_KEY);
    }

    /**
     * Returns the poi from the pis list by the given id
     * 
     * @return a CMXPoi
     */
    public CMXPoi getPoi(String poiId) {
        for (CMXPoi poi : getPois()) {
            if (poi.getId().equals(poiId))
                return poi;
        }
        return null;
    }

    /**
     * Return the bitmap image of the poi
     * 
     * @param poiId
     *            the poi id.
     */
    public Bitmap getPoiBitmap(String poiId) {
        return mPoiImageById.get(poiId);
    }

    /**
     * Set the progress listener.
     * 
     * @param listener
     *            a progress listener.
     */
    public void setProgressListener(ProgressListener listener) {
        mProgressListener = listener;
    }

    /**
     * Returns the progress listener.
     * 
     * @return the progress listener.
     */
    public ProgressListener getProgressListener() {
        return mProgressListener;
    }

    /**
     * Set the path progress listener.
     * 
     * @param listener
     *            a path progress listener.
     */
    public void setPathProgressListener(PathProgressListener listener) {
        mPathProgressListener = listener;
    }

    /**
     * Returns the path progress listener.
     * 
     * @return the path progress listener.
     */
    public PathProgressListener getPathProgressListener() {
        return mPathProgressListener;
    }

    /**
     * Set the poi selected listener.
     * 
     * @param listener
     *            a poi selected listener.
     */
    public void setOnPoiSelectedListener(OnPoiSelectedListener listener) {
        mSelectedListener = listener;
    }

    /**
     * Set the activve poi selected listener.
     * 
     * @param listener
     *            an active poi selected listener.
     */
    public void setOnActivePoiSelectedListener(OnActivePoiSelectedListener listener) {
        mActiveSelectedListener = listener;
    }

    /**
     * Returns the poi selected listener.
     * 
     * @return the poi selected listener.
     */
    public OnPoiSelectedListener getOnPoiSelectedListener() {
        return mSelectedListener;
    }

    /**
     * Returns the active poi selected listener.
     * 
     * @return the active poi selected listener.
     */
    public OnActivePoiSelectedListener getOnActivePoiSelectedListener() {
        return mActiveSelectedListener;
    }

    /**
     * Returns the feedback view chosen listener.
     * 
     * @return the feedback view chosen listener.
     */
    public OnFeedbackViewListener getOnFeedbackViewListener() {
        return mOnFeedbackViewListener;
    }

    /**
     * Set the feedback view chosen listener.
     * 
     * @param listener
     *            feedback view chosen listener.
     */
    public void setOnFeedbackViewListener(OnFeedbackViewListener listener) {
        mOnFeedbackViewListener = listener;
    }

    /**
     * Returns the map view.
     * 
     * @return the map view.
     */
    public CMXFloorView getMapView() {
        return mMapView;
    }

    public int getBannerDuration() {
        return mBannerDuration;
    }

    public void setBannerDuration(int mBannerDuration) {
        this.mBannerDuration = mBannerDuration;
    }

    public void refresh() {
        mBitmap = null;
        mPois = null;

        // Initially hide the content view.
        if (mMapView != null) {
            mMapView.setVisibility(View.GONE);
        }

        if (mLoadingView != null) {
            mLoadingView.setVisibility(View.VISIBLE);
        }

        CMXClient.getInstance().loadFloorImage(getMap().getVenueId(), getMap().getId(), new CMXImageResponseHandler() {

            @Override
            public void onStart() {
                if (mProgressListener != null) {
                    mProgressListener.onStart();
                }
            }

            @Override
            public void onSuccess(Bitmap bitmap) {
                mBitmap = bitmap;

                // Load pois
                CMXClient.getInstance().loadPois(getMap().getVenueId(), getMap().getId(), new CMXPoisResponseHandler() {

                    @Override
                    public void onSuccess(List<CMXPoi> pois) {
                        mPois = new ArrayList<CMXPoi>(pois.size());
                        for (CMXPoi poi : pois) {
                            if (poi.hasImage()) {
                                mPois.add(poi);
                            }
                        }

                        mPoiById = new HashMap<String, CMXPoi>(mPois.size());
                        for (CMXPoi poi : mPois) {
                            mPoiById.put(poi.getId(), poi);
                        }

                        mMapView.setFloor(getMap(), getMapBitmap());
                        updatePois();

                        crossfade();

                        if (mProgressListener != null) {
                            mProgressListener.onSuccess(mBitmap, mPois);
                        }
                    }

                    @Override
                    public void onFailure(Throwable e) {
                        crossfade();

                        if (mProgressListener != null) {
                            mProgressListener.onFailure(e);
                        }
                    }
                });

            }

            @Override
            public void onFailure(Throwable e) {
                if (mProgressListener != null) {
                    mProgressListener.onFailure(e);
                }
            }
        });
    }

    /**
     * Sets the client location
     * 
     * @param location
     *            , the ClientLocation
     */
    private void setClientLocation(CMXClientLocation location) {
        // Check if the location is for the current map
        if (mMapView != null && getMap() != null && location.getFloorId().equals(getMap().getId())) {
            mMapView.setClientLocation(location);
        }
    }

    /**
     * Sets the path of the map view
     * 
     * @param path
     *            , the path to draw
     */
    private void setPath(CMXPath path) {
        if (mMapView != null) {
            mMapView.setPath(path);
        }
    }

    /**
     * Update all pois
     */
    private void updatePois() {
        mMapView.clearPois();

        List<CMXPoi> pois = mPois;
        for (CMXPoi poi : pois) {
            if (mPoiImageById != null && mPoiImageById.containsKey(poi.getId())) {
                mMapView.showPoi(poi, mPoiImageById.get(poi.getId()));
            }
            else {
                CMXClient.getInstance().loadPoiImage(getMap().getVenueId(), poi.getId(), new PoiImageResponseHandler(poi.getId()));
            }
        }

        if (pois != null) {
            final List<CMXPoi> sortedPois = new ArrayList<CMXPoi>(pois);
            Collections.sort(sortedPois, new PoiComparator());

            setActivePoi(null, false);
        }
    }

    private void updateBanners(List<CMXBanner> banners) {
        mBanners = banners;
        mActiveBannerIndex = 0;

        if (mBanners.isEmpty()) {
            mBannerView.setVisibility(View.GONE);
            mRootView.requestLayout();
            mRootView.invalidate();
            return;
        }

        if (mBannerRefreshTimer != null) {
            mBannerRefreshTimer.cancel();
        }

        if (banners.size() > 1) {
            mBannerRefreshTimer = new Timer();
            mBannerRefreshTimer.schedule(new TimerTask() {

                @Override
                public void run() {
                    getActivity().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            loadBannerImage(mBanners.get(mActiveBannerIndex));
                        }
                    });
                    mActiveBannerIndex = (mActiveBannerIndex + 1) % mBanners.size();
                }
            }, 100, mBannerDuration * 1000);
        }
        else {
            loadBannerImage(banners.get(0));
        }
    }

    private void loadBannerImage(final CMXBanner banner) {
        CMXClient.getInstance().loadBannerImage(banner.getVenueId(), getMap().getId(), banner.getZoneId(), banner.getImageId(), new CMXImageResponseHandler() {

            @Override
            public void onSuccess(Bitmap bitmap) {
                mBannerView.setVisibility(View.VISIBLE);
                // TODO: Look into later why the image height is so off
                //mBannerView.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, bitmap.getHeight()));
                mBannerView.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 100));
                mBannerView.setImageBitmap(bitmap);
                mRootView.requestLayout();
                mRootView.invalidate();
            }
        });
    }

    /**
     * Load the path to the target poiId.
     * 
     * @param poiId
     *            poi ID of the target.
     */
    public void loadPath(String poiId) {
        CMXClient.getInstance().loadPath(poiId, new CMXPathResponseHandler() {

            @Override
            public void onStart() {
                if (mPathProgressListener != null) {
                    mPathProgressListener.onStart();
                }
            }

            @Override
            public void onSuccess(CMXPath path) {
                setPath(path);
                if (mPathProgressListener != null) {
                    mPathProgressListener.onSuccess(path);
                }
            }

            @Override
            public void onFailure(Throwable e) {
                setPath(null);
                if (mPathProgressListener != null) {
                    mPathProgressListener.onFailure(e);
                }
            }
        });
    }

    /**
     * @see http
     *      ://en.wikipedia.org/wiki/Low-pass_filter#Algorithmic_implementation
     * @see http
     *      ://developer.android.com/reference/android/hardware/SensorEvent.html
     *      #values
     * @param alpha
     *            : time smoothing constant for low-pass filter 0 ² alpha ² 1 ;
     *            a smaller value basically means more smoothing
     * @see http
     *      ://en.wikipedia.org/wiki/Low-pass_filter#Discrete-time_realization
     */
    private float[] lowPass(float[] input, float[] output, final float alpha) {
        if (output == null)
            return input;

        for (int i = 0; i < input.length; i++) {
            output[i] = output[i] + alpha * (input[i] - output[i]);
        }
        return output;
    }

    private void crossfade() {

        AlphaAnimation alpha0 = new AlphaAnimation(0F, 0F);
        alpha0.setDuration(0); // Make animation instant
        alpha0.setFillAfter(true); // Tell it to persist after the animation
                                   // ends
        mMapView.startAnimation(alpha0);

        mMapView.setVisibility(View.VISIBLE);
        mLoadingView.setVisibility(View.GONE);

        AlphaAnimation alpha = new AlphaAnimation(0.0F, 1.F);
        alpha.setDuration(mShortAnimationDuration); // Make animation instant
        alpha.setFillAfter(true); // Tell it to persist after the animation ends
        mMapView.startAnimation(alpha);
    }

    /**
     * Broadcast receiver for user location events
     */
    private class UserLocationBroadcastReceiver extends BroadcastReceiver {

        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equals(CMXMainActivity.USER_LOCATION_UPDATE_ACTION)) {
                CMXClientLocation location = intent.getParcelableExtra(CMXMainActivity.EXTRA_USER_LOCATION);
                if (mMapView != null && getMap() != null && location.getFloorId().equals(getMap().getId())) {

                    setClientLocation(location);

                    // If a target is active, reload the path
                    if (mTargetPoiId != null) {
                        loadPath(mTargetPoiId);
                    }

                    // Check if zone id has changed
                    if (location != null && location.getZoneId() != null && !location.getZoneId().equals(mActiveZoneId)) {
                        // Load banners for the new zone
                        mActiveZoneId = location.getZoneId();
                        CMXClient.getInstance().loadBanners(location.getVenueId(), location.getFloorId(), location.getZoneId(), new CMXBannersResponseHandler() {

                            @Override
                            public void onSuccess(List<CMXBanner> banners) {
                                updateBanners(banners);
                            }
                        });
                    }
                }
            }
        }
    }

    /**
     * POI Image handler.
     */
    private class PoiImageResponseHandler extends CMXImageResponseHandler {

        private String mPoiId;

        public PoiImageResponseHandler(String poiId) {
            mPoiId = poiId;
        }

        @Override
        public void onSuccess(Bitmap bitmap) {
            mPoiImageById.put(mPoiId, bitmap);
            if (mMapView != null) {
                mMapView.showPoi(mPoiById.get(mPoiId), bitmap);
            }
        }

        @Override
        public void onFailure(Throwable error) {
            mPoiImageById.remove(mPoiId);
        }
    }

    /**
     * Alphabetical sort.
     */
    private class PoiComparator implements Comparator<CMXPoi> {
        @Override
        public int compare(CMXPoi o1, CMXPoi o2) {
            return o1.getName().compareTo(o2.getName());
        }
    }

    /**
     * Draw the feedback location user
     * 
     * @param draw
     *            if true, continue to draw the feedback user location, remove
     *            view otherwise
     */
    public void setDrawFeedbackView(boolean draw) {
        mMapView.setDrawFeeebackView(draw);
    }

}
