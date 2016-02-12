package com.cisco.cmx.model;

import java.util.ArrayList;
import java.util.List;

import android.os.Parcel;
import android.os.Parcelable;

public class CMXVenue implements Parcelable {

    public enum WifiConnectionMode {
        AUTO, MANUAL, PROMPT
    }

    String mId;

    String mName;

    String mStreetAddress;

    List<CMXNetwork> mPreferredNetworks;

    WifiConnectionMode mWifiMode;

    int mLocationUpdateInterval;

    public CMXVenue() {
        mWifiMode = WifiConnectionMode.AUTO;
        mLocationUpdateInterval = 5;
    }

    protected CMXVenue(Parcel in) {
        mId = in.readString();
        mName = in.readString();
        mStreetAddress = in.readString();
        mPreferredNetworks = new ArrayList<CMXNetwork>();
        in.readList(mPreferredNetworks, CMXNetwork.class.getClassLoader());
        mWifiMode = WifiConnectionMode.valueOf(in.readString());
        mLocationUpdateInterval = in.readInt();
    }

    /**
     * Returns the id of the venue
     * 
     * @return id of the venue
     */
    public String getId() {
        return mId;
    }

    /**
     * Set the id of the venue
     * 
     * @param id
     *            id to set
     */
    public void setId(String id) {
        this.mId = id;
    }

    /**
     * @return
     */
    public String getName() {
        return mName;
    }

    public void setName(String name) {
        this.mName = name;
    }

    public String getStreetAddress() {
        return mStreetAddress;
    }

    public void setStreetAddress(String streetAddress) {
        this.mStreetAddress = streetAddress;
    }

    public List<CMXNetwork> getPreferredNetworks() {
        return mPreferredNetworks;
    }

    public void setPreferredNetworks(List<CMXNetwork> preferredNetworks) {
        this.mPreferredNetworks = preferredNetworks;
    }

    public int getLocationUpdateInterval() {
        return mLocationUpdateInterval;
    }

    public void setLocationUpdateInterval(int interval) {
        mLocationUpdateInterval = interval;
    }

    public WifiConnectionMode getWifiMode() {
        return mWifiMode;
    }

    public void setWifiMode(WifiConnectionMode mode) {
        mWifiMode = mode;
    }

    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(mId);
        dest.writeString(mName);
        dest.writeString(mStreetAddress);
        dest.writeList(mPreferredNetworks);
        dest.writeString(mWifiMode.name());
        dest.writeInt(mLocationUpdateInterval);
    }

    public static final Parcelable.Creator<CMXVenue> CREATOR = new Parcelable.Creator<CMXVenue>() {
        public CMXVenue createFromParcel(Parcel in) {
            return new CMXVenue(in);
        }

        public CMXVenue[] newArray(int size) {
            return new CMXVenue[size];
        }
    };

}
