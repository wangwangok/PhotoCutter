//
//  UIImage+Filter.swift
//  PhotoCutter
//
//  Created by 王望 on 16/9/1.
//  Copyright © 2016年 Will. All rights reserved.
//

import UIKit
import CoreImage

/// 滤镜的统一出口
extension UIImage{
    var filter:PFImageValue{
        return PFImageValue(value: nil, image: self)
    }
}

//default filter
extension CIImage{
    public var InstantFilter:PFImageFilter{
        return PFImageFilter(filter: CIFilter(name: "CIPhotoEffectInstant", withInputParameters: [kCIInputImageKey:self])!)
    }
    
    public var ProcessFilter:PFImageFilter{
        return PFImageFilter(filter: CIFilter(name: "CIPhotoEffectProcess", withInputParameters: [kCIInputImageKey:self])!)
    }
    
    public var ChromeFilter:PFImageFilter{
        return PFImageFilter(filter: CIFilter(name: "CIPhotoEffectChrome", withInputParameters: [kCIInputImageKey:self])!)
    }
    
    public var MonoFilter:PFImageFilter{
        return PFImageFilter(filter: CIFilter(name: "CIPhotoEffectMono", withInputParameters: [kCIInputImageKey:self])!)
    }
    
    public var TonalFilter:PFImageFilter{
        return PFImageFilter(filter: CIFilter(name: "CIPhotoEffectTonal", withInputParameters: [kCIInputImageKey:self])!)
    }
    
    public var FadeFilter:PFImageFilter{
        return PFImageFilter(filter: CIFilter(name: "CIPhotoEffectFade", withInputParameters: [kCIInputImageKey:self])!)
    }
    
    public var NoirFilter:PFImageFilter{
        return PFImageFilter(filter: CIFilter(name: "CIPhotoEffectNoir", withInputParameters: [kCIInputImageKey:self])!)
    }
    
    public var TransferFilter:PFImageFilter{
        return PFImageFilter(filter: CIFilter(name: "CIPhotoEffectTransfer", withInputParameters: [kCIInputImageKey:self])!)
    }
}



