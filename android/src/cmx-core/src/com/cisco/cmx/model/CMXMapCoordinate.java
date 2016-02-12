package com.cisco.cmx.model;

import android.os.Parcel;
import android.os.Parcelable;

public class CMXMapCoordinate implements Parcelable {

    public enum Unit {
        FEET
    };

    private float mX, mY;

    private Unit mUnit;

    protected CMXMapCoordinate(Parcel in) {
        mX = in.readFloat();
        mY = in.readFloat();
        mUnit = Unit.values()[in.readInt()];
    }

    /**
     * Constructor
     * 
     * @param x
     *            x value of the coordinate
     * @param y
     *            y value of the coordinate
     * @note default unit is FEET
     */
    public CMXMapCoordinate(float x, float y) {
        super();
        this.mX = x;
        this.mY = y;
        this.mUnit = Unit.FEET;
    }

    /**
     * Constructor
     * 
     * @param x
     *            x value of the coordinate
     * @param y
     *            y value of the coordinate
     * @note unit unit of the coordinate
     */
    public CMXMapCoordinate(float x, float y, Unit unit) {
        super();
        this.mX = x;
        this.mY = y;
        this.mUnit = unit;
    }

    @Override
    public boolean equals(Object other) {
        if (other == null)
            return false;
        if (other == this)
            return true;
        if (!(other instanceof CMXMapCoordinate))
            return false;
        CMXMapCoordinate otherCoord = (CMXMapCoordinate) other;
        return getX() == otherCoord.getX() && getY() == otherCoord.getY() && getUnit().equals(otherCoord.getUnit());
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
        dest.writeFloat(mX);
        dest.writeFloat(mY);
        dest.writeInt(mUnit.ordinal());
    }

    public static final Parcelable.Creator<CMXMapCoordinate> CREATOR = new Parcelable.Creator<CMXMapCoordinate>() {
        public CMXMapCoordinate createFromParcel(Parcel in) {
            return new CMXMapCoordinate(in);
        }

        public CMXMapCoordinate[] newArray(int size) {
            return new CMXMapCoordinate[size];
        }
    };
}
