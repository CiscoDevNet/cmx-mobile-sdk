package com.cisco.cmx.ui;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.content.LocalBroadcastManager;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseExpandableListAdapter;
import android.widget.ExpandableListView;
import android.widget.ExpandableListView.OnChildClickListener;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.cisco.cmx.R;
import com.cisco.cmx.model.CMXClientLocation;
import com.cisco.cmx.model.CMXFloor;
import com.cisco.cmx.model.CMXVenue;
import com.cisco.cmx.network.CMXClient;
import com.cisco.cmx.network.CMXImageResponseHandler;

/**
 * A fragment that displays a menu list, and exposes event handlers when the
 * user selects an item.
 */
public class CMXMenuListFragment extends Fragment implements OnChildClickListener {

    private static String VENUES_KEY = "venue";

    private static String MAPS_KEY = "maps";

    private OnMapSelectedListener mMapSelectedListener;

    private OnSettingsSelectedListener mSettingsSelectedListener;

    private OnCurrentLocationSelectedListener mCurrentLocationSelectedListener;

    private List<CMXFloor> mMaps;

    private List<CMXVenue> mVenues;

    private Context mContext;

    private ExpandableListView mListView;

    private TextView mCurrentLocationDisplay;

    private UserLocationBroadcastReceiver mLocationReceiver;

    private CMXClientLocation mCurrentLocation;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mLocationReceiver = new UserLocationBroadcastReceiver(this);
        LocalBroadcastManager.getInstance(getActivity()).registerReceiver(mLocationReceiver, new IntentFilter(CMXMainActivity.USER_LOCATION_UPDATE_ACTION));

    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);
        inflater.inflate(R.menu.cmx_empty_actionbar, menu);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);

        setHasOptionsMenu(true);

        mContext = inflater.getContext();
        View layout = inflater.inflate(R.layout.cmx_list_layout, container, false);
        mListView = (ExpandableListView) layout.findViewById(R.id.cmx_list_expandable_view);

        View footer = (View) inflater.inflate(R.layout.cmx_list_footer_layout, null);
        View header = (View) inflater.inflate(R.layout.cmx_list_header_layout, null);

        mCurrentLocationDisplay = (TextView) header.findViewById(R.id.cmx_list_header_current_location_title);

        mListView.setGroupIndicator(null);
        mListView.addHeaderView(header);
        mListView.addFooterView(footer);

        LinearLayout listSettings = (LinearLayout) footer.findViewById(R.id.cmx_list_footer_section_layout);
        listSettings.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mSettingsSelectedListener.onSettingsSelected();
            }
        });

        LinearLayout listCurrentLocation = (LinearLayout) header.findViewById(R.id.cmx_list_header_current_location_layout);
        listCurrentLocation.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mCurrentLocationSelectedListener.onCurrentLocationSelected(mCurrentLocation);
            }
        });

        fillList();

        return layout;
    }

    /**
     * Fills the list, creating the parent group and the child items
     */
    private void fillList() {
        this.setCurrentLocation(CMXClient.getInstance().getClientLocation());

        ArrayList<Group> arrayParents = new ArrayList<Group>();
        ArrayList<CMXFloor> arrayChildren;

        int index = 0;

        for (CMXVenue venue : getVenues()) {

            final Group gr = new Group();
            gr.setTitle(venue.getName());
            arrayParents.add(gr);

            CMXClient.getInstance().loadVenueImage(venue.getId(), new CMXImageResponseHandler() {

                @Override
                public void onSuccess(Bitmap bitmap) {
                    gr.setBitmap(bitmap);
                    ExpandableListAdapter adapter = (ExpandableListAdapter) mListView.getExpandableListAdapter();
                    adapter.notifyDataSetChanged();
                }

                @Override
                public void onFailure(Throwable error) {
                    // Do nothing
                }

            });

            arrayChildren = new ArrayList<CMXFloor>();

            for (CMXFloor map : getMaps()) {
                if (venue.getId().equals(map.getVenueId())) {
                    arrayChildren.add(map);
                }
            }

            arrayParents.get(index).setArrayChildren(arrayChildren);
            index++;

        }

        mListView.setAdapter(new ExpandableListAdapter(mContext, arrayParents));

    }

    @Override
    public void onDestroy() {
        if (mLocationReceiver != null) {
            LocalBroadcastManager.getInstance(getActivity()).unregisterReceiver(mLocationReceiver);
        }

        super.onDestroy();
    }

    /**
     * Sets the current location of the user and update the texte view
     * 
     * @param location
     *            , the current location of the user
     */
    public void setCurrentLocation(CMXClientLocation location) {
        mCurrentLocation = location;

        if (mCurrentLocation == null) {
            mCurrentLocationDisplay.setText(getResources().getString(R.string.cmx_list_no_current_location_title));
        }
        else {
            String currentLocationTitle = "unknown";
            for (CMXFloor map : getMaps()) {
                if (map.getId().equals(location.getFloorId()))
                    currentLocationTitle = map.getName();
            }

            if (!mCurrentLocationDisplay.getText().equals(getResources().getString(R.string.cmx_list_current_location_title) + currentLocationTitle))
                mCurrentLocationDisplay.setText(getResources().getString(R.string.cmx_list_current_location_title) + currentLocationTitle);
        }

    }

    /**
     * Broadcast receiver for user location events
     */
    private class UserLocationBroadcastReceiver extends BroadcastReceiver {

        WeakReference<CMXMenuListFragment> mFragment;

        public UserLocationBroadcastReceiver(CMXMenuListFragment fragment) {
            mFragment = new WeakReference<CMXMenuListFragment>(fragment);
        }

        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equals(CMXMainActivity.USER_LOCATION_UPDATE_ACTION)) {
                CMXClientLocation location = intent.getParcelableExtra(CMXMainActivity.EXTRA_USER_LOCATION);
                if (mFragment.get() != null) {
                    mFragment.get().setCurrentLocation(location);
                }
            }
        }
    }

    /**
     * Classes wishing to be notified of map selection implement this.
     */
    public interface OnMapSelectedListener {

        /**
         * Callback method to be invoked when a map has been selected
         * 
         * @param map
         *            selected map
         * @param venue
         *            selected venue (depending on the map selected)
         */
        public void onMapSelected(CMXFloor map, CMXVenue venue);
    }

    /**
     * Classes wishing to be notified of settings selection implement this.
     */
    public interface OnSettingsSelectedListener {

        /**
         * Callback method to be invoked when settings has been selected
         */
        public void onSettingsSelected();
    }

    /**
     * Classes wishing to be notified of current location selection implement
     * this.
     */
    public interface OnCurrentLocationSelectedListener {

        /**
         * Callback method to be invoked when current location has been selected
         */
        public void onCurrentLocationSelected(CMXClientLocation location);
    }

    /**
     * Create a new instance of CMXListFragment, initialized with a venues list
     * and a maps list
     * 
     * @param venues
     *            a venues list
     * @param maps
     *            a maps list
     * @return a new instance of CMXListFragment
     */
    public static CMXMenuListFragment newInstance(List<CMXVenue> venues, List<CMXFloor> maps) {
        CMXMenuListFragment f = new CMXMenuListFragment();

        // Supply index input as an argument.
        Bundle args = new Bundle();
        args.putParcelableArrayList(VENUES_KEY, new ArrayList<CMXVenue>(venues));
        args.putParcelableArrayList(MAPS_KEY, new ArrayList<CMXFloor>(maps));
        f.setArguments(args);

        return f;
    }

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);

        // Keep this Fragment around even during config changes
        setRetainInstance(true);
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        mListView.setOnChildClickListener(this);
    }

    @Override
    public boolean onChildClick(ExpandableListView parent, View view, int groupPosition, int childPosition, long id) {

        if (mMapSelectedListener != null) {

            CMXFloor mapSelected = (CMXFloor) ((ExpandableListAdapter) mListView.getExpandableListAdapter()).getChild(groupPosition, childPosition);
            CMXVenue venueSelected = getVenues().get(groupPosition);
            mMapSelectedListener.onMapSelected(mapSelected, venueSelected);
        }
        return false;
    }

    /**
     * Set the map selected listener.
     * 
     * @param listener
     *            a map selected listener.
     */
    public void setOnMapSelectedListener(OnMapSelectedListener listener) {
        mMapSelectedListener = listener;
    }

    /**
     * Returns the map selected listener.
     * 
     * @return the map selected listener.
     */
    public OnMapSelectedListener getOnMapSelectedListener() {
        return mMapSelectedListener;
    }

    /**
     * Set the settings selected listener.
     * 
     * @param listener
     *            a settings selected listener.
     */
    public void setOnSettingsSelectedListener(OnSettingsSelectedListener listener) {
        mSettingsSelectedListener = listener;
    }

    /**
     * Returns the settings selected listener.
     * 
     * @return the settings selected listener.
     */
    public OnSettingsSelectedListener getOnSettingsSelectedListener() {
        return mSettingsSelectedListener;
    }

    /**
     * Set the current location selected listener.
     * 
     * @param listener
     *            a current lcoation selected listener.
     */
    public void setOnCurrentLocationSelectedListener(OnCurrentLocationSelectedListener listener) {
        mCurrentLocationSelectedListener = listener;
    }

    /**
     * Returns the current location selected listener.
     * 
     * @return the current location selected listener.
     */
    public OnCurrentLocationSelectedListener getOnCurrentLocationSelectedListener() {
        return mCurrentLocationSelectedListener;
    }

    /**
     * Returns all the maps
     * 
     * @return mMap a maps list
     */
    public List<CMXFloor> getMaps() {
        if (mMaps != null)
            return mMaps;
        else
            return getArguments().getParcelableArrayList(MAPS_KEY);
    }

    /**
     * Returns all the venues
     * 
     * @return mVenues a venues list
     */
    public List<CMXVenue> getVenues() {
        if (mVenues != null)
            return mVenues;
        else
            return getArguments().getParcelableArrayList(VENUES_KEY);
    }

    /**
     * Expandable Adapter of the list
     */
    private class ExpandableListAdapter extends BaseExpandableListAdapter {

        private LayoutInflater inflater;

        private ArrayList<Group> mParent;

        private Context mContext;

        public ExpandableListAdapter(Context context, ArrayList<Group> parent) {
            mContext = context;
            inflater = LayoutInflater.from(mContext);
            mParent = parent;
        }

        @Override
        public CMXFloor getChild(int groupPosition, int childPosition) {
            return mParent.get(groupPosition).getArrayChildren().get(childPosition);
        }

        @Override
        public long getChildId(int groupPosition, int childPosition) {
            return childPosition;
        }

        @Override
        public View getChildView(final int groupPosition, final int childPosition, boolean isLastChild, View view, ViewGroup parent) {

            if (view == null) {
                view = inflater.inflate(R.layout.cmx_list_child_layout, parent, false);
            }

            TextView title = (TextView) view.findViewById(R.id.cmx_list_child_title);

            final CMXFloor map = mParent.get(groupPosition).getArrayChildren().get(childPosition);

            title.setText(map.getName());

            return view;
        }

        @Override
        public int getChildrenCount(int groupPosition) {
            return mParent.get(groupPosition).getArrayChildren().size();
        }

        @Override
        public Object getGroup(int groupPosition) {
            return mParent.get(groupPosition);
        }

        @Override
        public int getGroupCount() {
            return mParent.size();
        }

        @Override
        public long getGroupId(int groupPosition) {
            return groupPosition;
        }

        @Override
        public View getGroupView(int groupPosition, boolean isExpanded, View view, ViewGroup parent) {

            view = inflater.inflate(R.layout.cmx_list_group_layout, parent, false);

            ImageView venueImageView = (ImageView) view.findViewById(R.id.cmx_list_group_image);
            TextView textView = (TextView) view.findViewById(R.id.cmx_list_group_title);
            ImageView imageView = (ImageView) view.findViewById(R.id.cmx_list_group_accessory);

            Group group = (Group) getGroup(groupPosition);
            if (group.getBitmap() != null) {
                venueImageView.setImageBitmap(group.getBitmap());
            }

            textView.setText(group.getTitle());

            if (isExpanded) {
                textView.setTextColor(Color.parseColor("#0099cc"));
                textView.setTypeface(null, Typeface.BOLD);
                imageView.setImageResource(R.drawable.arrow_top);
            }
            else {
                textView.setTextColor(Color.parseColor("#000000"));
                textView.setTypeface(null, Typeface.NORMAL);
                imageView.setImageResource(R.drawable.arrow_down);
            }

            return view;

        }

        @Override
        public boolean hasStableIds() {
            return true;
        }

        @Override
        public boolean isChildSelectable(int groupPosition, int childPosition) {
            return true;
        }

    }

    /**
     * Parent list class
     */
    private class Group {
        private String mTitle;

        private Bitmap mBitmap;

        private ArrayList<CMXFloor> mFloors;

        public String getTitle() {
            return mTitle;
        }

        public void setTitle(String mTitle) {
            this.mTitle = mTitle;
        }

        public Bitmap getBitmap() {
            return mBitmap;
        }

        public void setBitmap(Bitmap bitmap) {
            this.mBitmap = bitmap;
        }

        public ArrayList<CMXFloor> getArrayChildren() {
            return this.mFloors;
        }

        public void setArrayChildren(ArrayList<CMXFloor> mPois) {
            this.mFloors = mPois;
        }
    }

}
