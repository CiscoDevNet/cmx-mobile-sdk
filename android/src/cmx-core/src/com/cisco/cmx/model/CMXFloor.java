package com.cisco.cmx.model;

import android.graphics.Bitmap;
import android.os.Parcel;
import android.os.Parcelable;

public class CMXFloor implements Parcelable {

    private String mId;

    private String mName;

    private String mVenueId;

    private String mHierarchy;

    private CMXDimension mDimension;

    private Bitmap mImageBitmap;

    public CMXFloor() {
    }

    public CMXFloor(Parcel in) {
        mId = in.readString();
        mName = in.readString();
        mVenueId = in.readString();
        mHierarchy = in.readString();
        mDimension = in.readParcelable(CMXFloor.class.getClassLoader());
        // mImageBitmap = (Bitmap)
        // in.readParcelable(Bitmap.class.getClassLoader());

    }

    @Override
    public boolean equals(Object other) {
        if (other == null)
            return false;
        if (other == this)
            return true;
        if (!(other instanceof CMXFloor))
            return false;
        CMXFloor otherMap = (CMXFloor) other;
        boolean res = mId.equals(otherMap.mId);
        return res;
    }

    public Bitmap getImageBitmap() {
        return mImageBitmap;
    }

    public void setImageBitmap(Bitmap bitmap) {
        this.mImageBitmap = bitmap;
    }

    public String getId() {
        return mId;
    }

    public void setId(String id) {
        this.mId = id;
    }

    public String getName() {
        if (mName == null && mHierarchy != null) {
            String str[] = mHierarchy.split("\\>");
            if (str.length >= 2) {
                return str[str.length - 1];
            }
        }
        return mName;
    }

    public void setName(String name) {
        this.mName = name;
    }

    public String getVenueId() {
        return mVenueId;
    }

    public void setVenueId(String venueId) {
        this.mVenueId = venueId;
    }

    public String getHierarchy() {
        return mHierarchy;
    }

    public void setHierarchy(String hierarchy) {
        this.mHierarchy = hierarchy;
    }

    public CMXDimension getDimension() {
        return mDimension;
    }

    public void setDimension(CMXDimension dimension) {
        this.mDimension = dimension;
    }

    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {

        dest.writeString(mId);
        dest.writeString(mName);
        dest.writeString(mVenueId);
        dest.writeString(mHierarchy);
        dest.writeParcelable(mDimension, PARCELABLE_WRITE_RETURN_VALUE);
        // dest.writeParcelable(mImageBitmap, PARCELABLE_WRITE_RETURN_VALUE);
    }

    public static final Parcelable.Creator<CMXFloor> CREATOR = new Parcelable.Creator<CMXFloor>() {
        public CMXFloor createFromParcel(Parcel in) {
            return new CMXFloor(in);
        }

        public CMXFloor[] newArray(int size) {
            return new CMXFloor[size];
        }
    };

}
