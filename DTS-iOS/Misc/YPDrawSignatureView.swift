// YPDrawSignatureView is open source
// Version 0.1.2
//
// Copyright (c) 2014 - 2016 Yuppielabel and the project contributors
// Available under the MIT license
//
// See https://github.com/yuppielabel/YPDrawSignatureView/blob/master/LICENSE for license information
// See https://github.com/yuppielabel/YPDrawSignatureView/blob/master/README.md for the list project contributors

import UIKit

@IBDesignable
open class YPDrawSignatureView: UIView {
    
    weak var delegate: YPDrawSignatureViewDelegate!
    
    // MARK: - Public properties
    @IBInspectable open var strokeWidth: CGFloat = 2.0 {
        didSet {
            self.path.lineWidth = strokeWidth
        }
    }
    
    @IBInspectable open var strokeColor: UIColor = UIColor.black {
        didSet {
            self.strokeColor.setStroke()
        }
    }
    
    @IBInspectable open var signatureBackgroundColor: UIColor = UIColor.white {
        didSet {
            self.backgroundColor = signatureBackgroundColor
        }
    }
    
    // Computed Property returns true if the view actually contains a signature
    open var containsSignature: Bool {
        get {
            if self.path.isEmpty {
                return false
            } else {
                return true
            }
        }
    }
    
    // MARK: - Private properties
    fileprivate var path = UIBezierPath()
    fileprivate var pts = [CGPoint](repeating: CGPoint(), count: 5)
    fileprivate var ctr = 0
    
    // MARK: - Init
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = self.signatureBackgroundColor
        self.path.lineWidth = self.strokeWidth
        self.path.lineJoinStyle = CGLineJoin.round
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = self.signatureBackgroundColor
        self.path.lineWidth = self.strokeWidth
        self.path.lineJoinStyle = CGLineJoin.round
    }
    
    // MARK: - Draw
    override open func draw(_ rect: CGRect) {
        self.strokeColor.setStroke()
        self.path.stroke()
    }
    
    // MARK: - Touch handling functions
    override open func touchesBegan(_ touches: Set <UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let touchPoint = firstTouch.location(in: self)
            self.ctr = 0
            self.pts[0] = touchPoint
        }
        
        if let delegate = self.delegate {
            delegate.startedSignatureDrawing!()
        }
    }
    
    override open func touchesMoved(_ touches: Set <UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let touchPoint = firstTouch.location(in: self)
            self.ctr += 1
            self.pts[self.ctr] = touchPoint
            if (self.ctr == 4) {
                self.pts[3] = CGPoint(x: (self.pts[2].x + self.pts[4].x)/2.0, y: (self.pts[2].y + self.pts[4].y)/2.0)
                self.path.move(to: self.pts[0])
                self.path.addCurve(to: self.pts[3], controlPoint1:self.pts[1], controlPoint2:self.pts[2])
                
                self.setNeedsDisplay()
                self.pts[0] = self.pts[3]
                self.pts[1] = self.pts[4]
                self.ctr = 1
            }
            
            self.setNeedsDisplay()
        }
    }
    
    override open func touchesEnded(_ touches: Set <UITouch>, with event: UIEvent?) {
        if self.ctr == 0 {
            let touchPoint = self.pts[0]
            self.path.move(to: CGPoint(x: touchPoint.x-1.0,y: touchPoint.y))
            self.path.addLine(to: CGPoint(x: touchPoint.x+1.0,y: touchPoint.y))
            self.setNeedsDisplay()
        } else {
            self.ctr = 0
        }
        
        if let delegate = self.delegate {
            delegate.finishedSignatureDrawing!()
        }
    }
    
    // MARK: - Methods for interacting with Signature View
    
    // Clear the Signature View
    open func clearSignature() {
        self.path.removeAllPoints()
        self.setNeedsDisplay()
    }
    
    // Save the Signature as an UIImage
    open func getSignature(scale:CGFloat = 1) -> UIImage? {
        if !containsSignature { return nil }
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, scale)
        self.strokeColor.setStroke()
        self.path.stroke()
        let signature = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return signature
    }
    
    // Save the Signature (cropped of outside white space) as a UIImage
    open func getSignatureCropped(scale:CGFloat = 1) -> UIImage? {
        guard let fullRender = getSignature(scale:scale) else { return nil }
        let bounds = scaleRect(path.bounds.insetBy(dx: -strokeWidth/2, dy: -strokeWidth/2), byFactor: scale)
        guard let imageRef = fullRender.cgImage!.cropping(to: bounds) else { return nil }
        return UIImage(cgImage: imageRef)
    }
    
    func scaleRect(_ rect: CGRect, byFactor factor: CGFloat) -> CGRect
    {
        var scaledRect = rect
        scaledRect.origin.x *= factor
        scaledRect.origin.y *= factor
        scaledRect.size.width *= factor
        scaledRect.size.height *= factor
        return scaledRect
    }
}

// MARK: - Optional Protocol Methods for YPDrawSignatureViewDelegate
@objc protocol YPDrawSignatureViewDelegate: class {
    @objc optional func startedSignatureDrawing()
    @objc optional func finishedSignatureDrawing()
}
