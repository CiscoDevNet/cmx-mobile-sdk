package com.cisco.cmx.model;

import java.util.ArrayList;
import java.util.List;

import android.graphics.Bitmap;
import android.os.Parcel;
import android.os.Parcelable;

public class CMXPoi implements Parcelable {

    private String mFloorId;

    private String mId;

    private String mName;

    private List<CMXPoint> mPoints;

    private String mVenueId;

    private String mImageType;

    private Bitmap mImageBitmap;

    private String mFacebookPlaceId;

    private String mTwitterPlaceId;

    public CMXPoi() {
    }

    protected CMXPoi(Parcel in) {
        mId = in.readString();
        mFloorId = in.readString();
        mName = in.readString();
        mPoints = new ArrayList<CMXPoint>();
        in.readList(mPoints, CMXPoint.class.getClassLoader());
        mVenueId = in.readString();
        mImageType = in.readString();
        mFacebookPlaceId = in.readString();
        mTwitterPlaceId = in.readString();
        // mImageBitmap = in.readParcelable(CMXPoint.class.getClassLoader());
    }

    @Override
    public boolean equals(Object other) {
        if (other == null)
            return false;
        if (other == this)
            return true;
        if (!(other instanceof CMXPoi))
            return false;
        CMXPoi otherPoi = (CMXPoi) other;
        return mId.equals(otherPoi.mId);
    }

    public String getFacebookPlaceId() {
        return mFacebookPlaceId;
    }

    public void setFacebookPlaceId(String placeId) {
        this.mFacebookPlaceId = placeId;
    }

    public String getTwitterPlaceId() {
        return mTwitterPlaceId;
    }

    public void setTwitterPlaceId(String placeId) {
        this.mTwitterPlaceId = placeId;
    }

    public Bitmap getImageBitmap() {
        return mImageBitmap;
    }

    public void setImageBitmap(Bitmap bitmap) {
        this.mImageBitmap = bitmap;
    }

    public String getFloorId() {
        return mFloorId;
    }

    public void setFloorId(String floorId) {
        this.mFloorId = floorId;
    }

    public String getId() {
        return mId;
    }

    public void setId(String id) {
        this.mId = id;
    }

    public String getName() {
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

    public List<CMXPoint> getPoints() {
        return mPoints;
    }

    public void setPoints(List<CMXPoint> points) {
        this.mPoints = points;
    }

    public String getImageType() {
        return mImageType;
    }

    public void setImageType(String imageType) {
        this.mImageType = imageType;
    }

    public boolean hasImage() {
        return mImageType != null && !mImageType.equals("none");
    }

    public CMXPoint getCenter() {
        CMXPoint point = null;
        if (mPoints != null && mPoints.size() > 0) {
            float centerX = 0;
            float centerY = 0;
            for (CMXPoint p : mPoints) {
                centerX += p.getX();
                centerY += p.getY();
            }
            centerX /= mPoints.size();
            centerY /= mPoints.size();
            point = new CMXPoint(centerX, centerY);
        }
        return point;
    }

    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(mId);
        dest.writeString(mFloorId);
        dest.writeString(mName);
        dest.writeList(mPoints);
        dest.writeString(mVenueId);
        dest.writeString(mImageType);
        dest.writeString(mFacebookPlaceId);
        dest.writeString(mTwitterPlaceId);
        // dest.writeParcelable(mImageBitmap,
        // Parcelable.PARCELABLE_WRITE_RETURN_VALUE);
    }

    public static final Parcelable.Creator<CMXPoi> CREATOR = new Parcelable.Creator<CMXPoi>() {
        public CMXPoi createFromParcel(Parcel in) {
            return new CMXPoi(in);
        }

        public CMXPoi[] newArray(int size) {
            return new CMXPoi[size];
        }
    };

}
