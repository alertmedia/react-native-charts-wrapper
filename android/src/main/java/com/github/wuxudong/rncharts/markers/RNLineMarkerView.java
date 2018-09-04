package com.github.wuxudong.rncharts.markers;

import android.content.Context;
import android.graphics.Color;
import android.text.SpannableString;
import android.text.SpannableStringBuilder;
import android.text.TextUtils;
import android.text.style.ForegroundColorSpan;
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
    private boolean isDH = false;
    private int lineColor = Color.WHITE;

    private float minPosX = -1;
    private float minPosY = -1;

    private float maxPosX = -1;
    private float maxPosY = -1;

    private static final int BAR_OVERLAP_HEIGHT = 20;
    private static final int BAR_X_OFFSET = 20;

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
    public void refreshContent(Entry e, Highlight highlight) {
        String text;

        int textColor       = -1;
        int separatorColor  = -1;
        int accentColor     = -1;

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
                        textColor = ((Number)textColorObj).intValue();
                        this.tvContent.setTextColor(textColor);
                    }
                }

                if(((Map) e.getData()).containsKey("markerSeparatorColor")) {
                    Object separatorColorObj = ((Map) e.getData()).get("markerSeparatorColor");
                    if (separatorColorObj instanceof Number) {
                        separatorColor = ((Number)separatorColorObj).intValue();
                    }
                }

                if(((Map) e.getData()).containsKey("markerAccentColor")) {
                    Object accentColorObj = ((Map) e.getData()).get("markerAccentColor");
                    if (accentColorObj instanceof Number) {
                        accentColor = ((Number)accentColorObj).intValue();
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

                if(((Map) e.getData()).containsKey("isDH")) {
                    Object isDH =  ((Map) e.getData()).get("isDH");
                    if (isDH instanceof Boolean && (boolean)isDH) {
                        this.isDH = true;
                    } else {
                        this.isDH = false;
                    }
                } else {
                    this.isDH = false;
                }

                MPPointF offset = getOffset();
                Chart chart = getChartView();

                final FrameLayout.LayoutParams params = (FrameLayout.LayoutParams) this.line.getLayoutParams();
                if (this.isMin) {
                    params.height = ((int)minPosY) - this.tvContent.getHeight() * 2 + BAR_OVERLAP_HEIGHT;
                } else {
                    params.height = ((int)maxPosY) - this.tvContent.getHeight() + BAR_OVERLAP_HEIGHT;
                }

                float posX = this.isMax ? this.maxPosX : this.minPosX;

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
            if (this.isDH) {
                SpannableStringBuilder builder = new SpannableStringBuilder();

                // in-temperature
                int inTemperatureIndex = text.indexOf("/");
                if (inTemperatureIndex > 0) {
                    SpannableString inTemperature = new SpannableString(text.substring(0, inTemperatureIndex));
                    inTemperature.setSpan(new ForegroundColorSpan(textColor), 0, inTemperature.length(), 0);
                    builder.append(inTemperature);
                }

                // separator
                int separatorIndex = text.indexOf("/");
                if (separatorIndex > 0 && text.length() > separatorIndex + 1 && separatorColor != -1) {
                    SpannableString separator = new SpannableString(text.substring(separatorIndex, separatorIndex+1));
                    separator.setSpan(new ForegroundColorSpan(separatorColor), 0, separator.length(), 0);
                    builder.append(separator);
                }

                // out-temperature
                int outTemperatureIndex = text.indexOf("/") + 1;
                int lineBreakIndex = text.indexOf("\n");
                if (text.length() > outTemperatureIndex && lineBreakIndex > 0 && accentColor != -1) {
                    SpannableString outTemperature = new SpannableString(text.substring(outTemperatureIndex, lineBreakIndex));
                    outTemperature.setSpan(new ForegroundColorSpan(accentColor), 0, outTemperature.length(), 0);
                    builder.append(outTemperature);
                }

                // weather
                if (text.length() > lineBreakIndex + 1) {
                    SpannableString weather = new SpannableString(text.substring(lineBreakIndex));
                    weather.setSpan(new ForegroundColorSpan(textColor), 0, weather.length(), 0);
                    builder.append(weather);
                }

                this.tvContent.setText(builder, TextView.BufferType.SPANNABLE);
                this.tvContent.setVisibility(VISIBLE);

            } else {
                this.tvContent.setText(text);
                this.tvContent.setVisibility(VISIBLE);
            }
        }

        super.refreshContent(e, highlight);
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

        // NOTE: at this point, this.line refers to the other marker.
        // Only keep posX and posY here and calculate line height in #refreshContent
        if (this.isMin) {
            this.minPosX = posX;
            this.minPosY = posY;
        } else {
            this.maxPosX = posX;
            this.maxPosY = posY;
        }

        return offset;
    }

    public TextView getTvContent() {
        return this.tvContent;
    }
}

