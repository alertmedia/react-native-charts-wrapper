//
//  BalloonMarker.swift
//  ChartsDemo
//
//  Created by Daniel Cohen Gindi on 19/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//  https://github.com/danielgindi/Charts/blob/1788e53f22eb3de79eb4f08574d8ea4b54b5e417/ChartsDemo/Classes/Components/BalloonMarker.swift
//  Edit: Added textColor

import Foundation;
import Charts;
import SwiftyJSON;

open class BalloonMarker: MarkerView {
    open var color: UIColor?
    open var arrowSize = CGSize(width: 15, height: 11)
    open var font: UIFont?
    open var textColor: UIColor?
    open var minimumSize = CGSize()
    open var useLineIndicator: Bool?

    fileprivate var insets = UIEdgeInsets(top: 8.0,left: 8.0,bottom: 8.0,right: 8.0)
    fileprivate let margin: CGFloat = 8.0
    fileprivate let shadowMargin: CGFloat = 0.0

    fileprivate var labelns: NSString?
    fileprivate var labelHtml: NSAttributedString?
    fileprivate var _labelSize: CGSize = CGSize()
    fileprivate var _size: CGSize = CGSize()
    fileprivate var _paragraphStyle: NSMutableParagraphStyle?
    fileprivate var _drawAttributes = [NSAttributedString.Key: Any]()

    fileprivate var isMax: Bool?
    fileprivate var isMin: Bool?
    fileprivate var isHtml: Bool?
    fileprivate let barOverwrapHeight: CGFloat = 10.0
    fileprivate let strokeWidth: CGFloat = 0.1

    public init(color: UIColor, font: UIFont, textColor: UIColor) {
        super.init(frame: CGRect.zero);
        self.color = color
        self.font = font
        self.textColor = textColor
        self.useLineIndicator = false

        _paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        _paragraphStyle?.alignment = .center
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }


    func drawRect(context: CGContext, point: CGPoint, originalPoint: CGPoint) -> (CGRect, Bool) {

      let chart = super.chartView
      var rect = CGRect(origin: point, size: _size)
      var isUpwards = false

      if self.useLineIndicator! {
        // Marker upwards rect only
        rect.origin.y = 0

        if point.x - _size.width / 1.2 < 0 {
          if originalPoint.y < _size.height + margin {
            rect.origin.x += margin
          }
          drawLeftRect(context: context, rect: rect, originalPoint: originalPoint)

        } else if (chart != nil && point.x + _size.width * 0.8 > (chart?.bounds.width)!) {
          if originalPoint.y < _size.height + margin {
            rect.origin.x -= margin
          }
          rect.origin.x -= _size.width
          drawRightRect(context: context, rect: rect, originalPoint: originalPoint)

        } else {
          if originalPoint.y < _size.height + margin {
            if originalPoint.x < (chart?.bounds.width)! / 2.0 {
                rect.origin.x += rect.size.width / 2.0 + margin
            } else {
              rect.origin.x -= rect.size.width / 2.0 + margin
            }
          }
          rect.origin.x -= _size.width / 2.0
          drawCenterRect(context: context, rect: rect, originalPoint: originalPoint)
        }
      } else {
        // Marker with upwards/downwards rect
        if point.y - _size.height - arrowSize.height - margin < 0 {
            rect.origin.y += margin

            if point.x - _size.width / 1.2 < 0 {
                drawTopLeftRect(context: context, rect: rect)
            } else if (chart != nil && point.x + _size.width * 0.8 > (chart?.bounds.width)!) {
                rect.origin.x -= _size.width
                drawTopRightRect(context: context, rect: rect)
            } else {
                rect.origin.x -= _size.width / 2.0
                drawTopCenterRect(context: context, rect: rect)
            }
            isUpwards = true

        } else {
            rect.origin.y -= _size.height + arrowSize.height + margin

            if point.x - _size.width / 1.2 < 0 {
                drawLeftRect(context: context, rect: rect, originalPoint: originalPoint)
            } else if (chart != nil && point.x + _size.width * 0.8 > (chart?.bounds.width)!) {
                rect.origin.x -= _size.width
                drawRightRect(context: context, rect: rect, originalPoint: originalPoint)
            } else {
                rect.origin.x -= _size.width / 2.0
                drawCenterRect(context: context, rect: rect, originalPoint: originalPoint)
            }
        }
      }

        /* Marker with line
        if point.x - _size.width / 2.0 < 0 {
          drawLeftLine(context: context, rect: rect, originalPoint: originalPoint)
        } else if (chart != nil && point.x + width - _size.width / 2.0 > (chart?.bounds.width)!) {
          rect.origin.x -= _size.width
          drawRightLine(context: context, rect: rect, originalPoint: originalPoint)
        } else {
          rect.origin.x -= _size.width / 2.0
          drawCenterLine(context: context, rect: rect, originalPoint: originalPoint)
        }
        */

        return (rect, isUpwards)
    }

    /*
    func drawCenterLine(context: CGContext, rect: CGRect, originalPoint: CGPoint) {
      let x = rect.origin.x + rect.size.width / 2.0
      let y = rect.origin.y + rect.size.height
      let height = originalPoint.y - (rect.origin.y + rect.size.height) + self.barOverwrapHeight
      context.setStrokeColor((self.color?.cgColor)!)
      context.stroke(CGRect(x: x, y: y, width: self.strokeWidth, height: height))
    }

    func drawLeftLine(context: CGContext, rect: CGRect, originalPoint: CGPoint) {
      let x = rect.origin.x
      let y = rect.origin.y + rect.size.height / 2.0
      let height = originalPoint.y - (rect.origin.y + rect.size.height / 2.0) + self.barOverwrapHeight
      context.setStrokeColor((self.color?.cgColor)!)
      context.stroke(CGRect(x: x, y: y, width: self.strokeWidth, height: height))
    }

    func drawRightLine(context: CGContext, rect: CGRect, originalPoint: CGPoint) {
      let x = rect.origin.x + rect.size.width
      let y = rect.origin.y + rect.size.height / 2.0
      let height = originalPoint.y - (rect.origin.y + rect.size.height / 2.0) + self.barOverwrapHeight
      context.setStrokeColor((self.color?.cgColor)!)
      context.stroke(CGRect(x: x, y: y, width: self.strokeWidth, height: height))
    }
    */

    func drawCenterRect(context: CGContext, rect: CGRect, originalPoint: CGPoint) {
      let topLeft = CGPoint(x: rect.origin.x + self.shadowMargin, y: rect.origin.y + self.shadowMargin)
      let topRight = CGPoint(x: rect.origin.x + rect.size.width - self.shadowMargin, y: rect.origin.y + self.shadowMargin)
      let bottomLeft = CGPoint(x: rect.origin.x + self.shadowMargin, y: rect.origin.y + rect.size.height - self.shadowMargin)
      let bottomRight = CGPoint(x: rect.origin.x + rect.size.width - self.shadowMargin, y: rect.origin.y + rect.size.height - self.shadowMargin)

      context.setFillColor((color?.cgColor)!)
      context.setShadow(offset: CGSize(width: 0.0, height: 2.0), blur: 4.0)

      context.beginPath()
      context.move(to: CGPoint(x: topLeft.x, y: topLeft.y))
      context.addLine(to: CGPoint(x: topRight.x, y: topRight.y))
      context.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y))
      if !self.useLineIndicator! {
        context.addLine(to: CGPoint(x: bottomRight.x - (rect.size.width + arrowSize.width) / 2.0, y: bottomRight.y))
        context.addLine(to: CGPoint(x: bottomRight.x - rect.size.width / 2.0, y: bottomLeft.y + arrowSize.height))
        context.addLine(to: CGPoint(x: bottomRight.x - (rect.size.width - arrowSize.width) / 2.0, y: bottomRight.y))
      }
      context.addLine(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y))
      context.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y))
      context.fillPath()

      context.setShadow(offset: CGSize(width: 0.0, height: 2.0), blur: 4.0, color: nil)

      if self.useLineIndicator! {
        context.setStrokeColor((self.textColor?.cgColor)!)
        context.strokeLineSegments(between: [CGPoint(x: bottomLeft.x+rect.size.width/2, y: bottomLeft.y-0.5), originalPoint])
      }

      /*
        let x = rect.origin.x + rect.size.width / 2.0
        let y = rect.origin.y + rect.size.height
        let height = originalPoint.y - (rect.origin.y + rect.size.height) + self.barOverwrapHeight
        context.setStrokeColor((self.color?.cgColor)!)
        context.stroke(CGRect(x: x, y: y, width: self.strokeWidth, height: height))
        */
    }

    func drawLeftRect(context: CGContext, rect: CGRect, originalPoint: CGPoint) {
      let topLeft = CGPoint(x: rect.origin.x + self.shadowMargin, y: rect.origin.y + self.shadowMargin)
      let topRight = CGPoint(x: rect.origin.x + rect.size.width - self.shadowMargin, y: rect.origin.y + self.shadowMargin)
      let bottomLeft = CGPoint(x: rect.origin.x + self.shadowMargin, y: rect.origin.y + rect.size.height - self.shadowMargin)
      let bottomRight = CGPoint(x: rect.origin.x + rect.size.width - self.shadowMargin, y: rect.origin.y + rect.size.height - self.shadowMargin)

      context.setFillColor((color?.cgColor)!)
      context.setShadow(offset: CGSize(width: 0.0, height: 2.0), blur: 4.0)

      context.beginPath()
      context.move(to: CGPoint(x: topLeft.x, y: topLeft.y))
      context.addLine(to: CGPoint(x: topRight.x, y: topRight.y))
      context.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y))
      if self.useLineIndicator! {
        context.addLine(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y))
      } else {
        context.addLine(to: CGPoint(x: bottomLeft.x + arrowSize.width / 2.0, y: bottomLeft.y))
        context.addLine(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y + arrowSize.height))
      }
      context.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y))
      context.fillPath()

      context.setShadow(offset: CGSize(width: 0.0, height: 2.0), blur: 4.0, color: nil)

      if self.useLineIndicator! {
        context.setStrokeColor((self.textColor?.cgColor)!)
        context.strokeLineSegments(between: [CGPoint(x: bottomLeft.x+0.5, y: bottomLeft.y), originalPoint])
      }

      /*
      let x = rect.origin.x + 0.5
      let y = rect.origin.y + rect.size.height / 2.0
      let height = originalPoint.y - (rect.origin.y + rect.size.height / 2.0) + self.barOverwrapHeight
      context.setStrokeColor((self.color?.cgColor)!)
      context.stroke(CGRect(x: x, y: y, width: self.strokeWidth, height: height))
      */
    }

    func drawRightRect(context: CGContext, rect: CGRect, originalPoint: CGPoint) {
      let topLeft = CGPoint(x: rect.origin.x + self.shadowMargin, y: rect.origin.y + self.shadowMargin)
      let topRight = CGPoint(x: rect.origin.x + rect.size.width - self.shadowMargin, y: rect.origin.y + self.shadowMargin)
      let bottomLeft = CGPoint(x: rect.origin.x + self.shadowMargin, y: rect.origin.y + rect.size.height - self.shadowMargin)
      let bottomRight = CGPoint(x: rect.origin.x + rect.size.width - self.shadowMargin, y: rect.origin.y + rect.size.height - self.shadowMargin)

      context.setFillColor((color?.cgColor)!)
      context.setShadow(offset: CGSize(width: 0.0, height: 2.0), blur: 4.0)

      context.beginPath()
      context.move(to: CGPoint(x: topLeft.x, y: topLeft.y))
      context.addLine(to: CGPoint(x: topRight.x, y: topRight.y))
      if self.useLineIndicator! {
        context.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y))
      } else {
        context.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y + arrowSize.height))
        context.addLine(to: CGPoint(x: bottomRight.x - arrowSize.width / 2.0, y: bottomRight.y))
      }
      context.addLine(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y))
      context.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y))
      context.fillPath()

      context.setShadow(offset: CGSize(width: 0.0, height: 2.0), blur: 4.0, color: nil)

      if self.useLineIndicator! {
        context.setStrokeColor((self.textColor?.cgColor)!)
        context.strokeLineSegments(between: [CGPoint(x: bottomRight.x-0.5, y: bottomRight.y), originalPoint])
      }

      /*
      let x = rect.origin.x + rect.size.width - 0.5
      let y = rect.origin.y + rect.size.height / 2.0
      let height = originalPoint.y - (rect.origin.y + rect.size.height / 2.0) + self.barOverwrapHeight
      context.setStrokeColor((self.color?.cgColor)!)
      context.stroke(CGRect(x: x, y: y, width: self.strokeWidth, height: height))
      */
    }

    func drawTopCenterRect(context: CGContext, rect: CGRect) {
      context.setFillColor((color?.cgColor)!)
      context.setShadow(offset: CGSize(width: 0.0, height: 2.0), blur: 4.0)

      context.beginPath()
      context.move(to: CGPoint(x: rect.origin.x + rect.size.width / 2.0, y: rect.origin.y))
      context.addLine(to: CGPoint(x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0, y: rect.origin.y + arrowSize.height))
      context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + arrowSize.height))
      context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height + arrowSize.height))
      context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height + arrowSize.height))
      context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + arrowSize.height))
      context.addLine(to: CGPoint(x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0, y: rect.origin.y + arrowSize.height))
      context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width / 2.0, y: rect.origin.y))
      context.fillPath()

      context.setShadow(offset: CGSize(width: 0.0, height: 2.0), blur: 4.0, color: nil)
    }

    func drawTopLeftRect(context: CGContext, rect: CGRect) {
      context.setFillColor((color?.cgColor)!)
      context.setShadow(offset: CGSize(width: 0.0, height: 2.0), blur: 4.0)

      context.beginPath()
      context.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
      context.addLine(to: CGPoint(x: rect.origin.x + arrowSize.width / 2.0, y: rect.origin.y + arrowSize.height))
      context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + arrowSize.height))
      context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height + arrowSize.height))
      context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height + arrowSize.height))
      context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
      context.fillPath()

      context.setShadow(offset: CGSize(width: 0.0, height: 2.0), blur: 4.0, color: nil)
    }

    func drawTopRightRect(context: CGContext, rect: CGRect) {
      context.setFillColor((color?.cgColor)!)
      context.setShadow(offset: CGSize(width: 0.0, height: 2.0), blur: 4.0)

      context.beginPath()
      context.move(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y))
      context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height + arrowSize.height))
      context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height + arrowSize.height))
      context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + arrowSize.height))
      context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width - arrowSize.width / 2.0, y: rect.origin.y + arrowSize.height))
      context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y))
      context.fillPath()

      context.setShadow(offset: CGSize(width: 0.0, height: 2.0), blur: 4.0, color: nil)
    }


    open override func draw(context: CGContext, point: CGPoint) {
        guard let labelns = self.labelns, labelns.length > 0 else {
          return
        }

        /*
        var newPoint = point
        newPoint.y = 20 //_size.height
        */

        context.saveGState()

        var (rect, isUpwards) = drawRect(context: context, point: point, originalPoint: point)
        if isUpwards {
          rect.origin.y += arrowSize.height + (insets.top + insets.bottom) / 2
        } else {
          rect.origin.y += (insets.top + insets.bottom) / 2
        }

        UIGraphicsPushContext(context)

        if self.isHtml ?? false, let labelHtml = self.labelHtml {
          labelHtml.draw(in: rect)

        } else {
          _drawAttributes.removeAll()
          _drawAttributes[.font] = self.font
          _drawAttributes[.paragraphStyle] = _paragraphStyle
          _drawAttributes[.foregroundColor] = self.textColor
          labelns.draw(in: rect, withAttributes: _drawAttributes)
        }

        UIGraphicsPopContext()


        context.restoreGState()
    }

    open override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {

        var label : String;

        if let candleEntry = entry as? CandleChartDataEntry {
            label = candleEntry.close.description
        } else {
            label = entry.y.description
        }

        if let object = entry.data as? JSON {
            if object["marker"].exists() {
                label = object["marker"].stringValue;

                if highlight.stackIndex != -1 && object["marker"].array != nil {
                    label = object["marker"].arrayValue[highlight.stackIndex].stringValue
                }

                if object["markerTextColor"].exists() {
                  self.textColor = RCTConvert.uiColor(object["markerTextColor"].intValue)
                }

                self.isMax = object["isMax"].exists() && object["isMax"].bool!
                self.isMin = object["isMin"].exists() && object["isMin"].bool!
                self.isHtml = object["isHtml"].exists() && object["isHtml"].bool!
            }
        }

        // set normal label first
        labelns = label as NSString
        labelHtml = nil

        _drawAttributes.removeAll()
        _drawAttributes[NSAttributedString.Key.font] = self.font
        _drawAttributes[NSAttributedString.Key.paragraphStyle] = _paragraphStyle
        _drawAttributes[NSAttributedString.Key.foregroundColor] = self.textColor

        _labelSize = labelns?.size(withAttributes: _drawAttributes) ?? CGSize.zero

        // override with html label
        if (self.isHtml ?? false) {
          if let data = label.data(using: .utf8) {

            if let htmlLabel = try? NSMutableAttributedString(
              data: data,
              options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
                        NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue],
              documentAttributes: nil) {

              htmlLabel.addAttributes([
                .font: self.font!,
                .paragraphStyle: _paragraphStyle!],
                range: NSRange(location: 0, length: htmlLabel.length))

              labelHtml = htmlLabel
              _labelSize = labelHtml?.size() ?? CGSize.zero
            }
          }
        }

        // calculate drawing size
        _size.width = _labelSize.width + self.insets.left + self.insets.right
        _size.height = _labelSize.height + self.insets.top + self.insets.bottom
        _size.width = max(minimumSize.width, _size.width)
        _size.height = max(minimumSize.height, _size.height)
    }
}
