package com.cisco.cmx.model;

import android.os.Parcel;
import android.os.Parcelable;

public class CMXNetwork implements Parcelable {

    private String mSSID;

    private String mPassword;

    public CMXNetwork(String SSID, String password) {
        this.mSSID = SSID;
        this.mPassword = password;
    }

    protected CMXNetwork(Parcel in) {
        mSSID = in.readString();
        mPassword = in.readString();
    }

    public String getSSID() {
        return mSSID;
        // return "OvhOrpheo";
    }

    public String getPassword() {
        return mPassword;
        // return "gratianopolis";
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(mSSID);
        dest.writeString(mPassword);
    }

    public static final Parcelable.Creator<CMXNetwork> CREATOR = new Parcelable.Creator<CMXNetwork>() {
        public CMXNetwork createFromParcel(Parcel in) {
            return new CMXNetwork(in);
        }

        public CMXNetwork[] newArray(int size) {
            return new CMXNetwork[size];
        }
    };

}
