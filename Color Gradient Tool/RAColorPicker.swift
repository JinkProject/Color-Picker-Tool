//
//  RAColorPicker.swift
//  Color Gradient Tool
//
//  Created by Stephen Whitfield on 12/18/15.
//  Copyright © 2015 Stephen Whitfield. All rights reserved.
//

import UIKit

/**
Type of gradient applied to view
*/

public enum Gradient {
    case Color
    case Transparent
}

protocol RAColorPickerDelegate {
    
    /**
    Updates color values after an update from tap or pan
     
     - parameter pickerColor Current color from color picker
    */
    
    func pickerColorDidChange(pickerColor: UIColor)
}

public class RAColorPicker: UIView {
    
    /// Pass messages to the listener
    var colorPickerDelegate: RAColorPickerDelegate?
    
    /// Pan gesture for finding color
    private var panGesture: UIPanGestureRecognizer!
    
    /// Tap gesture for picking color from tap
    private var tapGesture: UITapGestureRecognizer!
    
    /// Adds color picker to view
    convenience init(referenceView: UIView) {
        self.init()
        sizeColorPickerRelativeToView(referenceView)
        embedGestureRecognizers()
    }
    
    /// Support subclassing RAColorPicker via storyboard
    override public func awakeFromNib() {
        embedGestureRecognizers()
    }
    
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        applyGradient(gradientType: .Color)
        applyGradient(gradientType: .Transparent)
    }
    
    // MARK: Add gesture recognizers
    
    /**
    Adds gesture recognizers
    */
    
    private func embedGestureRecognizers() {
        panGesture = UIPanGestureRecognizer(target: self, action: "handleGesture:")
        tapGesture = UITapGestureRecognizer(target: self, action: "handleGesture:")
        addGestureRecognizer(panGesture)
        addGestureRecognizer(tapGesture)
    }
    
    /**
    Action method that handles responses sent by the gesture recognizers

    - parameter gesture: The gesture recognizer sending the events
    */
    
    func handleGesture(gesture: UIGestureRecognizer) {
        let location: CGPoint = gesture.locationInView(self)
        let viewWidth = bounds.width
        switch gesture.state {
            case .Began, .Changed, .Ended:
                if bounds.contains(location) {
                    colorPickerDelegate?.pickerColorDidChange(colorOfPixel(location))
                } else {
                    colorPickerDelegate?.pickerColorDidChange(UIColor(white: location.x/viewWidth, alpha: 1)) // If touch runs off gradient's bounds, toggle between white/black
                }
                break
            default:
                break
        }
    }
    
    // MARK: Gradient builders / applicators
    
    /**
    Creates a gradient object with which to apply gradients

    - parameter type: The type of color gradient to apply
    */
    
    private func createGradient(gradientType type: Gradient) -> CGGradientRef {
        let transparencyGradient: CGGradientRef
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let num_locations: size_t
        let locations: [CGFloat]
        let components: [CGFloat]
        
        if type == .Transparent {
            num_locations = 5
            locations = [ 0.0, 0.35, 0.5, 0.85, 1.0 ]
            components =
                [
                // R  G  B  A
                1.0, 1.0, 1.0, 1.0, //// Start color
                1.0, 1.0, 1.0, 0.3,
                0.0, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0, 0.3,
                0.0, 0.0, 0.0, 0.8  //// End color
                ]
        } else {
            num_locations = 7
            locations = [ 0.0, 0.1, 0.32, 0.5, 0.64, 0.80, 1.0 ]
            components =
                [
                // R  G  B  A
                1.0, 0.0, 0.0, 1.0,   //// Start color
                0.89, 0.0, 0.47, 1.0,
                0.0, 0.0, 1.0, 1.0,
                0.08, 0.65, 0.88, 1.0,
                0.07, 0.6, 0.24, 1.0,
                1.0, 1.0, 0.0, 1.0,
                0.89, 0.06, 0.1, 1.0  //// End color
                ]
        }
        
        transparencyGradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations)!
        return transparencyGradient
    }
    
    /**
    Applies the gradient to self
     
    - parameter type: The type of gradient to apply to self
    */
    
    private func applyGradient(gradientType type: Gradient) {
        let gradient: CGGradientRef = createGradient(gradientType: type)
        let startPoint: CGPoint
        let endPoint: CGPoint
        if type == .Transparent {
            startPoint = CGPoint(x: 0, y: bounds.size.height / 2)
            endPoint = CGPoint(x: bounds.size.width, y: bounds.size.height / 2)
        } else {
            startPoint = CGPoint(x: bounds.size.width / 2, y: 0)
            endPoint = CGPoint(x: bounds.size.width / 2, y: bounds.size.height)
        }
        
        let context: CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, .DrawsBeforeStartLocation)
    }
    
    /**
    Sizes the color picker relative to the given view

    - parameter view: The view the color picker's size will be based off of
    */
    
    private func sizeColorPickerRelativeToView(view: UIView) {
        let colorPickerHeight = view.bounds.size.height * 0.33
        var colorPickerFrame = view.frame
        colorPickerFrame.size.height = colorPickerHeight
        colorPickerFrame.origin.y = view.bounds.size.height - colorPickerHeight
        frame = colorPickerFrame
    }
    
}

extension UIView {
    
    /**
    Gets the color of a pixel at the point passed in
    
    - parameter position: Location of the pixel in the view
    */
    
    func colorOfPixel(position: CGPoint) -> UIColor {
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()!
        let bitmapInfo: UInt32 = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue).rawValue
        var pixelData: [UInt8] = [0, 0, 0, 0]
        let context = CGBitmapContextCreate(&pixelData, 1, 1, 8, 4, colorSpace, bitmapInfo)
        CGContextTranslateCTM(context, -position.x, -position.y);
        layer.renderInContext(context!)
        let red:   CGFloat = CGFloat(pixelData[0]) / CGFloat(255.0)
        let green: CGFloat = CGFloat(pixelData[1]) / CGFloat(255.0)
        let blue:  CGFloat = CGFloat(pixelData[2]) / CGFloat(255.0)
        let alpha: CGFloat = CGFloat(pixelData[3]) / CGFloat(255.0)
        let color: UIColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        
        return color
    }
}
