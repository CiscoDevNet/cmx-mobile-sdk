package com.cisco.cmx.model;

import android.os.Parcel;
import android.os.Parcelable;

public class CMXPoint implements Parcelable {

    private float mX, mY;

    public CMXPoint(float x, float y) {
        super();
        this.mX = x;
        this.mY = y;
    }

    protected CMXPoint(Parcel in) {
        mX = in.readFloat();
        mY = in.readFloat();
    }

    public float getX() {
        return mX;
    }

    public void setX(float x) {
        this.mX = x;
    }

    public float getY() {
        return mY;
    }

    public void setY(float y) {
        this.mY = y;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeFloat(mX);
        dest.writeFloat(mY);
    }

    public static final Parcelable.Creator<CMXPoint> CREATOR = new Parcelable.Creator<CMXPoint>() {
        public CMXPoint createFromParcel(Parcel in) {
            return new CMXPoint(in);
        }

        public CMXPoint[] newArray(int size) {
            return new CMXPoint[size];
        }
    };

}
