package com.cisco.cmx.ui;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;

import com.cisco.cmx.R;
import com.cisco.cmx.model.CMXPoi;
import com.facebook.model.GraphUser;
import com.facebook.widget.LoginButton;

public class CMXPoiActivity extends CMXShareActivity {

    public static String ACTION = "com.cisco.cmx.action.POI";

    public static String EXTRA_POI = "POI";

    public static String EXTRA_IMAGE = "IMAGE";

    public static String EXTRA_IMAGE_URL = "IMAGE_URL";

    public static int RESULT_GO_TO = 1000;

    private ImageView poiImage;

    //private ImageButton poiShare;

    private ImageButton poiGoTo;

    private TextView poiTitle;

    private Bitmap poiImageBitmap;

    private CMXPoi mPoi;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.cmx_poi_layout);

        poiImage = (ImageView) findViewById(R.id.cmx_poi_title_image);
        //poiShare = (ImageButton) findViewById(R.id.cmx_poi_share_button);
        poiGoTo = (ImageButton) findViewById(R.id.cmx_poi_goto_button);
        poiTitle = (TextView) findViewById(R.id.cmx_poi_title);

        /**poiShare.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                // share();
                sharePlaceId();
            }
        }); **/

        poiGoTo.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                goTo();
            }
        });

        // Recover data
        Bundle extras = getIntent().getExtras();
        mPoi = extras.getParcelable(EXTRA_POI);
        poiImageBitmap = extras.getParcelable(EXTRA_IMAGE);
        extras.getString(EXTRA_IMAGE_URL);

        poiImage.setImageBitmap(poiImageBitmap);
        poiTitle.setText(mPoi.getName());

        mLoginButton = (LoginButton) findViewById(R.id.cmx_poi_login_button);

        // setUserInfoChangedCallback is used to know if the connection has been
        // closed / opened
        mLoginButton.setUserInfoChangedCallback(new LoginButton.UserInfoChangedCallback() {
            @Override
            public void onUserInfoFetched(GraphUser user) {
                CMXPoiActivity.this.mUser = user;
                updateUI();
                handlePendingAction();
            }
        });
    }

    /**
     * Shares the current poi on twitter or/and facebook if place ids exist
     */
    private void sharePlaceId() {
        final CharSequence[] items;

        String titlePopUp = getResources().getString(R.string.cmx_poi_share_title);
        String facebook = getResources().getString(R.string.cmx_poi_share_facebook);
        String twitter = getResources().getString(R.string.cmx_poi_share_twitter);

        if (mPoi.getFacebookPlaceId() != null && mPoi.getTwitterPlaceId() != null && !getResources().getString(R.string.cmx_poi_share_facebook_app_id).equals("") && !getResources().getString(R.string.cmx_poi_share_twitter_consummer_key).equals("")
                && !getResources().getString(R.string.cmx_poi_share_twitter_consummer_secret).equals("")) {
            items = new CharSequence[2];
            items[0] = facebook;
            items[1] = twitter;
        }
        else if (mPoi.getFacebookPlaceId() != null && !getResources().getString(R.string.cmx_poi_share_facebook_app_id).equals("")) {
            items = new CharSequence[2];
            items[0] = facebook;
        }
        else if (mPoi.getTwitterPlaceId() != null && !getResources().getString(R.string.cmx_poi_share_twitter_consummer_key).equals("") && !getResources().getString(R.string.cmx_poi_share_twitter_consummer_secret).equals("")) {
            items = new CharSequence[2];
            items[0] = twitter;
        }
        else {
            return;
        }

        AlertDialog.Builder builder = new AlertDialog.Builder(this);

        builder.setTitle(titlePopUp);
        builder.setItems(items, new DialogInterface.OnClickListener() {

            public void onClick(DialogInterface dialog, int item) {
                if (items[item].toString().equals(getResources().getString(R.string.cmx_poi_share_facebook))) {
                    shareFacebook(null, null, getResources().getString(R.string.app_name), null, mPoi.getFacebookPlaceId());
                }
                if (items[item].toString().equals(getResources().getString(R.string.cmx_poi_share_twitter))) {
                    shareTwitter(getResources().getString(R.string.cmx_checkin_twitter_message), null, null, mPoi.getTwitterPlaceId());
                }
            }

        });

        AlertDialog alert = builder.create();

        alert.show();
    }

    /**
     * Sets the poi as the target destination, and finish the activity
     */
    private void goTo() {
        Intent resultIntent = new Intent();
        resultIntent.putExtra(EXTRA_POI, mPoi);
        setResult(RESULT_GO_TO, resultIntent);
        finish();
    }
}
