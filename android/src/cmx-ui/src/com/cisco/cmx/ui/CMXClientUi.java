package com.cisco.cmx.ui;

import java.util.ArrayList;
import java.util.List;

import android.content.Intent;
import android.os.AsyncTask;
import android.util.Log;

import com.cisco.cmx.model.CMXClientLocation;
import com.cisco.cmx.model.CMXFloor;
import com.cisco.cmx.model.CMXPoi;
import com.cisco.cmx.model.CMXVenue;
import com.cisco.cmx.network.CMXClient;
import com.cisco.cmx.network.CMXClientLocationResponseHandler;
import com.cisco.cmx.network.CMXFloorsResponseHandler;
import com.cisco.cmx.network.CMXPoisResponseHandler;
import com.cisco.cmx.network.CMXVenuesResponseHandler;

public class CMXClientUi {
    
    private static final String TAG = "CMXClientUi";
    
    private static CMXClientUi singletonInstance;
    
    private static CMXClient cmxClientInstance;
    
    private List<CMXVenue> mMainActivityVenues = new ArrayList<CMXVenue>();

    private List<CMXFloor> mMainActivityMaps = new ArrayList<CMXFloor>();

    private List<CMXPoi> mMainActivityPois = new ArrayList<CMXPoi>();

    private boolean mStartMainActivity = false;


    // To prevent any other class from instantiating
    private CMXClientUi() {
        cmxClientInstance = CMXClient.getInstance();
    }

    /**
     * Returns the unique instance of the CMXClient class
     * 
     * @return unique instance of the CMXClient class
     */
    public static CMXClientUi getInstance() {
        if (null == singletonInstance) {
            synchronized (CMXClientUi.class) {
                if (null == singletonInstance) {
                    singletonInstance = new CMXClientUi();
                }
            }
        }
        return singletonInstance;
    }

    public List<CMXVenue> getmMainActivityVenues() {
        return mMainActivityVenues;
    }

    public void setmMainActivityVenues(List<CMXVenue> mMainActivityVenues) {
        this.mMainActivityVenues = mMainActivityVenues;
    }

    public void showMapView() {
        loadMainActivityVenues();
        new WaitforTaskFinish().execute(null, null, null);
    }

    public List<CMXFloor> getmMainActivityMaps() {
        return mMainActivityMaps;
    }

    public void setmMainActivityMaps(List<CMXFloor> mMainActivityMaps) {
        this.mMainActivityMaps = mMainActivityMaps;
    }

    public List<CMXPoi> getmMainActivityPois() {
        return mMainActivityPois;
    }

    public void setmMainActivityPois(List<CMXPoi> mMainActivityPois) {
        this.mMainActivityPois = mMainActivityPois;
    }

    private void loadMainActivityVenues() {
        Log.d(TAG, "Attempting to load venue information...");
        cmxClientInstance.loadVenues(new CMXVenuesResponseHandler() {
            @Override
            public void onSuccess(List<CMXVenue> venues) {
            Log.d(TAG, "Successfully retrieved venue information...");
                mMainActivityVenues.addAll(venues);
                for (CMXVenue venue : venues) {
                    loadMainActivityFloors(venue);
                }
                cmxClientInstance.loadUserLocation(new CMXClientLocationResponseHandler() {
                    
                    public void onUpdate(CMXClientLocation clientLocation) {
                        mStartMainActivity = true;
                        
                    }
                    public void onFailure(Throwable error) {
                        mStartMainActivity = true;
                    }
                });
            }

            @Override
            public void onFailure(Throwable error) {
                // TODO: Handle failure.
            }
        });
    }

    private void loadMainActivityFloors(final CMXVenue venue) {
        Log.d(TAG, "Attempting to load floor information for venue: " + venue.getName());
        cmxClientInstance.loadMaps(venue.getId(), new CMXFloorsResponseHandler() {
            @Override
            public void onSuccess(List<CMXFloor> floors) {
                Log.d(TAG, "Successfully loaded floor information for venue: " + venue.getName());
                mMainActivityMaps.addAll(floors);
                for (CMXFloor floor : floors) {
                    loadMainActivityPois(floor);
                }
            }
        });
    }

    private void loadMainActivityPois(final CMXFloor floor) {
        cmxClientInstance.loadPois(floor.getVenueId(), floor.getId(), new CMXPoisResponseHandler() {
            @Override
            public void onSuccess(List<CMXPoi> pois) {
                mMainActivityPois.addAll(pois);
            }
        });
    }

    private class WaitforTaskFinish extends AsyncTask<Void, Void, Void> {

        @Override
        protected Void doInBackground(Void... params) {
            while (mStartMainActivity == false) {
                try {
                    Thread.sleep(2000);
                }
                catch (Exception e) {

                }
            }
            return null;
        }

        @Override
        protected void onPostExecute(Void result) {
            Intent i = new Intent(cmxClientInstance.getContext(), CMXMainActivity.class);
            i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            cmxClientInstance.getContext().startActivity(i);
        }
    }

}
