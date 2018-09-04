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
    open var separatorColor: UIColor?
    open var accentColor: UIColor?
    open var minimumSize = CGSize()

    fileprivate var insets = UIEdgeInsetsMake(0.0, 8.0, 4.0, 8.0)
    fileprivate var topInsets = UIEdgeInsetsMake(20.0, 8.0, 8.0, 8.0)

    fileprivate var labelns: NSString?
    fileprivate var _labelSize: CGSize = CGSize()
    fileprivate var _size: CGSize = CGSize()
    fileprivate var _paragraphStyle: NSMutableParagraphStyle?
    fileprivate var _paragraphStyleLeft: NSMutableParagraphStyle?
    fileprivate var _drawAttributes = [String: AnyObject]()

    fileprivate var isMax: Bool?
    fileprivate var isMin: Bool?
    fileprivate var isDH: Bool?
    fileprivate let barOverwrapHeight: CGFloat = 10.0
    fileprivate let strokeWidth: CGFloat = 0.1
  
    public init(color: UIColor, font: UIFont, textColor: UIColor) {
        super.init(frame: CGRect.zero);
        self.color = color
        self.font = font
        self.textColor = textColor

        _paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        _paragraphStyle?.alignment = .center

        _paragraphStyleLeft = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        _paragraphStyleLeft?.alignment = .left
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }


    func drawRect(context: CGContext, point: CGPoint, originalPoint: CGPoint) -> CGRect{

        let chart = super.chartView

        let width = _size.width


        var rect = CGRect(origin: point, size: _size)


        //rect.origin.y -= _size.height
      
        if point.x - _size.width / 2.0 < 0 {
          drawLeftLine(context: context, rect: rect, originalPoint: originalPoint)
        } else if (chart != nil && point.x + width - _size.width / 2.0 > (chart?.bounds.width)!) {
          rect.origin.x -= _size.width
          drawRightLine(context: context, rect: rect, originalPoint: originalPoint)
        } else {
          rect.origin.x -= _size.width / 2.0
          drawCenterLine(context: context, rect: rect, originalPoint: originalPoint)
        }
      
        //rect.origin.y += self.insets.top
        //rect.size.height -= self.insets.top + self.insets.bottom
        //rect.size.height += originalPoint.y - _size.height
      
      
        /*
        if point.y - _size.height < 0 {

            if point.x - _size.width / 2.0 < 0 {
                drawTopLeftRect(context: context, rect: rect)
            } else if (chart != nil && point.x + width - _size.width / 2.0 > (chart?.bounds.width)!) {
                rect.origin.x -= _size.width
                drawTopRightRect(context: context, rect: rect)
            } else {
                rect.origin.x -= _size.width / 2.0
                drawTopCenterRect(context: context, rect: rect)
            }

            rect.origin.y += self.topInsets.top
            rect.size.height -= self.topInsets.top + self.topInsets.bottom

        } else {

            rect.origin.y -= _size.height

            if point.x - _size.width / 2.0 < 0 {
                drawLeftRect(context: context, rect: rect)
            } else if (chart != nil && point.x + width - _size.width / 2.0 > (chart?.bounds.width)!) {
                rect.origin.x -= _size.width
                drawRightRect(context: context, rect: rect)
            } else {
                rect.origin.x -= _size.width / 2.0
                drawCenterRect(context: context, rect: rect)
            }

            rect.origin.y += self.insets.top
            rect.size.height -= self.insets.top + self.insets.bottom

        }
        */

        return rect
    }

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

  
    /*
    func drawCenterRect(context: CGContext, rect: CGRect) {

        context.setFillColor((color?.cgColor)!)
        context.beginPath()
        context.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height - arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0, y: rect.origin.y + rect.size.height - arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width / 2.0, y: rect.origin.y + rect.size.height))
        context.addLine(to: CGPoint(x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0, y: rect.origin.y + rect.size.height - arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height - arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
        context.fillPath()

    }

    func drawLeftRect(context: CGContext, rect: CGRect) {
        context.setFillColor((color?.cgColor)!)
        context.beginPath()
        context.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height - arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x + arrowSize.width / 2.0, y: rect.origin.y + rect.size.height - arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height))
        context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
        context.fillPath()

    }

    func drawRightRect(context: CGContext, rect: CGRect) {
        context.setFillColor((color?.cgColor)!)
        context.beginPath()
        context.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height))
        context.addLine(to: CGPoint(x: rect.origin.x  + rect.size.width - arrowSize.width / 2.0, y: rect.origin.y + rect.size.height - arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height - arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
        context.fillPath()

    }

    func drawTopCenterRect(context: CGContext, rect: CGRect) {

        context.setFillColor((color?.cgColor)!)
        context.beginPath()
        context.move(to: CGPoint(x: rect.origin.x + rect.size.width / 2.0, y: rect.origin.y))
        context.addLine(to: CGPoint(x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0, y: rect.origin.y + arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height))
        context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height))
        context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0, y: rect.origin.y + arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width / 2.0, y: rect.origin.y))
        context.fillPath()

    }

    func drawTopLeftRect(context: CGContext, rect: CGRect) {
        context.setFillColor((color?.cgColor)!)
        context.beginPath()
        context.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
        context.addLine(to: CGPoint(x: rect.origin.x + arrowSize.width / 2.0, y: rect.origin.y + arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height))
        context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height))
        context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
        context.fillPath()

    }

    func drawTopRightRect(context: CGContext, rect: CGRect) {
        context.setFillColor((color?.cgColor)!)
        context.beginPath()
        context.move(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height))
        context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height))
        context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width - arrowSize.height / 2.0, y: rect.origin.y + arrowSize.height))
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y))
        context.fillPath()

    }
    */


    open override func draw(context: CGContext, point: CGPoint) {
        guard let labelns = self.labelns, labelns.length > 0 else {
          return
        }
  
        var newPoint = point
        newPoint.y = (isMin ?? false) ? _size.height : 0.0

        context.saveGState()

        let rect = drawRect(context: context, point: newPoint, originalPoint: point)

        UIGraphicsPushContext(context)

        if(isDH ?? false) {
          // for district heating graph
          // draw text 4 times:
          // (1) weather temperature (2) out-temperature (3) separater (4) in-temperature
          _drawAttributes.removeAll()
          _drawAttributes[NSFontAttributeName] = self.font
          _drawAttributes[NSParagraphStyleAttributeName] = _paragraphStyle
          _drawAttributes[NSForegroundColorAttributeName] = self.textColor

          // 1: weather
          let range = labelns.range(of: "\n")
          if range.location != NSNotFound, labelns.length >= range.location+1 {
            let labelWeather = "\n\(labelns.substring(from: range.location+1))" as NSString
            labelWeather.draw(in: rect, withAttributes: _drawAttributes)
          }

          // 2: out-temperature
          if let accentColor = self.accentColor {
            let range = labelns.range(of: "\n")
            _drawAttributes[NSForegroundColorAttributeName] = accentColor
            _drawAttributes[NSParagraphStyleAttributeName] = _paragraphStyleLeft

            if range.location != NSNotFound {
              let labelWithoutWeather = labelns.substring(to: range.location) as NSString
              labelWithoutWeather.draw(in: rect, withAttributes: _drawAttributes)
            } else {
              labelns.draw(in: rect, withAttributes: _drawAttributes)
            }
          }

          // 3: separater
          if let separatorColor = self.separatorColor {
            let range = labelns.range(of: "/")
            _drawAttributes[NSForegroundColorAttributeName] = separatorColor
            _drawAttributes[NSParagraphStyleAttributeName] = _paragraphStyleLeft

            if range.location != NSNotFound {
              let labelWithoutOutTemeprature = labelns.substring(to: range.location+1) as NSString
              labelWithoutOutTemeprature.draw(in: rect, withAttributes: _drawAttributes)
            }
          }
          
          // 4: in-temperature
          let inRange = labelns.range(of: "/")
          _drawAttributes[NSForegroundColorAttributeName] = self.textColor
          _drawAttributes[NSParagraphStyleAttributeName] = _paragraphStyleLeft

          if inRange.location != NSNotFound {
            let labelInTemperature = labelns.substring(to: inRange.location) as NSString
            labelInTemperature.draw(in: rect, withAttributes: _drawAttributes)
          }

        } else {
          _drawAttributes.removeAll()
          _drawAttributes[NSFontAttributeName] = self.font
          _drawAttributes[NSParagraphStyleAttributeName] = _paragraphStyle
          _drawAttributes[NSForegroundColorAttributeName] = self.textColor
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
              
                if object["markerSeparatorColor"].exists() {
                  self.separatorColor = RCTConvert.uiColor(object["markerSeparatorColor"].intValue)
                }
              
                if object["markerAccentColor"].exists() {
                  self.accentColor = RCTConvert.uiColor(object["markerAccentColor"].intValue)
                }
              
                self.isMax = object["isMax"].exists() && object["isMax"].bool!
                self.isMin = object["isMin"].exists() && object["isMin"].bool!
                self.isDH = object["isDH"].exists() && object["isDH"].bool!
            }
        }

        labelns = label as NSString

        _drawAttributes.removeAll()
        _drawAttributes[NSFontAttributeName] = self.font
        _drawAttributes[NSParagraphStyleAttributeName] = _paragraphStyleLeft
        _drawAttributes[NSForegroundColorAttributeName] = self.textColor

        _labelSize = labelns?.size(attributes: _drawAttributes) ?? CGSize.zero
        _size.width = _labelSize.width // + self.insets.left + self.insets.right
        _size.height = _labelSize.height + self.insets.top + self.insets.bottom
        _size.width = max(minimumSize.width, _size.width)
        _size.height = max(minimumSize.height, _size.height)

    }
}
