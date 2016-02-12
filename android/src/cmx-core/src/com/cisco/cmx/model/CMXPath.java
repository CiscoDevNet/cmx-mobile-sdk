package com.cisco.cmx.model;

import java.util.ArrayList;
import java.util.List;

public class CMXPath {

    private List<CMXPoint> mPoints = new ArrayList<CMXPoint>();

    public void add(CMXPoint point) {
        mPoints.add(point);
    }

    public List<CMXPoint> getPoints() {
        return mPoints;
    }
}
