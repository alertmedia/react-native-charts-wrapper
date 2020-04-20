package com.github.wuxudong.rncharts.markers;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.text.Html;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.github.mikephil.charting.charts.Chart;
import com.github.mikephil.charting.components.MarkerView;
import com.github.mikephil.charting.data.CandleEntry;
import com.github.mikephil.charting.data.Entry;
import com.github.mikephil.charting.highlight.Highlight;
import com.github.mikephil.charting.utils.MPPointF;
import com.github.mikephil.charting.utils.Utils;
import com.github.wuxudong.rncharts.R;

import java.util.List;
import java.util.Map;

public class RNRectangleMarkerView extends MarkerView {

    private LinearLayout baseLayout;
    private TextView tvContentLeft;
    private TextView tvContentRight;
    private View divider;

    private static final float BALOON_STRORKE_WIDTH = 2.0f;
    private static final float BALLOON_Y_OFFSET = 20.0f;
    private static final float MARKER_VERTICAL_PADDING = 20.0f;
    private static final float MARKER_HORIZONTAL_PADDING = 20.0f;
    private static final MPPointF ARROW_SIZE = new MPPointF(30.0f, 20.0f);
    private static final float BALOON_CORNER_RADIUS = 10.0f;

    private int digits = 0;
    private boolean isMax = false;
    private boolean isMin = false;
    private boolean isHtml = false;
    private boolean isSideBySide = false;

    private Paint markerStrokePaint = new Paint();
    private Paint markerFillPaint = new Paint();
    private RectF markerRectangle = new RectF();
    private Path markerTriangleFillPath = new Path();
    private Path markerTriangleStrokePath = new Path();

    public RNRectangleMarkerView(Context context) {
        super(context, R.layout.rectangle_marker);

        this.baseLayout = this.findViewById(R.id.rectangle_markerContent);
        this.tvContentLeft = this.findViewById(R.id.rectangle_tvContentLeft);
        this.tvContentRight = this.findViewById(R.id.rectangle_tvContentRight);
        this.divider = this.findViewById(R.id.rectangle_divider);

        // TODO:
        this.markerStrokePaint.setStrokeWidth(BALOON_STRORKE_WIDTH);
        this.markerStrokePaint.setColor(Color.GRAY);
        this.markerStrokePaint.setStyle(Paint.Style.STROKE);
        this.markerFillPaint.setColor(Color.WHITE);
        this.markerFillPaint.setStyle(Paint.Style.FILL);
    }

    public void setDigits(int digits) {
        this.digits = digits;
    }

    @Override
    public void refreshContent(Entry e, Highlight highlight, float posX, float posY) {
        String text = "";
        String leftText ="";
        String rightText ="";

        if (e instanceof CandleEntry) {
            CandleEntry ce = (CandleEntry) e;
            text = Utils.formatNumber(ce.getClose(), digits, false);
        } else {
            text = Utils.formatNumber(e.getY(), digits, false);
        }

        if (e.getData() instanceof Map) {
            if (((Map) e.getData()).containsKey("marker")) {

                Object marker = ((Map) e.getData()).get("marker");
                text = marker.toString();

                if (highlight.getStackIndex() != -1 && marker instanceof List) {
                    text = ((List) marker).get(highlight.getStackIndex()).toString();
                }
            }

            if(((Map) e.getData()).containsKey("markerTextColor")) {
                Object textColorObj = ((Map) e.getData()).get("markerTextColor");
                if (textColorObj instanceof Number) {
                    this.tvContentLeft.setTextColor(((Number)textColorObj).intValue());
                    this.tvContentRight.setTextColor(((Number)textColorObj).intValue());
                }
            }

            if(((Map) e.getData()).containsKey("isMax")) {
                Object isMax =  ((Map) e.getData()).get("isMax");
                if (isMax instanceof Boolean && (boolean)isMax) {
                    this.isMax = true;
                } else {
                    this.isMax = false;
                }
            } else {
                this.isMax = false;
            }

            if(((Map) e.getData()).containsKey("isMin")) {
                Object isMin =  ((Map) e.getData()).get("isMin");
                if (isMin instanceof Boolean && (boolean)isMin) {
                    this.isMin = true;
                } else {
                    this.isMin = false;
                }
            } else {
                this.isMin = false;
            }

            if(((Map) e.getData()).containsKey("isHtml")) {
                Object isHtml =  ((Map) e.getData()).get("isHtml");
                if (isHtml instanceof Boolean && (boolean)isHtml) {
                    this.isHtml = true;
                } else {
                    this.isHtml = false;
                }
            } else {
                this.isHtml = false;
            }

            if(((Map) e.getData()).containsKey("isSideBySide")) {
                Object isSideBySide =  ((Map) e.getData()).get("isSideBySide");
                if (isSideBySide instanceof Boolean && (boolean)isSideBySide) {
                    this.isSideBySide = true;

                    if (((Map) e.getData()).containsKey("leftMarker")) {
                        Object leftMarker = ((Map) e.getData()).get("leftMarker");
                        leftText = leftMarker.toString();
                    }
                    if (((Map) e.getData()).containsKey("rightMarker")) {
                        Object rightMarker = ((Map) e.getData()).get("rightMarker");
                        rightText = rightMarker.toString();
                    }

                } else {
                    this.isSideBySide = false;
                }
            } else {
                this.isSideBySide = false;
            }

            if(((Map) e.getData()).containsKey("dividerColor")) {
                Object textColorObj = ((Map) e.getData()).get("dividerColor");
                if (textColorObj instanceof Number) {
                    this.divider.setBackgroundColor(((Number)textColorObj).intValue());
                }
            }
        }


        this.tvContentLeft.setVisibility(GONE);
        this.tvContentLeft.setGravity(Gravity.CENTER);
        this.tvContentRight.setVisibility(GONE);
        this.tvContentRight.setGravity(Gravity.CENTER);
        this.divider.setVisibility(GONE);

        if (this.isSideBySide) {
            int measuredWidth = 0;

            if (!TextUtils.isEmpty(leftText)) {
                this.tvContentLeft.setVisibility(VISIBLE);
                this.tvContentLeft.setGravity(Gravity.START);
                this.tvContentLeft.setText(Html.fromHtml(leftText));
                this.tvContentLeft.measure(0, 0);
                measuredWidth = this.tvContentLeft.getMeasuredWidth();
            }
            if (!TextUtils.isEmpty(rightText)) {
                this.tvContentRight.setVisibility(VISIBLE);
                this.tvContentRight.setGravity(Gravity.START);
                this.tvContentRight.setText(Html.fromHtml(rightText));
                if (measuredWidth > 0) {
                    this.tvContentRight.setWidth(measuredWidth);
                }
            }
            if (!TextUtils.isEmpty(leftText) && !TextUtils.isEmpty(rightText)) {
                this.divider.setVisibility(VISIBLE);
            }

        } else if (!TextUtils.isEmpty(text)) {
            this.tvContentLeft.setVisibility(VISIBLE);

            if (this.isHtml) {
                this.tvContentLeft.setText(Html.fromHtml(text));
            } else {
                this.tvContentLeft.setText(text);
            }
        }

        super.refreshContent(e, highlight, posX, posY);
    }

    @Override
    public MPPointF getOffsetForDrawingAtPoint(float posX, float posY) {

        MPPointF offset = new MPPointF();
        Chart chart = this.getChartView();

        float width = this.getWidth();
        float height = this.getHeight();

        float extraInset = Math.max(0.0f, (chart.getWidth() - width - MARKER_HORIZONTAL_PADDING * 2) / 2.0f);

        if (posY - BALLOON_Y_OFFSET - ARROW_SIZE.y - height - MARKER_VERTICAL_PADDING * 2 < 0) {
            // upwards /\
            offset.y = BALLOON_Y_OFFSET + ARROW_SIZE.y + MARKER_VERTICAL_PADDING;

            if (posX < extraInset) {
                // left
                offset.x = MARKER_HORIZONTAL_PADDING;
                this.drawTopLeftRect(posX, posY);

            } else if (width + extraInset < posX) {
                // right
                offset.x = -width - MARKER_HORIZONTAL_PADDING;
                this.drawTopRightRect(posX, posY);

            } else {
                // center
                offset.x = this.drawTopCenterRect(posX, posY, extraInset);
            }

        } else {
            // downwards \/
            offset.y = -(this.getHeight() + BALLOON_Y_OFFSET + ARROW_SIZE.y + MARKER_VERTICAL_PADDING);

            if (posX < extraInset) {
                // left
                offset.x = MARKER_HORIZONTAL_PADDING;
                this.drawLeftRect(posX, posY);

            } else if (width + extraInset < posX) {
                // right
                offset.x = -width - MARKER_HORIZONTAL_PADDING;
                this.drawRightRect(posX, posY);

            } else {
                // center
                offset.x = this.drawCenterRect(posX, posY, extraInset);
            }
        }

        return offset;
    }

    @Override
    public void draw(Canvas canvas, float posX, float posY) {

        MPPointF offset = getOffsetForDrawingAtPoint(posX, posY);

        int saveId = canvas.save();

        // draw maker balloon
        canvas.drawRoundRect(this.markerRectangle, BALOON_CORNER_RADIUS, BALOON_CORNER_RADIUS, this.markerFillPaint);
        canvas.drawRoundRect(this.markerRectangle, BALOON_CORNER_RADIUS, BALOON_CORNER_RADIUS, this.markerStrokePaint);
        canvas.drawPath(this.markerTriangleFillPath, this.markerFillPaint);
        canvas.drawPath(this.markerTriangleStrokePath, this.markerStrokePaint);

        // translate to the correct position and draw values
        canvas.translate(posX + offset.x, posY + offset.y);
        draw(canvas);

        canvas.restoreToCount(saveId);
    }

    public TextView getTvContentLeft() {
        return tvContentLeft;
    }

    public TextView getTvContentRight() {
        return tvContentRight;
    }

    private void drawLeftRect(float posX, float posY) {
        float width = this.getWidth();
        float height = this.getHeight();

        MPPointF topLeft = new MPPointF(posX, posY - BALLOON_Y_OFFSET - ARROW_SIZE.y - height - MARKER_VERTICAL_PADDING * 2);
        MPPointF bottomRight = new MPPointF(topLeft.x + width + MARKER_HORIZONTAL_PADDING * 2, topLeft.y + height + MARKER_VERTICAL_PADDING * 2);

        MPPointF arrowStart = new MPPointF(posX, posY - BALLOON_Y_OFFSET - ARROW_SIZE.y - BALOON_CORNER_RADIUS*2);
        MPPointF arrowPoint = new MPPointF(posX, posY - BALLOON_Y_OFFSET);
        MPPointF arrowEnd = new MPPointF(posX + ARROW_SIZE.x/2, posY - BALLOON_Y_OFFSET - ARROW_SIZE.y);

        this.drawBaloon(topLeft, bottomRight, arrowStart, arrowPoint, arrowEnd);
    }

    private float drawCenterRect(float posX, float posY, float extraInset) {
        float width = this.getWidth();
        float height = this.getHeight();

        MPPointF topLeft = new MPPointF(extraInset, posY - BALLOON_Y_OFFSET - ARROW_SIZE.y - height - MARKER_VERTICAL_PADDING * 2);
        MPPointF bottomRight = new MPPointF(topLeft.x + width + MARKER_HORIZONTAL_PADDING * 2, topLeft.y + height + MARKER_VERTICAL_PADDING * 2);

        MPPointF arrowStart = new MPPointF(posX - ARROW_SIZE.x/2.0f, posY - BALLOON_Y_OFFSET - ARROW_SIZE.y - BALOON_STRORKE_WIDTH/2.0f);
        MPPointF arrowPoint = new MPPointF(posX, posY - BALLOON_Y_OFFSET);
        MPPointF arrowEnd = new MPPointF(posX + ARROW_SIZE.x/2.0f, arrowStart.y);

        if (arrowStart.x <= topLeft.x + BALOON_CORNER_RADIUS) {
            this.drawLeftRect(posX, posY);
            return MARKER_HORIZONTAL_PADDING;
        }
        if (arrowEnd.x >= bottomRight.x - BALOON_CORNER_RADIUS) {
            this.drawRightRect(posX, posY);
            return -width - MARKER_HORIZONTAL_PADDING;
        }

        this.drawBaloon(topLeft, bottomRight, arrowStart, arrowPoint, arrowEnd);

        return -posX + extraInset + MARKER_HORIZONTAL_PADDING;
    }

    private void drawRightRect(float posX, float posY) {
        float width = this.getWidth();
        float height = this.getHeight();

        MPPointF topLeft = new MPPointF(posX - width - MARKER_HORIZONTAL_PADDING * 2, posY - BALLOON_Y_OFFSET - ARROW_SIZE.y - height - MARKER_VERTICAL_PADDING * 2);
        MPPointF bottomRight = new MPPointF(topLeft.x + width + MARKER_HORIZONTAL_PADDING * 2, topLeft.y + height + MARKER_VERTICAL_PADDING * 2);

        MPPointF arrowStart = new MPPointF(posX, posY - BALLOON_Y_OFFSET - ARROW_SIZE.y - BALOON_CORNER_RADIUS*2);
        MPPointF arrowPoint = new MPPointF(posX, posY - BALLOON_Y_OFFSET);
        MPPointF arrowEnd = new MPPointF(posX - ARROW_SIZE.x/2, posY - BALLOON_Y_OFFSET - ARROW_SIZE.y);

        this.drawBaloon(topLeft, bottomRight, arrowStart, arrowPoint, arrowEnd);
    }

    private void drawTopLeftRect(float posX, float posY) {
        float width = this.getWidth();
        float height = this.getHeight();

        MPPointF topLeft = new MPPointF(posX, posY + BALLOON_Y_OFFSET + ARROW_SIZE.y);
        MPPointF bottomRight = new MPPointF(topLeft.x + width + MARKER_HORIZONTAL_PADDING * 2, topLeft.y + height + MARKER_VERTICAL_PADDING * 2);

        MPPointF arrowStart = new MPPointF(posX, posY + BALLOON_Y_OFFSET + ARROW_SIZE.y + BALOON_CORNER_RADIUS*2);
        MPPointF arrowPoint = new MPPointF(posX, posY + BALLOON_Y_OFFSET);
        MPPointF arrowEnd = new MPPointF(posX + ARROW_SIZE.x/2, posY + BALLOON_Y_OFFSET + ARROW_SIZE.y);

        this.drawBaloon(topLeft, bottomRight, arrowStart, arrowPoint, arrowEnd);
    }

    private float drawTopCenterRect(float posX, float posY, float extraInset) {
        float width = this.getWidth();
        float height = this.getHeight();

        MPPointF topLeft = new MPPointF(extraInset, posY + BALLOON_Y_OFFSET + ARROW_SIZE.y);
        MPPointF bottomRight = new MPPointF(topLeft.x + width + MARKER_HORIZONTAL_PADDING * 2, topLeft.y + height + MARKER_VERTICAL_PADDING * 2);

        MPPointF arrowStart = new MPPointF(posX - ARROW_SIZE.x/2.0f, posY + BALLOON_Y_OFFSET + ARROW_SIZE.y + BALOON_STRORKE_WIDTH/2.0f);
        MPPointF arrowPoint = new MPPointF(posX, posY + BALLOON_Y_OFFSET);
        MPPointF arrowEnd = new MPPointF(posX + ARROW_SIZE.x/2.0f, arrowStart.y);

        if (arrowStart.x <= topLeft.x + BALOON_CORNER_RADIUS) {
            this.drawTopLeftRect(posX, posY);
            return MARKER_HORIZONTAL_PADDING;
        }
        if (arrowEnd.x >= bottomRight.x - BALOON_CORNER_RADIUS) {
            this.drawTopRightRect(posX, posY);
            return -width - MARKER_HORIZONTAL_PADDING;
        }

        this.drawBaloon(topLeft, bottomRight, arrowStart, arrowPoint, arrowEnd);

        return -posX + extraInset + MARKER_HORIZONTAL_PADDING;
    }

    private void drawTopRightRect(float posX, float posY) {
        float width = this.getWidth();
        float height = this.getHeight();

        MPPointF topLeft = new MPPointF(posX - width - MARKER_HORIZONTAL_PADDING * 2, posY + BALLOON_Y_OFFSET + ARROW_SIZE.y);
        MPPointF bottomRight = new MPPointF(topLeft.x + width + MARKER_HORIZONTAL_PADDING * 2, topLeft.y + height + MARKER_VERTICAL_PADDING * 2);

        MPPointF arrowStart = new MPPointF(posX, posY + BALLOON_Y_OFFSET + ARROW_SIZE.y + BALOON_CORNER_RADIUS*2);
        MPPointF arrowPoint = new MPPointF(posX, posY + BALLOON_Y_OFFSET);
        MPPointF arrowEnd = new MPPointF(posX - ARROW_SIZE.x/2, posY + BALLOON_Y_OFFSET + ARROW_SIZE.y);

        this.drawBaloon(topLeft, bottomRight, arrowStart, arrowPoint, arrowEnd);
    }

    private void drawBaloon(MPPointF topLeft, MPPointF bottomRight, MPPointF arrowStart, MPPointF arrowPoint, MPPointF arrowEnd) {
        this.markerRectangle.set(topLeft.x, topLeft.y, bottomRight.x, bottomRight.y);

        this.markerTriangleFillPath.reset();
        this.markerTriangleFillPath.moveTo(arrowStart.x, arrowStart.y);
        this.markerTriangleFillPath.lineTo(arrowPoint.x, arrowPoint.y);
        this.markerTriangleFillPath.lineTo(arrowEnd.x, arrowEnd.y);
        this.markerTriangleFillPath.lineTo(arrowStart.x, arrowStart.y);

        this.markerTriangleStrokePath.reset();
        this.markerTriangleStrokePath.moveTo(arrowStart.x, arrowStart.y);
        this.markerTriangleStrokePath.lineTo(arrowPoint.x, arrowPoint.y);
        this.markerTriangleStrokePath.lineTo(arrowEnd.x, arrowEnd.y);
    }
}
