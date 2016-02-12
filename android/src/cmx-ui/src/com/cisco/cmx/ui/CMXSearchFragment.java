package com.cisco.cmx.ui;

import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.content.Context;
import android.graphics.PorterDuff.Mode;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.widget.SearchView;
import android.support.v7.widget.SearchView.OnCloseListener;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.cisco.cmx.R;
import com.cisco.cmx.model.CMXPoi;
import com.cisco.cmx.model.CMXVenue;
import com.cisco.cmx.network.CMXClient;
import com.cisco.cmx.network.CMXPoisResponseHandler;

/**
 * A fragment that displays a search widget and a list for the results, and
 * exposes event handlers when the user selects a result.
 */
public class CMXSearchFragment extends Fragment implements OnItemClickListener {

    static String EXTRA_VENUE = "VENUE";

    private OnPoiSelectedListener mPoiSelectedListener;

    private OnPoiGoToSelectedListener mPoiGoToSelectedListener;

    private List<CMXPoi> mSearchPois = new ArrayList<CMXPoi>();

    private Context mContext;

    private ListView mListView;

    private SearchView mSearchView;

    private TextView mEmptyTextView;

    private SearchPoiAdapter adpt;

    private ProgressBar searchProgresbar;

    private String mVenueId;

    private String mVenueName;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);

        mContext = inflater.getContext();
        View layout = inflater.inflate(R.layout.cmx_search_layout, container, false);
        mListView = (ListView) layout.findViewById(R.id.cmx_search_list_view);
        searchProgresbar = (ProgressBar) layout.findViewById(R.id.cmx_search_progressbar);
        mSearchView = (SearchView) layout.findViewById(R.id.cmx_search_view);
        mSearchView.setIconifiedByDefault(false);

        mEmptyTextView = new TextView(inflater.getContext());
        mEmptyTextView.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
        mEmptyTextView.setVisibility(View.GONE);
        mEmptyTextView.setGravity(Gravity.CENTER);
        ((ViewGroup) mListView.getParent()).addView(mEmptyTextView);
        mListView.setEmptyView(mEmptyTextView);

        setupSearchView();

        fillList();

        searchProgresbar.setVisibility(View.INVISIBLE);

        clearUI();

        return layout;
    }

    /**
     * Setup the searchview
     */
    private void setupSearchView() {

        mSearchView.setOnCloseListener(new OnCloseListener() {

            @Override
            public boolean onClose() {
                clearUI();
                return false;
            }
        });

        mSearchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String query) {
                search(query);
                mSearchView.clearFocus();
                return true;
            }

            @Override
            public boolean onQueryTextChange(String newText) {
                if (newText.length() == 0) {
                    mSearchPois.clear();
                    updateList();
                }
                return false;
            }
        });
    }

    /**
     * Fills the list
     */
    public void fillList() {

        adpt = new SearchPoiAdapter(mContext);
        mListView.setAdapter(adpt);

    }

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
        public void onPoiSelected(CMXPoi poi);
    }

    /**
     * Classes wishing to be notified of poi selection implement this.
     */
    public interface OnPoiGoToSelectedListener {

        /**
         * Callback method to be invoked when go to has been selected
         * 
         * @param poi
         *            selected poi
         */
        public void onPoiGoToSelected(CMXPoi poi);
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
         * @param pois
         *            result of the loading
         */
        public void onSuccess(List<CMXPoi> pois);

        /**
         * Notifies that the task has failed.
         * 
         * @param error
         *            an error
         */
        public void onFailure(Throwable error);
    }

    /**
     * Create a new instance of CMXSearchFragment, initialized with a venue
     * 
     * @param venue
     *            a venue
     * @return a new instance of CMXSearchFragment
     */
    public static CMXSearchFragment newInstance(CMXVenue venue) {
        CMXSearchFragment f = new CMXSearchFragment();

        // Supply index input as an argument.
        Bundle args = new Bundle();
        if (venue != null) {
            args.putParcelable(EXTRA_VENUE, venue);
        }
        f.setArguments(args);

        return f;
    }

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);

        CMXVenue venue = getArguments().getParcelable(EXTRA_VENUE);
        mVenueId = venue.getId();
        mVenueName = venue.getName();

        // Keep this Fragment around even during config changes
        setRetainInstance(true);
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        mListView.setOnItemClickListener(this);
    }

    /**
     * Set the poi selected listener.
     * 
     * @param listener
     *            a poi selected listener.
     */
    public void setOnPoiSelectedListener(OnPoiSelectedListener listener) {
        mPoiSelectedListener = listener;
    }

    /**
     * Returns the poi selected listener.
     * 
     * @return the poi selected listener.
     */
    public OnPoiSelectedListener getOnPoiSelectedListener() {
        return mPoiSelectedListener;
    }

    /**
     * Set the poi goTo selected listener.
     * 
     * @param listener
     *            a poi goTo selected listener.
     */
    public void setOnPoiGoToSelectedListener(OnPoiGoToSelectedListener listener) {
        mPoiGoToSelectedListener = listener;
    }

    /**
     * Returns the poi goTo selected listener.
     * 
     * @return the poi goTo selected listener.
     */
    public OnPoiGoToSelectedListener getOnPoiGoToSelectedListener() {
        return mPoiGoToSelectedListener;
    }

    /**
     * Updates the list (refresh)
     */
    public void updateList() {
        adpt.notifyDataSetChanged();
        mListView.setAdapter(adpt);
    }

    public void changeVenue(CMXVenue venue) {
        mVenueId = venue.getId();
        mVenueName = venue.getName();

        clearUI();
    }

    private void clearUI() {
        mSearchView.setQueryHint(getResources().getString(R.string.cmx_search_query_hint, mVenueName));
        mSearchView.setQuery("", false);
        mSearchPois.clear();
        mEmptyTextView.setVisibility(View.GONE);
        mEmptyTextView.setText("");
        updateList();
    }

    @Override
    public void onItemClick(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
        if (mPoiSelectedListener != null) {
            mPoiSelectedListener.onPoiSelected(mSearchPois.get(arg2));
        }
    }

    private void search(String query) {

        CMXClient.getInstance().loadQuery(mVenueId, query, new CMXPoisResponseHandler() {

            @Override
            public void onStart() {
                mSearchPois.clear();
                searchProgresbar.setVisibility(View.VISIBLE);
                mEmptyTextView.setVisibility(View.GONE);
            }

            @Override
            public void onSuccess(List<CMXPoi> pois) {

                searchProgresbar.setVisibility(View.INVISIBLE);

                for (CMXPoi poi : pois) {
                    mSearchPois.add(poi);
                }

                if (mSearchPois.isEmpty()) {
                    mEmptyTextView.setText("No result");
                }

                updateList();
            }

            @Override
            public void onFailure(Throwable e) {
                searchProgresbar.setVisibility(View.INVISIBLE);
                mEmptyTextView.setText(e.getLocalizedMessage());
                updateList();
            }
        });
    }

    /**
     * Adapter of the list
     */
    public class SearchPoiAdapter extends BaseAdapter {

        private Context mContext;

        private LayoutInflater mInflater;

        public SearchPoiAdapter(Context context) {
            mContext = context;
            mInflater = LayoutInflater.from(mContext);
        }

        @Override
        public int getCount() {
            return mSearchPois.size();
        }

        @Override
        public Object getItem(int position) {
            return mSearchPois.get(position);
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {

            RelativeLayout layoutItem;
            TextView title;
            final ImageView goTo;

            final CMXPoi poi = mSearchPois.get(position);

            if (convertView == null) {
                layoutItem = (RelativeLayout) mInflater.inflate(R.layout.cmx_search_item_layout, parent, false);

                title = (TextView) layoutItem.findViewById(R.id.cmx_search_item_title);
                goTo = (ImageView) layoutItem.findViewById(R.id.cmx_search_item_goto_button);

                layoutItem.setTag(R.id.cmx_search_item_title, title);
                layoutItem.setTag(R.id.cmx_search_item_goto_button, goTo);

            }
            else {
                layoutItem = (RelativeLayout) convertView;

                title = (TextView) layoutItem.getTag(R.id.cmx_search_item_title);
                goTo = (ImageView) layoutItem.getTag(R.id.cmx_search_item_goto_button);
            }

            title.setText(poi.getName());

            goTo.setOnClickListener(new OnClickListener() {

                @Override
                public void onClick(View v) {
                    if (mPoiGoToSelectedListener != null) {
                        mPoiGoToSelectedListener.onPoiGoToSelected(poi);
                    }
                }
            });
            goTo.setOnTouchListener(new OnTouchListener() {
                @Override
                public boolean onTouch(View v, MotionEvent event) {
                    if (event.getAction() == MotionEvent.ACTION_DOWN)
                        goTo.setColorFilter(0xFF999999, Mode.MULTIPLY);
                    else if (event.getAction() == MotionEvent.ACTION_UP)
                        goTo.setColorFilter(null);
                    return false;
                }
            });

            return layoutItem;

        }

    }

}
