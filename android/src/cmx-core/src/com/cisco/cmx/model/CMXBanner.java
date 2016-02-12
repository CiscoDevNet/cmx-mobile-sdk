package com.cisco.cmx.model;

import android.os.Parcel;
import android.os.Parcelable;

public class CMXBanner implements Parcelable {

    String mZoneId;

    String mVenueId;

    String mImageId;

    String mImageType;

    public CMXBanner() {
    }

    public CMXBanner(Parcel in) {
        mZoneId = in.readString();
        mVenueId = in.readString();
        mImageId = in.readString();
        mImageType = in.readString();
    }

    @Override
    public boolean equals(Object other) {
        if (other == null)
            return false;
        if (other == this)
            return true;
        if (!(other instanceof CMXBanner))
            return false;
        CMXBanner otherBanner = (CMXBanner) other;
        boolean res = mImageId.equals(otherBanner.mImageId);
        return res;
    }

    public String getZoneId() {
        return mZoneId;
    }

    public void setZoneId(String zoneId) {
        this.mZoneId = zoneId;
    }

    public String getVenueId() {
        return mVenueId;
    }

    public void setVenueId(String venueId) {
        this.mVenueId = venueId;
    }

    public String getImageId() {
        return mImageId;
    }

    public void setImageId(String imageId) {
        this.mImageId = imageId;
    }

    public String getImageType() {
        return mImageType;
    }

    public void setImageType(String imageType) {
        this.mImageType = imageType;
    }

    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {

        dest.writeString(mZoneId);
        dest.writeString(mVenueId);
        dest.writeString(mImageId);
        dest.writeString(mImageType);
    }

    public static final Parcelable.Creator<CMXBanner> CREATOR = new Parcelable.Creator<CMXBanner>() {
        public CMXBanner createFromParcel(Parcel in) {
            return new CMXBanner(in);
        }

        public CMXBanner[] newArray(int size) {
            return new CMXBanner[size];
        }
    };
}
