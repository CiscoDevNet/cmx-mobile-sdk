package com.cisco.cmx.model;

import android.os.Parcel;
import android.os.Parcelable;

public class CMXGeoCoordinate implements Parcelable {

    private double mLatitude, mLongitude;

    protected CMXGeoCoordinate(Parcel in) {
        mLatitude = in.readFloat();
        mLongitude = in.readFloat();
    }

    /**
     * Constructor
     * 
     * @param latitude
     *            latitude value of the coordinate
     * @param longitude
     *            longitude value of the coordinate
     */
    public CMXGeoCoordinate(float latitude, float longitude) {
        super();
        this.mLatitude = latitude;
        this.mLongitude = longitude;
    }

    @Override
    public boolean equals(Object other) {
        if (other == null)
            return false;
        if (other == this)
            return true;
        if (!(other instanceof CMXGeoCoordinate))
            return false;
        CMXGeoCoordinate otherCoord = (CMXGeoCoordinate) other;
        return getLongitude() == otherCoord.getLongitude() && getLatitude() == otherCoord.getLatitude();
    }

    public double getLongitude() {
        return mLongitude;
    }

    public void setLongitude(float longitude) {
        this.mLongitude = longitude;
    }

    public double getLatitude() {
        return mLatitude;
    }

    public void setLatitude(float latitude) {
        this.mLatitude = latitude;
    }

    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeDouble(mLatitude);
        dest.writeDouble(mLongitude);
    }

    public static final Parcelable.Creator<CMXGeoCoordinate> CREATOR = new Parcelable.Creator<CMXGeoCoordinate>() {
        public CMXGeoCoordinate createFromParcel(Parcel in) {
            return new CMXGeoCoordinate(in);
        }

        public CMXGeoCoordinate[] newArray(int size) {
            return new CMXGeoCoordinate[size];
        }
    };
}
