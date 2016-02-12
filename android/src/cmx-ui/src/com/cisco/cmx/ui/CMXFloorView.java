package com.cisco.cmx.ui;

import it.sephiroth.android.library.imagezoom.ImageViewTouch;
import it.sephiroth.android.library.imagezoom.ImageViewTouchBase;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.ComposePathEffect;
import android.graphics.CornerPathEffect;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Paint.Align;
import android.graphics.Paint.Cap;
import android.graphics.Paint.Join;
import android.graphics.Paint.Style;
import android.graphics.PathDashPathEffect;
import android.graphics.PathEffect;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.drawable.NinePatchDrawable;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;

import com.cisco.cmx.R;
import com.cisco.cmx.model.CMXClientLocation;
import com.cisco.cmx.model.CMXDimension;
import com.cisco.cmx.model.CMXFloor;
import com.cisco.cmx.model.CMXMapCoordinate;
import com.cisco.cmx.model.CMXPath;
import com.cisco.cmx.model.CMXPoi;
import com.cisco.cmx.model.CMXPoint;
import com.nineoldandroids.animation.TypeEvaluator;
import com.nineoldandroids.animation.ValueAnimator;
import com.nineoldandroids.animation.ValueAnimator.AnimatorUpdateListener;

/**
 * Displays an arbitrary map with POIs, with zoom & scrolling.
 */
public class CMXFloorView extends ImageViewTouch {

    // Handler poi selected
    private SelectionHandler mSelectionHandler;

    // Handler active poi selected
    private ActiveSelectionHandler mActiveSelectionHandler;

    // Handler FeedbackView new user location chosen
    private FeedbackViewHandler mFeedbackViewHandler;

    private Paint mPaint = new Paint();

    private Paint mPathPaint = new Paint();

    private Paint mArrowPathPaint = new Paint();

    private CMXMapCoordinate mClientCoordinate;

    private float mClientDirection;

    private boolean mHasDirection;

    private boolean mFeedbackLocationEventEnabled = false;

    private boolean mShowPOIs;

    private CMXDimension mDimension;

    private Bitmap mEndPointBitmap;

    private Bitmap mTargetBitmap;

    private Bitmap mLocationFeedbackBitmap;

    // FeedbackView, manually re place user location
    private float mLocationFeedbackX, mLocationFeedbackY; // in image space

    private boolean mDrawFeedbackView = false;

    private Bitmap mArrowLocationBitmap;

    private float mArrowLocationBitmapScaling;

    private Matrix mTransformMatrix = new Matrix();

    private int mMapBitmapWidth;

    private int mMapBitmapHeight;

    private android.graphics.Path mPath = new android.graphics.Path();

    private List<ImageTag> mPoiTags = new ArrayList<ImageTag>();

    private List<PathPoint> mPoints = new ArrayList<PathPoint>();

    private ValueAnimator mClientLocationAnimation = null;

    private CMXPoi mActivePoi = null;

    /* Bubbles poi marker */
    private Bitmap mBubbleActivePoi;

    private int mOffsetYBubble = 0;

    private int mOffsetXBubble = 0;

    private int mPaddingXMapBubbles = 100;

    private int mPaddingYMapBubbles = 150;

    private int mHeightBubble = 50;

    private int mOffsetYText = 4;

    public CMXFloorView(Context context) {
        super(context);
    }

    public CMXFloorView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }

    public CMXFloorView(Context context, AttributeSet attrs) {
        super(context, attrs);

        mArrowLocationBitmapScaling = 1.0f;

        mHasDirection = false;

        mPaint.setColor(Color.BLACK);
        mPaint.setAntiAlias(true);
        mPaint.setTextAlign(Align.CENTER);
        mPaint.setTextSize(15);

        mPathPaint.setColor(Color.BLACK);
        mPathPaint.setStrokeWidth(5);
        mPathPaint.setStyle(Paint.Style.STROKE);
        mPathPaint.setAntiAlias(true);
        mPathPaint.setPathEffect(new CornerPathEffect(10));
        mPathPaint.setStrokeJoin(Paint.Join.ROUND);
        mPathPaint.setStrokeCap(Paint.Cap.ROUND);

        mArrowPathPaint.setARGB(255, 33, 0xAA, 0);
        mArrowPathPaint.setStrokeWidth(mPathPaint.getStrokeWidth() * 2);
        mArrowPathPaint.setStyle(Paint.Style.STROKE);
        mArrowPathPaint.setAntiAlias(true);
        mArrowPathPaint.setPathEffect(new ComposePathEffect(new PathDashPathEffect(makeArrowPathDash(), 25, 0, PathDashPathEffect.Style.ROTATE), new CornerPathEffect(20)));
        mArrowPathPaint.setStrokeJoin(Paint.Join.ROUND);
        mArrowPathPaint.setStrokeCap(Paint.Cap.ROUND);
        mArrowPathPaint.setAlpha(192);

        mShowPOIs = true;

    }
    
    /**
     * Set the color for the path
     * 
     * @param color 
     * 
     * For example if you want to set the color
     * of the path to be black you can pass in
     * Color.black as a parameter.
     */
    
    public void setPathColor(int color) {
    	mPathPaint.setColor(color);
    }
    
    /**
     * Set the color for the path using ARGB
     * 
     * @param alpha
     * @param red
     * @param green
     * @param blue
     *   
     */
    
    public void setPathARGB(int alpha, int red, int green, int blue) {
    	mPathPaint.setARGB(alpha, red, green, blue);
    }
    
    /**
     * Set the stroke width of the path
     * 
     * @param width
     *            
     */
    
    public void setPathStrokeWidth(int width) {
    	mPathPaint.setStrokeWidth(width);
    }
    
    /**
     * Set the style of the path
     * 
     * @param width
     * 
     * For example you can set the style of
     * the path by passing in Paint.Style.STROKE
     * for the default stroke
     *            
     */
    
    public void setPathStyle(Style style) {
    	mPathPaint.setStyle(style);
    }
    
    /**
     * Enable or disable the anti alias for the path
     * 
     * @param antiAlias
     *            
     */
    
    public void setPathAntiAlias(boolean antiAlias) {
    	mPathPaint.setAntiAlias(antiAlias);
    }
    
    /**
     * Set the effect of the path
     * 
     * @param effect
     * 
     * For example you can set the effect of the path by
     * new CornerPathEffect(10), this will create a
     * corner path effect with a radius of 10.
     *            
     */
    
    public void setPathEffect(PathEffect effect) {
    	mPathPaint.setPathEffect(effect);
    }
    
    /**
     * Set the stroke join for a path
     * 
     * @param pathStrokeJoin
     * 
     * For example you can set the stroke join
     * by passing in Paint.Join.ROUND as a parameter
     * 
     */
    
    public void setPathStrokeJoin(Join pathStrokeJoin) {
    	mPathPaint.setStrokeJoin(pathStrokeJoin);
    }
    
    /**
     * Set the stroke cap for a path
     * 
     * @param pathStrokeCap
     * 
     * For example you can set the stroke cap
     * by passing in Paint.Cap.ROUND as a parameter
     * 
     */
    
    public void setPathStrokeCap(Cap pathStrokeCap) {
    	mPathPaint.setStrokeCap(pathStrokeCap);
    }
    
    /**
     * Set the path alpha
     * 
     * @param alpha
     * 
     */
    
    public void setPathAlpha(int alpha) {
    	mPathPaint.setAlpha(alpha);
    }
    
    /**
     * Set the color for the path arrow
     * 
     * @param color 
     * 
     * For example if you want to set the color
     * for the path arrow to be black you can pass in
     * Color.black as a parameter.
     */
    
    public void setPathArrowColor(int color) {
    	mArrowPathPaint.setColor(color);
    }
    
    /**
     * Set the color for the path arrow using ARGB
     * 
     * @param alpha
     * @param red
     * @param green
     * @param blue
     *  
     */
    
    public void setPathArrowARGB(int alpha, int red, int green, int blue) {
    	mArrowPathPaint.setARGB(alpha, red, green, blue);
    }
    
    /**
    * Set the stroke width of the path arrow
    * 
    * @param width
    *            
    */
   
    public void setPathArrowStrokeWidth(int width) {
    	mArrowPathPaint.setStrokeWidth(width);
    }
   
   /**
    * Set the style of the path arrow
    * 
    * @param width
    * 
    * For example you can set the style of
    * the path arrow by passing in Paint.Style.STROKE
    * for the default stroke
    *            
    */
   
    public void setPathArrowStyle(Style style) {
    	mArrowPathPaint.setStyle(style);
    }
    
    /**
     * Enable or disable the anti alias for the path arrow
     * 
     * @param antiAlias
     *            
     */
    
    public void setPathArrowAntiAlias(boolean antiAlias) {
    	mArrowPathPaint.setAntiAlias(antiAlias);
    }
    
    /**
     * Set the effect of the path arrow
     * 
     * @param effect
     *            
     */
    
    public void setPathArrowEffect(PathEffect effect) {
    	mArrowPathPaint.setPathEffect(effect);
    }
    
    /**
     * Set the stroke join for a path arrow
     * 
     * @param pathStrokeJoin
     * 
     * For example you can set the stroke join for the arrow
     * by passing in Paint.Join.ROUND as a parameter
     * 
     */
    
    public void setPathArrowStrokeJoin(Join pathStrokeJoin) {
    	mArrowPathPaint.setStrokeJoin(pathStrokeJoin);
    }
    
    /**
     * Set the stroke cap for a path arrow
     * 
     * @param pathStrokeCap
     * 
     * For example you can set the stroke cap for the arrow
     * by passing in Paint.Cap.ROUND as a parameter
     * 
     */
    
    public void setPathArrowStrokeCap(Cap pathStrokeCap) {
    	mArrowPathPaint.setStrokeCap(pathStrokeCap);
    }
    
    /**
     * Set the path arrow alpha
     * 
     * @param alpha
     * 
     */
    
    public void setPathArrowAlpha(int alpha) {
    	mArrowPathPaint.setAlpha(alpha);
    }
    
    public Bitmap getNinepatch(int id, int x, int y) {
        // id is a resource id for a valid ninepatch

        Bitmap bitmap = BitmapFactory.decodeResource(getResources(), id);

        byte[] chunk = bitmap.getNinePatchChunk();
        NinePatchDrawable np_drawable = new NinePatchDrawable(bitmap, chunk, new Rect(), null);
        np_drawable.setBounds(0, 0, x, y);

        Bitmap output_bitmap = Bitmap.createBitmap(x, y, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(output_bitmap);
        np_drawable.draw(canvas);

        return output_bitmap;
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);

        if (mPoiTags.size() > 0 && mShowPOIs) {
            for (ImageTag tag : mPoiTags) {

                if (tag.bitmap != null) {
                    float[] target = new float[] { tag.center.getX() * mMapBitmapWidth / mDimension.getLength(), tag.center.getY() * mMapBitmapHeight / mDimension.getWidth() };
                    getImageMatrix().mapPoints(target);

                    mTransformMatrix.reset();
                    int bitmapWidth = tag.bitmap.getWidth();
                    int bitmapHeight = tag.bitmap.getHeight();
                    //mTransformMatrix.postTranslate(-bitmapWidth / 2.0f, -bitmapHeight / 2.0f);
                    //mTransformMatrix.postTranslate(-bitmapWidth, -bitmapHeight);
                    mTransformMatrix.postTranslate(-tag.bitmap.getWidth() / 2.0f, -tag.bitmap.getHeight() / 2.0f);
                    //mTransformMatrix.postScale(1.5f, 1.5f);
                    mTransformMatrix.postTranslate(target[0], target[1]);
                    canvas.drawBitmap(tag.bitmap, mTransformMatrix, mPaint);
                }
            }
        }

        if (mPoints.size() > 0) {
            // Note : path.transform doesn't work !!
            // Transform each point
            float[] target = new float[mPoints.size() * 2];
            int i = 0;
            for (PathPoint p : mPoints) {
                target[i++] = p.getX() * mMapBitmapWidth / mDimension.getLength();
                target[i++] = p.getY() * mMapBitmapHeight / mDimension.getWidth();

            }
            getImageMatrix().mapPoints(target);
            mPath.reset();
            mPath.moveTo(target[0], target[1]);
            for (int j = 2; j < i; j += 2) {
                mPath.lineTo(target[j], target[j + 1]);
            }

            // Draw path
            canvas.drawPath(mPath, mArrowPathPaint);

            // and end point
            if (mEndPointBitmap != null) {
                float endX = target[target.length - 2];
                float endY = target[target.length - 1];
                mTransformMatrix.reset();
                mTransformMatrix.postTranslate(-mEndPointBitmap.getWidth() / 2.0f, -mEndPointBitmap.getHeight() / 2.0f);
                mTransformMatrix.postTranslate(endX, endY);
                canvas.drawBitmap(mEndPointBitmap, mTransformMatrix, mPaint);
            }
        }

        // Draw client location
        if (mClientCoordinate != null && getDrawable() != null && mMapBitmapWidth != 0 && mMapBitmapHeight != 0) {

            float[] target = new float[] { mClientCoordinate.getX() * mMapBitmapWidth / mDimension.getLength(), mClientCoordinate.getY() * mMapBitmapHeight / mDimension.getWidth() };
            getImageMatrix().mapPoints(target);

            if (mHasDirection && mArrowLocationBitmap != null) {
                mTransformMatrix.reset();
                mTransformMatrix.postTranslate(-mArrowLocationBitmap.getWidth() / 2.0f, -mArrowLocationBitmap.getHeight() / 2.0f);
                mTransformMatrix.postRotate(this.mClientDirection);
                mTransformMatrix.postScale(mArrowLocationBitmapScaling, mArrowLocationBitmapScaling);
                mTransformMatrix.postTranslate(target[0], target[1]);
                canvas.drawBitmap(mArrowLocationBitmap, mTransformMatrix, mPaint);
            }
            else if (mTargetBitmap != null) {
                mTransformMatrix.reset();
                mTransformMatrix.postTranslate(-mTargetBitmap.getWidth() / 2.0f, -mTargetBitmap.getHeight() / 2.0f);
                mTransformMatrix.postTranslate(target[0], target[1]);
                canvas.drawBitmap(mTargetBitmap, mTransformMatrix, mPaint);
            }

            if (mDrawFeedbackView) {
                if (mLocationFeedbackBitmap != null) {
                    float[] feedbackTarget = new float[] { mLocationFeedbackX, mLocationFeedbackY };
                    getImageMatrix().mapPoints(feedbackTarget);

                    mTransformMatrix.reset();
                    mTransformMatrix.postTranslate(-mLocationFeedbackBitmap.getWidth() / 2.0f, -mLocationFeedbackBitmap.getHeight() / 2.0f);
                    if (mFeedbackLocationEventEnabled) {
                        mTransformMatrix.postScale(3, 3);
                    }
                    mTransformMatrix.postTranslate(feedbackTarget[0], feedbackTarget[1]);
                    canvas.drawBitmap(mLocationFeedbackBitmap, mTransformMatrix, mPaint);
                }
            }
        }

        // draw bubble poi marker
        if (getActivePoi() != null && mBubbleActivePoi != null) {

            float[] mActivePoiCenter = new float[] { getActivePoi().getCenter().getX() * mMapBitmapWidth / mDimension.getLength(), getActivePoi().getCenter().getY() * mMapBitmapHeight / mDimension.getWidth() };

            getImageMatrix().mapPoints(mActivePoiCenter);
            mTransformMatrix.reset();
            mTransformMatrix.postTranslate(-mBubbleActivePoi.getWidth() / 2.0f, -mBubbleActivePoi.getHeight() / 2.0f);
            // transformMatrix.postScale(0.5f, 0.5f);
            mTransformMatrix.postTranslate(mActivePoiCenter[0] + mOffsetXBubble, mActivePoiCenter[1] + mOffsetYBubble);
            canvas.drawBitmap(mBubbleActivePoi, mTransformMatrix, mPaint);

            // draw text on bubble
            canvas.drawText(getActivePoi().getName(), mActivePoiCenter[0] + mOffsetXBubble, mActivePoiCenter[1] + mOffsetYBubble + mOffsetYText, mPaint);

        }
    }

    /**
     * Returns the current active poi
     * 
     * @return poi active poi
     */
    public CMXPoi getActivePoi() {
        return mActivePoi;
    }

    /**
     * Sets the active poi. Inits the bubble marker (callout) depending on the
     * poi image
     * 
     * @param activePoi
     *            the active poi
     */
    public void setActivePoi(CMXPoi activePoi) {
        mActivePoi = activePoi;

        mOffsetYBubble = 0;
        mOffsetXBubble = 0;

        int heightPoi = 0;
        int widthPoi = 0;

        if (activePoi != null) {
            for (ImageTag tag : mPoiTags) {
                if (tag.poiId.equals(activePoi.getId())) {
                    heightPoi = tag.bitmap.getHeight();
                    widthPoi = tag.bitmap.getWidth();
                    mOffsetYBubble = -heightPoi;
                }
            }

            // create the bitmap bubble
            mBubbleActivePoi = getNinepatch(R.drawable.cmx_poi_bubble_marker_on_map, mActivePoi.getName().length() * 12, mHeightBubble);

            if (activePoi.getCenter().getX() * mMapBitmapWidth / mDimension.getLength() <= mPaddingXMapBubbles)
                mOffsetXBubble = mBubbleActivePoi.getWidth() / 2 - widthPoi / 2;
            else if (activePoi.getCenter().getX() * mMapBitmapWidth / mDimension.getLength() >= (mMapBitmapWidth - mPaddingXMapBubbles)) {
                mOffsetXBubble = -mBubbleActivePoi.getWidth() / 2 + widthPoi / 2;
            }

            if (activePoi.getCenter().getY() * mMapBitmapHeight / mDimension.getWidth() <= mPaddingYMapBubbles)
                mOffsetYBubble = heightPoi;

        }
    }

    /**
     * Set map to display
     * 
     * @param floor
     *            floor infos
     * @param bitmap
     *            image to display
     */
    public void setFloor(CMXFloor floor, Bitmap bitmap) {
        clearPois();
        setPath(null);
        setClientLocation(null);
        mDimension = floor.getDimension();
        if (bitmap != null) {
            mMapBitmapWidth = bitmap.getWidth();
            mMapBitmapHeight = bitmap.getHeight();
            this.setImageBitmap(bitmap, null, ImageViewTouchBase.ZOOM_INVALID, ImageViewTouchBase.ZOOM_INVALID);
        }
        invalidate();
    }

    /**
     * Show poi on map
     * 
     * @param poi
     *            poi to display
     * @param bitmap
     *            image to display
     */
    public void showPoi(CMXPoi poi, Bitmap bitmap) {
        CMXPoint p = poi.getCenter();
        if (p != null) {
            mPoiTags.add(new ImageTag(poi.getId(), p, bitmap));
            invalidate();
        }
    }

    /**
     * Clear all pois on map
     */
    public void clearPois() {
        mPoiTags.clear();
        invalidate();
    }

    /**
     * Display a path on map
     * 
     * @param newPath
     *            path to display
     */
    public void setPath(CMXPath newPath) {
        mPoints.clear();
        if (newPath != null) {
            List<CMXPoint> pp = newPath.getPoints();
            for (CMXPoint p : pp) {
                mPoints.add(new PathPoint(p));
            }
        }
        invalidate();
    }

    /**
     * Clear path on map
     */
    public void clearPath() {
        mPoints.clear();
        invalidate();
    }

    /**
     * Display client location on map
     * 
     * @param location
     *            client location
     */
    public void setClientLocation(CMXClientLocation location) {
        if (mClientLocationAnimation != null) {
            mClientLocationAnimation.cancel();
            mClientLocationAnimation = null;
        }

        if (location == null) {
            mClientCoordinate = null;
            this.postInvalidate();
        }
        else if (!location.getMapCoordinate().equals(mClientCoordinate)) {

            // 1st coordinate
            if (mClientCoordinate == null) {
                mClientCoordinate = location.getMapCoordinate();
                this.postInvalidate();
            }
            else {

                // Do a smooth animation between locations
                mClientLocationAnimation = ValueAnimator.ofObject(new MapCoordinateEvaluator(), new CMXMapCoordinate(mClientCoordinate.getX(), mClientCoordinate.getY(), mClientCoordinate.getUnit()), location.getMapCoordinate());
                mClientLocationAnimation.setDuration(1000);
                mClientLocationAnimation.addUpdateListener(new AnimatorUpdateListener() {

                    @Override
                    public void onAnimationUpdate(ValueAnimator animation) {
                        mClientCoordinate = (CMXMapCoordinate) animation.getAnimatedValue();
                        postInvalidate();
                    }

                });
                mClientLocationAnimation.start();
            }
        }
    }

    /**
     * Display client direction on map
     * 
     * @param clientDirection
     *            angle in degrees
     */
    public void setClientDirection(float clientDirection) {
        this.mClientDirection = clientDirection;
        mHasDirection = true;
    }

    /**
     * Disable client direction displaying
     */
    public void disableClientDirection() {
        mHasDirection = false;
    }

    public void setArrowLocationBitmap(Bitmap arrowLocationBitmap) {
        this.mArrowLocationBitmap = arrowLocationBitmap;
    }

    public void setArrowLocationBitmapScaling(float arrowLocationBitmapScaling) {
        this.mArrowLocationBitmapScaling = arrowLocationBitmapScaling;
    }

    public void setEndPointBitmap(Bitmap endNavigationPathBitmap) {
        this.mEndPointBitmap = endNavigationPathBitmap;
    }

    public void setTargetLocationBitmap(Bitmap bitmap) {
        mTargetBitmap = bitmap;
        invalidate();
    }

    public void setLocationFeedbackBitmap(Bitmap bitmap) {
        mLocationFeedbackBitmap = bitmap;
        invalidate();
    }

    public boolean isShowingPOIs() {
        return mShowPOIs;
    }

    public void showPOIs(boolean showPOIs) {
        this.mShowPOIs = showPOIs;
        this.postInvalidate();
    }

    /**
     * Scroll map to center on poi
     * 
     * @param poi
     *            poi to center
     */
    public void centerOnPoi(CMXPoi poi) {
        if (poi.getCenter() != null)
            centerOn(poi.getCenter().getX() * mMapBitmapWidth / mDimension.getLength(), poi.getCenter().getY() * mMapBitmapHeight / mDimension.getWidth());
    }

    /**
     * Center on a specific coordinate in the image. This method uses
     * image-based coordinates, with 0,0 at the top left of the image. It is
     * scale agnostic.
     * 
     * @param x
     * @param y
     */
    public void centerOn(float x, float y) {
        if (getDrawable() == null) {
            return; // nothing to do
        }

        float[] target = new float[] { x, y };
        getImageViewMatrix().mapPoints(target);

        float xp = getCenter().x - target[0];
        float yp = getCenter().y - target[1];

        scrollBy(xp, yp, 350);
    }

    /**
     * Scroll map to center on point
     * 
     * @param x
     * @param y
     */
    public void centerOnPoint(float x, float y) {
        if (mDimension != null) {
            centerOn(x * mMapBitmapWidth / mDimension.getLength(), y * mMapBitmapHeight / mDimension.getWidth());
        }
    }

    /**
     * Set the selection handler
     * 
     * @param selectionHandler
     *            handler
     */
    public void setSelectionHandler(SelectionHandler selectionHandler) {
        this.mSelectionHandler = selectionHandler;
    }

    /**
     * Set the active selection handler
     * 
     * @param activeselectionHandler
     *            handler
     */
    public void setActiveSelectionHandler(ActiveSelectionHandler activeselectionHandler) {
        this.mActiveSelectionHandler = activeselectionHandler;
    }

    /**
     * Set the FeedbackViewHandler handler
     * 
     * @param feedbackview
     *            handler
     */
    public void setFeedbackViewHandler(FeedbackViewHandler feedbackViewHandler) {
        this.mFeedbackViewHandler = feedbackViewHandler;
    }

    @Override
    public boolean onSingleTapConfirmed(MotionEvent e) {

        if (mShowPOIs) {
            Matrix imgMatrix = this.getImageViewMatrix();
            Matrix invImgMatrix = new Matrix();
            boolean invert = imgMatrix.invert(invImgMatrix);
            if (invert) {

                float pt[] = { e.getX(), e.getY() };
                invImgMatrix.mapPoints(pt);

                boolean somethingTouched = false;

                // on bubble tap
                if (getActivePoi() != null && mBubbleActivePoi != null) {
                    float bitmapSize[] = { mBubbleActivePoi.getWidth(), mBubbleActivePoi.getHeight() };
                    invImgMatrix.mapVectors(bitmapSize);
                    float bitmapWidth = bitmapSize[0];
                    float bitmapHeight = bitmapSize[1];

                    float centerX = (getActivePoi().getCenter().getX()) * mMapBitmapWidth / mDimension.getLength();
                    float centerY = getActivePoi().getCenter().getY() * mMapBitmapHeight / mDimension.getWidth();

                    float offsets[] = { mOffsetXBubble, mOffsetYBubble };
                    invImgMatrix.mapVectors(offsets);
                    float mOffsetXBubbleOnMap = offsets[0];
                    float mOffsetYBubbleOnMap = offsets[1];

                    float left = centerX - bitmapWidth / 2.0f;
                    float top = centerY - bitmapHeight / 2.0f;
                    float right = centerX + bitmapWidth / 2.0f;
                    float bottom = centerY + bitmapHeight / 2.0f;
                    RectF r = new RectF(left + mOffsetXBubbleOnMap, top + mOffsetYBubbleOnMap, right + mOffsetXBubbleOnMap, bottom + mOffsetYBubbleOnMap);

                    if (r.contains(pt[0], pt[1])) {
                        somethingTouched = true;
                        if (mActiveSelectionHandler != null) {
                            mActiveSelectionHandler.onActivePoiSelected(getActivePoi().getId());
                        }
                    }
                }

                // on poi image tap
                if (mPoiTags.size() > 0) {
                    for (ImageTag tag : mPoiTags) {

                        if (tag.bitmap != null) {
                            float bitmapSize[] = { Math.max(48, tag.bitmap.getWidth()), Math.max(48, tag.bitmap.getHeight()) };
                            invImgMatrix.mapVectors(bitmapSize);
                            float bitmapWidth = bitmapSize[0];
                            float bitmapHeight = bitmapSize[1];

                            float centerX = tag.center.getX() * mMapBitmapWidth / mDimension.getLength();
                            float centerY = tag.center.getY() * mMapBitmapHeight / mDimension.getWidth();

                            float left = centerX - bitmapWidth / 2.0f;
                            float top = centerY - bitmapHeight / 2.0f;
                            float right = centerX + bitmapWidth / 2.0f;
                            float bottom = centerY + bitmapHeight / 2.0f;
                            RectF r = new RectF(left, top, right, bottom);

                            if (r.contains(pt[0], pt[1])) {
                                somethingTouched = true;
                                if (mSelectionHandler != null) {
                                    mSelectionHandler.onPoiSelected(tag.poiId);
                                }
                            }
                        }
                    }
                }

                if (!somethingTouched) {
                    if (mActiveSelectionHandler != null) {
                        mActiveSelectionHandler.onActivePoiSelected(null);
                    }
                    setActivePoi(null);
                }
            }
        }
        return true;

    }

    private class ImageTag {
        public String poiId;

        public CMXPoint center;

        public Bitmap bitmap;

        public ImageTag(String id, CMXPoint center, Bitmap bitmap) {
            super();
            this.poiId = id;
            this.center = center;
            this.bitmap = bitmap;
        }
    }

    private class PathPoint {
        float x, y;

        public PathPoint(CMXPoint point) {
            this.x = point.getX();
            this.y = point.getY();
        }

        public float getX() {
            return x;
        }

        public float getY() {
            return y;
        }
    }

    /**
     * Classes wishing to be notified of poi selection implement this.
     */
    public interface SelectionHandler {
        /**
         * Callback method to be invoked when a poi has been selected
         * 
         * @param poiIdentifier
         *            the poi id selected
         */
        public void onPoiSelected(String poiIdentifier);
    }

    /**
     * Classes wishing to be notified of active poi selection implement this.
     */
    public interface ActiveSelectionHandler {
        /**
         * Callback method to be invoked when an active poi has been selected
         * 
         * @param poiIdentifier
         *            the active poi id selected
         */
        public void onActivePoiSelected(String poiIdentifier);
    }

    /**
     * Classes wishing to be notified of feedbackview choice implement this.
     */
    public interface FeedbackViewHandler {
        /**
         * Callback method to be invoked when user choose a new location
         * manually
         * 
         * @param x
         *            x position of the feedback view
         * @param y
         *            y position of the feedback view
         */
        public void onFeedbackViewChosen(float x, float y);
    }

    private static android.graphics.Path makeArrowPathDash() {
        android.graphics.Path p = new android.graphics.Path();

        p.moveTo(10, 0);
        p.lineTo(-10, -5f);
        p.lineTo(-5f, 0);
        p.lineTo(-10, 5f);
        p.lineTo(10, 0);
        return p;
    }

    private class MapCoordinateEvaluator implements TypeEvaluator<CMXMapCoordinate> {

        @Override
        public CMXMapCoordinate evaluate(float fraction, CMXMapCoordinate startValue, CMXMapCoordinate endValue) {
            return new CMXMapCoordinate(startValue.getX() * (1.0f - fraction) + endValue.getX() * fraction, startValue.getY() * (1.0f - fraction) + endValue.getY() * fraction, startValue.getUnit());
        }

    }

    @Override
    public boolean onTouchEvent(MotionEvent e) {

        if (e.getAction() == MotionEvent.ACTION_DOWN) {
            Matrix imgMatrix = this.getImageViewMatrix();
            Matrix invImgMatrix = new Matrix();
            boolean invert = imgMatrix.invert(invImgMatrix);
            if (invert) {
                float pt[] = { e.getX(), e.getY() };
                invImgMatrix.mapPoints(pt);

                Log.v("FLV", "Action down :  " + e.getX() + "  " + e.getY() + "  (" + pt[0] + " " + pt[1] + ")");

                // on user location image tap
                if (mClientCoordinate != null && getDrawable() != null && mMapBitmapWidth != 0 && mMapBitmapHeight != 0) {
                    float bitmapSize[] = null;
                    if (mHasDirection && mArrowLocationBitmap != null) {
                        bitmapSize = new float[] { mArrowLocationBitmap.getWidth(), mArrowLocationBitmap.getHeight() };
                    }
                    else {
                        bitmapSize = new float[] { mTargetBitmap.getWidth(), mTargetBitmap.getHeight() };
                    }

                    invImgMatrix.mapVectors(bitmapSize);
                    float bitmapWidth = bitmapSize[0];
                    float bitmapHeight = bitmapSize[1];

                    float centerX = mClientCoordinate.getX() * mMapBitmapWidth / mDimension.getLength();
                    float centerY = mClientCoordinate.getY() * mMapBitmapHeight / mDimension.getWidth();

                    float left = centerX - bitmapWidth / 2.0f;
                    float top = centerY - bitmapHeight / 2.0f;
                    float right = centerX + bitmapWidth / 2.0f;
                    float bottom = centerY + bitmapHeight / 2.0f;
                    RectF r = new RectF(left, top, right, bottom);
                    // r.inset(-32, -32);

                    if (r.contains(pt[0], pt[1])) {
                        Log.v("FLV", "User location down");
                        mLocationFeedbackX = pt[0];
                        mLocationFeedbackY = pt[1];
                        mFeedbackLocationEventEnabled = true;
                        enableFeedbackMode(true);
                    }
                }

                if (mDrawFeedbackView && mLocationFeedbackBitmap != null) {
                    float bitmapSize[] = null;
                    bitmapSize = new float[] { mLocationFeedbackBitmap.getWidth(), mLocationFeedbackBitmap.getHeight() };

                    invImgMatrix.mapVectors(bitmapSize);
                    float bitmapWidth = bitmapSize[0];
                    float bitmapHeight = bitmapSize[1];

                    float centerX = mLocationFeedbackX;
                    float centerY = mLocationFeedbackY;

                    float left = centerX - bitmapWidth / 2.0f;
                    float top = centerY - bitmapHeight / 2.0f;
                    float right = centerX + bitmapWidth / 2.0f;
                    float bottom = centerY + bitmapHeight / 2.0f;
                    RectF r = new RectF(left, top, right, bottom);

                    if (r.contains(pt[0], pt[1])) {
                        mLocationFeedbackX = pt[0];
                        mLocationFeedbackY = pt[1];
                        mFeedbackLocationEventEnabled = true;
                        enableFeedbackMode(true);
                    }
                }
            }
        }
        if (e.getAction() == MotionEvent.ACTION_MOVE) {
            if (mFeedbackLocationEventEnabled) {
                Matrix imgMatrix = this.getImageViewMatrix();
                Matrix invImgMatrix = new Matrix();
                boolean invert = imgMatrix.invert(invImgMatrix);
                if (invert) {
                    float pt[] = { e.getX(), e.getY() };
                    invImgMatrix.mapPoints(pt);
                    mLocationFeedbackX = pt[0];
                    mLocationFeedbackY = pt[1];
                    Log.v("FLV", "Action move :  " + e.getX() + "  " + e.getY() + "  (" + pt[0] + " " + pt[1] + ")");
                }
                // drawPlaceTargetBitmap = true;
            }
        }
        if (e.getAction() == MotionEvent.ACTION_UP) {
            if (mFeedbackLocationEventEnabled) {
                Matrix imgMatrix = this.getImageViewMatrix();
                Matrix invImgMatrix = new Matrix();
                boolean invert = imgMatrix.invert(invImgMatrix);
                if (invert) {
                    float pt[] = { e.getX(), e.getY() };
                    invImgMatrix.mapPoints(pt);
                    mLocationFeedbackX = pt[0];
                    mLocationFeedbackY = pt[1];
                    Log.v("FLV", "Action up :  " + e.getX() + "  " + e.getY() + "  (" + pt[0] + " " + pt[1] + ")");
                }
                enableFeedbackMode(false);
                mFeedbackLocationEventEnabled = false;
            }
        }

        // TODO Auto-generated method stub
        return super.onTouchEvent(e);
    }

    public void setDrawFeeebackView(boolean draw) {
        mDrawFeedbackView = draw;
    }

    private void enableFeedbackMode(boolean enabled) {
        if (enabled) {
            mDrawFeedbackView = true;
        }
        else {
            // Send new location to the handler
            if (mFeedbackViewHandler != null) {
                mFeedbackViewHandler.onFeedbackViewChosen(mLocationFeedbackX, mLocationFeedbackY);
            }
        }
    }

    public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {
        if (mFeedbackLocationEventEnabled)
            return false;
        else
            return super.onScroll(e1, e2, distanceX, distanceY);
    }
}
