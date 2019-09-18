package com.github.wuxudong.rncharts.markers;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.support.v4.content.res.ResourcesCompat;
import android.text.Html;
import android.text.TextUtils;
import android.view.Gravity;
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

    private TextView tvContent;

    private Drawable backgroundLeft = ResourcesCompat.getDrawable(getResources(), R.drawable.rectangle_marker_left, null);
    private Drawable background = ResourcesCompat.getDrawable(getResources(), R.drawable.rectangle_marker, null);
    private Drawable backgroundRight = ResourcesCompat.getDrawable(getResources(), R.drawable.rectangle_marker_right, null);

    private Drawable backgroundTopLeft = ResourcesCompat.getDrawable(getResources(), R.drawable.rectangle_marker_top_left, null);
    private Drawable backgroundTop = ResourcesCompat.getDrawable(getResources(), R.drawable.rectangle_marker_top, null);
    private Drawable backgroundTopRight = ResourcesCompat.getDrawable(getResources(), R.drawable.rectangle_marker_top_right, null);

    private static final float BALLOON_Y_OFFSET = 20.0f;
    private static final float Y_AXIS_OFFSET = 120.0f;

    private int digits = 0;
    private boolean isMax = false;
    private boolean isMin = false;
    private boolean isHtml = false;

    public RNRectangleMarkerView(Context context) {
        super(context, R.layout.rectangle_marker);

        tvContent = (TextView) findViewById(R.id.rectangle_tvContent);
    }

    public void setDigits(int digits) {
        this.digits = digits;
    }

    @Override
    public void refreshContent(Entry e, Highlight highlight, float posX, float posY) {
        String text = "";

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
                    this.tvContent.setTextColor(((Number)textColorObj).intValue());
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
        }

        if (TextUtils.isEmpty(text)) {
            tvContent.setVisibility(INVISIBLE);
        } else {
            if (this.isHtml) {
                this.tvContent.setText(Html.fromHtml(text));
            } else {
                this.tvContent.setText(text);
            }
            this.tvContent.setGravity(Gravity.CENTER);
            this.tvContent.setVisibility(VISIBLE);
        }

        super.refreshContent(e, highlight, posX, posY);
    }

    @Override
    public MPPointF getOffset() {
        return new MPPointF(-(getWidth() / 2.0f), -(getHeight()+BALLOON_Y_OFFSET));
    }

    @Override
    public MPPointF getOffsetForDrawingAtPoint(float posX, float posY) {

        MPPointF offset = this.getOffset();

        MPPointF fixedOffset = new MPPointF();
        fixedOffset.x = offset.x;
        fixedOffset.y = offset.y;

        Chart chart = getChartView();

        float width = getWidth();

        if (posX - Y_AXIS_OFFSET + fixedOffset.x < 0) {
            fixedOffset.x = 0;

            if (posY + fixedOffset.y < 0) {
                fixedOffset.y = BALLOON_Y_OFFSET;
                tvContent.setBackground(backgroundTopLeft);
            } else {
                tvContent.setBackground(backgroundLeft);
            }

        } else if (chart != null && posX + width + fixedOffset.x + Y_AXIS_OFFSET > chart.getWidth()) {
            fixedOffset.x = -width;

            if (posY + fixedOffset.y < 0) {
                fixedOffset.y = BALLOON_Y_OFFSET;
                tvContent.setBackground(backgroundTopRight);
            } else {
                tvContent.setBackground(backgroundRight);
            }
        } else {
            if (posY + fixedOffset.y < 0) {
                fixedOffset.y = BALLOON_Y_OFFSET;
                tvContent.setBackground(backgroundTop);
            } else {
                tvContent.setBackground(background);
            }
        }

        return fixedOffset;
    }

    public TextView getTvContent() {
        return tvContent;
    }

}
