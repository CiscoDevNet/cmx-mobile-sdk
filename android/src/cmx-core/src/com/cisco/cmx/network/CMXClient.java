package com.cisco.cmx.network;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;
import java.security.KeyStore;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Timer;
import java.util.TimerTask;
import java.util.regex.Pattern;

import junit.framework.Assert;

import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.StatusLine;
import org.apache.http.client.HttpResponseException;
import org.apache.http.conn.ssl.SSLSocketFactory;
import org.apache.http.entity.BufferedHttpEntity;
import org.apache.http.util.EntityUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager.NameNotFoundException;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.net.Uri;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.AsyncTask;
import android.os.Message;
import android.util.Log;

import com.caverock.androidsvg.PreserveAspectRatio;
import com.caverock.androidsvg.SVG;
import com.caverock.androidsvg.SVGParseException;
import com.cisco.cmx.model.CMXBanner;
import com.cisco.cmx.model.CMXClientLocation;
import com.cisco.cmx.model.CMXDimension;
import com.cisco.cmx.model.CMXFloor;
import com.cisco.cmx.model.CMXGeoCoordinate;
import com.cisco.cmx.model.CMXMapCoordinate;
import com.cisco.cmx.model.CMXNetwork;
import com.cisco.cmx.model.CMXPath;
import com.cisco.cmx.model.CMXPoi;
import com.cisco.cmx.model.CMXPoint;
import com.cisco.cmx.model.CMXVenue;
import com.cisco.cmx.res.CMXStrings;
import com.google.android.gms.gcm.GoogleCloudMessaging;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;
import com.loopj.android.http.JsonHttpResponseHandler;
import com.loopj.android.http.PersistentCookieStore;
import com.loopj.android.http.RequestParams;

/**
 * CMXClient is a low level class that manages connection with CMX server.
 */
public class CMXClient {

    /**
     * CMXClient configuration
     */
    public static class Configuration {

        URL mServerURL;
        
        String mServerAddress;
        
        String mServerPort = Integer.toString(CMXStrings.CMX_DEFAULT_MOBILE_APP_SERVER_PORT);

        String mSenderId;

        /**
         * Return server URL
         * 
         * @return server URL
         */
        public URL getServerURL() {
            return mServerURL;
        }

        /**
         * Return server address
         * 
         * @return server address
         */
        public String getServerAddress() {
            return mServerAddress;
        }

        /**
         * Set Mobile App Server address to connect with
         * 
         * @param address
         *            Mobile App Server address
         */
        public void setServerAddress(String address) throws MalformedURLException {
            mServerAddress = address;
            String baseUrl = "https://" + mServerAddress + ":" + mServerPort + "/" + CMXStrings.CMX_DEAULT_MOBILE_APP_SERVER_WEB_APP + "/";
            mServerURL = new URL(baseUrl);
        }

        /**
         * Set Mobile App Server port to connect with
         * 
         * @param address
         *            Mobile App Server port
         */
        public void setServerPort(String port) throws MalformedURLException {
            mServerPort = port;
            String baseUrl = "https://" + mServerAddress + ":" + mServerPort + "/" + CMXStrings.CMX_DEAULT_MOBILE_APP_SERVER_WEB_APP + "/";
            mServerURL = new URL(baseUrl);
        }

        /**
         * Return project number you got from the API Console
         * 
         * @return project number
         */
        public String getSenderId() {
            return mSenderId;
        }

        /**
         * Set project number you got from the API Console
         * 
         * @param senderId
         *            sender id
         */
        public void setSenderId(String senderId) {
            this.mSenderId = senderId;
        }

    }

    private static final String TAG = "CMXClient";

    private static final String VENUES_INFO_URL = "api/cmxmobile/v1/venues/info/";

    private static final String VENUE_INFO_URL = "api/cmxmobile/v1/venues/info/%s";

    private static final String VENUE_IMAGE_URL = "api/cmxmobile/v1/venues/image/%s";

    private static final String MAPS_INFO_URL = "api/cmxmobile/v1/maps/info/%s";

    private static final String FLOOR_INFO_URL = "api/cmxmobile/v1/maps/info/%s/%s";

    private static final String FLOOR_IMAGE_URL = "api/cmxmobile/v1/maps/image/%s/%s";

    private static final String CLIENTS_LOCATION_URL = "api/cmxmobile/v1/clients/location/%s";

    private static final String CLIENT_REGISTERING_URL = "api/cmxmobile/v1/clients/register/";

    private static final String CLIENT_LOCATION_FEEDBACK_URL = "api/cmxmobile/v1/clients/feedback/location/%s";

    private static final String POIS_URL = "api/cmxmobile/v1/pois/info/%s";

    private static final String POI_IMAGE_URL = "api/cmxmobile/v1/pois/image/%s/%s";

    private static final String FLOOR_POIS_URL = "api/cmxmobile/v1/pois/info/%s/%s";

    private static final String SEARCH_URL = "api/cmxmobile/v1/pois/info/%s?search=%s";

    private static final String PATH_URL = "api/cmxmobile/v1/routes/clients/%s?destpoi=%s";

    private static final String BANNERS_INFO_URL = "api/cmxmobile/v1/banners/info/%s/%s/%s";

    private static final String BANNER_IMAGE_URL = "api/cmxmobile/v1/banners/image/%s/%s/%s/%s";

    private static final String PROPERTY_REG_ID = "registration_id";

    private static final String PROPERTY_DEVICE_ID = "device_id";

    private static final String PROPERTY_APP_VERSION = "appVersion";

    private static CMXClient singletonInstance;

    private static Context mContext;

    private AsyncHttpClient mHTTPClient;

    private URL mServerURL;
    
    private String mServerAddress;

    private String mSenderId;

    private Timer mLocationUpdateTimer;

    private CMXClientLocation mLatestLocation;
    
    private CMXWifiScanner mwifi;
    
    // To prevent any other class from instantiating
    private CMXClient() {
    }

    /**
     * Returns the unique instance of the CMXClient class
     * 
     * @return unique instance of the CMXClient class
     */
    public static CMXClient getInstance() {
        if (null == singletonInstance) {
            synchronized (CMXClient.class) {
                if (null == singletonInstance) {
                    singletonInstance = new CMXClient();
                }
            }
        }
        return singletonInstance;
    }

    public void resetClientRegistration() {
        storeDeviceId("");
    }

    public URL getBaseServerUrl() {
        return mServerURL;
    }

    public String getServerAddress() {
        return mServerAddress;
    }

    public Context getContext() {
        return mContext;
    }
    
    /**
     * Initialize the CMX client. Must be call once (for example in
     * Application.onCreate())
     * 
     * @param context
     *            a context
     */
    public void initialize(Context context) {
        if (mContext != null || mHTTPClient != null) {
            return;
        }

        mContext = context.getApplicationContext();

        // Create & configure HTTP client
        mHTTPClient = new AsyncHttpClient();
        try {
            KeyStore trustStore = KeyStore.getInstance(KeyStore.getDefaultType());
            trustStore.load(null, null);
            SSLSocketFactory sf = new CMXSSLSocketFactory(trustStore);
            sf.setHostnameVerifier(SSLSocketFactory.ALLOW_ALL_HOSTNAME_VERIFIER);
            mHTTPClient.setSSLSocketFactory(sf);
        }
        catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        // Ask for JSON output
        mHTTPClient.addHeader("Accept", "application/json");

        PersistentCookieStore myCookieStore = new PersistentCookieStore(mContext);
        mHTTPClient.setCookieStore(myCookieStore);
        CMXNetworkManager.getInstance().initialize(mContext);
    }

    /**
     * Set a new configuration.
     * 
     * @note don't forget to reload data if necessary.
     * @param config
     *            the new configuration to apply
     */
    public void setConfiguration(CMXClient.Configuration config) {
        if (config != null) {
            mServerURL = config.getServerURL();
            mServerAddress = config.getServerAddress();
            mSenderId = config.getSenderId();
        }
    }

    private String getVenuesInfosURL() {
        Uri.Builder b = Uri.parse(mServerURL.toString()).buildUpon();
        b.appendEncodedPath(String.format(VENUES_INFO_URL));
        return b.build().toString();
    }

    private String getVenueInfosURL(String venueId) {
        Uri.Builder b = Uri.parse(mServerURL.toString()).buildUpon();
        b.appendEncodedPath(String.format(VENUE_INFO_URL, venueId));
        return b.build().toString();
    }

    private String getVenueImageURL(String venueId) {
        try {
            Uri.Builder b = Uri.parse(mServerURL.toString()).buildUpon();
            String param1 = URLEncoder.encode(venueId, "utf-8");
            b.appendEncodedPath(String.format(VENUE_IMAGE_URL, param1));
            return b.build().toString();
        }
        catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return null;
    }

    private String getMapsInfosURL(String venueId) {
        try {
            Uri.Builder b = Uri.parse(mServerURL.toString()).buildUpon();
            String param1 = URLEncoder.encode(venueId, "utf-8");
            b.appendEncodedPath(String.format(MAPS_INFO_URL, param1));
            return b.build().toString();
        }
        catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return null;
    }

    private String getFloorInfosURL(String venueId, String floorId) {
        try {
            Uri.Builder b = Uri.parse(mServerURL.toString()).buildUpon();
            String param1 = URLEncoder.encode(venueId, "utf-8");
            String param2 = URLEncoder.encode(floorId, "utf-8");
            b.appendEncodedPath(String.format(FLOOR_INFO_URL, param1, param2));
            return b.build().toString();
        }
        catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return null;
    }

    private String getFloorImageURL(String venueId, String floorId) {
        try {
            Uri.Builder b = Uri.parse(mServerURL.toString()).buildUpon();
            String param1 = URLEncoder.encode(venueId, "utf-8");
            String param2 = URLEncoder.encode(floorId, "utf-8");
            b.appendEncodedPath(String.format(FLOOR_IMAGE_URL, param1, param2));
            return b.build().toString();
        }
        catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return null;
    }

    private String getPoisURL(String venueId, String floorId) {
        try {
            Uri.Builder b = Uri.parse(mServerURL.toString()).buildUpon();
            String param1 = URLEncoder.encode(venueId, "utf-8");
            String param2 = URLEncoder.encode(floorId, "utf-8");
            b.appendEncodedPath(String.format(FLOOR_POIS_URL, param1, param2));
            return b.build().toString();
        }
        catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return null;
    }

    private String getPoisURL(String venueId) {
        try {
            Uri.Builder b = Uri.parse(mServerURL.toString()).buildUpon();
            String param1 = URLEncoder.encode(venueId, "utf-8");
            b.appendEncodedPath(String.format(POIS_URL, param1));
            return b.build().toString();
        }
        catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return null;
    }

    public String getPoiImageURL(String venueId, String poiId) {
        try {
            Uri.Builder b = Uri.parse(mServerURL.toString()).buildUpon();
            String param1 = URLEncoder.encode(venueId, "utf-8");
            String param2 = URLEncoder.encode(poiId, "utf-8");
            b.appendEncodedPath(String.format(POI_IMAGE_URL, param1, param2));
            return b.build().toString();
        }
        catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return null;
    }

    private String getSearchURL(String venueId, String keywords) {
        try {
            Uri.Builder b = Uri.parse(mServerURL.toString()).buildUpon();
            String param1 = URLEncoder.encode(venueId, "utf-8");
            String param2 = URLEncoder.encode(keywords, "utf-8");
            b.appendEncodedPath(String.format(SEARCH_URL, param1, param2));
            return b.build().toString();
        }
        catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return null;
    }

    private String getClientLocationURL() {
        Uri.Builder b = Uri.parse(mServerURL.toString()).buildUpon();
        b.appendEncodedPath(String.format(CLIENTS_LOCATION_URL, getDeviceId()));
        return b.build().toString();
    }

    private String getClientRegisteringURL() {
        Uri.Builder b = Uri.parse(mServerURL.toString()).buildUpon();
        b.appendEncodedPath(CLIENT_REGISTERING_URL);
        return b.build().toString();
    }

    private String getPathURL(String poiId) {
        try {
            Uri.Builder b = Uri.parse(mServerURL.toString()).buildUpon();
            String param2 = URLEncoder.encode(poiId, "utf-8");
            b.appendEncodedPath(String.format(PATH_URL, getDeviceId(), param2));
            return b.build().toString();
        }
        catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return null;
    }

    private String getBannersURL(String venueId, String floorId, String zoneId) {
        try {
            Uri.Builder b = Uri.parse(mServerURL.toString()).buildUpon();
            String param1 = URLEncoder.encode(venueId, "utf-8");
            String param2 = URLEncoder.encode(floorId, "utf-8");
            String param3 = URLEncoder.encode(zoneId, "utf-8");
            b.appendEncodedPath(String.format(BANNERS_INFO_URL, param1, param2, param3));
            return b.build().toString();
        }
        catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return null;
    }

    private String getBannerImageURL(String venueId, String floorId, String zoneId, String imageId) {
        try {
            Uri.Builder b = Uri.parse(mServerURL.toString()).buildUpon();
            String param1 = URLEncoder.encode(venueId, "utf-8");
            String param2 = URLEncoder.encode(floorId, "utf-8");
            String param3 = URLEncoder.encode(zoneId, "utf-8");
            String param4 = URLEncoder.encode(imageId, "utf-8");
            b.appendEncodedPath(String.format(BANNER_IMAGE_URL, param1, param2, param3, param4));
            return b.build().toString();
        }
        catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return null;
    }

    private String getClientLocationFeedbackURL() {
        Uri.Builder b = Uri.parse(mServerURL.toString()).buildUpon();
        b.appendEncodedPath(String.format(CLIENT_LOCATION_FEEDBACK_URL, getDeviceId()));
        return b.build().toString();
    }

    /**
     * Return boolean indicating if client has already been registered or not.
     * 
     * @return true if the client has already been registered, false otherwise.
     */
    public boolean isRegistered() {
        String deviceId = getDeviceId();
        return deviceId != null && !deviceId.isEmpty();
    }

    /**
     * Register this client to Cisco CMX server. If registration has already
     * been done, do nothing
     * 
     * @param handler
     *            response handler
     */
    public void registerClient(final CMXClientRegisteringResponseHandler handler) {
        Assert.assertNotNull("CMXClient has not been initialized", mHTTPClient);
        Assert.assertNotNull("CMXClient has not been initialized", mContext);

        if (isRegistered())
            return;

        if (handler != null) {
            handler.onStart();
        }

        final GoogleCloudMessaging gcm = GoogleCloudMessaging.getInstance(mContext);

        // Registers the application with GCM servers asynchronously (to avoid
        // MAIN_THRAD exception).
        new AsyncTask<Void, Void, String>() {
            @Override
            protected String doInBackground(Void... params) {
                try {
                    String res = gcm.register(mSenderId);
                    return res;
                }
                catch (IOException ex) {
                    ex.printStackTrace();
                    return "";
                }
            }

            @Override
            protected void onPostExecute(final String regId) {
                String macAddress = getMacAddress();

                if (macAddress != null) {

                    RequestParams params = new RequestParams();
                    if (regId != null)
                        params.put("pushNotificationRegistrationId", regId);
                    params.put("clientMACAddress", macAddress);
                    params.put("clientType", "android");

                    mHTTPClient.post(getClientRegisteringURL(), params, new AsyncHttpResponseHandler() {

                        // no onStart here because it's done before !!

                        public void onSuccess(int statusCode, Header[] headers, String content) {
                            // TODO : manage status code value
                            // 4xx code if something went wrong (like the MAC
                            // address you registered with was already taken for
                            // some reason)
                            // 5xx code if something went wrong on the server
                            // 202/Accepted code if the server hasn't received
                            // the matching AssociationEvent yet
                            // 201/Created code if everything went right. There
                            // will also be a Set-cookie header, and the URI
                            // created will be
                            // /api/cmxmobile/v1/clients/location/{deviceId}

                            if (regId != null && !regId.isEmpty()) {
                                // Persist the regID - no need to register
                                // again.
                                storeRegistrationId(regId);
                            }

                            // Extract & store the device ID
                            for (Header header : headers) {
                                if (header.getName().equals("Location")) {
                                    String location = header.getValue();
                                    String str[] = location.split("/");
                                    storeDeviceId(str[str.length - 1]);
                                }
                            }

                            if (handler != null) {
                                handler.onSuccess();
                            }
                        }

                        @Override
                        public void onFailure(Throwable e) {
                            if (CMXNetworkManager.getInstance().isConnectingToWifi()) {
                                registerClient(handler);
                            } else if (handler != null) {
                                handler.onFailure(new IOException(CMXStrings.CMX_REGISTRATION_FAILED_EXCEPTION));
                            }
                        }
                    });
                }
                else {
                    if (handler != null) {
                        handler.onFailure(new IOException(CMXStrings.CMX_GCM_REGISTRATION_FAILED_EXCEPTION));
                    }
                }
            }
        }.execute(null, null, null);
    }

    private void internalLoadVenues(final String url, final CMXVenuesResponseHandler handler) {

        mHTTPClient.get(url, new JsonHttpResponseHandler() {

            private CMXNetwork createNetwork(JSONObject obj) {
                if (obj == null)
                    return null;

                return new CMXNetwork(obj.optString("ssid"), obj.optString("password"));
            }

            private List<CMXNetwork> createNetworks(JSONArray objs) {
                if (objs == null)
                    return null;

                List<CMXNetwork> networks = new ArrayList<CMXNetwork>(objs.length());
                for (int index = 0; index < objs.length(); ++index) {
                    try {
                        CMXNetwork network = createNetwork(objs.getJSONObject(index));
                        if (network != null) {
                            networks.add(network);
                        }
                    }
                    catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
                return networks;
            }

            private CMXVenue createVenue(JSONObject obj) {
                if (obj == null)
                    return null;

                CMXVenue venue = new CMXVenue();
                venue.setId(obj.optString("venueId"));
                venue.setName(obj.optString("name"));
                venue.setStreetAddress(obj.optString("streetAddress"));
                venue.setPreferredNetworks(createNetworks(obj.optJSONArray("preferredNetwork")));
                try {
                    venue.setLocationUpdateInterval(obj.getInt("locationUpateInterval"));
                }
                catch (JSONException e) {
                    venue.setLocationUpdateInterval(Integer.parseInt(obj.optString("locationUpateInterval", "5")));
                }
                venue.setWifiMode(CMXVenue.WifiConnectionMode.valueOf(obj.optString("wifiConnectionMode").toUpperCase(Locale.getDefault())));
                return venue;
            }

            @Override
            public void onStart() {
                // Initiated the request
                if (handler != null) {
                    handler.onStart();
                }
            }

            @Override
            public void onSuccess(JSONObject obj) {
                if (CMXNetworkManager.getInstance().isConnectingToWifi()) {
                    CMXNetworkManager.getInstance().setConnectingToWifi(false);
                }
                // Successfully got a response
                CMXVenue venue = createVenue(obj);

                if (venue != null) {
                    if (handler != null) {
                        List<CMXVenue> venues = new ArrayList<CMXVenue>();
                        venues.add(venue);
                        handler.onSuccess(venues);
                    }
                }
                else {
                    if (handler != null) {
                        handler.onFailure(null); // TODO exception
                    }
                }
            }

            @Override
            public void onSuccess(JSONArray objects) {
                if (CMXNetworkManager.getInstance().isConnectingToWifi()) {
                    CMXNetworkManager.getInstance().setConnectingToWifi(false);
                }
                List<CMXVenue> venues = new ArrayList<CMXVenue>(objects.length());
                for (int index = 0; index < objects.length(); ++index) {
                    try {
                        JSONObject obj = objects.getJSONObject(index);
                        CMXVenue venue = createVenue(obj);
                        if (venue != null) {
                            venues.add(venue);
                        }
                    }
                    catch (JSONException e) {
                    }
                }
                handler.onSuccess(venues);
            }

            @Override
            public void onFailure(Throwable e, JSONObject obj) {
                if (CMXNetworkManager.getInstance().isConnectingToWifi()) {
                    internalLoadVenues(url, handler);
                } else if (handler != null) {
                    handler.onFailure(e);
                }
            }

            @Override
            public void onFailure(Throwable e) {
                if (CMXNetworkManager.getInstance().isConnectingToWifi()) {
                    internalLoadVenues(url, handler);
                } else if (handler != null) {
                    handler.onFailure(e);
                }
            }
        });
    }

    /**
     * Load venues informations
     * 
     * @param handler
     *            response handler
     */
    public void loadVenues(final CMXVenuesResponseHandler handler) {
        Assert.assertNotNull("CMXClient has not been initialized", mHTTPClient);

        internalLoadVenues(getVenuesInfosURL(), handler);
    }

    /**
     * Load informations for the given venue
     * 
     * @param venueId
     *            id of the venue
     * @param handler
     *            response handler
     */
    public void loadVenue(String venueId, final CMXVenuesResponseHandler handler) {
        Assert.assertNotNull("CMXClient has not been initialized", mHTTPClient);

        internalLoadVenues(getVenueInfosURL(venueId), handler);
    }

    /**
     * Load image for the given venue
     * 
     * @param venueId
     *            id of the venue
     * @param handler
     *            response handler
     */
    public void loadVenueImage(String venueId, final CMXImageResponseHandler handler) {
        Assert.assertNotNull("CMXClient has not been initialized", mHTTPClient);

        internalLoadImage(getVenueImageURL(venueId), 64, 64, handler);
    }

    private void internalLoadMaps(final String url, final CMXFloorsResponseHandler handler) {
        // Ask for JSON output
        mHTTPClient.get(url, new JsonHttpResponseHandler() {

            private CMXDimension createDimension(JSONObject obj) {
                CMXDimension dim = null;
                if (obj != null) {
                    dim = new CMXDimension((float) obj.optDouble("width", 0), // (float)obj.optDouble("length",
                                                                              // 0),
                            (float) obj.optDouble("length", 0), // (float)obj.optDouble("width",
                                                                // 0),
                            (float) obj.optDouble("height", 0), (float) obj.optDouble("offsetX", 0), (float) obj.optDouble("offsetY", 0), CMXDimension.Unit.valueOf(obj.optString("unit", "FEET")));
                }
                return dim;
            }

            private CMXFloor createFloor(JSONObject obj) {
                CMXFloor floor = new CMXFloor();
                floor.setId(obj.optString("floorId"));
                floor.setVenueId(obj.optString("venueid"));
                floor.setHierarchy(obj.optString("mapHierarchyString"));
                floor.setDimension(createDimension(obj.optJSONObject("dimension")));

                return floor;
            }

            @Override
            public void onStart() {
                // Initiated the request
                if (handler != null) {
                    handler.onStart();
                }
            }

            @Override
            public void onSuccess(JSONObject obj) {
                // Successfully got a response
                CMXFloor map = createFloor(obj);

                if (map != null) {
                    if (handler != null) {
                        List<CMXFloor> floors = new ArrayList<CMXFloor>();
                        floors.add(map);
                        handler.onSuccess(floors);
                    }
                }
                else {
                    if (handler != null) {
                        handler.onFailure(null); // TODO exception
                    }
                }
            }

            public void onSuccess(JSONArray objects) {
                List<CMXFloor> maps = new ArrayList<CMXFloor>(objects.length());
                for (int index = 0; index < objects.length(); ++index) {
                    try {
                        JSONObject obj = objects.getJSONObject(index);
                        CMXFloor map = createFloor(obj);
                        if (map != null) {
                            maps.add(map);
                        }
                    }
                    catch (JSONException e) {
                    }
                }
                handler.onSuccess(maps);
            }

            @Override
            public void onFailure(Throwable e, JSONObject obj) {
                if (CMXNetworkManager.getInstance().isConnectingToWifi()) {
                    internalLoadMaps(url, handler);
                } else if (handler != null) {
                    handler.onFailure(e);
                }
            }

            @Override
            public void onFailure(Throwable e) {
                if (CMXNetworkManager.getInstance().isConnectingToWifi()) {
                    internalLoadMaps(url, handler);
                } else if (handler != null) {
                    handler.onFailure(e);
                }
            }
        });
    }

    /**
     * Load all maps for the given venue
     * 
     * @param venueId
     *            id of the venue
     * @param handler
     *            response handler
     */
    public void loadMaps(String venueId, final CMXFloorsResponseHandler handler) {
        Assert.assertNotNull("CMXClient has not been initialized", mHTTPClient);

        internalLoadMaps(getMapsInfosURL(venueId), handler);
    }

    /**
     * Load floor info for the given venue
     * 
     * @param venueId
     *            id of the venue
     * @param floorId
     *            floor ID
     * @param handler
     *            response handler
     */
    public void loadFloor(String venueId, String floorId, final CMXFloorsResponseHandler handler) {
        Assert.assertNotNull("CMXClient has not been initialized", mHTTPClient);

        internalLoadMaps(getFloorInfosURL(venueId, floorId), handler);
    }

    public void internalLoadImage(final String url, final int svgWidth, final int svgHeight, final CMXImageResponseHandler handler) {

        mHTTPClient.get(url, new ImageResponseHandler() {
            @Override
            public void onStart() {
                // Initiated the request
                if (handler != null) {
                    handler.onStart();
                }
            }

            @Override
            public void onSuccess(int statusCode, Header[] headers, String content) {
                // Successfully got a response

                AsyncTask<String, Integer, Bitmap> task = new AsyncTask<String, Integer, Bitmap>() {

                    @Override
                    protected Bitmap doInBackground(String... contents) {
                        String content = contents[0];

                        try {
                            Log.d(TAG, "Start rendering SVG to bitmap");
                            SVG svg = SVG.getFromString(content);

                            // Create a canvas to draw onto
                            Bitmap bitmap = Bitmap.createBitmap(svgWidth, svgHeight, Bitmap.Config.ARGB_8888);
                            Canvas bmcanvas = new Canvas(bitmap);
                            // Render our document scaled to fit inside our
                            // canvas dimensions
                            svg.setDocumentHeight(svgWidth);
                            svg.setDocumentWidth(svgHeight);
                            svg.setDocumentPreserveAspectRatio(PreserveAspectRatio.LETTERBOX);
                            svg.renderToCanvas(bmcanvas);
                            // svg.renderToCanvas(bmcanvas, null, 96f,
                            // AspectRatioAlignment.xMidYMid,
                            // AspectRatioScale.MEET);
                            Log.d(TAG, "Finish rendering SVG to bitmap");
                            return bitmap;

                        }
                        catch (SVGParseException e) {
                            // TODO Auto-generated catch block
                            e.printStackTrace();
                        }

                        return null;
                    }

                    @Override
                    protected void onPostExecute(Bitmap bitmap) {
                        if (handler != null) {
                            handler.onSuccess(bitmap);
                        }
                    }
                };

                task.execute(content);
            }

            @Override
            public void onSuccess(byte[] imageData) {
                // Successfully got a response
                Bitmap bitmap = null;
                BitmapFactory.Options options = new BitmapFactory.Options();
                options.inSampleSize = 1;
                boolean decoding = true;
                int retryDecode = 0;
                while (imageData != null && decoding && imageData.length > 0 && retryDecode < 100) {
                    try {
                        bitmap = BitmapFactory.decodeByteArray(imageData, 0, imageData.length, options);
                        decoding = bitmap == null;
                        if (decoding) {
                            ++retryDecode;
                        } else {
                            retryDecode = 0;
                        }
                    }
                    catch (OutOfMemoryError e) {
                        options.inSampleSize *= 2;
                    }
                }

                if (handler != null) {
                    handler.onSuccess(bitmap);
                }
            }

            @Override
            public void onFailure(Throwable e) {
                // Response failed :(
                if (CMXNetworkManager.getInstance().isConnectingToWifi()) {
                    internalLoadImage(url, svgWidth, svgHeight, handler);
                } else if (handler != null) {
                    handler.onFailure(e);
                }
            }

        });

    }

    /**
     * Load floor image for the given venue
     * 
     * @param venueId
     *            id of the venue
     * @param floorId
     *            floor ID
     * @param handler
     *            reponse handler
     */
    public void loadFloorImage(String venueId, String floorId, final CMXImageResponseHandler handler) {
        Assert.assertNotNull("CMXClient has not been initialized", mHTTPClient);

        internalLoadImage(getFloorImageURL(venueId, floorId), 1024, 1024, handler);
    }

    private void internalLoadPois(final String url, final CMXPoisResponseHandler handler) {
        try {
            mHTTPClient.get(url, new JsonHttpResponseHandler() {

                @Override
                public void onStart() {
                    // Initiated the request
                    if (handler != null) {
                        handler.onStart();
                    }
                }

                @Override
                public void onSuccess(JSONArray objects) {
                    // Successfully got a response

                    List<CMXPoi> pois = new ArrayList<CMXPoi>(objects.length());
                    for (int index = 0; index < objects.length(); ++index) {
                        try {
                            JSONObject obj = objects.getJSONObject(index);

                            CMXPoi poi = new CMXPoi();

                            if (obj.has("id")) {
                                poi.setId(obj.getString("id"));
                            }

                            if (obj.has("floorid")) {
                                poi.setFloorId(obj.getString("floorid"));
                            }

                            if (obj.has("name")) {
                                poi.setName(obj.getString("name"));
                            }

                            if (obj.has("venueid")) {
                                poi.setVenueId(obj.getString("venueid"));
                            }

                            if (obj.has("imageType")) {
                                poi.setImageType(obj.getString("imageType"));
                            }

                            if (obj.has("twitterPlaceid")) {
                                poi.setTwitterPlaceId(obj.getString("twitterPlaceid"));
                            }

                            if (obj.has("facebookPlaceid")) {
                                poi.setFacebookPlaceId(obj.getString("facebookPlaceid"));
                            }

                            if (obj.has("points")) {
                                String stringPoints = obj.getString("points");
                                JSONArray objPoints = new JSONArray(stringPoints);
                                List<CMXPoint> points = new ArrayList<CMXPoint>();
                                for (int pointIndex = 0; pointIndex < objPoints.length(); ++pointIndex) {
                                    JSONObject objPoint = objPoints.optJSONObject(pointIndex);
                                    points.add(new CMXPoint((float) objPoint.getDouble("x"), (float) objPoint.getDouble("y")));
                                }
                                if (points.size() > 0) {
                                    poi.setPoints(points);
                                }
                            }

                            pois.add(poi);

                        }
                        catch (JSONException e) {
                            // TODO Auto-generated catch block
                            e.printStackTrace();
                        }

                    }

                    if (handler != null) {
                        handler.onSuccess(pois);
                    }
                }

                @Override
                public void onFailure(Throwable e, JSONObject obj) {
                    if (CMXNetworkManager.getInstance().isConnectingToWifi()) {
                        internalLoadPois(url, handler);
                    } else if (handler != null) {
                        handler.onFailure(e);
                    }
                }

                @Override
                public void onFailure(Throwable e) {
                    if (CMXNetworkManager.getInstance().isConnectingToWifi()) {
                        internalLoadPois(url, handler);
                    } else if (handler != null) {
                        handler.onFailure(e);
                    }
                }
            });
        }
        catch (Exception e) {
            if (handler != null) {
                handler.onFailure(e);
            }
        }
    }

    /**
     * Load all pois for the given venue
     * 
     * @param venueId
     *            id of the venue
     * @param handler
     *            response handler
     */
    public void loadPois(String venueId, final CMXPoisResponseHandler handler) {
        Assert.assertNotNull("CMXClient has not been initialized", mHTTPClient);

        internalLoadPois(getPoisURL(venueId), handler);
    }

    /**
     * Load pois for the given floor
     * 
     * @param venueId
     *            id of the venue
     * @param floorId
     *            floor ID
     * @param handler
     *            response handler
     */
    public void loadPois(String venueId, String floorId, final CMXPoisResponseHandler handler) {
        Assert.assertNotNull("CMXClient has not been initialized", mHTTPClient);

        internalLoadPois(getPoisURL(venueId, floorId), handler);
    }

    /**
     * Load image for the given poi
     * 
     * @param venueId
     *            id of the venue
     * @param poiId
     *            id of the poi
     * @param handler
     *            response handler
     */
    public void loadPoiImage(String venueId, String poiId, final CMXImageResponseHandler handler) {
        Assert.assertNotNull("CMXClient has not been initialized", mHTTPClient);
        internalLoadImage(getPoiImageURL(venueId, poiId), 48, 48, handler);
    }

    /**
     * Search pois infos for the given keywords
     * 
     * @param venueId
     *            id of the venue
     * @param keywords
     *            keywords of the search query
     * @param handler
     *            response handler
     */
    public void loadQuery(String venueId, String keywords, final CMXPoisResponseHandler handler) {
        Assert.assertNotNull("CMXClient has not been initialized", mHTTPClient);

        internalLoadPois(getSearchURL(venueId, keywords), handler);
    }

    /**
     * Search navigation path to go to the given poi
     * 
     * @param poiId
     *            poi ID of the destination
     * @param handler
     *            response handler
     */
    public void loadPath(String poiId, final CMXPathResponseHandler handler) {
        Assert.assertNotNull("CMXClient has not been initialized", mHTTPClient);

        try {
            mHTTPClient.get(getPathURL(poiId), new JsonHttpResponseHandler() {

                @Override
                public void onStart() {
                    // Initiated the request
                    if (handler != null) {
                        handler.onStart();
                    }
                }

                @Override
                public void onSuccess(JSONArray objects) {
                    // Successfully got a response
                    CMXPath path = new CMXPath();

                    for (int index = 0; index < objects.length(); ++index) {
                        try {
                            JSONObject obj = objects.getJSONObject(index);
                            path.add(new CMXPoint((float) obj.getDouble("x"), (float) obj.getDouble("y")));

                        }
                        catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }

                    if (handler != null) {
                        handler.onSuccess(path);
                    }
                }

                @Override
                public void onFailure(Throwable e, JSONObject obj) {
                    // Response failed :(
                    if (handler != null) {
                        handler.onFailure(e);
                    }
                }

                @Override
                public void onFailure(Throwable e) {
                    // Response failed :(
                    if (handler != null) {
                        handler.onFailure(e);
                    }
                }
            });
        }
        catch (Exception e) {
            if (handler != null) {
                handler.onFailure(e);
            }
        }
    }

    public void loadBanners(String venueId, String floorId, String zoneId, final CMXBannersResponseHandler handler) {
        Assert.assertNotNull("CMXClient has not been initialized", mHTTPClient);

        try {
            mHTTPClient.get(getBannersURL(venueId, floorId, zoneId), new JsonHttpResponseHandler() {

                @Override
                public void onStart() {
                    // Initiated the request
                    if (handler != null) {
                        handler.onStart();
                    }
                }

                @Override
                public void onSuccess(JSONArray objects) {
                    // Successfully got a response

                    List<CMXBanner> banners = new ArrayList<CMXBanner>(objects.length());
                    for (int index = 0; index < objects.length(); ++index) {
                        try {
                            JSONObject obj = objects.getJSONObject(index);

                            CMXBanner banner = new CMXBanner();

                            if (obj.has("zoneid")) {
                                banner.setZoneId(obj.getString("zoneid"));
                            }

                            if (obj.has("venueid")) {
                                banner.setVenueId(obj.getString("venueid"));
                            }

                            if (obj.has("id")) {
                                banner.setImageId(obj.getString("id"));
                            }

                            if (obj.has("imageType")) {
                                banner.setImageType(obj.getString("imageType"));
                            }

                            banners.add(banner);

                        }
                        catch (JSONException e) {
                            // TODO Auto-generated catch block
                            e.printStackTrace();
                        }

                    }

                    if (banners.size() > 0) {
                        if (handler != null) {
                            handler.onSuccess(banners);
                        }
                    }
                    else {
                        if (handler != null) {
                            handler.onFailure(null); // TODO exception
                        }
                    }
                }

                @Override
                public void onFailure(Throwable e, JSONObject obj) {
                    // Response failed :(
                    if (handler != null) {
                        handler.onFailure(e);
                    }
                }

                @Override
                public void onFailure(Throwable e) {
                    // Response failed :(
                    if (handler != null) {
                        handler.onFailure(e);
                    }
                }
            });
        }
        catch (Exception e) {
            if (handler != null) {
                handler.onFailure(e);
            }
        }
    }

    /**
     * Load image for the given banner
     * 
     * @param venueId
     *            id of the venue
     * @param poiId
     *            id of the poi
     * @param handler
     *            response handler
     */
    public void loadBannerImage(String venueId, String floorId, String zoneId, String imageId, final CMXImageResponseHandler handler) {
        Assert.assertNotNull("CMXClient has not been initialized", mHTTPClient);
        internalLoadImage(getBannerImageURL(venueId, floorId, zoneId, imageId), 320, 60, handler);
    }

    /**
     * Get the latest indoor client location.
     * 
     * @return the latest client location or null if not available
     */
    public CMXClientLocation getClientLocation() {
        return mLatestLocation;
    }

    /**
     * Load indoor user location.
     * 
     * @param handler
     *            response handler
     * @note user must have been registered in order to call this method
     */
    public void loadUserLocation(final CMXClientLocationResponseHandler handler) {
        Assert.assertNotNull("CMXClient has not been initialized", mHTTPClient);

        if (CMXClient.this.getDeviceId() != null) {
            CMXClient.this.mHTTPClient.get(getClientLocationURL(), new JsonHttpResponseHandler() {

                private CMXClientLocation createClientLocation(JSONObject obj) {
                    CMXClientLocation clientLoc = new CMXClientLocation();

                    clientLoc.setDeviceId(obj.optString("deviceId", null));
                    clientLoc.setVenueId(obj.optString("venueId", null));
                    clientLoc.setFloorId(obj.optString("floorId", null));
                    clientLoc.setZoneId(obj.optString("zoneId", null));
                    clientLoc.setZoneName(obj.optString("zoneName", null));
                    clientLoc.setLastLocationUpdateTime(obj.optLong("lastLocationUpdateTime", 0));
                    clientLoc.setLastLocationCalculationTime(obj.optLong("lastLocationCalculationTime", 0));
                    clientLoc.setMapCoordinate(createMapCoordinate(obj.optJSONObject("mapCoordinate")));
                    clientLoc.setGeoCoordinate(createGeoCoordinate(obj.optJSONObject("geoCoordinate")));

                    return clientLoc;
                }

                private CMXMapCoordinate createMapCoordinate(JSONObject obj) {
                    CMXMapCoordinate coordinates = null;
                    if (obj != null) {
                        try {
                            coordinates = new CMXMapCoordinate((float) obj.getDouble("x"), (float) obj.getDouble("y"));
                        }
                        catch (JSONException e) {
                            // TODO Auto-generated catch block
                            e.printStackTrace();
                        }
                    }
                    return coordinates;
                }

                private CMXGeoCoordinate createGeoCoordinate(JSONObject obj) {
                    CMXGeoCoordinate coordinates = null;
                    if (obj != null) {
                        try {
                            coordinates = new CMXGeoCoordinate((float) obj.getDouble("latitude"), (float) obj.getDouble("longitude"));
                        }
                        catch (JSONException e) {
                            // TODO Auto-generated catch block
                            Log.d(TAG, "Client location does not have a GEO coordinate");
                        }
                    }
                    return coordinates;
                }

                @Override
                public void onSuccess(JSONObject obj) {
                    Log.d(TAG, "Client location request successed...");

                    // Successfully got a response
                    CMXClientLocation clientLoc = createClientLocation(obj);
                    mLatestLocation = clientLoc;

                    if (handler != null) {
                        handler.onUpdate(clientLoc);
                    }
                }

                @Override
                public void onFailure(Throwable error) {
                    if (error instanceof HttpResponseException) {
                        HttpResponseException httpException = (HttpResponseException) error;
                        if (httpException.getStatusCode() == 401) {
                            resetClientRegistration();
                            registerClient(null);
                        }
                    }
                    if (handler != null) {
                        if (CMXNetworkManager.getInstance().isConnectingToWifi()) {
                        } else if (handler != null) {
                            //handler.onFailure(error);
                        }
                    }
                }

            });
        }
    }

    /**
     * Start indoor user location.
     * 
     * @param locationUpdateInterval
     *            interval in seconds between update
     * @param handler
     *            response handler
     */
    public void startUserLocationPolling(int locationUpdateInterval, final CMXClientLocationResponseHandler handler) {
        Assert.assertNotNull("CMXClient has not been initialized", mHTTPClient);

        stopUserLocationPolling();

        mLocationUpdateTimer = new Timer();
        mwifi = new CMXWifiScanner(mContext);
        mwifi.startScan(locationUpdateInterval * 1000);
        mLocationUpdateTimer.schedule(new TimerTask() {

            @Override
            public void run() {
                Log.d(TAG, "Start user location polling...");
                loadUserLocation(handler);
            }
        }, 100, locationUpdateInterval * 1000);
    }

    /**
     * Stop indoor user location
     */
    public void stopUserLocationPolling() {
        if (mLocationUpdateTimer != null) {
            mLocationUpdateTimer.cancel();
            mLocationUpdateTimer = null;
        }
        if (mwifi != null) {
            mwifi.stopScan();
            mwifi = null;
        }
    }

    public void postClientLocationFeedback(String rating, String comment, final CMXLocationFeedbackResponseHandler handler) {
        if (handler != null) {
            handler.onStart();
        }

        RequestParams params = new RequestParams();
        params.put("rating", rating);
        params.put("comment", comment);

        mHTTPClient.post(getClientLocationFeedbackURL(), params, new AsyncHttpResponseHandler() {

            // no onStart here because it's done before !!

            public void onSuccess(int statusCode, Header[] headers, String content) {

                if (handler != null) {
                    handler.onSuccess();
                }
            }

            @Override
            public void onFailure(Throwable e) {
                if (handler != null) {
                    handler.onFailure(e);
                }
            }
        });
    }

    public void postClientLocationFeedback(int x, int y, final CMXLocationFeedbackResponseHandler handler) {
        if (handler != null) {
            handler.onStart();
        }

        RequestParams params = new RequestParams();
        params.put("x", Integer.toString(x));
        params.put("y", Integer.toString(y));

        mHTTPClient.post(getClientLocationFeedbackURL(), params, new AsyncHttpResponseHandler() {

            // no onStart here because it's done before !!

            public void onSuccess(int statusCode, Header[] headers, String content) {

                if (handler != null) {
                    handler.onSuccess();
                }
            }

            @Override
            public void onFailure(Throwable e) {
                if (handler != null) {
                    handler.onFailure(e);
                }
            }
        });
    }

    /**
     * @return Application's version code from the {@code PackageManager}.
     */
    private int getAppVersion() {
        Assert.assertNotNull("CMXClient has not been initialized", mContext);

        try {
            PackageInfo packageInfo = mContext.getPackageManager().getPackageInfo(mContext.getPackageName(), 0);
            return packageInfo.versionCode;
        }
        catch (NameNotFoundException e) {
            // should never happen
            throw new RuntimeException("Could not get package name: " + e);
        }
    }

    /**
     * @return Application's {@code SharedPreferences}.
     */
    private SharedPreferences getGcmPreferences() {
        Assert.assertNotNull("CMXClient has not been initialized", mContext);

        return mContext.getSharedPreferences(CMXClient.class.getSimpleName(), Context.MODE_PRIVATE);
    }

    /**
     * Stores the registration ID and the app versionCode in the application's
     * {@code SharedPreferences}.
     * 
     * @param regId
     *            registration ID
     */
    private void storeRegistrationId(String regId) {
        final SharedPreferences prefs = getGcmPreferences();
        int appVersion = getAppVersion();
        Log.i(TAG, "Saving regId on app version " + appVersion);
        SharedPreferences.Editor editor = prefs.edit();
        editor.putString(PROPERTY_REG_ID, regId);
        editor.putInt(PROPERTY_APP_VERSION, appVersion);
        editor.commit();
    }

    /**
     * Stores the device ID in the application's {@code SharedPreferences}.
     * 
     * @param deviceId
     *            device ID
     */
    private void storeDeviceId(String deviceId) {
        final SharedPreferences prefs = getGcmPreferences();
        Log.i(TAG, "Saving device Id");
        SharedPreferences.Editor editor = prefs.edit();
        editor.putString(PROPERTY_DEVICE_ID, deviceId);
        editor.commit();
    }

    /**
     * Gets the current registration ID for application on GCM service, if there
     * is one. If result is empty, the app needs to register.
     * 
     * @return registration ID, or empty string if there is no existing
     *         registration ID.
     */
    private String getRegistrationId() {
        final SharedPreferences prefs = getGcmPreferences();
        String registrationId = prefs.getString(PROPERTY_REG_ID, "");
        if (registrationId.isEmpty()) {
            Log.i(TAG, "Registration not found.");
            return "";
        }
        // Check if app was updated; if so, it must clear the registration ID
        // since the existing regID is not guaranteed to work with the new
        // app version.
        int registeredVersion = prefs.getInt(PROPERTY_APP_VERSION, Integer.MIN_VALUE);
        int currentVersion = getAppVersion();
        if (registeredVersion != currentVersion) {
            Log.i(TAG, "App version changed.");
            return "";
        }
        return registrationId;
    }

    /**
     * Gets the device ID, if there is one. If result is empty, the app needs to
     * register.
     * 
     * @return device ID, or empty string if there is no existing device ID.
     */
    private String getDeviceId() {
        final SharedPreferences prefs = getGcmPreferences();
        String deviceId = prefs.getString(PROPERTY_DEVICE_ID, "");
        if (deviceId.isEmpty()) {
            Log.i(TAG, "Device ID not found.");
            return "";
        }
        return deviceId;
    }

    /**
     * Get MAC address of the device
     * 
     * @return MAC address of the device
     */
    private String getMacAddress() {
        Assert.assertNotNull("CMXClient has not been initialized", mContext);
        if (CMXUtils.isEmulator()) {
            return CMXStrings.CMX_SIMULATION_MAC_ADDRESS;
        }

        WifiManager wifiMgr = (WifiManager) mContext.getSystemService(Context.WIFI_SERVICE);
        WifiInfo wifiInfo = wifiMgr.getConnectionInfo();
        return wifiInfo != null ? wifiInfo.getMacAddress() : null;
    }

    /**
     * Get MAC address of the access point
     * 
     * @return MAC address of the access point
     */
    /*
     * private String getAccessPointMacAddress() {
     * Assert.assertNotNull("CMXClient has not been initialized", mContext);
     * WifiManager wifiMgr =
     * (WifiManager)mContext.getSystemService(Context.WIFI_SERVICE); WifiInfo
     * wifiInfo = wifiMgr.getConnectionInfo(); return wifiInfo.getBSSID(); }
     */

    /**
     * Get IP address of the device
     * 
     * @return IP address of the device
     */
    /*
     * private String getIPAddress() {
     * Assert.assertNotNull("CMXClient has not been initialized", mContext);
     * WifiManager wifiMgr =
     * (WifiManager)mContext.getSystemService(Context.WIFI_SERVICE); WifiInfo
     * wifiInfo = wifiMgr.getConnectionInfo(); return
     * Formatter.formatIpAddress(wifiInfo.getIpAddress()); }
     */

    /**
     * Image Handler. Will be remove with the next AsyncHTTPClient lib version.
     */
    private class ImageResponseHandler extends AsyncHttpResponseHandler {

        protected static final int SUCCESS_BINARY_MESSAGE = 100;

        private String[] mAllowedContentTypes = new String[] { "image/jpeg", "image/png", "image/gif", "image/svg\\+xml" };

        @Override
        public void sendResponseMessage(HttpResponse response) {
            StatusLine status = response.getStatusLine();
            Header[] contentTypeHeaders = response.getHeaders("Content-Type");
            if (contentTypeHeaders.length != 1) {
                // malformed/ambiguous HTTP Header, ABORT!
                byte[] responseBody = null;
                sendFailureMessage(new HttpResponseException(status.getStatusCode(), "None, or more than one, Content-Type Header found!"), responseBody);
                return;
            }
            Header contentTypeHeader = contentTypeHeaders[0];
            boolean foundAllowedContentType = false;
            for (String anAllowedContentType : mAllowedContentTypes) {
                if (Pattern.matches(anAllowedContentType, contentTypeHeader.getValue())) {
                    foundAllowedContentType = true;
                }
            }
            if (!foundAllowedContentType) {
                // Content-Type not in allowed list, ABORT!
                byte[] responseBody = null;
                sendFailureMessage(new HttpResponseException(status.getStatusCode(), "Content-Type not allowed!"), responseBody);
                return;
            }

            boolean isSVG = Pattern.matches("image/svg\\+xml", contentTypeHeader.getValue());

            if (isSVG) {
                super.sendResponseMessage(response);
            }
            else {
                byte[] responseBody = null;
                try {
                    HttpEntity entity = null;
                    HttpEntity temp = response.getEntity();
                    if (temp != null) {
                        entity = new BufferedHttpEntity(temp);
                    }
                    responseBody = EntityUtils.toByteArray(entity);
                }
                catch (IOException e) {
                    sendFailureMessage(e, (byte[]) null);
                }

                if (status.getStatusCode() >= 300) {
                    sendFailureMessage(new HttpResponseException(status.getStatusCode(), status.getReasonPhrase()), responseBody);
                }
                else {
                    sendSuccessMessage(status.getStatusCode(), responseBody);
                }
            }
        }

        protected void sendSuccessMessage(int statusCode, byte[] responseBody) {
            sendMessage(obtainMessage(SUCCESS_BINARY_MESSAGE, new Object[] { statusCode, responseBody }));
        }

        @Override
        protected void handleMessage(Message msg) {
            Object[] response;
            switch (msg.what) {
                case SUCCESS_BINARY_MESSAGE:
                    response = (Object[]) msg.obj;
                    handleSuccessMessage(((Integer) response[0]).intValue(), (byte[]) response[1]);
                    break;
                default:
                    super.handleMessage(msg);
                    break;
            }
        }

        protected void handleSuccessMessage(int statusCode, byte[] responseBody) {
            onSuccess(statusCode, responseBody);
        }

        public void onSuccess(byte[] binaryData) {
        }

        public void onSuccess(int statusCode, byte[] binaryData) {
            onSuccess(binaryData);
        }
    };
}
