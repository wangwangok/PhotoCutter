//
//  PFImageView.swift
//  PhotoCutter
//
//  Created by 王望 on 16/8/31.
//  Copyright © 2016年 Will. All rights reserved.
//

import UIKit
import CoreImage
import GLKit
import OpenGLES

public enum PFImageViewAspectMode : Int {
    
    case scaleAspectFitt
    
    case scaleAspectFill
}

typealias InRect = (PFImageViewAspectMode) -> CGRect

final public class PFImageView:GLKView{
    
    public var image:CIImage?{
        didSet{
            setNeedsDisplay()
        }
    }
    
    public var aspectMode:PFImageViewAspectMode = .scaleAspectFitt
    
    fileprivate var pf_context:CIContext!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.context = EAGLContext(api: .openGLES2)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.context = EAGLContext(api: .openGLES2)
        setup()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    public override func draw(_ rect: CGRect) {
        do{
            try drawGL(in: rect)
        }catch{
            print(error)
        }
    }
    
    fileprivate func setup(){
        clipsToBounds = true
        self.pf_context = CIContext(eaglContext: context, options: [kCIContextWorkingColorSpace:CGColorSpaceCreateDeviceRGB()])
        //self.pf_context = CIContext(EAGLContext: context)
    }
    
    public func drawGL(in rect: CGRect)throws{
        guard let output_image = image else{
            throw PhotoFilterError.FilterResourceNone
        }
        clean()
        let drawable = CGRect(x: 0, y: 0, width: drawableWidth, height: drawableHeight)
        let onput_rect = output_image.extent
        let fromAspectRatio = onput_rect.size.width / onput_rect.size.height
        let toAspectRatio = drawable.size.width / drawable.size.height
        var fitRect = drawable
        let inRect:InRect = { mode in
            switch mode {
            case .scaleAspectFitt:
                return {
                    if (fromAspectRatio > toAspectRatio) {
                        fitRect.size.height = drawable.size.width / fromAspectRatio;
                        fitRect.origin.y += (drawable.size.height - fitRect.size.height) * 0.5
                    } else {
                        fitRect.size.width = drawable.size.height  * fromAspectRatio
                        fitRect.origin.x += (drawable.size.width - fitRect.size.width) * 0.5
                    }
                    return fitRect.integral
                    }()
            case .scaleAspectFill:
                return {
                    if (fromAspectRatio > toAspectRatio) {
                        fitRect.size.width = drawable.size.height  * fromAspectRatio
                        fitRect.origin.x += (drawable.size.width - fitRect.size.width) * 0.5
                    } else {
                        fitRect.size.height = drawable.size.width / fromAspectRatio;
                        fitRect.origin.y += (drawable.size.height - fitRect.size.height) * 0.5
                    }
                    return fitRect.integral
                    }()
            }
        }
        pf_context.draw(output_image, in: inRect(aspectMode), from: onput_rect)
    }
    
    fileprivate func clean(){
        var r: CGFloat = 0,
        g: CGFloat = 0,
        b: CGFloat = 0,
        a: CGFloat = 0
        backgroundColor?.getRed(&r, green: &g, blue: &b, alpha: &a)
        glClearColor(GLfloat(r), GLfloat(g), GLfloat(b), GLfloat(a))
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    }
}
