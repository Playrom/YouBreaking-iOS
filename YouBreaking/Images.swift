//
//  Images.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 17/03/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//
//  Generated by PaintCode
//  http://www.paintcodeapp.com
//



import UIKit

public class Images : NSObject {

    //// Cache

    private struct Cache {
        static var imageOfArrowUp: UIImage?
        static var arrowUpTargets: [AnyObject]?
        static var imageOfArrowDown: UIImage?
        static var arrowDownTargets: [AnyObject]?
        static var imageOfArrowUpFill: UIImage?
        static var arrowUpFillTargets: [AnyObject]?
        static var imageOfArrowDownFill: UIImage?
        static var arrowDownFillTargets: [AnyObject]?
        static var imageOfNo: UIImage?
        static var noTargets: [AnyObject]?
        static var imageOfYes: UIImage?
        static var yesTargets: [AnyObject]?
        static var imageOfCross: UIImage?
        static var crossTargets: [AnyObject]?
    }

    //// Drawing Methods

    public dynamic class func drawArrowUp(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 240, height: 120), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 240, height: 120), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 240, y: resizedFrame.height / 120)


        //// Color Declarations
        let color6 = UIColor(red: 0.839, green: 0.157, blue: 0.157, alpha: 1.000)

        //// Polygon Drawing
        let polygonPath = UIBezierPath()
        polygonPath.move(to: CGPoint(x: 120, y: 3.5))
        polygonPath.addLine(to: CGPoint(x: 234.75, y: 117.5))
        polygonPath.addLine(to: CGPoint(x: 5.25, y: 117.5))
        polygonPath.close()
        color6.setStroke()
        polygonPath.lineWidth = 5
        polygonPath.stroke()


        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 119.5, y: 29.5))
        bezier3Path.addLine(to: CGPoint(x: 119.5, y: 99.5))
        bezier3Path.move(to: CGPoint(x: 84.5, y: 64.5))
        bezier3Path.addLine(to: CGPoint(x: 154.5, y: 64.5))
        color6.setStroke()
        bezier3Path.lineWidth = 5
        bezier3Path.stroke()
        
        context.restoreGState()

    }

    public dynamic class func drawArrowDown(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 240, height: 120), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 240, height: 120), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 240, y: resizedFrame.height / 120)


        //// Color Declarations
        let color6 = UIColor(red: 0.839, green: 0.157, blue: 0.157, alpha: 1.000)

        //// Polygon Drawing
        context.saveGState()
        context.translateBy(x: 252.5, y: 116.5)
        context.rotate(by: -180 * CGFloat.pi/180)

        let polygonPath = UIBezierPath()
        polygonPath.move(to: CGPoint(x: 132.5, y: 0))
        polygonPath.addLine(to: CGPoint(x: 247.25, y: 114.75))
        polygonPath.addLine(to: CGPoint(x: 17.75, y: 114.75))
        polygonPath.close()
        color6.setStroke()
        polygonPath.lineWidth = 5
        polygonPath.stroke()

        context.restoreGState()


        //// Bezier 3 Drawing
        context.saveGState()
        context.translateBy(x: 85.5, y: 46.5)
        context.rotate(by: -90 * CGFloat.pi/180)

        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 0, y: 0))
        bezier3Path.addLine(to: CGPoint(x: 0, y: 70))
        color6.setStroke()
        bezier3Path.lineWidth = 5
        bezier3Path.stroke()

        context.restoreGState()
        
        context.restoreGState()

    }

    public dynamic class func drawArrowUpFill(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 240, height: 120), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 240, height: 120), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 240, y: resizedFrame.height / 120)


        //// Color Declarations
        let color2 = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        let color4 = UIColor(red: 0.839, green: 0.157, blue: 0.157, alpha: 1.000)
        let color5 = UIColor(red: 0.839, green: 0.157, blue: 0.157, alpha: 1.000)

        //// Polygon Drawing
        let polygonPath = UIBezierPath()
        polygonPath.move(to: CGPoint(x: 120.5, y: 3.5))
        polygonPath.addLine(to: CGPoint(x: 235.25, y: 117.5))
        polygonPath.addLine(to: CGPoint(x: 5.75, y: 117.5))
        polygonPath.close()
        color4.setFill()
        polygonPath.fill()
        color5.setStroke()
        polygonPath.lineWidth = 5
        polygonPath.stroke()


        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 120.5, y: 29.5))
        bezierPath.addLine(to: CGPoint(x: 120.5, y: 99.5))
        bezierPath.move(to: CGPoint(x: 85.5, y: 64.5))
        bezierPath.addLine(to: CGPoint(x: 155.5, y: 64.5))
        color2.setStroke()
        bezierPath.lineWidth = 5
        bezierPath.stroke()
        
        context.restoreGState()

    }

    public dynamic class func drawArrowDownFill(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 240, height: 120), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 240, height: 120), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 240, y: resizedFrame.height / 120)


        //// Color Declarations
        let color3 = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        let color6 = UIColor(red: 0.839, green: 0.157, blue: 0.157, alpha: 1.000)

        //// Polygon Drawing
        context.saveGState()
        context.translateBy(x: 253, y: 116)
        context.rotate(by: -180 * CGFloat.pi/180)

        let polygonPath = UIBezierPath()
        polygonPath.move(to: CGPoint(x: 132.5, y: 0))
        polygonPath.addLine(to: CGPoint(x: 247.25, y: 114.75))
        polygonPath.addLine(to: CGPoint(x: 17.75, y: 114.75))
        polygonPath.close()
        color6.setFill()
        polygonPath.fill()
        color6.setStroke()
        polygonPath.lineWidth = 5
        polygonPath.stroke()

        context.restoreGState()


        //// Bezier Drawing
        context.saveGState()
        context.translateBy(x: 85, y: 46.5)
        context.rotate(by: -90 * CGFloat.pi/180)

        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0, y: 0))
        bezierPath.addLine(to: CGPoint(x: 0, y: 70))
        color3.setStroke()
        bezierPath.lineWidth = 5
        bezierPath.stroke()

        context.restoreGState()
        
        context.restoreGState()

    }

    public dynamic class func drawNo(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 150, height: 150), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 150, height: 150), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 150, y: resizedFrame.height / 150)


        //// Group 2
        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: 4, y: 5.5, width: 140.5, height: 140.5))
        UIColor.black.setStroke()
        ovalPath.lineWidth = 3
        ovalPath.stroke()


        //// Group
        //// Bezier 3 Drawing
        context.saveGState()
        context.translateBy(x: 33.5, y: 116.5)
        context.rotate(by: -90 * CGFloat.pi/180)

        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 0, y: 81.5))
        bezier3Path.addCurve(to: CGPoint(x: 81.49, y: 0), controlPoint1: CGPoint(x: 83.37, y: -1.87), controlPoint2: CGPoint(x: 81.49, y: 0))
        UIColor.black.setStroke()
        bezier3Path.lineWidth = 3
        bezier3Path.stroke()

        context.restoreGState()


        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 33.5, y: 116.5))
        bezierPath.addCurve(to: CGPoint(x: 114.37, y: 35.63), controlPoint1: CGPoint(x: 116.23, y: 33.77), controlPoint2: CGPoint(x: 114.37, y: 35.63))
        UIColor.black.setStroke()
        bezierPath.lineWidth = 3
        bezierPath.stroke()
        
        context.restoreGState()

    }

    public dynamic class func drawYes(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 150, height: 150), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 150, height: 150), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 150, y: resizedFrame.height / 150)


        //// Group 2
        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: 4, y: 5.5, width: 140.5, height: 140.5))
        UIColor.black.setStroke()
        ovalPath.lineWidth = 3
        ovalPath.stroke()


        //// Group
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 67.5, y: 116.5))
        bezierPath.addCurve(to: CGPoint(x: 114.37, y: 35.63), controlPoint1: CGPoint(x: 115.45, y: 33.77), controlPoint2: CGPoint(x: 114.37, y: 35.63))
        UIColor.black.setStroke()
        bezierPath.lineWidth = 3
        bezierPath.stroke()




        //// Group 3
        context.saveGState()
        context.translateBy(x: 84.88, y: 69.62)
        context.rotate(by: 90 * CGFloat.pi/180)



        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 6, y: 45.88))
        bezier2Path.addCurve(to: CGPoint(x: 46.87, y: 17), controlPoint1: CGPoint(x: 47.81, y: 16.34), controlPoint2: CGPoint(x: 46.87, y: 17))
        UIColor.black.setStroke()
        bezier2Path.lineWidth = 3
        bezier2Path.stroke()



        context.restoreGState()
        
        context.restoreGState()

    }

    public dynamic class func drawCross(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 150, height: 150), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 150, height: 150), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 150, y: resizedFrame.height / 150)


        //// Group
        //// Bezier 3 Drawing
        context.saveGState()
        context.translateBy(x: 8, y: 142)
        context.rotate(by: -90 * CGFloat.pi/180)

        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 0, y: 134))
        bezier3Path.addCurve(to: CGPoint(x: 133.99, y: 0.01), controlPoint1: CGPoint(x: 137.07, y: -3.07), controlPoint2: CGPoint(x: 133.99, y: 0.01))
        UIColor.black.setStroke()
        bezier3Path.lineWidth = 3
        bezier3Path.stroke()

        context.restoreGState()


        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 7.5, y: 142.5))
        bezierPath.addCurve(to: CGPoint(x: 140.96, y: 9.03), controlPoint1: CGPoint(x: 144.03, y: 5.97), controlPoint2: CGPoint(x: 140.96, y: 9.03))
        UIColor.black.setStroke()
        bezierPath.lineWidth = 3
        bezierPath.stroke()
        
        context.restoreGState()

    }

    //// Generated Images

    public dynamic class var imageOfArrowUp: UIImage {
        if Cache.imageOfArrowUp != nil {
            return Cache.imageOfArrowUp!
        }

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 240, height: 120), false, 0)
            Images.drawArrowUp()

        Cache.imageOfArrowUp = UIGraphicsGetImageFromCurrentImageContext()!.withRenderingMode(.alwaysOriginal)
        UIGraphicsEndImageContext()

        return Cache.imageOfArrowUp!
    }

    public dynamic class var imageOfArrowDown: UIImage {
        if Cache.imageOfArrowDown != nil {
            return Cache.imageOfArrowDown!
        }

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 240, height: 120), false, 0)
            Images.drawArrowDown()

        Cache.imageOfArrowDown = UIGraphicsGetImageFromCurrentImageContext()!.withRenderingMode(.alwaysOriginal)
        UIGraphicsEndImageContext()

        return Cache.imageOfArrowDown!
    }

    public dynamic class var imageOfArrowUpFill: UIImage {
        if Cache.imageOfArrowUpFill != nil {
            return Cache.imageOfArrowUpFill!
        }

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 240, height: 120), false, 0)
            Images.drawArrowUpFill()

        Cache.imageOfArrowUpFill = UIGraphicsGetImageFromCurrentImageContext()!.withRenderingMode(.alwaysOriginal)
        UIGraphicsEndImageContext()

        return Cache.imageOfArrowUpFill!
    }

    public dynamic class var imageOfArrowDownFill: UIImage {
        if Cache.imageOfArrowDownFill != nil {
            return Cache.imageOfArrowDownFill!
        }

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 240, height: 120), false, 0)
            Images.drawArrowDownFill()

        Cache.imageOfArrowDownFill = UIGraphicsGetImageFromCurrentImageContext()!.withRenderingMode(.alwaysOriginal)
        UIGraphicsEndImageContext()

        return Cache.imageOfArrowDownFill!
    }

    public dynamic class var imageOfNo: UIImage {
        if Cache.imageOfNo != nil {
            return Cache.imageOfNo!
        }

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 150, height: 150), false, 0)
            Images.drawNo()

        Cache.imageOfNo = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return Cache.imageOfNo!
    }

    public dynamic class var imageOfYes: UIImage {
        if Cache.imageOfYes != nil {
            return Cache.imageOfYes!
        }

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 150, height: 150), false, 0)
            Images.drawYes()

        Cache.imageOfYes = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return Cache.imageOfYes!
    }

    public dynamic class var imageOfCross: UIImage {
        if Cache.imageOfCross != nil {
            return Cache.imageOfCross!
        }

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 150, height: 150), false, 0)
            Images.drawCross()

        Cache.imageOfCross = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return Cache.imageOfCross!
    }

    //// Customization Infrastructure

    @IBOutlet dynamic var arrowUpTargets: [AnyObject]! {
        get { return Cache.arrowUpTargets }
        set {
            Cache.arrowUpTargets = newValue
            for target: AnyObject in newValue {
                let _ = target.perform(NSSelectorFromString("setImage:"), with: Images.imageOfArrowUp)
            }
        }
    }

    @IBOutlet dynamic var arrowDownTargets: [AnyObject]! {
        get { return Cache.arrowDownTargets }
        set {
            Cache.arrowDownTargets = newValue
            for target: AnyObject in newValue {
                let _ = target.perform(NSSelectorFromString("setImage:"), with: Images.imageOfArrowDown)
            }
        }
    }

    @IBOutlet dynamic var arrowUpFillTargets: [AnyObject]! {
        get { return Cache.arrowUpFillTargets }
        set {
            Cache.arrowUpFillTargets = newValue
            for target: AnyObject in newValue {
                let _ = target.perform(NSSelectorFromString("setImage:"), with: Images.imageOfArrowUpFill)
            }
        }
    }

    @IBOutlet dynamic var arrowDownFillTargets: [AnyObject]! {
        get { return Cache.arrowDownFillTargets }
        set {
            Cache.arrowDownFillTargets = newValue
            for target: AnyObject in newValue {
                let _ = target.perform(NSSelectorFromString("setImage:"), with: Images.imageOfArrowDownFill)
            }
        }
    }

    @IBOutlet dynamic var noTargets: [AnyObject]! {
        get { return Cache.noTargets }
        set {
            Cache.noTargets = newValue
            for target: AnyObject in newValue {
                let _ = target.perform(NSSelectorFromString("setImage:"), with: Images.imageOfNo)
            }
        }
    }

    @IBOutlet dynamic var yesTargets: [AnyObject]! {
        get { return Cache.yesTargets }
        set {
            Cache.yesTargets = newValue
            for target: AnyObject in newValue {
                let _ = target.perform(NSSelectorFromString("setImage:"), with: Images.imageOfYes)
            }
        }
    }

    @IBOutlet dynamic var crossTargets: [AnyObject]! {
        get { return Cache.crossTargets }
        set {
            Cache.crossTargets = newValue
            for target: AnyObject in newValue {
                let _ = target.perform(NSSelectorFromString("setImage:"), with: Images.imageOfCross)
            }
        }
    }




    @objc public enum ResizingBehavior: Int {
        case aspectFit /// The content is proportionally resized to fit into the target rectangle.
        case aspectFill /// The content is proportionally resized to completely fill the target rectangle.
        case stretch /// The content is stretched to match the entire target rectangle.
        case center /// The content is centered in the target rectangle, but it is NOT resized.

        public func apply(rect: CGRect, target: CGRect) -> CGRect {
            if rect == target || target == CGRect.zero {
                return rect
            }

            var scales = CGSize.zero
            scales.width = abs(target.width / rect.width)
            scales.height = abs(target.height / rect.height)

            switch self {
                case .aspectFit:
                    scales.width = min(scales.width, scales.height)
                    scales.height = scales.width
                case .aspectFill:
                    scales.width = max(scales.width, scales.height)
                    scales.height = scales.width
                case .stretch:
                    break
                case .center:
                    scales.width = 1
                    scales.height = 1
            }

            var result = rect.standardized
            result.size.width *= scales.width
            result.size.height *= scales.height
            result.origin.x = target.minX + (target.width - result.width) / 2
            result.origin.y = target.minY + (target.height - result.height) / 2
            return result
        }
    }
}
