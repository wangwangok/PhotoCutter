//
//  PFContentView.swift
//  PhotoCutter
//
//  Created by 王望 on 16/9/1.
//  Copyright © 2016年 Will. All rights reserved.
//

import UIKit

internal class PFContentView: UIView {
    
    fileprivate var image:UIImage?
    
    fileprivate var contentImageView:PFImageView!

    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        
    }
    
    convenience init(image:UIImage?){
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height - listHeight - toobarHeight
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        self.init(frame: rect)
        self.image = image
        reloadData(nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup(){
        contentImageView = {
            let imgView = PFImageView(
                frame: CGRect(
                    x: 0,
                    y: 0,
                    width: frame.size.width,
                    height: frame.size.height)
            )
            imgView.aspectMode = .scaleAspectFill
            return imgView
        }()
        addSubview(contentImageView)
    }
    
    internal func reloadData(_ resouce:CIImage?){
        do{
            try refreshView()
        }catch{}
        var imageSource:CIImage?
        if let ciImage = resouce{
            imageSource = ciImage
        }else{
            imageSource = CIImage(image: image!)
        }
        self.contentImageView.image = imageSource
    }
    
    fileprivate func refreshView()throws{
        guard let c_image = image else{
            throw PhotoFilterError.ReloadImageNone
        }
        let width = c_image.size.width
        let height = c_image.size.height
        let max_width = frame.size.width
        let max_height = frame.size.height
        let scale = width/height
        let `center` = CGPoint(x: max_width/2, y: max_height/2)
        var bounds = CGRect.zero
        if scale > 1 {//width > height
            if width > max_width {
                bounds = CGRect(x: 0, y: 0, width: max_width, height: max_width / scale)
            }else{
                bounds = CGRect(x: 0, y: 0, width: width, height: height)
            }
        }else{//height > width
            if height > max_height {
                bounds = CGRect(x: 0, y: 0, width: max_height * scale, height: max_height)
            }else{
                bounds = CGRect(x: 0, y: 0, width: width, height: height)
            }
        }
        contentImageView.center  = `center`
        contentImageView.bounds  = bounds
    }
}
