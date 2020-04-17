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

    fileprivate var insets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    fileprivate var dividerInsets = UIEdgeInsets(top: 8.0, left: 4.0, bottom: 8.0, right: 4.0)
    fileprivate let margin: CGFloat = 8.0

    fileprivate var labelns: NSString?
    fileprivate var labelHtml: NSAttributedString?
    fileprivate var leftLabelHtml: NSAttributedString?
    fileprivate var rightLabelHtml: NSAttributedString?
    fileprivate var _labelSize: CGSize = CGSize()
    fileprivate var _size: CGSize = CGSize()
    fileprivate var _paragraphStyle: NSMutableParagraphStyle?
    fileprivate var _drawAttributes = [NSAttributedString.Key: Any]()

    fileprivate var isMax: Bool?
    fileprivate var isMin: Bool?
    fileprivate var isHtml: Bool?
    fileprivate var isSideBySide: Bool?
    fileprivate var labelDividerColor: UIColor = UIColor.gray
    fileprivate var labelDividerWidth: CGFloat = 2.0
    fileprivate let barOverwrapHeight: CGFloat = 10.0
    fileprivate let strokeWidth: CGFloat = 0.1

    public init(color: UIColor, font: UIFont, textColor: UIColor) {
        super.init(frame: CGRect.zero);
        self.color = color
        self.font = font
        self.textColor = textColor
        self.useLineIndicator = false

        self._paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        self._paragraphStyle?.alignment = .center
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }

    func drawRect(context: CGContext, point: CGPoint, originalPoint: CGPoint) -> (CGRect, Bool) {

      guard let chart = super.chartView else {
        return (CGRect.zero, false)
      }

      let chartWidth = chart.bounds.width
      let extraInset = max(0.0, (chartWidth - self._size.width) / 2.0)
      var rect = CGRect(origin: point, size: self._size)
      var isUpwards = false

      if self.useLineIndicator! {
        // Marker upwards rect only
        rect.origin.y = 0

        if point.x < extraInset {
          if originalPoint.y < _size.height + self.margin {
            rect.origin.x += self.margin
          }
          self.drawLeftRect(context: context, rect: rect, originalPoint: originalPoint)

        } else if (self._size.width + extraInset < point.x) {
          if originalPoint.y < self._size.height + self.margin {
            rect.origin.x -= self.margin
          }
          rect.origin.x -= self._size.width
          self.drawRightRect(context: context, rect: rect, originalPoint: originalPoint)

        } else {
          if originalPoint.y < self._size.height + self.margin {
            if originalPoint.x < chartWidth / 2.0 {
              rect.origin.x += self.margin
            } else {
              rect.origin.x -= self.margin
            }
          }
          rect.origin.x -= self._size.width / 2.0
          self.drawCenterRect(context: context, rect: rect, originalPoint: originalPoint)
        }
      } else {
        // Marker with upwards/downwards rect
        if point.y - self._size.height - self.arrowSize.height - self.margin < 0 {
            // upwards /\
            rect.origin.y += self.margin

            if point.x < extraInset {
                self.drawTopLeftRect(context: context, rect: rect)
            } else if (self._size.width + extraInset < point.x) {
                rect.origin.x -= self._size.width
                self.drawTopRightRect(context: context, rect: rect)
            } else {
                rect.origin.x = extraInset
                self.drawTopCenterRect(context: context, rect: rect, originalPoint: originalPoint)
            }
            isUpwards = true

        } else {
            // downwards \/
            rect.origin.y -= self._size.height + self.arrowSize.height + self.margin

            if point.x < extraInset {
                self.drawLeftRect(context: context, rect: rect, originalPoint: originalPoint)
            } else if (self._size.width + extraInset < point.x) {
                rect.origin.x -= self._size.width
                self.drawRightRect(context: context, rect: rect, originalPoint: originalPoint)
            } else {
                rect.origin.x = extraInset
                self.drawCenterRect(context: context, rect: rect, originalPoint: originalPoint)
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

    func drawDivider(context: CGContext, rect: CGRect) {
      let x = rect.origin.x + self.insets.left + (self.leftLabelHtml?.size().width ?? 0) + self.dividerInsets.left
      let top = CGPoint(x: x, y: rect.origin.y + self.insets.top)
      let bottom = CGPoint(x: x, y: rect.origin.y + rect.size.height - self.insets.bottom)

      context.setStrokeColor(self.labelDividerColor.cgColor)
      context.strokeLineSegments(between: [top, bottom])
    }

    func drawCenterRect(context: CGContext, rect: CGRect, originalPoint: CGPoint) {
      let topLeft = CGPoint(x: rect.origin.x, y: rect.origin.y)
      let topRight = CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y)
      let bottomLeft = CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height)
      let bottomRight = CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height)

      let arrowLeftEdge = max(bottomLeft.x, originalPoint.x - self.arrowSize.width / 2.0)
      let arrowRightEdge = min(bottomRight.x, originalPoint.x + self.arrowSize.width / 2.0)

      context.setFillColor((self.color?.cgColor)!)
      context.setShadow(offset: CGSize(width: 0.0, height: 2.0), blur: 4.0)

      context.beginPath()
      context.move(to: topLeft)
      context.addLine(to: topRight)
      context.addLine(to: bottomRight)
      if !self.useLineIndicator! {
        context.addLine(to: CGPoint(x: arrowRightEdge, y: bottomRight.y))
        context.addLine(to: CGPoint(x: originalPoint.x, y: bottomLeft.y + self.arrowSize.height))
        context.addLine(to: CGPoint(x: arrowLeftEdge, y: bottomRight.y))
      }
      context.addLine(to: bottomLeft)
      context.addLine(to: topLeft)
      context.fillPath()

      context.setShadow(offset: CGSize(width: 0.0, height: 2.0), blur: 4.0, color: nil)

      if self.useLineIndicator! {
        context.setStrokeColor((self.textColor?.cgColor)!)
        context.strokeLineSegments(between: [CGPoint(x: bottomLeft.x+rect.size.width/2, y: bottomLeft.y-0.5), originalPoint])
      }

      // draw divider if needed
      if (self.isSideBySide ?? false) {
        self.drawDivider(context: context, rect: CGRect(x: topLeft.x, y: topLeft.y, width: topRight.x-topLeft.x, height: bottomRight.y-topRight.y))
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
      let topLeft = CGPoint(x: rect.origin.x, y: rect.origin.y)
      let topRight = CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y)
      let bottomLeft = CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height)
      let bottomRight = CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height)

      context.setFillColor((self.color?.cgColor)!)
      context.setShadow(offset: CGSize(width: 0.0, height: 2.0), blur: 4.0)

      context.beginPath()
      context.move(to: CGPoint(x: topLeft.x, y: topLeft.y))
      context.addLine(to: CGPoint(x: topRight.x, y: topRight.y))
      context.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y))
      if self.useLineIndicator! {
        context.addLine(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y))
      } else {
        context.addLine(to: CGPoint(x: bottomLeft.x + self.arrowSize.width / 2.0, y: bottomLeft.y))
        context.addLine(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y + self.arrowSize.height))
      }
      context.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y))
      context.fillPath()

      context.setShadow(offset: CGSize(width: 0.0, height: 2.0), blur: 4.0, color: nil)

      if self.useLineIndicator! {
        context.setStrokeColor((self.textColor?.cgColor)!)
        context.strokeLineSegments(between: [CGPoint(x: bottomLeft.x+0.5, y: bottomLeft.y), originalPoint])
      }

      // draw divider if needed
      if (self.isSideBySide ?? false) {
        self.drawDivider(context: context, rect: CGRect(x: topLeft.x, y: topLeft.y, width: topRight.x-topLeft.x, height: bottomRight.y-topRight.y))
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
      let topLeft = CGPoint(x: rect.origin.x, y: rect.origin.y)
      let topRight = CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y)
      let bottomLeft = CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height)
      let bottomRight = CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height)

      context.setFillColor((color?.cgColor)!)
      context.setShadow(offset: CGSize(width: 0.0, height: 2.0), blur: 4.0)

      context.beginPath()
      context.move(to: CGPoint(x: topLeft.x, y: topLeft.y))
      context.addLine(to: CGPoint(x: topRight.x, y: topRight.y))
      if self.useLineIndicator! {
        context.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y))
      } else {
        context.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y + self.arrowSize.height))
        context.addLine(to: CGPoint(x: bottomRight.x - self.arrowSize.width / 2.0, y: bottomRight.y))
      }
      context.addLine(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y))
      context.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y))
      context.fillPath()

      context.setShadow(offset: CGSize(width: 0.0, height: 2.0), blur: 4.0, color: nil)

      if self.useLineIndicator! {
        context.setStrokeColor((self.textColor?.cgColor)!)
        context.strokeLineSegments(between: [CGPoint(x: bottomRight.x-0.5, y: bottomRight.y), originalPoint])
      }

      // draw divider if needed
      if (self.isSideBySide ?? false) {
        self.drawDivider(context: context, rect: CGRect(x: topLeft.x, y: topLeft.y, width: topRight.x-topLeft.x, height: bottomRight.y-topRight.y))
      }

      /*
      let x = rect.origin.x + rect.size.width - 0.5
      let y = rect.origin.y + rect.size.height / 2.0
      let height = originalPoint.y - (rect.origin.y + rect.size.height / 2.0) + self.barOverwrapHeight
      context.setStrokeColor((self.color?.cgColor)!)
      context.stroke(CGRect(x: x, y: y, width: self.strokeWidth, height: height))
      */
    }

    func drawTopCenterRect(context: CGContext, rect: CGRect, originalPoint: CGPoint) {
      let topLeft = CGPoint(x: rect.origin.x, y: rect.origin.y + self.arrowSize.height)
      let topRight = CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + self.arrowSize.height)
      let bottomLeft = CGPoint(x: rect.origin.x, y: rect.origin.y + self.arrowSize.height + rect.size.height)
      let bottomRight = CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + self.arrowSize.height + rect.size.height)

      let arrowLeftEdge = max(topLeft.x, originalPoint.x - self.arrowSize.width / 2.0)
      let arrowRightEdge = min(topRight.x, originalPoint.x + self.arrowSize.width / 2.0)

      context.setFillColor((self.color?.cgColor)!)
      context.setShadow(offset: CGSize(width: 0.0, height: 2.0), blur: 4.0)

      context.beginPath()
      context.move(to: CGPoint(x: originalPoint.x, y: rect.origin.y))
      context.addLine(to: CGPoint(x: arrowRightEdge, y: rect.origin.y + self.arrowSize.height))
      context.addLine(to: topRight)
      context.addLine(to: bottomRight)
      context.addLine(to: bottomLeft)
      context.addLine(to: topLeft)
      context.addLine(to: CGPoint(x: arrowLeftEdge, y: rect.origin.y + self.arrowSize.height))
      context.addLine(to: CGPoint(x: originalPoint.x, y: rect.origin.y))
      context.fillPath()

      context.setShadow(offset: CGSize(width: 0.0, height: 2.0), blur: 4.0, color: nil)

      // draw divider if needed
      if (self.isSideBySide ?? false) {
        self.drawDivider(context: context, rect: CGRect(x: topLeft.x, y: topLeft.y, width: topRight.x-topLeft.x, height: bottomRight.y-topRight.y))
      }
    }

    func drawTopLeftRect(context: CGContext, rect: CGRect) {
      let topLeft = CGPoint(x: rect.origin.x, y: rect.origin.y + self.arrowSize.height)
      let topRight = CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + self.arrowSize.height)
      let bottomLeft = CGPoint(x: rect.origin.x, y: rect.origin.y + self.arrowSize.height + rect.size.height)
      let bottomRight = CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + self.arrowSize.height + rect.size.height)

      context.setFillColor((self.color?.cgColor)!)
      context.setShadow(offset: CGSize(width: 0.0, height: 2.0), blur: 4.0)

      context.beginPath()
      context.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
      context.addLine(to: CGPoint(x: rect.origin.x + self.arrowSize.width / 2.0, y: rect.origin.y + self.arrowSize.height))
      context.addLine(to: topRight)
      context.addLine(to: bottomRight)
      context.addLine(to: bottomLeft)
      context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
      context.fillPath()

      context.setShadow(offset: CGSize(width: 0.0, height: 2.0), blur: 4.0, color: nil)

      // draw divider if needed
      if (self.isSideBySide ?? false) {
        self.drawDivider(context: context, rect: CGRect(x: topLeft.x, y: topLeft.y, width: topRight.x-topLeft.x, height: bottomRight.y-topRight.y))
      }
    }

    func drawTopRightRect(context: CGContext, rect: CGRect) {
      let topLeft = CGPoint(x: rect.origin.x, y: rect.origin.y + self.arrowSize.height)
      let topRight = CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + self.arrowSize.height)
      let bottomLeft = CGPoint(x: rect.origin.x, y: rect.origin.y + self.arrowSize.height + rect.size.height)
      let bottomRight = CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + self.arrowSize.height + rect.size.height)

      context.setFillColor((self.color?.cgColor)!)
      context.setShadow(offset: CGSize(width: 0.0, height: 2.0), blur: 4.0)

      context.beginPath()
      context.move(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y))
      context.addLine(to: bottomRight)
      context.addLine(to: bottomLeft)
      context.addLine(to: topLeft)
      context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width - self.arrowSize.width / 2.0, y: rect.origin.y + self.arrowSize.height))
      context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y))
      context.fillPath()

      context.setShadow(offset: CGSize(width: 0.0, height: 2.0), blur: 4.0, color: nil)

      // draw divider if needed
      if (self.isSideBySide ?? false) {
        self.drawDivider(context: context, rect: CGRect(x: topLeft.x, y: topLeft.y, width: topRight.x-topLeft.x, height: bottomRight.y-topRight.y))
      }
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

        var (rect, isUpwards) = self.drawRect(context: context, point: point, originalPoint: point)
        if isUpwards {
          rect.origin.y += self.arrowSize.height + (self.insets.top + self.insets.bottom) / 2.0
        } else {
          rect.origin.y += (self.insets.top + self.insets.bottom) / 2.0
        }

        UIGraphicsPushContext(context)

        if self.isHtml ?? false, let labelHtml = self.labelHtml {
          labelHtml.draw(in: rect)

        } else if self.isSideBySide ?? false, let leftLabelHtml = self.leftLabelHtml, let rightLabelHtml = self.rightLabelHtml {
          rect.origin.x += self.insets.left

          let leftRect = CGRect(x: rect.origin.x, y: rect.origin.y, width: leftLabelHtml.size().width, height: leftLabelHtml.size().height)
          let rightRect = CGRect(x: rect.origin.x + leftLabelHtml.size().width + self.dividerInsets.left + self.dividerInsets.right + self.labelDividerWidth,
                                 y: rect.origin.y, width: (rect.width - self.labelDividerWidth - self.insets.left)/2 + self.insets.left, height: rect.height)

          leftLabelHtml.draw(in: leftRect)
          rightLabelHtml.draw(in: rightRect)

        } else {
          self._drawAttributes.removeAll()
          self._drawAttributes[.font] = self.font
          self._drawAttributes[.paragraphStyle] = self._paragraphStyle
          self._drawAttributes[.foregroundColor] = self.textColor
          labelns.draw(in: rect, withAttributes: self._drawAttributes)
        }

        UIGraphicsPopContext()


        context.restoreGState()
    }

    open override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {

        var label : String;
        var leftLabel = "";
        var rightLabel = "";

        if let candleEntry = entry as? CandleChartDataEntry {
            label = candleEntry.close.description
        } else {
            label = entry.y.description
        }

        if let object = entry.data as? JSON {
            self.isMax = object["isMax"].exists() && object["isMax"].bool!
            self.isMin = object["isMin"].exists() && object["isMin"].bool!
            self.isHtml = object["isHtml"].exists() && object["isHtml"].bool!
            self.isSideBySide = object["isSideBySide"].exists() && object["isSideBySide"].bool!

            if object["marker"].exists() {
                label = object["marker"].stringValue;

                if highlight.stackIndex != -1 && object["marker"].array != nil {
                    label = object["marker"].arrayValue[highlight.stackIndex].stringValue
                }

                if object["markerTextColor"].exists() {
                  self.textColor = RCTConvert.uiColor(object["markerTextColor"].intValue)
                }
            }

            if (self.isSideBySide ?? false && object["leftMarker"].exists() && object["rightMarker"].exists()) {
                leftLabel = object["leftMarker"].stringValue;
                rightLabel = object["rightMarker"].stringValue;

                if (object["dividerColor"].exists()) {
                    self.labelDividerColor = RCTConvert.uiColor(object["dividerColor"].intValue)
                }

                if (object["dividerWidth"].exists()) {
                    self.labelDividerWidth = CGFloat(object["dividerWidth"].floatValue)
                }
            }
        }

        // set normal label first
        self.labelns = label as NSString
        self.labelHtml = nil
        self.leftLabelHtml = nil
        self.rightLabelHtml = nil

        self._drawAttributes.removeAll()
        self._drawAttributes[NSAttributedString.Key.font] = self.font
        self._drawAttributes[NSAttributedString.Key.paragraphStyle] = self._paragraphStyle
        self._drawAttributes[NSAttributedString.Key.foregroundColor] = self.textColor

        self._labelSize = self.labelns?.size(withAttributes: self._drawAttributes) ?? CGSize.zero
        self._paragraphStyle?.alignment = .center

        if (self.isSideBySide ?? false) {
          // override with side by side html labales
          self._labelSize = CGSize.zero
          self._paragraphStyle?.alignment = .natural

          if let leftData = leftLabel.data(using: .utf8), let rightData = rightLabel.data(using: .utf8) {

            if let htmlLabel = try? NSMutableAttributedString(
              data: leftData,
              options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
                        NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue],
              documentAttributes: nil) {

              htmlLabel.addAttributes([
                .font: self.font!,
                .paragraphStyle: self._paragraphStyle!],
                range: NSRange(location: 0, length: htmlLabel.length))

              self.leftLabelHtml = htmlLabel
              self._labelSize = CGSize(width: (self.leftLabelHtml?.size() ?? CGSize.zero).width,
                                  height: (self.leftLabelHtml?.size() ?? CGSize.zero).height)
            }

            if let htmlLabel = try? NSMutableAttributedString(
              data: rightData,
              options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
                      NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue],
              documentAttributes: nil) {

              htmlLabel.addAttributes([
              .font: self.font!,
              .paragraphStyle: self._paragraphStyle!],
              range: NSRange(location: 0, length: htmlLabel.length))

              self.rightLabelHtml = htmlLabel
              self._labelSize.width += (self.rightLabelHtml?.size() ?? CGSize.zero).width
              self._labelSize.height = max((self.rightLabelHtml?.size() ?? CGSize.zero).height, self._labelSize.height)
            }

            // add extra width for divider and insets
            self._labelSize.width += self.labelDividerWidth
            self._labelSize.width += self.dividerInsets.left + self.dividerInsets.right
          }

        } else if (self.isHtml ?? false) {
          // override with html label
          if let data = label.data(using: .utf8) {

            if let htmlLabel = try? NSMutableAttributedString(
              data: data,
              options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
                        NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue],
              documentAttributes: nil) {

              htmlLabel.addAttributes([
                .font: self.font!,
                .paragraphStyle: self._paragraphStyle!],
                range: NSRange(location: 0, length: htmlLabel.length))

              self.labelHtml = htmlLabel
              self._labelSize = self.labelHtml?.size() ?? CGSize.zero
            }
          }
        }

        // calculate drawing size
        _size.width = _labelSize.width + self.insets.left + self.insets.right
        _size.height = _labelSize.height + self.insets.top + self.insets.bottom
        _size.width = max(self.minimumSize.width, self._size.width)
        _size.height = max(self.minimumSize.height, self._size.height)
    }
}
