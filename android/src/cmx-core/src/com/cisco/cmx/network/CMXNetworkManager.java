package com.cisco.cmx.network;

import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import junit.framework.Assert;
import android.app.AlertDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiConfiguration;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.provider.Settings;
import android.text.Html;
import android.util.Log;

import com.cisco.cmx.model.CMXNetwork;
import com.cisco.cmx.model.CMXVenue;
import com.cisco.cmx.res.CMXStrings;

/**
 * CMX Network Manager to manage Wi-Fi
 */
public class CMXNetworkManager {

    private static final String TAG = "CMX Netwwork Manager";
    
    private NetworkStateBroadcastReceiver mReceiver;

    private WLANAccessPointBroadcastReceiver mScanReceiver;

    private WifiManager mWifiManager;

    private CMXNetworkState mNetworkState;
    
    private Context mContext;
    
    private Context mAppContext;
    
    private static CMXNetworkManager singletonInstance;
    
    private CMXVenue mActiveVenue;

    private AlertDialog mAlertDialog;
    
    private CMXNetworkHandlerIf mHandlerIf;

    private boolean mConnectingToWifi = false;
    
    private boolean mDisplayNetworkDialog = true;

    private CMXNetworkManager() {
    }

    /**
     * Returns the unique instance of the CMXNetworkManager class
     * 
     * @return unique instance of the CMXNetworkManager class
     */
    public static CMXNetworkManager getInstance() {
        if (null == singletonInstance) {
            synchronized (CMXNetworkManager.class) {
                if (null == singletonInstance) {
                    singletonInstance = new CMXNetworkManager();
                }
            }
        }
        return singletonInstance;
    }

    /**
     * Initialize CMXNetworkManager class
     *  
     * @param context Context
     */
    public void initialize(Context context) {
        this.initialize(context, null);
    }

    /**
     * Initialize CMXNetworkManager class
     * 
     * @param context Context
     * @param handlerIf Network handler interface
     */
    public void initialize(Context context, CMXNetworkHandlerIf handlerIf) {
        mContext = context;
        mAppContext = context.getApplicationContext();
        mHandlerIf = handlerIf;
        
        mWifiManager = (WifiManager) mAppContext.getSystemService(Context.WIFI_SERVICE);

        // Register broadcast receiver for network events
        mReceiver = new NetworkStateBroadcastReceiver();

        mAppContext.registerReceiver(mReceiver, new IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION));
        mAppContext.registerReceiver(mReceiver, new IntentFilter(WifiManager.NETWORK_STATE_CHANGED_ACTION));
        mAppContext.registerReceiver(mReceiver, new IntentFilter(WifiManager.WIFI_STATE_CHANGED_ACTION));
        changeNetworkState(isConnected() ? new ConnectedState() : new NotConnectedState());
    }

    public void onDestroy() {
        mNetworkState.onExit();
        mNetworkState = null;

        if (mAppContext != null) {
            mAppContext.unregisterReceiver(mReceiver);
        }
        mReceiver = null;

        stopWLANAccessPointsScanning();
    }

    /**
     * Indicates whether geolocalisation with venue's Wi-Fi is enabled.
     * 
     * @return true if geolocalisation is enabled
     */
    public boolean isCMXGeolocalisationAvailable() {
        return getActiveVenue() != null && mNetworkState.isVenueWifiAvailable();
    }

    /**
     * Get the active venue
     * 
     * @return Active venue
     */
    public CMXVenue getActiveVenue() {
        return mActiveVenue;
    }

    public void setActiveVenue(CMXVenue activeVenue) {
        Assert.assertNotNull("CMXNetworkManager has not been initialized", mContext);

        mActiveVenue = activeVenue;
        if (activeVenue != null) {
            if (activeVenue.getWifiMode() == CMXVenue.WifiConnectionMode.AUTO) {
                addNetworks(activeVenue.getPreferredNetworks());
                if (!isConnectedToVenueWifi()) {
                    enableNetworks(activeVenue.getPreferredNetworks());
                }
            }
        }

        mNetworkState.onVenueChanged();
    }
    
    /**
     * Broadcast receiver class for network events
     */
    private class NetworkStateBroadcastReceiver extends BroadcastReceiver {

        @Override
        public void onReceive(Context context, Intent intent) {

            if (intent.getAction().equals(ConnectivityManager.CONNECTIVITY_ACTION)) {
                boolean noConnectivity = intent.getBooleanExtra(ConnectivityManager.EXTRA_NO_CONNECTIVITY, false);
                if (noConnectivity) {
                    mNetworkState.onDisconnected();
                }
                else {
                    ConnectivityManager cm = (ConnectivityManager) mAppContext.getSystemService(Context.CONNECTIVITY_SERVICE);
                    NetworkInfo network = cm.getActiveNetworkInfo();
                    if (network != null && network.isConnected()) {
                        mNetworkState.onConnected();
                    }
                }
            }
            else if (intent.getAction().equals(WifiManager.NETWORK_STATE_CHANGED_ACTION)) {
                NetworkInfo networkInfo = intent.getParcelableExtra(WifiManager.EXTRA_NETWORK_INFO);
                if (networkInfo.isConnected()) {
                    mNetworkState.onConnected();
                }
            }
            else if (intent.getAction().equals(WifiManager.WIFI_STATE_CHANGED_ACTION)) {
                int extraWifiState = intent.getIntExtra(WifiManager.EXTRA_WIFI_STATE, WifiManager.WIFI_STATE_UNKNOWN);

                switch (extraWifiState) {
                    case WifiManager.WIFI_STATE_DISABLED:
                        mNetworkState.onWifiDisabled();
                        break;
                    case WifiManager.WIFI_STATE_ENABLED:
                        mNetworkState.onWifiEnabled();
                        break;
                }
            }
        }
    }

    /**
     * Broadcast receiver class for scan results events
     */
    private class WLANAccessPointBroadcastReceiver extends BroadcastReceiver {

        @Override
        public void onReceive(Context context, Intent intent) {

            if (intent.getAction().equals(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION)) {
                List<ScanResult> result = mWifiManager.getScanResults();

                if (result != null && getActiveVenue() != null) {
                    List<CMXNetwork> availableNetworks = new ArrayList<CMXNetwork>(result.size());
                    boolean foundNetwork = false;
                    for (ScanResult accessPoint : result) {
                        for (CMXNetwork network : getActiveVenue().getPreferredNetworks()) {
                            if (accessPoint.SSID.equals(network.getSSID())) {
                                foundNetwork = false;
                                for (CMXNetwork addedNetwork : availableNetworks) {
                                    if (addedNetwork.getSSID().equals(network.getSSID())) {
                                        // SSID already added
                                        foundNetwork = true;
                                        break;
                                    }
                                }
                                // SSID found
                                if (!foundNetwork) {
                                    availableNetworks.add(network);
                                }
                                break;
                            }
                        }
                    }
                    mNetworkState.onScanResult(availableNetworks);
                }
            }
        }
    }

    private abstract class CMXNetworkState {

        public void onEnter() {
        }

        public void onExit() {
        }

        public void onConnected() {
        }

        public void onDisconnected() {
        }

        public void onWifiEnabled() {
        }

        public void onWifiDisabled() {
        }

        public void onVenueChanged() {
        }

        public void onScanResult(List<CMXNetwork> availableNetworks) {
        }

        public abstract boolean isVenueWifiAvailable();

    }

    private class NotConnectedState extends CMXNetworkState {

        boolean mVenueWifiAvailable = false;

        public void onEnter() {
            mDisplayNetworkDialog = true;
            if (isWifiEnabled()) {
                scanWLANAccessPoints();
            }
            else {
                showWifiDisabledDialog();
            }
        }

        public void onConnected() {
            mDisplayNetworkDialog = true;
            changeNetworkState(isConnectedToVenueWifi() ? new ConnectedToVenueWifiState() : new ConnectedState());
        }

        public void onWifiEnabled() {
            mDisplayNetworkDialog = true;
            scanWLANAccessPoints();
        }

        public void onWifiDisabled() {
            mDisplayNetworkDialog = true;
            stopWLANAccessPointsScanning();
        }

        public void onScanResult(List<CMXNetwork> availableNetworks) {

            if (getActiveVenue() != null) {

                // Check if venue's Wi-Fi is available
                if (availableNetworks.size() == 0 && !CMXUtils.isEmulator()) {

                    mVenueWifiAvailable = false;

                    // Display dialog to go to the venue
                    showNoVenueWifiUseGoogleMapsDialog();
                }
                else {

                    mVenueWifiAvailable = true;

                    if (!isConnectedToVenueWifi()) {

                        switch (getActiveVenue().getWifiMode()) {
                            case AUTO:
                                // Connect to the venue's Wi-Fi
                                enableNetworks(availableNetworks);
                                break;
                            case MANUAL:
                                // Display dialog to go to Wi-Fi settings
                                showConnectManuallyToVenueWifiDialog(availableNetworks);
                                break;
                            case PROMPT:
                                // Display dialog to connect to the venue's
                                // Wi-Fi
                                showConnectToVenueWifiDialog(availableNetworks);
                                break;
                            default:
                                break;
                        }
                    }
                }
            }
        }

        public void onVenueChanged() {
            mDisplayNetworkDialog = true;

            if (getActiveVenue() == null) {
                stopWLANAccessPointsScanning();
            }
            else {
                if (isWifiEnabled()) {
                    scanWLANAccessPoints();
                }
                else {
                    showWifiDisabledDialog();
                }
            }
        }

        public boolean isVenueWifiAvailable() {
            return mVenueWifiAvailable;
        }
    }

    private class ConnectedState extends CMXNetworkState {

        boolean mVenueWifiAvailable = false;

        public void onEnter() {
            mDisplayNetworkDialog = true;

            if (isWifiEnabled()) {
                scanWLANAccessPoints();
            }
            else {
                showWifiDisabledDialog();
            }
            if (mHandlerIf != null) {
                mHandlerIf.updateActionBarItemVisibility();
            }
        }

        public void onDisconnected() {
            mDisplayNetworkDialog = true;
            changeNetworkState(new NotConnectedState());
        }

        public void onConnected() {
            mDisplayNetworkDialog = true;
            if (isConnectedToVenueWifi()) {
                changeNetworkState(new ConnectedToVenueWifiState());
            }
        }

        public void onWifiEnabled() {
            mDisplayNetworkDialog = true;
            scanWLANAccessPoints();
        }

        public void onWifiDisabled() {
            mDisplayNetworkDialog = true;
            stopWLANAccessPointsScanning();
        }

        public void onScanResult(List<CMXNetwork> availableNetworks) {

            if (getActiveVenue() != null) {
                // Check if venue's Wi-Fi is available
                if (availableNetworks.size() == 0 && !CMXUtils.isEmulator()) {
                    mVenueWifiAvailable = false;

                    // Display dialog to go to the venue
                    showNoVenueWifiUseGoogleMapsDialog();

                    if (mHandlerIf != null) {
                        mHandlerIf.startLocationUpdate();
                    }
                }
                else {

                    mVenueWifiAvailable = true;

                    // With Wi-Fi available, user location works, so start
                    // polling.
                    if (mHandlerIf != null) {
                        mHandlerIf.startLocationUpdate();
                    }

                    if (!isConnectedToVenueWifi()) {
                        switch (getActiveVenue().getWifiMode()) {
                            case AUTO:
                                // Connect to the venue's Wi-Fi
                                enableNetworks(availableNetworks);
                                break;
                            case MANUAL:
                                // Display dialog to display Wi-Fi settings
                                showConnectManuallyToVenueWifiDialog(availableNetworks);
                                break;
                            case PROMPT:
                                // Display dialog to connect to the venue's
                                // Wi-Fi
                                showConnectToVenueWifiDialog(availableNetworks);
                                break;
                            default:
                                break;
                        }
                    }
                }
            }
        }

        public void onVenueChanged() {
            mDisplayNetworkDialog = true;
            if (getActiveVenue() == null) {
                // No venue, we stop the polling.
                // CMXClient.getInstance().stopUserLocationPolling();

                stopWLANAccessPointsScanning();
            }
            else {
                if (isConnectedToVenueWifi()) {
                    changeNetworkState(new ConnectedToVenueWifiState());
                }
                else {
                    if (isWifiEnabled()) {
                        scanWLANAccessPoints();
                    }
                    else {
                        showWifiDisabledDialog();
                    }
                }
            }
        }

        public boolean isVenueWifiAvailable() {
            return mVenueWifiAvailable;
        }
    }

    private class ConnectedToVenueWifiState extends CMXNetworkState {

        public void onEnter() {
            // DEBUG
            // register();
            stopWLANAccessPointsScanning();
            if (mHandlerIf != null) {
                mHandlerIf.startLocationUpdate();
                mHandlerIf.updateActionBarItemVisibility();
            }
        }

        public void onExit() {
            // CMXClient.getInstance().stopUserLocationPolling();
        }

        public void onConnected() {
            if (!isConnectedToVenueWifi()) {
                changeNetworkState(new ConnectedState());
            }
        }

        public void onDisconnected() {
            changeNetworkState(new NotConnectedState());
        }

        public void onVenueChanged() {
            if (getActiveVenue() == null) {
                // No venue selected, change to simple connected state
                changeNetworkState(new ConnectedState());
            }
            else {
                if (!isConnectedToVenueWifi()) {
                    changeNetworkState(new ConnectedState());
                }
            }
        }

        public boolean isVenueWifiAvailable() {
            return true;
        }
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

    /**
     * Show the dialog requesting to change the current Wi-Fi network to the venue desired one
     * 
     * @param availableNetworks List of networks the user can join
     */
    public void showConnectToVenueWifiDialog(final List<CMXNetwork> availableNetworks) {

        if (mDisplayNetworkDialog) {
            mDisplayNetworkDialog = false;
            AlertDialog.Builder builder = new AlertDialog.Builder(mContext);
            builder.setTitle(CMXStrings.CMX_INFORMATION_DIALOG_TITLE);
            builder.setMessage(CMXStrings.CMX_CONNECT_TO_VENUE_WIFI_DIALOG_MSG);
            builder.setPositiveButton(CMXStrings.CMX_YES_DIALOG_BUTTON, new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int id) {
                    addNetworks(availableNetworks);
                    enableNetworks(availableNetworks);
                    dismissAlertDialog();
                }
            });
            builder.setNegativeButton(CMXStrings.CMX_NO_DIALOG_BUTTON, new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int id) {
                    dismissAlertDialog();
                }
            });
    
            showAlertDialog(builder.create());
        }
    }

    /**
     * Show the dialog describing which Wi-Fi networks the user can join. The user will have to perform the steps
     * manually to join the network.
     * 
     * @param availableNetworks List of networks the user can join
     */
    public void showConnectManuallyToVenueWifiDialog(final List<CMXNetwork> availableNetworks) {

        if (mDisplayNetworkDialog) {
            mDisplayNetworkDialog = false;
            AlertDialog.Builder builder = new AlertDialog.Builder(mContext);
            builder.setTitle(CMXStrings.CMX_INFORMATION_DIALOG_TITLE);
            String ssidList = "";
            for (CMXNetwork network : availableNetworks) {
                ssidList += CMXStrings.CMX_WIFI_NETWORK + "<b>" + network.getSSID() + "</b><br>";
                if (network.getPassword() != null && network.getPassword().length() > 0) {
                    ssidList += CMXStrings.CMX_WIFI_NETWORK_PASSWORD + "<b>" + network.getPassword() + "</b><br>";
                }
            }
            builder.setMessage(Html.fromHtml(CMXStrings.CMX_CONNECT_MANUALLY_TO_VENUE_WIFI_DIALOG_MSG + ssidList + CMXStrings.CMX_CONNECT_MANUALLY_TO_VENUE_WIFI_DIALOG_MSG_2));
            builder.setPositiveButton(CMXStrings.CMX_YES_DIALOG_BUTTON, new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int id) {
                    mContext.startActivity(new Intent(Settings.ACTION_WIFI_SETTINGS));
                    dismissAlertDialog();
                }
            });
            builder.setNegativeButton(CMXStrings.CMX_NO_DIALOG_BUTTON, new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int id) {
                    dismissAlertDialog();
                }
            });
    
            showAlertDialog(builder.create());
        }
    }

    /**
     * Display a dialog requesting if the user wants to navigate to the venue using Google Maps
     */
    public void showNoVenueWifiUseGoogleMapsDialog() {

        if (mDisplayNetworkDialog) {
            mDisplayNetworkDialog = false;
            AlertDialog.Builder builder = new AlertDialog.Builder(mContext);
            builder.setTitle(CMXStrings.CMX_INFORMATION_DIALOG_TITLE);
            builder.setMessage(CMXStrings.CMX_NO_VENUE_WIFI_USE_GOOGLE_MAPS_DIALOG_MSG);
            builder.setPositiveButton(CMXStrings.CMX_YES_DIALOG_BUTTON, new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int id) {
                    Intent intent = new Intent(android.content.Intent.ACTION_VIEW, Uri.parse("google.navigation:q=" + Uri.encode(getActiveVenue().getStreetAddress())));
                    mContext.startActivity(intent);
                    dismissAlertDialog();
                }
            });
            builder.setNegativeButton(CMXStrings.CMX_NO_DIALOG_BUTTON, new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int id) {
                    dismissAlertDialog();
                }
            });
    
            showAlertDialog(builder.create());
        }
    }

    /**
     * Display a dialog requesting permission to enable the Wi-Fi
     */
    public void showWifiDisabledDialog() {

        AlertDialog.Builder builder = new AlertDialog.Builder(mContext);
        builder.setTitle(CMXStrings.CMX_INFORMATION_DIALOG_TITLE);
        builder.setMessage(CMXStrings.CMX_WIFI_DISABLED_DIALOG_MSG);
        builder.setPositiveButton(CMXStrings.CMX_YES_DIALOG_BUTTON, new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int id) {
                setWifiEnabled(true);
                dismissAlertDialog();
            }
        });
        builder.setNegativeButton(CMXStrings.CMX_NO_DIALOG_BUTTON, new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int id) {
                dismissAlertDialog();
            }
        });

        showAlertDialog(builder.create());
    }

    /**
     * Change internal network state.
     * 
     * @param newState
     *            new state.
     */
    private void changeNetworkState(CMXNetworkState newState) {
        mDisplayNetworkDialog = true;

        if (mNetworkState != null) {
            mNetworkState.onExit();
        }

        mNetworkState = newState;
        Log.v(TAG, "Network state changed : " + mNetworkState.getClass().getName());

        if (mNetworkState != null) {
            mNetworkState.onEnter();
        }
    }

    /**
     * Return whether Wi-Fi is enabled or disabled.
     * 
     * @return true if Wi-Fi is enabled
     */
    private boolean isWifiEnabled() {
        if (CMXUtils.isEmulator()) {
            return true;
        }
        return mWifiManager.isWifiEnabled();
    }

    /**
     * Enable or disable Wi-Fi.
     * 
     * @param enabled
     *            true to enable, false to disable.
     * @return true if the operation succeeds (or if the existing state is the
     *         same as the requested state).
     */
    private boolean setWifiEnabled(boolean enabled) {
        return mWifiManager.setWifiEnabled(enabled);
    }

    /**
     * Indicates whether network connectivity exists and it is possible to
     * establish connections and pass data.
     * 
     * @return true if network connectivity exists
     */
    private boolean isConnected() {
        Assert.assertNotNull("CMXNetworkManager has not been initialized", mAppContext);
        ConnectivityManager cm = (ConnectivityManager) mAppContext.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo network = cm.getActiveNetworkInfo();
        return network != null ? network.isConnected() : false;
    }

    /**
     * Indicates whether device is connected to the venue Wi-Fi.
     * 
     * @return true if connected to venue Wi-Fi
     */
    private boolean isConnectedToVenueWifi() {
        // Check if we are connected to a venue preferred network
        if (CMXUtils.isEmulator()) {
            return true;
        }
        final WifiInfo connectionInfo = mWifiManager.getConnectionInfo();
        if (connectionInfo != null && connectionInfo.getSSID() != null && getActiveVenue() != null) {
            for (CMXNetwork network : getActiveVenue().getPreferredNetworks()) {
                String connectionId = connectionInfo.getSSID().trim();
                if (connectionId != null && connectionId.startsWith("\"") && connectionId.endsWith("\"")) {
                    connectionId = connectionId.substring(1, connectionId.length() - 1);
                }
                if (connectionId.matches(network.getSSID())) {
                    return true;
                }
            }
        }

        return false;
    }

    /**
     * Scan WLAN access points. Register broadcast receiver with IntentFilter
     * equals to CMXClient.SCAN_WLAN_RESULTS_AVAILABLE_ACTION to get results.
     * Use getBooleanExtra(CMXClient.EXTRA_CMX_WIFI_AVAILABLE) to check if CMX
     * Wi-fi is available from the intent
     * 
     * @return true if the operation succeeded, i.e., the scan was initiated
     */
    private boolean scanWLANAccessPoints() {
        Assert.assertNotNull("CMXNetworkManager has not been initialized", mAppContext);
        if (mScanReceiver == null) {

            mScanReceiver = new WLANAccessPointBroadcastReceiver();
            mAppContext.registerReceiver(mScanReceiver, new IntentFilter(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION));
        }
        return mWifiManager.startScan();
    }

    private void stopWLANAccessPointsScanning() {
        Assert.assertNotNull("CMXNetworkManager has not been initialized", mAppContext);
        if (mScanReceiver != null) {
            mAppContext.unregisterReceiver(mScanReceiver);
            mScanReceiver = null;
        }
    }

    @SuppressWarnings("unused")
    private int addWEPNetwork(WifiConfiguration configuration, String password) {
        configureWEPNetwork(configuration, password);
        return mWifiManager.addNetwork(configuration);
    }

    private void configureWEPNetwork(WifiConfiguration configuration, String password) {
        configuration.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.NONE);
        configuration.allowedProtocols.set(WifiConfiguration.Protocol.RSN);
        configuration.allowedProtocols.set(WifiConfiguration.Protocol.WPA);
        configuration.allowedAuthAlgorithms.set(WifiConfiguration.AuthAlgorithm.OPEN);
        configuration.allowedAuthAlgorithms.set(WifiConfiguration.AuthAlgorithm.SHARED);
        configuration.allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.CCMP);
        configuration.allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.TKIP);
        configuration.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.WEP40);
        configuration.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.WEP104);
        configuration.wepKeys[0] = "\"".concat(password).concat("\"");
        configuration.wepTxKeyIndex = 0;
    }

    private int addWPANetwork(WifiConfiguration configuration, String password) {
        configureWPANetwork(configuration, password);
        return mWifiManager.addNetwork(configuration);
    }

    private void configureWPANetwork(WifiConfiguration configuration, String password) {
        configuration.allowedAuthAlgorithms.set(WifiConfiguration.AuthAlgorithm.OPEN);
        configuration.allowedProtocols.set(WifiConfiguration.Protocol.RSN);
        configuration.allowedProtocols.set(WifiConfiguration.Protocol.WPA);
        configuration.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.WPA_PSK);
        configuration.allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.TKIP);
        configuration.allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.CCMP);
        configuration.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.WEP40);
        configuration.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.WEP104);
        configuration.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.TKIP);
        configuration.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.CCMP);
        configuration.preSharedKey = "\"".concat(password).concat("\"");
    }

    public boolean isConnectingToWifi() {
        return mConnectingToWifi;
    }
    
    public void setConnectingToWifi(boolean isConnecting) {
        mConnectingToWifi = isConnecting;
    }

    /**
     * Add networks to the Android Wi-Fi configuration.
     * 
     * @param networks
     *            network list to add
     */
    private void addNetworks(List<CMXNetwork> networks) {
        for (CMXNetwork network : networks) {
            WifiConfiguration wc = new WifiConfiguration();
            wc.SSID = "\"".concat(network.getSSID()).concat("\"");
            // wc.hiddenSSID = true;
            // wc.status = WifiConfiguration.Status.ENABLED;
            addWPANetwork(wc, network.getPassword());

            mWifiManager.addNetwork(wc);
        }

        mWifiManager.saveConfiguration();
    }

    /**
     * Enable the given networks, meaning try to connect to these networks.
     * 
     * @param networks
     *            network list to enable
     */
    private void enableNetworks(List<CMXNetwork> networks) {
        List<WifiConfiguration> configurations = mWifiManager.getConfiguredNetworks();
        if (configurations != null) {
            for (CMXNetwork network : networks) {
                for (WifiConfiguration configuration : configurations) {
                    if (configuration.SSID.equals("\"" + network.getSSID() + "\"")) {
                        if (!mConnectingToWifi) {
                            mConnectingToWifi = true;
                            Timer mTimer = new Timer();
                            mTimer.schedule(new TimerTask() {
                                
                                @Override
                                public void run() {
                                    CMXClient.getInstance().loadVenues(null);
                                }
                            }, 3000);
                        }
                        mWifiManager.enableNetwork(configuration.networkId, true);
                        break;
                    }
                }
            }
        }
    }
}
