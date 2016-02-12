package com.cisco.cmx.ui;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.content.LocalBroadcastManager;
import android.support.v7.app.ActionBar;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.FrameLayout;
import android.widget.Toast;

import com.cisco.cmx.R;
import com.cisco.cmx.model.CMXClientLocation;
import com.cisco.cmx.model.CMXFloor;
import com.cisco.cmx.model.CMXPoi;
import com.cisco.cmx.model.CMXVenue;
import com.cisco.cmx.network.CMXClient;
import com.cisco.cmx.network.CMXNetworkHandlerIf;
import com.cisco.cmx.network.CMXNetworkManager;
import com.cisco.cmx.network.CMXClientLocationResponseHandler;
import com.cisco.cmx.network.CMXLocationFeedbackResponseHandler;
import com.cisco.cmx.ui.CMXMenuListFragment.OnCurrentLocationSelectedListener;
import com.cisco.cmx.ui.CMXMenuListFragment.OnSettingsSelectedListener;
import com.cisco.cmx.ui.CMXSearchFragment.OnPoiGoToSelectedListener;
import com.jeremyfeinstein.slidingmenu.lib.SlidingMenu;

/**
 * Activity that manages fragments to load & display maps from CMX server, with
 * left & right menus.
 */
public class CMXMainActivity extends CMXSlidingActionBarActivity implements CMXNetworkHandlerIf {

    private static final String TAG = "CMX Main Activity";

    public static String ACTION = "com.cisco.cmx.action.MAIN";

    private static final String MENULIST_FRAGMENT_TAG = "MENULIST";

    private static final String SEARCH_FRAGMENT_TAG = "SEARCH";

    private static final String FLOOR_FRAGMENT_TAG = "FLOOR";

    static public final String USER_LOCATION_UPDATE_ACTION = "com.cisco.cmx.USER_LOCATION_UPDATE_ACTION";

    static public final String EXTRA_USER_LOCATION = "com.cisco.cmx.network.extra_user_location";

    // The request codes
    static final int SEARCH_RESULT_REQUEST_CODE = 100;

    static final int POI_RESULT_REQUEST_CODE = SEARCH_RESULT_REQUEST_CODE + 1;

    static final int PLAY_SERVICES_RESOLUTION_REQUEST = 9000;

    private String mActiveVenueId;

    // private String mActiveFloorId;

    private CMXFloorFragment mFloorFragment;

    private List<CMXVenue> mOrderedVenues = new ArrayList<CMXVenue>();

    private HashMap<String, List<CMXFloor>> mOrderedFloors = new HashMap<String, List<CMXFloor>>();

    private HashMap<String, CMXVenue> mVenuesById = new HashMap<String, CMXVenue>(); // map
                                                                                     // of
                                                                                     // venues,
                                                                                     // key
                                                                                     // =
                                                                                     // venue
                                                                                     // identifier

    private HashMap<String, HashMap<String, CMXFloor>> mFloorsByIds = new HashMap<String, HashMap<String, CMXFloor>>(); // 1st
                                                                                                                        // key
                                                                                                                        // =
                                                                                                                        // venue
                                                                                                                        // id,
                                                                                                                        // 2nd
                                                                                                                        // key
                                                                                                                        // =
                                                                                                                        // floor
                                                                                                                        // id

    private HashMap<String, HashMap<String, CMXPoi>> mPoisByIds = new HashMap<String, HashMap<String, CMXPoi>>(); // 1stkfey
                                                                                                                  // =
                                                                                                                  // venue
                                                                                                                  // id,
                                                                                                                  // 2nd
                                                                                                                  // key
                                                                                                                  // =
                                                                                                                  // floor
                                                                                                                  // id

    private SlidingMenu slidingMenu;

    private CMXSearchFragment searchFragment;

    private CMXMenuListFragment listFragment;

    private CMXClientLocation currentClientLocation;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.cmx_main_layout);

        // Recover data from LaunchActivity
        List<CMXVenue> venues = CMXClientUi.getInstance().getmMainActivityVenues();
        List<CMXFloor> maps = CMXClientUi.getInstance().getmMainActivityMaps();
        List<CMXPoi> pois = CMXClientUi.getInstance().getmMainActivityPois();
        currentClientLocation = CMXClient.getInstance().getClientLocation();

        mOrderedVenues.addAll(venues);

        for (CMXVenue venue : venues) {
            mVenuesById.put(venue.getId(), venue);
            mFloorsByIds.put(venue.getId(), new HashMap<String, CMXFloor>());
            mPoisByIds.put(venue.getId(), new HashMap<String, CMXPoi>());
            mOrderedFloors.put(venue.getId(), new ArrayList<CMXFloor>());
        }

        for (CMXFloor floor : maps) {
            mFloorsByIds.get(floor.getVenueId()).put(floor.getId(), floor);
            mOrderedFloors.get(floor.getVenueId()).add(floor);
        }

        for (CMXPoi poi : pois) {
            mPoisByIds.get(poi.getVenueId()).put(poi.getId(), poi);
        }

        // By default, empty action bar
        ActionBar actionBar = getSupportActionBar();
        actionBar.setDisplayHomeAsUpEnabled(true);
        // actionBar.setHomeButtonEnabled(true);
        // actionBar.setDisplayShowHomeEnabled(true);
        // actionBar.setDisplayUseLogoEnabled(true);

        // Init sliding Menu
        slidingMenu = getSlidingMenu();
        slidingMenu.setMode(SlidingMenu.LEFT_RIGHT);
        slidingMenu.setTouchModeAbove(SlidingMenu.SLIDING_WINDOW);
        slidingMenu.setShadowWidthRes(R.dimen.slidingmenu_shadow_width);
        slidingMenu.setShadowDrawable(R.drawable.list_shadow);
        slidingMenu.setBehindOffsetRes(R.dimen.slidingmenu_offset);
        slidingMenu.setFadeDegree(0.35f);

        // Action bar slides too
        setSlidingActionBarEnabled(true);

        CMXNetworkManager.getInstance().initialize(this, this);
        //CMXNetworkManager.getInstance().start();

        // Set active venue and display map
        if (currentClientLocation != null) {
            CMXFloor floor = getFloor(currentClientLocation.getVenueId(), currentClientLocation.getFloorId());
            if (floor != null) {
                showFloor(floor);
            }
            else {
                if (maps != null && maps.size() > 0) {
                    showFloor(maps.get(0));
                }
            }

        }
        else {
            if (maps != null && maps.size() > 0) {
                showFloor(maps.get(0));
            }
        }

        // Fragment left menu
        FrameLayout frameLayoutLeft = new FrameLayout(this);
        frameLayoutLeft.setId(330064);
        setBehindContentView(frameLayoutLeft);
        FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
        listFragment = getListFragment();
        ft.replace(330064, listFragment);
        ft.commit();

        // Fragment right menu
        FrameLayout frameLayoutRight = new FrameLayout(this);
        frameLayoutRight.setId(3300512);
        getSlidingMenu().setSecondaryMenu(frameLayoutRight);
        getSlidingMenu().setSecondaryShadowDrawable(R.drawable.list_shadow);
        searchFragment = getSearchFragment();
        getSupportFragmentManager().beginTransaction().replace(3300512, searchFragment).commit();

    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onStart() {
        super.onStart();
    }

    @Override
    protected void onStop() {
        super.onStop();
    }

    @Override
    protected void onDestroy() {

        CMXNetworkManager.getInstance().onDestroy();
        super.onDestroy();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {

        getMenuInflater().inflate(R.menu.cmx_floor_actionbar, menu);

        updateActionBarItemVisibility();

        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int itemId = item.getItemId();
        if (itemId == android.R.id.home) {
            CMXMainActivity.this.toggle();
            return true;
        }
        else if (itemId == R.id.menu_refresh) {
            refresh();
            return true;
        }
        else if (itemId == R.id.menu_search) {
            if (CMXMainActivity.this.getSlidingMenu().isSecondaryMenuShowing())
                CMXMainActivity.this.toggle();
            else
                CMXMainActivity.this.getSlidingMenu().showSecondaryMenu(true);

            return true;
        }
        else {
            return super.onOptionsItemSelected(item);
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        switch (requestCode) {
            case POI_RESULT_REQUEST_CODE: {
                if (resultCode == CMXPoiActivity.RESULT_GO_TO) {
                    CMXPoi destination = data.getParcelableExtra(CMXPoiActivity.EXTRA_POI);
                    if (currentClientLocation != null) {
                        ((CMXFloorFragment) getActiveFloorFragment()).setTargetPoi(destination.getId());
                    }
                    else {
                        CMXNetworkManager.getInstance().showNoVenueWifiUseGoogleMapsDialog();
                    }
                }
                break;
            }
        }
    }

    public void updateActionBarItemVisibility() {

        getSlidingMenu().setEnabled(false);
    }

    private CMXVenue getActiveVenue() {
        return mActiveVenueId != null ? getVenue(mActiveVenueId) : null;
    }

    private void setActiveVenueId(String venueId) {
        mActiveVenueId = venueId;
        CMXVenue activeVenue = getVenue(mActiveVenueId);
        
        CMXNetworkManager.getInstance().setActiveVenue(activeVenue);

        if (searchFragment != null) {
            searchFragment.changeVenue(getVenue(mActiveVenueId));
        }
    }

    /*
     * private CMXFloor getActiveFloor() { if(mActiveFloorId != null &&
     * mActiveVenueId != null) { return getFloor(mActiveVenueId,
     * mActiveFloorId); } return null; }
     */

    private void setActiveFloor(CMXFloor floor) {
        // String activeFloorId = floor != null ? floor.getIdentifier() : null;
        String activeVenueId = floor != null ? floor.getVenueId() : null;

        // boolean floorHasChanged = activeFloorId != mActiveFloorId;
        boolean venueHasChanged = (activeVenueId == null && mActiveVenueId != null) || (activeVenueId != null && !activeVenueId.equals(mActiveVenueId));

        // mActiveFloorId = activeFloorId;

        if (venueHasChanged) {
            setActiveVenueId(activeVenueId);
        }
    }

    public List<CMXVenue> getVenues() {
        return new ArrayList<CMXVenue>(mOrderedVenues);
    }

    public CMXVenue getVenue(String venueId) {
        return mVenuesById.get(venueId);
    }

    public List<CMXFloor> getFloors() {
        List<CMXFloor> floors = new ArrayList<CMXFloor>();
        for (CMXVenue venue : getVenues()) {
            floors.addAll(getFloors(venue.getId()));
        }
        return floors;
    }

    public List<CMXFloor> getFloors(String venueId) {
        return new ArrayList<CMXFloor>(mOrderedFloors.get(venueId));
    }

    private HashMap<String, CMXFloor> getMappedFloors(String venueId) {
        return mFloorsByIds.get(venueId);
    }

    public CMXFloor getFloor(String venueId, String floorId) {
        HashMap<String, CMXFloor> floors = getMappedFloors(venueId);
        if (floors != null) {
            return floors.get(floorId);
        }
        return null;
    }

    public List<CMXPoi> getPois(String venueId, String poiId) {
        return new ArrayList<CMXPoi>(mPoisByIds.get(venueId).values());
    }

    private HashMap<String, CMXPoi> getMappedPois(String venueId) {
        return mPoisByIds.get(venueId);
    }

    public CMXPoi getPoi(String venueId, String poiId) {
        HashMap<String, CMXPoi> pois = getMappedPois(venueId);
        if (pois != null) {
            pois.get(poiId);
        }
        return null;
    }

    public void startLocationUpdate() {
        if (getActiveVenue() != null) {
            CMXClient.getInstance().startUserLocationPolling(getActiveVenue().getLocationUpdateInterval(), new CMXClientLocationResponseHandler() {

                @Override
                public void onUpdate(CMXClientLocation clientLocation) {
                    currentClientLocation = clientLocation;
                    Log.v("", "Location onUpdate");
                    // Send notification
                    Intent localIntent = new Intent(USER_LOCATION_UPDATE_ACTION);
                    localIntent.putExtra(EXTRA_USER_LOCATION, clientLocation);
                    LocalBroadcastManager.getInstance(CMXMainActivity.this).sendBroadcast(localIntent);
                }

            });
        }
    }

    protected void refresh() {
        CMXFloorFragment fragment = this.getActiveFloorFragment();
        fragment.refresh();
    }

    private void showFloorFragment(CMXFloorFragment fragment, String id, boolean addToBackStack) {

        final FragmentManager fm = getSupportFragmentManager();
        FragmentTransaction ft = fm.beginTransaction();

        ft.replace(R.id.cmx_main_root_layout, fragment, id);

        // add it to the backstack
        if (addToBackStack) {
            ft.setCustomAnimations(R.animator.slide_in_right, R.animator.slide_out_left, android.R.anim.slide_in_left, android.R.anim.slide_out_right);
            ft.addToBackStack(id);
        }

        ft.commit();

        mFloorFragment = fragment;
        getSupportActionBar().setTitle(fragment.getMap().getName());

        updateActionBarItemVisibility();

        Log.v(TAG, "Active fragment id : " + id);
    }

    private void showFloorFragment(CMXFloorFragment fragment, String id) {
        showFloorFragment(fragment, id, false);
    }

    private CMXFloorFragment getActiveFloorFragment() {
        return mFloorFragment;
    }

    private String getListFragmentTag() {
        return MENULIST_FRAGMENT_TAG;
    }

    private String getSearchFragmentTag() {
        return SEARCH_FRAGMENT_TAG;
    }

    private String getMapFragmentTag(String venueId, String mapId) {
        return FLOOR_FRAGMENT_TAG + venueId + "_" + mapId;
    }

    private CMXMenuListFragment getListFragment() {
        final FragmentManager fm = getSupportFragmentManager();
        CMXMenuListFragment listFragment = (CMXMenuListFragment) fm.findFragmentByTag(getListFragmentTag());
        if (listFragment == null) {

            listFragment = CMXMenuListFragment.newInstance(getVenues(), getFloors());

            listFragment.setOnMapSelectedListener(new CMXMenuListFragment.OnMapSelectedListener() {
                @Override
                public void onMapSelected(CMXFloor map, CMXVenue venue) {

                    CMXMainActivity.this.toggle();

                    showFloor(map);
                }
            });
            listFragment.setOnCurrentLocationSelectedListener(new OnCurrentLocationSelectedListener() {
                @Override
                public void onCurrentLocationSelected(CMXClientLocation location) {

                    if (getActiveFloorFragment() instanceof CMXFloorFragment) {
                        CMXMainActivity.this.getSlidingMenu().toggle(true);

                        if (location != null && CMXNetworkManager.getInstance().isCMXGeolocalisationAvailable()) {
                            // if not on current map
                            if (!location.getFloorId().equals(((CMXFloorFragment) getActiveFloorFragment()).getMap().getId())) {
                                for (CMXFloor map : getFloors()) {
                                    if (location.getFloorId().equals(map.getId())) {

                                        showFloor(map);

                                        if (getMapFragment(map).getMapView() != null) {

                                            getMapFragment(map).getMapView().centerOnPoint(location.getMapCoordinate().getX(), location.getMapCoordinate().getY());
                                        }

                                    }
                                }
                            }
                            else {

                                ((CMXFloorFragment) getActiveFloorFragment()).getMapView().centerOnPoint(location.getMapCoordinate().getX(), location.getMapCoordinate().getY());
                            }
                        }
                        else {
                            CMXNetworkManager.getInstance().showNoVenueWifiUseGoogleMapsDialog();
                        }
                    }
                }
            });
            listFragment.setOnSettingsSelectedListener(new OnSettingsSelectedListener() {

                @Override
                public void onSettingsSelected() {
                    showSettings();
                }
            });
        }
        return listFragment;
    }

    private CMXSearchFragment getSearchFragment() {
        final FragmentManager fm = getSupportFragmentManager();
        CMXSearchFragment searchFragment = (CMXSearchFragment) fm.findFragmentByTag(getSearchFragmentTag());
        if (searchFragment == null) {

            searchFragment = CMXSearchFragment.newInstance(getActiveVenue());

            searchFragment.setOnPoiSelectedListener(new CMXSearchFragment.OnPoiSelectedListener() {
                @Override
                public void onPoiSelected(CMXPoi poi) {
                    if (getActiveFloorFragment() instanceof CMXFloorFragment) {
                        CMXMainActivity.this.getSlidingMenu().toggle(true);

                        // if not on current map
                        if (!poi.getFloorId().equals(((CMXFloorFragment) getActiveFloorFragment()).getMap().getId())) {
                            for (CMXFloor map : getFloors()) {
                                if (poi.getFloorId().equals(map.getId())) {
                                    showFloor(map);
                                    getMapFragment(map).setActivePoi(poi.getId(), true);
                                }
                            }
                        }
                        else {
                            ((CMXFloorFragment) getActiveFloorFragment()).setActivePoi(poi.getId(), true);
                        }
                    }
                }
            });

            searchFragment.setOnPoiGoToSelectedListener(new OnPoiGoToSelectedListener() {

                @Override
                public void onPoiGoToSelected(CMXPoi poi) {
                    if (getActiveFloorFragment() instanceof CMXFloorFragment) {
                        CMXMainActivity.this.getSlidingMenu().toggle(true);

                        if (((CMXFloorFragment) getActiveFloorFragment()).getMap().getId().equals(poi.getFloorId()))
                            ((CMXFloorFragment) getActiveFloorFragment()).setActivePoi(poi.getId(), true);

                        ((CMXFloorFragment) getActiveFloorFragment()).setTargetPoi(poi.getId());

                    }
                }
            });
        }
        return searchFragment;
    }

    private CMXFloorFragment getMapFragment(final CMXFloor map) {
        final FragmentManager fm = getSupportFragmentManager();
        CMXFloorFragment fragment = (CMXFloorFragment) fm.findFragmentByTag(getMapFragmentTag(map.getVenueId(), map.getId()));
        if (fragment == null) {

            List<CMXPoi> poisMap = getPois(map.getVenueId(), map.getId());
            fragment = CMXFloorFragment.newInstance(map, poisMap);

            fragment.setProgressListener(new CMXFloorFragment.ProgressListener() {

                @Override
                public void onStart() {

                }

                @Override
                public void onSuccess(Bitmap mapBitmap, List<CMXPoi> pois) {

                }

                @Override
                public void onFailure(Throwable error) {

                    if (CMXNetworkManager.getInstance().isConnectingToWifi()) {
                        getMapFragment(map);
                    } else {
                        AlertDialog.Builder builder = new AlertDialog.Builder(CMXMainActivity.this);
                        builder.setTitle(R.string.cmx_error_dialog_title);
                        builder.setMessage(error.getLocalizedMessage());
                        builder.setPositiveButton(R.string.cmx_ok_dialog_bt, new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                dialog.cancel();
                            }
                        });
                        builder.create().show();
                    }
                }

            });

            fragment.setOnPoiSelectedListener(new CMXFloorFragment.OnPoiSelectedListener() {

                @Override
                public void onPoiSelected(CMXPoi poi) {
                    Fragment activeFragment = getActiveFloorFragment();
                    if (activeFragment instanceof CMXFloorFragment) {
                        ((CMXFloorFragment) activeFragment).setActivePoi(poi.getId(), true);
                    }
                }
            });
            fragment.setOnActivePoiSelectedListener(new CMXFloorFragment.OnActivePoiSelectedListener() {

                @Override
                public void onActivePoiSelected(CMXPoi poi) {
                    showPoi(poi);
                }
            });

            fragment.setOnFeedbackViewListener(new CMXFloorFragment.OnFeedbackViewListener() {

                @Override
                public void onFeedbackViewListener(final float x, final float y) {
                    AlertDialog.Builder builder = new AlertDialog.Builder(CMXMainActivity.this);
                    builder.setTitle(R.string.cmx_information_dialog_title);
                    builder.setMessage(R.string.cmx_confirm_feedback_view);
                    builder.setPositiveButton(R.string.cmx_ok_dialog_bt, new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int id) {
                            dialog.dismiss();

                            final ProgressDialog progressDialog = new ProgressDialog(CMXMainActivity.this);
                            progressDialog.setMessage(getResources().getString(R.string.cmx_posting_new_user_location));
                            progressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
                            progressDialog.setCancelable(false);

                            CMXClient.getInstance().postClientLocationFeedback((int) x, (int) y, new CMXLocationFeedbackResponseHandler() {
                                @Override
                                public void onStart() {
                                    progressDialog.show();
                                }

                                @Override
                                public void onSuccess() {
                                    progressDialog.dismiss();
                                    Toast.makeText(CMXMainActivity.this, getResources().getString(R.string.cmx_posting_new_user_location_success), Toast.LENGTH_SHORT).show();
                                    mFloorFragment.setDrawFeedbackView(false);
                                }

                                @Override
                                public void onFailure(Throwable error) {
                                    progressDialog.dismiss();
                                    AlertDialog.Builder builder = new AlertDialog.Builder(CMXMainActivity.this);
                                    builder.setTitle(R.string.cmx_information_dialog_title);
                                    builder.setMessage(R.string.cmx_posting_new_user_location_failed);
                                    builder.setPositiveButton(R.string.cmx_ok_dialog_bt, new DialogInterface.OnClickListener() {
                                        public void onClick(DialogInterface dialog, int id) {
                                            dialog.dismiss();
                                        }
                                    });
                                    builder.create().show();
                                }

                            });
                        }
                    });
                    builder.setNegativeButton(R.string.cmx_cancel_dialog_bt, new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int id) {
                            dialog.dismiss();
                        }
                    });
                    builder.create().show();

                }

            });

        }
        return fragment;
    }

    private void showFloor(CMXFloor map) {

        setActiveFloor(map);

        CMXFloorFragment fragment = getMapFragment(map);
        showFloorFragment(fragment, getMapFragmentTag(map.getVenueId(), map.getId()));

        if (!fragment.hasResult()) {
            fragment.refresh();
        }
        else {
            if (fragment.getProgressListener() != null) {
                fragment.getProgressListener().onSuccess(fragment.getMapBitmap(), fragment.getPois());
            }
        }
    }

    private void showPoi(CMXPoi poi) {

        Bitmap poiBitmap = ((CMXFloorFragment) getActiveFloorFragment()).getPoiBitmap(poi.getId());

        Intent i = new Intent();
        i.setAction(CMXPoiActivity.ACTION);
        i.putExtra(CMXPoiActivity.EXTRA_POI, poi);
        i.putExtra(CMXPoiActivity.EXTRA_IMAGE, poiBitmap);
        i.putExtra(CMXPoiActivity.EXTRA_IMAGE_URL, CMXClient.getInstance().getPoiImageURL(mActiveVenueId, poi.getId()));
        this.startActivityForResult(i, POI_RESULT_REQUEST_CODE);
    }

    private void showSettings() {
        Intent i = new Intent();
        i.setAction(CMXSettingsActivity.ACTION);
        this.startActivity(i);
    }
}
