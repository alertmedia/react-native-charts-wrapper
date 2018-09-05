package com.github.wuxudong.rncharts.markers;

import android.content.Context;
import android.graphics.Color;
import android.text.Html;
import android.text.TextUtils;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;
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

public class RNLineMarkerView extends MarkerView {

    private TextView tvContent;

    private FrameLayout lineLayout;
    private View line;

    private int digits = 0;
    private boolean isMax = false;
    private boolean isMin = false;
    private boolean isHtml = false;
    private int lineColor = Color.WHITE;

    private static final int BAR_OVERLAP_HEIGHT = 20;
    private static final int BAR_X_OFFSET = 80;

    public RNLineMarkerView(Context context) {
        super(context, R.layout.line_marker);

        this.tvContent = this.findViewById(R.id.line_tvContent);
        this.lineLayout = this.findViewById(R.id.line_layout);
        this.line = this.findViewById(R.id.line);
    }

    public void setDigits(int digits) {
        this.digits = digits;
    }

    public void setLineColor(int color) {
        this.lineColor = color;
    }

    @Override
    public void refreshContent(Entry e, Highlight highlight, float posX, float posY) {
        String text;

        if (e instanceof CandleEntry) {
            CandleEntry ce = (CandleEntry) e;
            text = Utils.formatNumber(ce.getClose(), digits, true);
        } else {
            text = Utils.formatNumber(e.getY(), digits, true);
        }

        if (e.getData() instanceof Map) {
            if(((Map) e.getData()).containsKey("marker")) {

                Object marker = ((Map) e.getData()).get("marker");
                text = marker.toString();

                if (highlight.getStackIndex() != -1 && marker instanceof List) {
                    text = ((List) marker).get(highlight.getStackIndex()).toString();
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

                MPPointF offset = getOffset();
                Chart chart = getChartView();

                final FrameLayout.LayoutParams params = (FrameLayout.LayoutParams) this.line.getLayoutParams();
                if (this.isMin) {
                    params.height = ((int)posY) - this.tvContent.getHeight() * 2 + BAR_OVERLAP_HEIGHT;
                } else {
                    params.height = ((int)posY) - this.tvContent.getHeight() + BAR_OVERLAP_HEIGHT;
                }

                if (posX + offset.x < BAR_X_OFFSET) {
                    params.gravity = Gravity.START;
                } else if (chart != null && posX + this.getWidth() + offset.x > chart.getWidth() - BAR_X_OFFSET) {
                    params.gravity = Gravity.END;
                } else {
                    params.gravity = Gravity.CENTER_HORIZONTAL;
                }

                this.line.setLayoutParams(params);
            }
        }

        this.line.setBackgroundColor(this.lineColor);

        if (TextUtils.isEmpty(text)) {
            this.tvContent.setVisibility(INVISIBLE);
            this.lineLayout.setVisibility(View.GONE);

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
        return new MPPointF( -(getWidth() / 2), -getHeight());
    }

    @Override
    public MPPointF getOffsetForDrawingAtPoint(float posX, float posY) {

        MPPointF offset = getOffset();

        Chart chart = getChartView();
        float width = getWidth();

        offset.y = this.isMin ? - (posY) + this.tvContent.getHeight() : - (posY);

        if (posX + offset.x < BAR_X_OFFSET) {
            offset.x += width/2;
        }
        else if (chart != null && posX + width + offset.x > chart.getWidth() - BAR_X_OFFSET) {
            offset.x -= width/2;
        }

        return offset;
    }

    public TextView getTvContent() {
        return this.tvContent;
    }
}

