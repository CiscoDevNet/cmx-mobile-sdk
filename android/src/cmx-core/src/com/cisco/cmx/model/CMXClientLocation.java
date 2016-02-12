package com.cisco.cmx.model;

import android.os.Parcel;
import android.os.Parcelable;

public class CMXClientLocation implements Parcelable {

    private String mDeviceId;

    private String mVenueId;

    private String mFloorId;

    private String mZoneId;
    
    private String mZoneName;
    
    private long mLastLocationUpdateTime;
    
    private long mLastLocationCalculationTime;

    private CMXMapCoordinate mMapCoordinate;

    private CMXGeoCoordinate mGeoCoordinate;

    public CMXClientLocation() {
    }

    public CMXClientLocation(Parcel in) {
        mDeviceId = in.readString();
        mVenueId = in.readString();
        mFloorId = in.readString();
        mZoneId = in.readString();
        mZoneName = in.readString();
        mLastLocationUpdateTime = in.readLong();
        mLastLocationCalculationTime = in.readLong();
        mMapCoordinate = (CMXMapCoordinate) in.readParcelable(CMXMapCoordinate.class.getClassLoader());
        mGeoCoordinate = (CMXGeoCoordinate) in.readParcelable(CMXGeoCoordinate.class.getClassLoader());
    }

    public String getDeviceId() {
        return mDeviceId;
    }

    public void setDeviceId(String deviceId) {
        this.mDeviceId = deviceId;
    }

    public String getVenueId() {
        return mVenueId;
    }

    public void setVenueId(String venueId) {
        this.mVenueId = venueId;
    }

    public String getFloorId() {
        return mFloorId;
    }

    public void setFloorId(String floorId) {
        this.mFloorId = floorId;
    }

    public String getZoneId() {
        return mZoneId;
    }

    public void setZoneId(String zoneId) {
        this.mZoneId = zoneId;
    }

    public String getZoneName() {
        return mZoneName;
    }

    public void setZoneName(String zoneName) {
        this.mZoneName = zoneName;
    }

    public long getLastLocationUpdateTime() {
        return mLastLocationUpdateTime;
    }

    public void setLastLocationUpdateTime(long lastLocationUpdateTime) {
        this.mLastLocationUpdateTime = lastLocationUpdateTime;
    }

    public long getLastLocationCalculationTime() {
        return mLastLocationCalculationTime;
    }

    public void setLastLocationCalculationTime(long lastLocationCalculationTime) {
        this.mLastLocationCalculationTime = lastLocationCalculationTime;
    }

    public CMXMapCoordinate getMapCoordinate() {
        return mMapCoordinate;
    }

    public void setMapCoordinate(CMXMapCoordinate coordinate) {
        this.mMapCoordinate = coordinate;
    }

    public CMXGeoCoordinate getGeoCoordinate() {
        return mGeoCoordinate;
    }

    public void setGeoCoordinate(CMXGeoCoordinate coordinate) {
        this.mGeoCoordinate = coordinate;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel out, int flags) {
        out.writeString(mDeviceId);
        out.writeString(mVenueId);
        out.writeString(mFloorId);
        out.writeString(mZoneId);
        out.writeString(mZoneName);
        out.writeLong(mLastLocationUpdateTime);
        out.writeLong(mLastLocationCalculationTime);
        out.writeParcelable(mMapCoordinate, flags);
        out.writeParcelable(mGeoCoordinate, flags);
    }

    // this is used to regenerate your object. All Parcelables must have a
    // CREATOR that implements these two methods
    public static final Parcelable.Creator<CMXClientLocation> CREATOR = new Parcelable.Creator<CMXClientLocation>() {
        public CMXClientLocation createFromParcel(Parcel in) {
            return new CMXClientLocation(in);
        }

        public CMXClientLocation[] newArray(int size) {
            return new CMXClientLocation[size];
        }
    };
}
