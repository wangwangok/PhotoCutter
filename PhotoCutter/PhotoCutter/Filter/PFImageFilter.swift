//
//  PCImageFilter.swift
//  PhotoCutter
//
//  Created by 王望 on 16/8/29.
//  Copyright © 2016年 Will. All rights reserved.
//

import UIKit
import CoreImage
import GLKit
//https://developer.apple.com/library/ios/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIColorMatrix
//系统内部完整的滤镜列表，以及参数的设置规则
/*******************提供的滤镜种类********************
 *1.Vignette
 *2.GaussianBlur
 *3.Monochrome
 */

///滤镜中间件，外部可不比调用
public class PFImageValue{
    
    var image:UIImage
    
    var value:CIImage?
    
    init(value:CIImage? ,image:UIImage){
        self.value = value
        self.image = image
    }
    
    internal func blur(_ radius:Double) -> PFImageValue {
        let inputValue = self
        let outputValue = PFImageValue(value: nil, image: inputValue.image)
        outputValue.value = PFImageFilter.blur(radius)(inputValue.image)
        return outputValue
    }
    
    internal func monochrome(_ color:CIColor ,intensity:Double) -> PFImageValue {
        let inputValue = self
        let outputValue = PFImageValue(value: nil, image: inputValue.image)
        outputValue.value = PFImageFilter.monochrome(color ,intensity:intensity)(inputValue.image)
        return outputValue
    }
    
    internal func vignette(_ radius:Double ,intensity:Double) -> PFImageValue {
        let inputValue = self
        let outputValue = PFImageValue(value: nil, image: inputValue.image)
        outputValue.value = PFImageFilter.vignette(radius ,intensity:intensity)(inputValue.image)
        return outputValue
    }
}

//属性约束protocol，具体的在各个子类中
/*
 *关键字说明：
 *1.属性：filter在通过kvo设置的时候，我将key提出来作为一个filter的属性
 *这里为什么选择使用protocol？因为在某一种或者某几种他们有共同的属性，为了避免重复代码的出现，如果直接写在类的属性中，就会让几个同时写几个相同的属性（可以使用继承的方式，但是继承的多了就比较乱，这里统一只有一层的继承关系）。所以我选择使用protocol的方式来解决上述的问题
 */
//MARK: - Protocol -
public protocol PFImageFilterAttributes {
    var filter:CIFilter{ set get }
}

public protocol PFImageRadius:PFImageFilterAttributes{}
extension PFImageRadius{
    public var inputRadius:Double{
        set{
            var radius:Double = 0
            var inputRadiusPara:[String:AnyObject] = {
                return filter.attributes[kCIInputRadiusKey] as! [String:AnyObject]
            }()
            if let slider_max = inputRadiusPara[kCIAttributeSliderMax] as? NSNumber
            {
                radius = min(newValue, slider_max.doubleValue)
            }
            
            if let slider_min = inputRadiusPara[kCIAttributeSliderMin] as? NSNumber
            {
                radius = max(newValue, slider_min.doubleValue)
            }
            filter.setValue(NSNumber(value: radius as Double), forKey: kCIInputRadiusKey)
        }
        
        get{
            return filter.value(forKey: kCIInputRadiusKey) as? Double ?? 0
        }
    }
}

public protocol PFImageIntensity:PFImageFilterAttributes{}

extension PFImageIntensity{
    public var inputIntensity:Double{
        set{
            filter.setValue(newValue, forKey: kCIInputIntensityKey)
        }
        
        get{
            return filter.value(forKey: kCIInputIntensityKey) as? Double ?? 0
        }
    }
}

//MARK: - PFImageFilter -

public typealias PFilter = (UIImage) -> CIImage?

open class PFImageFilter {
    
    open var inputImage:UIImage{
        set{
            filter.setValue(CIImage(image: newValue), forKey: kCIInputImageKey)
            _inputImage = newValue
        }
        
        get{
            return _inputImage
        }
    }
    
    fileprivate var _inputImage:UIImage = UIImage()
    
    open var outputImage:CIImage?{
        get{
            let out = self.filter.outputImage
            return out
        }
    }
    
    fileprivate var _filter:CIFilter!
    
    init(filter:CIFilter){
        _filter = filter
    }
}

extension PFImageFilter{
    /*
     geiven the gaussian blur filter
     */
    public class func blur(_ radius:Double) -> PFilter {
        return { image in
            var gaussian = PFImageFilter.GaussianBlur
            gaussian.inputImage = image
            gaussian.inputRadius = radius
            return gaussian.outputImage
        }
    }
    
    public class func monochrome(_ color:CIColor ,intensity:Double) -> PFilter {
        return { image in
            var monochrome = PFImageFilter.Monochrome
            monochrome.inputImage = image
            monochrome.inputColor = color
            monochrome.inputIntensity = intensity
            return monochrome.outputImage
        }
    }
    
    public class func vignette(_ radius:Double ,intensity:Double) -> PFilter {
        return { image in
            var monochrome = PFImageFilter.Vignette
            monochrome.inputImage = image
            monochrome.inputRadius = radius
            monochrome.inputIntensity = intensity
            return monochrome.outputImage
        }
    }
}

//https://developer.apple.com/library/mac/documentation/GraphicsImaging/Conceptual/CoreImaging/ci_concepts/ci_concepts.html#//apple_ref/doc/uid/TP30001185-CH2-SW3

//Filter category constants for filter origin
extension PFImageFilter{
    
    public static var BuiltInArray:[String]{//A filter provided by Core Image
        return CIFilter.filterNames(inCategory: kCICategoryBuiltIn)
    }
}

//MARK: - Filter category constants for effect types -
extension PFImageFilter{
    public static var DistEfectArray:[String]{
        return CIFilter.filterNames(inCategory: kCICategoryDistortionEffect)
    }
    
    public static var GeomAdjustArray:[String]{
        return CIFilter.filterNames(inCategory: kCICategoryGeometryAdjustment)
    }
    
    public static var HalfEfectArray:[String]{
        return CIFilter.filterNames(inCategory: kCICategoryHalftoneEffect)
    }
    
    public static var ColorAdjustArray:[String]{
        return CIFilter.filterNames(inCategory: kCICategoryColorAdjustment)
    }
    
    public static var ColorEfectArray:[String]{
        return CIFilter.filterNames(inCategory: kCICategoryColorEffect)
    }
    
    public static var TransitionArray:[String]{
        return CIFilter.filterNames(inCategory: kCICategoryTransition)
    }
    
    public static var TileEfectnArray:[String]{
        return CIFilter.filterNames(inCategory: kCICategoryTileEffect)
    }
    
    public static var GeneratorArray:[String]{
        return CIFilter.filterNames(inCategory: kCICategoryGenerator)
    }
    
    public static var GradientArray:[String]{
        return CIFilter.filterNames(inCategory: kCICategoryGradient)
    }
    
    public static var StylizeArray:[String]{
        return CIFilter.filterNames(inCategory: kCICategoryStylize)
    }
    
    public static var SharpenArray:[String]{
        return CIFilter.filterNames(inCategory: kCICategorySharpen)
    }
    
    public static var BlurArray:[String]{//Blur, such as Gaussian, zoom, motion
        return CIFilter.filterNames(inCategory: kCICategoryBlur)
    }
}

//MARK: - Filter category constants for filter usage -
extension PFImageFilter{
    public static var StlImgArray:[String]{
        return CIFilter.filterNames(inCategory: kCICategoryStillImage)
    }
    
    public static var VideoArray:[String]{
        return CIFilter.filterNames(inCategory: kCICategoryVideo)
    }
    
    public static var InterlacedArray:[String]{
        return CIFilter.filterNames(inCategory: kCICategoryInterlaced)
    }
    
    public static var SqPxsArray:[String]{
        return CIFilter.filterNames(inCategory: kCICategoryNonSquarePixels)
    }
    
    public static var HiDyRgeArray:[String]{
        return CIFilter.filterNames(inCategory: kCICategoryHighDynamicRange)
    }
}

extension PFImageFilter:PFImageFilterAttributes{
    public var filter:CIFilter{
        set
        {
            _filter = newValue
        }
        get
        {
            return _filter
        }
    }
}

//MARK: - Vignette -
public final class VignetteFilter:PFImageFilter{
    
    override init(filter: CIFilter) {
        super.init(filter: filter)
    }
}

extension VignetteFilter:PFImageRadius{}

extension VignetteFilter:PFImageIntensity{}

extension PFImageFilter{
    public static var Vignette:VignetteFilter{
        return VignetteFilter(filter: CIFilter(name: "CIVignette")!)
    }
}

//MARK: - GaussianFilter -
public final class GaussianFilter:PFImageFilter{
    override init(filter: CIFilter) {
        super.init(filter: filter)
    }
}

extension GaussianFilter:PFImageRadius{}

extension PFImageFilter{
    
    public static var GaussianBlur:GaussianFilter{
        return GaussianFilter(filter: CIFilter(name: "CIGaussianBlur")!)
    }
}


//MARK: - MonochromeFilter -
public final class MonochromeFilter:PFImageFilter{
    
    fileprivate var _inputIntensity:Double = 0
    
    fileprivate var _inputColor:CIColor = CIColor(red: 0.0, green: 0.0, blue: 0.0)
    
    override init(filter: CIFilter) {
        super.init(filter: filter)
    }
}

extension MonochromeFilter:PFImageIntensity{}

public extension PFImageFilterAttributes where Self:MonochromeFilter {
    public var inputColor:CIColor{
        set{
            _inputColor = newValue
            filter.setValue(newValue, forKey: kCIInputColorKey)
        }
        
        get{
            return _inputColor
        }
    }
}

extension PFImageFilter{
    public static var Monochrome:MonochromeFilter{
        return MonochromeFilter(filter: CIFilter(name: "CIColorMonochrome")!)
    }
}




