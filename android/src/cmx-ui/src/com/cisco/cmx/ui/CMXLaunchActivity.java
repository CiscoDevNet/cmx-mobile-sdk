package com.cisco.cmx.ui;

import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageButton;
import android.widget.ProgressBar;

import com.cisco.cmx.R;
import com.cisco.cmx.model.CMXClientLocation;
import com.cisco.cmx.model.CMXFloor;
import com.cisco.cmx.model.CMXPoi;
import com.cisco.cmx.model.CMXVenue;
import com.cisco.cmx.network.CMXClient;
import com.cisco.cmx.network.CMXClientLocationResponseHandler;
import com.cisco.cmx.network.CMXClientRegisteringResponseHandler;
import com.cisco.cmx.network.CMXFloorsResponseHandler;
import com.cisco.cmx.network.CMXPoisResponseHandler;
import com.cisco.cmx.network.CMXVenuesResponseHandler;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesUtil;

public class CMXLaunchActivity extends Activity {

    private CMXClientLocation mUserLocation;

    private ImageButton mRetryButton;

    private ProgressBar mProgressBar;

    private AlertDialog mAlertDialog;

    private boolean mLastFloorsLoading = false;

    private boolean mLastPoisLoading = false;

    private boolean mUserLocationDone = false;

    private int mFloorsRequestCount;

    private int mPoisRequestCount;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.cmx_launch_layout);

        mRetryButton = (ImageButton) findViewById(R.id.cmx_launch_retry_button);
        mProgressBar = (ProgressBar) findViewById(R.id.cmx_launch_progress);

        mRetryButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                registerAndLoadData();
            }
        });

        registerAndLoadData();
    }

    /**
     * Register to gcm, then load the data (venues and floors)
     */
    private void registerAndLoadData() {
        mRetryButton.setVisibility(View.INVISIBLE);
        mProgressBar.setVisibility(View.VISIBLE);

        mLastFloorsLoading = false;
        mLastPoisLoading = false;
        mUserLocationDone = false;

        // register
        register(new CMXClientRegisteringResponseHandler() {
            @Override
            public void onFailure(Throwable e) {
                AlertDialog.Builder builder = new AlertDialog.Builder(CMXLaunchActivity.this);
                builder.setTitle(R.string.cmx_warning_dialog_title);
                builder.setMessage(R.string.cmx_registration_failed_dialog_msg);
                builder.setPositiveButton(R.string.cmx_ok_dialog_bt, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        dialog.cancel();
                    }
                });
                builder.create().show();
                mRetryButton.setVisibility(View.VISIBLE);
                mProgressBar.setVisibility(View.INVISIBLE);
            }

            @Override
            public void onSuccess() {
                super.onSuccess();

                final CMXClientLocationResponseHandler locationHandler = new CMXClientLocationResponseHandler() {

                    @Override
                    public void onUpdate(CMXClientLocation clientLocation) {
                        mUserLocation = clientLocation;
                        mUserLocationDone = true;
                        checkRequestsStatus();
                    }

                    @Override
                    public void onFailure(Throwable error) {
                        mUserLocation = null;
                        mUserLocationDone = true;
                        checkRequestsStatus();
                    }
                };

                if (!CMXClient.getInstance().isRegistered()) {
                    AlertDialog.Builder builder = new AlertDialog.Builder(CMXLaunchActivity.this);
                    builder.setTitle(R.string.cmx_warning_dialog_title);
                    builder.setMessage(R.string.cmx_registration_failed_dialog_msg);
                    builder.setPositiveButton(R.string.cmx_ok_dialog_bt, new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int id) {
                            dialog.cancel();
                            CMXClient.getInstance().loadUserLocation(locationHandler);
                        }
                    });
                    builder.create().show();
                }
                else {
                    CMXClient.getInstance().loadUserLocation(locationHandler);
                }

                loadVenues();
            }
        });
    }

    /**
     * Registers to gcm
     * 
     * @param handler
     */
    private void register(final CMXClientRegisteringResponseHandler handler) {
        if (!CMXClient.getInstance().isRegistered()) {

            // Check the device to make sure it has the Google Play Services
            // APK. If
            // it doesn't, display a dialog that allows users to download the
            // APK from
            // the Google Play Store or enable it in the device's system
            // settings.
            int resultCode = GooglePlayServicesUtil.isGooglePlayServicesAvailable(this);
            if (resultCode != ConnectionResult.SUCCESS) {
                if (GooglePlayServicesUtil.isUserRecoverableError(resultCode)) {
                    GooglePlayServicesUtil.getErrorDialog(resultCode, this, CMXMainActivity.PLAY_SERVICES_RESOLUTION_REQUEST).show();
                }
                else {
                    // It means that device doesn't support latest Google Play
                    // Services (Android < v2.2)
                    // Must never happen because minimum version required is
                    // v2.3.3 (API 10)
                    finish();
                }
            }
            else {
                // If check succeeds, proceed with GCM registration.
                CMXClient.getInstance().registerClient(handler);
            }
        }
        else {
            if (handler != null) {
                handler.onSuccess();
            }
        }
    }

    /**
     * Loads all the venues
     */
    private void loadVenues() {

        // load venues then floor foreach venue
        CMXClient.getInstance().loadVenues(new CMXVenuesResponseHandler() {

            @Override
            public void onSuccess(List<CMXVenue> venues) {

                if (venues != null && venues.size() > 0) {
                    CMXClientUi.getInstance().setmMainActivityVenues(venues);
    
                    mFloorsRequestCount = venues.size();
                    mPoisRequestCount = venues.size();
    
                    for (final CMXVenue venue : venues) {
                        loadFloors(venue);
                        loadPois(venue);
                    }
                } else {
                    mRetryButton.setVisibility(View.VISIBLE);
                    mProgressBar.setVisibility(View.INVISIBLE);

                    displayError(getResources().getString(R.string.cmx_no_venue_data_configured));
                }
            }

            @Override
            public void onFailure(Throwable e) {
                mRetryButton.setVisibility(View.VISIBLE);
                mProgressBar.setVisibility(View.INVISIBLE);

                displayError(e.getLocalizedMessage());
            }
        });
    }

    /**
     * Loads all the floors of given venue
     * 
     * @param venue
     *            the venue
     */
    private void loadFloors(final CMXVenue venue) {
        CMXClient.getInstance().loadMaps(venue.getId(), new CMXFloorsResponseHandler() {

            @Override
            public void onSuccess(List<CMXFloor> maps) {
                CMXClientUi.getInstance().setmMainActivityMaps(maps);
                updateFloorsRequests();
            }

            @Override
            public void onFailure(Throwable e) {
                updateFloorsRequests();
                // displayError(e.getCause().getMessage());
            }
        });
    }

    private void updateFloorsRequests() {
        --mFloorsRequestCount;
        mLastFloorsLoading = mFloorsRequestCount == 0;
        if (mLastFloorsLoading) {
            checkRequestsStatus();
        }
    }

    /**
     * Loads all pois of the given venue
     * 
     * @param floor
     */
    private void loadPois(final CMXVenue venue) {
        CMXClient.getInstance().loadPois(venue.getId(), new CMXPoisResponseHandler() {

            @Override
            public void onSuccess(List<CMXPoi> pois) {
                CMXClientUi.getInstance().setmMainActivityPois(pois);
                updatePoisRequests();
            }

            @Override
            public void onFailure(Throwable e) {
                updatePoisRequests();
            }
        });
    }

    private void updatePoisRequests() {
        --mPoisRequestCount;
        mLastPoisLoading = mPoisRequestCount == 0;
        if (mLastPoisLoading) {
            checkRequestsStatus();
        }
    }

    private void checkRequestsStatus() {
        if (mLastFloorsLoading && mLastPoisLoading & mUserLocationDone) {
            Intent i = new Intent();
            i.setAction(CMXMainActivity.ACTION);
            startActivity(i);
            finish();
        }
    }

    private void displayError(String message) {
        AlertDialog.Builder builder = new AlertDialog.Builder(CMXLaunchActivity.this);
        builder.setTitle(R.string.cmx_error_dialog_title);
        builder.setMessage(message);
        builder.setPositiveButton(R.string.cmx_ok_dialog_bt, new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int id) {
                dismissAlertDialog();
            }
        });
        showAlertDialog(builder.create());
    }

    private void showAlertDialog(AlertDialog dialog) {
        if (mAlertDialog == null) {
            mAlertDialog = dialog;
            mAlertDialog.show();
        }
    }

    private void dismissAlertDialog() {
        if (mAlertDialog != null) {
            mAlertDialog.dismiss();
            mAlertDialog = null;
        }
    }

}
