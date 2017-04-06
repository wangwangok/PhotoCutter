//
//  PhotoCutterView.swift
//  PhotoCutter
//
//  Created by 王望 on 16/7/19.
//  Copyright © 2016年 Will. All rights reserved.
//

import UIKit
import ImageIO

public class PhotoCutterView: UIScrollView {
    //MARK: - public Propertise-
    public var cutterType:CutterType{
        set{
            _cutterType = newValue
            contentView.layer.addSublayer(maskLayer)
        }
        
        get{
            return _cutterType
        }
    }
    
    public var content:UIImage?{
        set{
            _content = newValue
        }
        
        get{ return _content }
    }
    
    public var contentImageView:UIImageView!
    
    public var contentView:UIView!
    
    public var tap:UITapGestureRecognizer{
        get{
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PhotoCutterView.doubleTap(_:)))
            tapGesture.numberOfTapsRequired = 2
            return tapGesture
        }
    }

    //MARK: - private propertise -
    fileprivate var _content:UIImage?
    
    fileprivate var _cutterType:CutterType = CutterType.circle(radius: 100)
    
    fileprivate var maskLayer:CAShapeLayer{
        let shape = CAShapeLayer()
        var path:UIBezierPath!
        switch cutterType{
        case .rect(let width,let height):
            
            let line_width = max(
                bounds.height - CGFloat(height) / 2.0,
                (bounds.width - CGFloat(width)) / 2.0)
            let hor_spaceing = (bounds.width - CGFloat(width)) / 2.0
            let ver_spaceing = (bounds.height - CGFloat(height)) / 2.0
            path = UIBezierPath()
            path.move(to: CGPoint(
                x: -(line_width/2 - hor_spaceing),
                y: -(line_width/2 - ver_spaceing)))
            path.addLine(to: CGPoint(
                x: bounds.width + (line_width/2 - hor_spaceing),
                y: -(line_width/2 - ver_spaceing)))
            path.addLine(to: CGPoint(
                x: bounds.width + (line_width/2 - hor_spaceing),
                y: bounds.height + (line_width/2 - ver_spaceing)))
            path.addLine(to: CGPoint(
                x: -(line_width/2 - hor_spaceing),
                y: bounds.height + (line_width/2 - ver_spaceing)))
            path.close()
            shape.lineWidth  = line_width
            updateContentInset()
        case .circle(let radius):
            let center = CGPoint(
                x:bounds.width/2,
                y: bounds.height/2)
            let startAngle: CGFloat = 0
            let radius_cg = CGFloat(radius) >= bounds.width ? bounds.width : CGFloat(radius)
            let endAngle: CGFloat = CGFloat(Double.pi) * CGFloat(2)
            let line_width = sqrt(pow(bounds.width/2, 2)+pow(bounds.height/2, 2))
            path = UIBezierPath(
                arcCenter: center,
                radius:CGFloat(radius_cg) + line_width/2,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: true)
            shape.lineWidth  = line_width
            updateContentInset()
        }
        
        shape.path = path.cgPath
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.black.withAlphaComponent(0.3).cgColor
        return shape
    }
    
    fileprivate var scale:CGFloat {
        set{
            setZoomScale(newValue, animated: false)
        }
        get{
            return self.zoomScale
        }
    }
    
    override fileprivate init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    public convenience init(frame: CGRect, image:UIImage?) {
        self.init(frame: frame)
        content = image
        initializers()
    }

    required public init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if let superView = self.superview , superView.subviews.contains(contentView) == false{
            superView.addSubview(contentView)
            superView.bringSubview(toFront: contentView)
        }
    }
}

private typealias internalFunction = PhotoCutterView
extension internalFunction{
    func reloadView(){
        let height = max(contentImageView.frame.height, bounds.height)
        let width = max(contentImageView.frame.width, bounds.width)
        contentSize = CGSize(width: width, height: height)
        contentImageView.center =  CGPoint(x: contentSize.width/2, y: contentSize.height/2)
        updateContentInset()
    }
    
    /*
     *裁剪的思路：
     *因为imageview的contentMode为aspetfill，这在视觉上对image进行了一定比例的压缩，所以这里在原来的基础上通过比例进行裁剪，然后将这个图片取出，再通过这个比例进行缩小
     */
    func cutter(_ center:CGPoint) -> UIImage? {
        let contentScale = zoomScale
        guard let content_image = content else{
            return nil
        }
        let scale = contentImageView.contentScale
        switch cutterType {
        case .circle(let radius):
            let rect = CGRect(
                x: 0,
                y: 0,
                width:  CGFloat(radius)*2,
                height: CGFloat(radius)*2
            )
            return content_image.refer.crop_rect(
                CGRect(
                    x: center.x * contentScale - rect.size.width/2,
                    y: center.y * contentScale - rect.size.height/2,
                    width: rect.size.width,
                    height: rect.size.height),
                scale: scale).compression(rect.size, alphaInfo: .premultipliedLast).clip_circle(rect.size).image
        case .rect(let width, let height):
            let rect = CGRect(
                x: 0,
                y: 0,
                width:  CGFloat(width),
                height: CGFloat(height)
            )
            return content_image.refer.crop_rect(
                CGRect(
                    x: center.x * contentScale - rect.size.width/2,
                    y: center.y * contentScale - rect.size.height/2,
                    width: rect.size.width,
                    height: rect.size.height),
                scale: scale).compression(rect.size, alphaInfo: .premultipliedLast).image
        }
    }
}

private typealias PrivateFunction = PhotoCutterView
extension PrivateFunction{
    fileprivate func initializers(){
        backgroundColor                = .clear
        minimumZoomScale               = 1
        maximumZoomScale               = 2
        showsVerticalScrollIndicator    = false
        showsHorizontalScrollIndicator   = false
        //always 
        alwaysBounceHorizontal          = true
        alwaysBounceVertical           = true
        contentSize                    = CGSize(
                                         width: bounds.width,
                                         height: bounds.height)
        addGestureRecognizer(tap)
        contentView = {
        let content                    = UIView()
        content.backgroundColor        = UIColor.clear
        content.isUserInteractionEnabled = false
        content.layer.masksToBounds    = true
        content.frame                  = frame
            return content
            }()
        contentImageView = {
            $0.contentMode            = .scaleAspectFill
            $0.isUserInteractionEnabled = true
            let width  = contentSize.width
            var height = contentSize.height
            $0.center                 = CGPoint(
                x: width / 2,
                y: height / 2)
            if let image = content{
                $0.image = image
                let scale = image.size.width/image.size.height
                height = width / scale
            }
            $0.bounds                = CGRect(
                x: 0,
                y: 0,
                width: width,
                height: height)
            return $0
        }(UIImageView())
        addSubview(contentImageView)
    }
    
    fileprivate func updateContentInset(){
        switch self.cutterType{
        case .rect(let width,let height):
            
            let maxHorMargin = bounds.width/2 - CGFloat(width)/2
            let base_width = contentImageView.bounds.width > bounds.width ?  contentImageView.bounds.width : contentImageView.frame.width
            let curHorMargin = max(base_width  / 2  - CGFloat(width)/2, 0)
            let horMargin = contentSize.width > bounds.width ? maxHorMargin : curHorMargin
            
            let maxVerMargin = bounds.height/2 - CGFloat(height)/2
            let base_height = contentImageView.bounds.height > bounds.height ?  contentImageView.bounds.height : contentImageView.frame.height
            let curVerMargin = max(base_height / 2  - CGFloat(height)/2, 0)
            let verMargin = contentSize.height > bounds.height ? maxVerMargin : curVerMargin
            
            contentInset = UIEdgeInsets(
                top:    verMargin,
                left:   horMargin,
                bottom: verMargin,
                right:  horMargin)
        case .circle(let radius):
            let maxHorMargin = bounds.width/2 - CGFloat(radius)
            let base_width = contentImageView.bounds.width > bounds.width ?  contentImageView.bounds.width : contentImageView.frame.width
            let curHorMargin = max(base_width  / 2  - CGFloat(radius), 0)
            let horMargin = contentSize.width > bounds.width ? maxHorMargin : curHorMargin
            
            let maxVerMargin = bounds.height/2 - CGFloat(radius)
            let base_height = contentImageView.bounds.height > bounds.height ?  contentImageView.bounds.height : contentImageView.frame.height
            let curVerMargin = max(base_height / 2  - CGFloat(radius), 0)
            let verMargin = contentSize.height > bounds.height ? maxVerMargin : curVerMargin

            contentInset = UIEdgeInsets(
                top:    verMargin,
                left:   horMargin,
                bottom: verMargin,
                right:  horMargin)
        }
    }
}


private typealias ActionFunction = PhotoCutterView
extension ActionFunction{
    func doubleTap(_ tap:UITapGestureRecognizer){
        scale = scale == 1 ? 2 : 1
        setZoomScale(scale, animated: true)
        reloadView()
    }
}
