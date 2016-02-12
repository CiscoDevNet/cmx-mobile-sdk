package com.cisco.cmx.ui;

import com.cisco.cmx.R;

import android.os.Bundle;
import android.preference.PreferenceActivity;

public class CMXSettingsActivity extends PreferenceActivity {

    public static String ACTION = "com.cisco.cmx.action.SETTINGS";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        addPreferencesFromResource(R.xml.cmx_settings);
    }
}
