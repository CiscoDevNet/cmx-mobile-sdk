package com.cisco.cmx.model;

import android.os.Parcel;
import android.os.Parcelable;

public class CMXDimension implements Parcelable {

    public enum Unit {
        FEET
    };

    private float mLength;

    private float mWidth;

    private float mHeight;

    private float mOffsetX;

    private float mOffsetY;

    private Unit mUnit;

    public CMXDimension(float length, float width, float height, float offsetX, float offsetY, Unit unit) {
        super();
        this.mLength = length;
        this.mWidth = width;
        this.mHeight = height;
        this.mOffsetX = offsetX;
        this.mOffsetY = offsetY;
        this.mUnit = unit;
    }

    public CMXDimension(Parcel in) {
        mLength = in.readFloat();
        mWidth = in.readFloat();
        mHeight = in.readFloat();
        mOffsetX = in.readFloat();
        mOffsetY = in.readFloat();
        mUnit = Unit.values()[in.readInt()];
    }

    public float getLength() {
        return mLength;
    }

    public void setLength(float length) {
        this.mLength = length;
    }

    public float getWidth() {
        return mWidth;
    }

    public void setWidth(float width) {
        this.mWidth = width;
    }

    public float getHeight() {
        return mHeight;
    }

    public void setHeight(float height) {
        this.mHeight = height;
    }

    public float getOffsetX() {
        return mOffsetX;
    }

    public void setOffsetX(float offsetX) {
        this.mOffsetX = offsetX;
    }

    public float getOffsetY() {
        return mOffsetY;
    }

    public void setOffsetY(float offsetY) {
        this.mOffsetY = offsetY;
    }

    public Unit getUnit() {
        return mUnit;
    }

    public void setUnit(Unit unit) {
        this.mUnit = unit;
    }

    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeFloat(mLength);
        dest.writeFloat(mWidth);
        dest.writeFloat(mHeight);
        dest.writeFloat(mOffsetX);
        dest.writeFloat(mOffsetY);
        dest.writeInt(mUnit.ordinal());
    }

    public static final Parcelable.Creator<CMXDimension> CREATOR = new Parcelable.Creator<CMXDimension>() {
        public CMXDimension createFromParcel(Parcel in) {
            return new CMXDimension(in);
        }

        public CMXDimension[] newArray(int size) {
            return new CMXDimension[size];
        }
    };

}
