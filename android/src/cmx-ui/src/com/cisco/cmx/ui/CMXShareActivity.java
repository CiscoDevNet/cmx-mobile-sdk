package com.cisco.cmx.ui;

import java.io.File;

import twitter4j.StatusUpdate;
import twitter4j.Twitter;
import twitter4j.TwitterException;
import twitter4j.TwitterFactory;
import twitter4j.auth.AccessToken;
import twitter4j.auth.RequestToken;
import twitter4j.conf.Configuration;
import twitter4j.conf.ConfigurationBuilder;
import android.app.Activity;
import android.app.Dialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Toast;

import com.cisco.cmx.R;
import com.facebook.AppEventsLogger;
import com.facebook.FacebookAuthorizationException;
import com.facebook.FacebookOperationCanceledException;
import com.facebook.HttpMethod;
import com.facebook.Request;
import com.facebook.Response;
import com.facebook.Session;
import com.facebook.SessionState;
import com.facebook.UiLifecycleHelper;
import com.facebook.model.GraphUser;
import com.facebook.widget.LoginButton;

/**
 * The activity which takes in charge facebook/twitter sharing
 */
public class CMXShareActivity extends Activity {

    // Login button needed to log in with a facebook account
    protected LoginButton mLoginButton;

    // This button is needed to performs the onclick event of mLoginButton
    LoginButton mHolderLoginButton;

    // Dialog containing the login button
    Dialog mLoginDialog;

    // Helper to manage the active connection
    private UiLifecycleHelper mUIHelper;

    // Pending action
    private enum PendingAction {
        NONE, POST_STATUS_UPDATE
    }

    // Permission needed: publish
    private static final String PERMISSION = "publish_actions";

    // Pending action bundle key
    private final String PENDING_ACTION_BUNDLE_KEY = "PENDING_ACTION";

    // Current pending action
    private PendingAction mPendingAction = PendingAction.NONE;

    // Current facebook user
    protected GraphUser mUser;

    // What to share on facebook
    private String mMessageFacebook, mLinkFacebook, mNameFacebook, mPictureFacebook, mPlaceIdFacebook;

    // Twitter parameters
    private String TWITTER_CONSUMER_KEY;

    private String TWITTER_CONSUMER_SECRET;

    private final String PREF_KEY_OAUTH_TOKEN = "oauth_token";

    private final String PREF_KEY_OAUTH_SECRET = "oauth_token_secret";

    private final String PREF_KEY_TWITTER_LOGIN = "isTwitterLogedIn";

    private final String TWITTER_CALLBACK_URL = "oauth://cmxcallback";

    private final String URL_TWITTER_OAUTH_VERIFIER = "oauth_verifier";

    // Twitter instance
    private Twitter mTwitterInstance;

    // Twitter token for aouth
    private RequestToken mRequestToken;

    // Token will be saved in shared preferences
    private SharedPreferences mSharedPreferences;

    // What to share on twitter
    private String mMessageTwitter, mLinkTwitter, mPictureTwitter, mPlaceIdTwitter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (savedInstanceState != null) {
            String name = savedInstanceState.getString(PENDING_ACTION_BUNDLE_KEY);
            mPendingAction = PendingAction.valueOf(name);
        }

        // get Twitter parameters from strings.xml
        TWITTER_CONSUMER_KEY = getResources().getString(R.string.cmx_poi_share_twitter_consummer_key);
        TWITTER_CONSUMER_SECRET = getResources().getString(R.string.cmx_poi_share_twitter_consummer_secret);

        // UI Helper for facebook
        mUIHelper = new UiLifecycleHelper(this, callback);
        mUIHelper.onCreate(savedInstanceState);

        // Twitter connection is saved into prefs
        mSharedPreferences = getApplicationContext().getSharedPreferences("MyPref", 0);

    }

    /**
     * On new intent received (from twitter permission page)
     */
    @Override
    protected void onNewIntent(final Intent intent) {

        if (intent.getData().getQueryParameter("oauth_verifier") != null) {
            GetOAuthSaveInPrefTweets get = new GetOAuthSaveInPrefTweets(intent.getData());
            get.execute();
        }
    }

    /**
     * Share on twitter
     * 
     * @param message
     *            the message to share
     * @param link
     *            optional, add a link
     * @param picture
     *            optional, add a picture
     * @param placeId
     *            optional, place id (check-in)
     */
    protected void shareTwitter(String message, String link, String picture, String placeId) {
        mMessageTwitter = message;
        mLinkTwitter = link;
        mPictureTwitter = picture;
        mPlaceIdTwitter = placeId;
        loginToTwitter();
    }

    /**
     * Share on facebook
     * 
     * @param message
     *            the message to share
     * @param link
     *            optional, add a link
     * @param name
     *            application name
     * @param picture
     *            optional, add a picture
     * @param placeId
     *            optional, place id (check-in)
     */
    protected void shareFacebook(String message, String link, String name, String picture, String placeId) {

        mMessageFacebook = message;
        mLinkFacebook = link;
        mNameFacebook = name;
        mPictureFacebook = picture;
        mPlaceIdFacebook = placeId;

        mLoginDialog = new Dialog(CMXShareActivity.this);
        mLoginDialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        mLoginDialog.setContentView(R.layout.cmx_share_login_dialog);

        mHolderLoginButton = (LoginButton) mLoginDialog.findViewById(R.id.cmx_share_dialog_login_button);

        updateUI();

        if (mHolderLoginButton.getVisibility() == View.INVISIBLE) {
            performPublish(PendingAction.POST_STATUS_UPDATE/*
                                                            * ,
                                                            * canPresentShareDialog
                                                            */);
        }
        else {

            mHolderLoginButton.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    mLoginButton.performClick();
                }
            });
            mLoginDialog.setCancelable(true);
            mLoginDialog.setTitle(getResources().getString(R.string.cmx_share_dialog_title));
            mLoginDialog.setCanceledOnTouchOutside(true);
            mLoginDialog.show();

        }

    }

    /**
     * Status callback when facebook session change
     */
    protected Session.StatusCallback callback = new Session.StatusCallback() {
        @Override
        public void call(Session session, SessionState state, Exception exception) {
            onSessionStateChange(session, state, exception);
        }
    };

    /**
     * onActivityResult, update the facebook UIHelper called after enter new
     * facebook login
     */
    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        Session.getActiveSession().onActivityResult(this, requestCode, resultCode, data);
        mUIHelper.onActivityResult(requestCode, resultCode, data);
    }

    /**
     * Handler pending facebook action (need if a post must be send)
     */
    @SuppressWarnings("incomplete-switch")
    protected void handlePendingAction() {
        PendingAction previouslyPendingAction = mPendingAction;
        // These actions may re-set pendingAction if they are still pending, but
        // we assume they
        // will succeed.
        mPendingAction = PendingAction.NONE;

        switch (previouslyPendingAction) {
            case POST_STATUS_UPDATE:
                postStatusUpdate();
                break;
        }
    }

    /**
     * Check if active current facebook session has publish permission
     * 
     * @return true if current session has publish permission, false otherwise
     */
    protected boolean hasPublishPermission() {
        Session session = Session.getActiveSession();
        return session != null && session.getPermissions().contains("publish_actions");
    }

    /**
     * Perform the facebook publication
     * 
     * @param action
     *            current pending action
     */
    protected void performPublish(PendingAction action) {
        Session session = Session.getActiveSession();

        Toast.makeText(CMXShareActivity.this, getResources().getString(R.string.cmx_poi_share_start_publish), Toast.LENGTH_SHORT).show();

        if (session != null) {

            mPendingAction = action;
            if (hasPublishPermission()) {
                // We can do the action right away.
                handlePendingAction();
                return;
            }
            else if (session.isOpened()) {

                // We need to get new permissions, then complete the action when
                // we get called back.
                session.requestNewPublishPermissions(new Session.NewPermissionsRequest(this, PERMISSION));
                return;
            }
            else {
                Toast.makeText(CMXShareActivity.this, "you must login before", Toast.LENGTH_SHORT).show();
            }
        }
        else {
            Toast.makeText(CMXShareActivity.this, "you must login before", Toast.LENGTH_SHORT).show();
        }

    }

    /**
     * Post on current facebook user wall if he has the right permission
     */
    protected void postStatusUpdate() {
        if (mUser != null && hasPublishPermission()) {

            Bundle bundle = new Bundle();
            bundle.putString("message", mMessageFacebook);
            bundle.putString("link", mLinkFacebook);
            bundle.putString("name", mNameFacebook);
            if (mPictureFacebook != null)
                bundle.putString("picture", mPictureFacebook);
            if (mPlaceIdFacebook != null)
                bundle.putString("place", mPlaceIdFacebook);

            Request request = new Request(Session.getActiveSession(), "me/feed", bundle, HttpMethod.POST);
            request.setCallback(new Request.Callback() {
                @Override
                public void onCompleted(Response response) {
                    if (response.getError() == null) {
                        Toast.makeText(CMXShareActivity.this, getResources().getString(R.string.cmx_poi_share_facebook_succeed), Toast.LENGTH_SHORT).show();
                    }
                    else {
                        Log.e("DEBUG", "Error: " + response.getError().getErrorMessage());
                        if (response.getError().getErrorMessage().contains("#200")) {
                            Session.getActiveSession().closeAndClearTokenInformation();
                            Toast.makeText(CMXShareActivity.this, "Active session seems to have permission to publish but it's not the case anymore. Access token has been removed, please retry", Toast.LENGTH_LONG).show();

                        }
                        else {
                            Toast.makeText(CMXShareActivity.this, getResources().getString(R.string.cmx_poi_share_facebook_failed) + " " + response.getError().getErrorMessage(), Toast.LENGTH_LONG).show();
                        }

                    }
                }
            });
            request.executeAsync();
        }
        else {
            mPendingAction = PendingAction.POST_STATUS_UPDATE;
        }
    }

    /**
     * updateUI, needed to see if user must to login or if he can directly
     * perform the publication
     */
    protected void updateUI() {
        Session session = Session.getActiveSession();
        boolean enableButtons = (session != null && session.isOpened());
        if (enableButtons && mUser != null) {
            if (mHolderLoginButton != null) {
                mHolderLoginButton.setVisibility(View.INVISIBLE);

            }
            if (mLoginDialog != null && mLoginDialog.isShowing()) {
                performPublish(PendingAction.POST_STATUS_UPDATE/*
                                                                * ,
                                                                * canPresentShareDialog
                                                                */);
                mLoginDialog.dismiss();
            }
        }
        else {
            if (mHolderLoginButton != null) {
                mHolderLoginButton.setVisibility(View.VISIBLE);
            }
        }
    }

    /**
     * When the facebook session status changed
     * 
     * @param session
     *            a facebook session
     * @param state
     *            sate of the session
     * @param exception
     *            exception if an error occurred
     */
    protected void onSessionStateChange(Session session, SessionState state, Exception exception) {
        if (mPendingAction != PendingAction.NONE && (exception instanceof FacebookOperationCanceledException || exception instanceof FacebookAuthorizationException)) {
            Log.e("DEBUG", "Error");
            if (exception != null) {
                Log.e("DEBUG", "ERROR: " + exception.getMessage());
            }
            mPendingAction = PendingAction.NONE;
        }
        else if (state == SessionState.OPENED_TOKEN_UPDATED) {
            handlePendingAction();
        }
        updateUI();
    }

    @Override
    public void onResume() {
        super.onResume();
        mUIHelper.onResume();
        AppEventsLogger.activateApp(this);
        updateUI();
    }

    @Override
    public void onPause() {
        super.onPause();
        mUIHelper.onPause();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        mUIHelper.onDestroy();
    }

    /**
     * Save the current handler pending action
     */
    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        mUIHelper.onSaveInstanceState(outState);
        outState.putString(PENDING_ACTION_BUNDLE_KEY, mPendingAction.name());
    }

    /**
     * Tweets
     */
    private void updateStatusTwitter() {

        String text = mMessageTwitter + "\n";
        if (mLinkTwitter != null)
            text += mLinkTwitter + " \n";
        String imagePath = mPictureTwitter;

        StatusUpdate status = new StatusUpdate(text);

        if (imagePath != null)
            status.setMedia(new File(imagePath));
        if (mPlaceIdTwitter != null) {
            status.setPlaceId(mPlaceIdTwitter);
        }

        new updateTwitterStatus(status).execute();
    }

    /**
     * Login to twitter, if user isn't already logged, request a new oauth token
     */
    private void loginToTwitter() {

        // Check if already logged in
        if (!isTwitterLoggedInAlready()) {
            Thread thread = new Thread(new Runnable() {
                @Override
                public void run() {
                    ConfigurationBuilder builder = new ConfigurationBuilder();
                    builder.setOAuthConsumerKey(TWITTER_CONSUMER_KEY);
                    builder.setOAuthConsumerSecret(TWITTER_CONSUMER_SECRET);
                    Configuration configuration = builder.build();

                    TwitterFactory factory = new TwitterFactory(configuration);
                    mTwitterInstance = factory.getInstance();

                    try {
                        mRequestToken = mTwitterInstance.getOAuthRequestToken(TWITTER_CALLBACK_URL);
                        Intent twitwi = new Intent(Intent.ACTION_VIEW, Uri.parse(mRequestToken.getAuthenticationURL()));
                        startActivity(twitwi);

                    }
                    catch (TwitterException e) {
                        e.printStackTrace();
                    }
                }
            });
            thread.start();
        }
        else {

            Toast.makeText(getApplicationContext(), getResources().getString(R.string.cmx_poi_share_start_publish), Toast.LENGTH_SHORT).show();

            // user already logged into twitter
            updateStatusTwitter();
        }
    }

    /**
     * Check user already logged in your application using twitter Login flag is
     * fetched from Shared Preferences
     */
    private boolean isTwitterLoggedInAlready() {
        // return twitter login status from Shared Preferences
        return mSharedPreferences.getBoolean(PREF_KEY_TWITTER_LOGIN, false);
    }

    /**
     * Update the status (tweets) asynchronously
     */
    class updateTwitterStatus extends AsyncTask<String, String, String> {

        private String error = null;

        private StatusUpdate status;

        public updateTwitterStatus(StatusUpdate status) {
            this.status = status;
        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
        }

        protected String doInBackground(String... args) {
            try {
                ConfigurationBuilder builder = new ConfigurationBuilder();
                builder.setOAuthConsumerKey(TWITTER_CONSUMER_KEY);
                builder.setOAuthConsumerSecret(TWITTER_CONSUMER_SECRET);

                // Access Token
                String access_token = mSharedPreferences.getString(PREF_KEY_OAUTH_TOKEN, "");
                // Access Token Secret
                String access_token_secret = mSharedPreferences.getString(PREF_KEY_OAUTH_SECRET, "");

                AccessToken accessToken = new AccessToken(access_token, access_token_secret);
                Twitter twitter = new TwitterFactory(builder.build()).getInstance(accessToken);

                // Update status
                twitter4j.Status response = twitter.updateStatus(status);

                Log.e("Status", "> " + response.getText());
            }
            catch (TwitterException e) {
                // Error in updating status
                Log.e("Twitter Update Error", e.getMessage());
                error = e.getMessage();

            }
            return null;
        }

        protected void onPostExecute(String file_url) {

            // updating UI from Background Thread
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if (error == null)
                        Toast.makeText(getApplicationContext(), getResources().getString(R.string.cmx_poi_share_twitter_succeed), Toast.LENGTH_SHORT).show();
                    else
                        Toast.makeText(getApplicationContext(), getResources().getString(R.string.cmx_poi_share_twitter_failed) + " " + error, Toast.LENGTH_LONG).show();
                }
            });
        }
    }

    /**
     * Get the oauth from the uri (received from onNewIntent) If valid, saves it
     * in shared preferences then update twitter status (tweets)
     */
    class GetOAuthSaveInPrefTweets extends AsyncTask<String, String, String> {

        private boolean noUpdate = false;

        private Uri uri;

        public GetOAuthSaveInPrefTweets(Uri uri) {
            this.uri = uri;
        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
        }

        protected String doInBackground(String... args) {
            if (!isTwitterLoggedInAlready()) {
                // Uri uri = ((MenuActivity) menuActivity).getData();
                if (uri != null && uri.toString().startsWith(TWITTER_CALLBACK_URL)) {
                    // oAuth verifier
                    String verifier = uri.getQueryParameter(URL_TWITTER_OAUTH_VERIFIER);

                    try {
                        // Get the access token
                        AccessToken accessToken = mTwitterInstance.getOAuthAccessToken(mRequestToken, verifier);

                        // Shared Preferences
                        Editor e = mSharedPreferences.edit();

                        // After getting access token, access token secret
                        // store them in application preferences
                        e.putString(PREF_KEY_OAUTH_TOKEN, accessToken.getToken());
                        e.putString(PREF_KEY_OAUTH_SECRET, accessToken.getTokenSecret());
                        // Store login status - true
                        e.putBoolean(PREF_KEY_TWITTER_LOGIN, true);
                        e.commit(); // save changes

                        Log.e("Twitter OAuth Token", "teken 4 > " + accessToken.getToken());

                        // Displaying in xml ui
                    }
                    catch (Exception e) {
                        // Check log for login errors
                        noUpdate = true;
                        e.printStackTrace();
                        Log.e("Twitter Login Error", "> " + e.getMessage());
                    }
                }
                else {
                    noUpdate = true;
                }
            }
            else {
                noUpdate = true;
            }
            return null;
        }

        protected void onPostExecute(String file_url) {
            if (!noUpdate)
                updateStatusTwitter();
        }
    }

}
