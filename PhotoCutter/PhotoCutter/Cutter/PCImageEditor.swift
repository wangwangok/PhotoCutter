//
//  PCImageEditor.swift
//  PhotoCutter
//
//  Created by 王望 on 16/7/20.
//  Copyright © 2016年 Will. All rights reserved.
//

import Foundation
import UIKit
import ImageIO
import CoreImage
import CoreGraphics
import CoreFoundation
#if os(iOS)
    import MobileCoreServices
#endif

//支持的源图片类型
//let source_identifiers = CGImageSourceCopyTypeIdentifiers()
//CFShow(source_identifiers)
//支持转换的目标数据类型
//let destination_identifiers = CGImageDestinationCopyTypeIdentifiers()
//CFShow(destination_identifiers)

//image mask :http://www.innofied.com/implementing-image-masking-in-ios/

//apple Guides and Sample Code:https://developer.apple.com/library/prerelease/content/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_images/dq_images.html#//apple_ref/doc/uid/TP30001066-CH212-SW3

/*
 *  UIImageJPEGRepresentation(self, 0.9)
    UIImagePNGRepresentation(self)
 *  这里有个疑问：用png的方式转换出来的data，获得的信息没有exif和tiff之类的信息，所以这里我选择用jpeg的方式来获取data
 *
 * CoreImage -- { CIFilter,CIImage }
 *
 * CoreGraphics --{
 CGImage:
 
 CGBitmap: you can use for drawing bits to memory (https://developer.apple.com/library/tvos/documentation/GraphicsImaging/Reference/CGBitmapContext/index.html#//apple_ref/doc/uid/TP30000947)
 
 CGDataProvider:https://developer.apple.com/reference/coregraphics/cgdataprovider
 CFData:
 CFDictionary:
 }
 *
 *            //图像源       目标图像，输入源      图像相关属性
 * ImageIO --{CGImageSource,CGImageDestination,CGImagePropertise }
*/



/*
 *Swift 3 update
 
 *About UnsafePointer:https://swift.org/migration-guide/se-0107-migrate.html
 
 *
 
 */


protocol ImageEditor:class{
    
    /// image Propertise
    var properties:Dictionary<String,AnyObject> { get }
    
    /// image type: eg jpeg,png
    var type:CutterImageType{ get }
    
    var data:Data?{ get }
    
    /**
     Create a thumbnail image from an image Source
     
     - returns: CGImageRef
     */
    func thumbnail() -> CGImage?
}

extension ImageEditor{
    /*
    func imageRef() -> CGImageRef?{
        guard let self_image = self as? UIImage else{
            return nil
        }
        let lock = SPinLock()
        lock.lock()
        guard let data  = UIImageJPEGRepresentation(self_image, 0.9) else{ return nil}
        var image:CGImageRef?,
        imageSource:CGImageSourceRef?,
        options:CFDictionaryRef?,
        keys:[CFStringRef] = [
            kCGImageSourceShouldCache,
            kCGImageSourceShouldAllowFloat],
        values:[CFTypeRef] = [
            kCFBooleanTrue,
            kCFBooleanTrue],
        kcKeysBack = kCFTypeDictionaryKeyCallBacks,
        kcValuesBack = kCFTypeDictionaryValueCallBacks,
        cfdata = CFDataCreate(kCFAllocatorDefault, UnsafePointer<UInt8>(data.bytes), data.length)
        
        options = CFDictionaryCreate(kCFAllocatorDefault,
            UnsafeMutablePointer(UnsafePointer<Void>(keys)),
            UnsafeMutablePointer(UnsafePointer<Void>(values)),
            2,
            &kcKeysBack,
            &kcValuesBack)
        
        
        imageSource = CGImageSourceCreateWithData(cfdata, options)
        guard let imageSource_not_nil = imageSource else{
            return nil
        }
        image = CGImageSourceCreateImageAtIndex(imageSource_not_nil, 0, nil)
        lock.unlock()
        return image
    }
    */
    
    func thumbnail() -> CGImage?{
        
        let lock = SPinLock()
        guard let `self` = self as? UIImage else{
            return nil
        }
        lock.lock()
        guard let data  = UIImageJPEGRepresentation(`self`, 0.9) else{ return nil}
        var imageSize:Int = data.count
        let thumbainlSize = CFNumberCreate(nil, .intType, &imageSize)
        
        var image:CGImage?,
        imageSource:CGImageSource?,
        options:CFDictionary?,
        keys:[CFString] = [
            kCGImageSourceCreateThumbnailWithTransform,
            kCGImageSourceCreateThumbnailFromImageIfAbsent,
            kCGImageSourceThumbnailMaxPixelSize],
        values:[CFTypeRef] = [
            kCFBooleanTrue,
            kCFBooleanTrue,
            thumbainlSize!],
        kcKeysBack = kCFTypeDictionaryKeyCallBacks,
        kcValuesBack = kCFTypeDictionaryValueCallBacks,
        cfdata = CFDataCreate(kCFAllocatorDefault, (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), data.count)
        
        imageSource = CGImageSourceCreateWithData(cfdata!, nil)
        guard let imageSource_not_nil = imageSource else{
            return nil
        }
        
        let keybuffer = buffer(to: CFString.self, source: keys)
        let valuebuffer = buffer(to: CFTypeRef.self, source: values)
        
        options = CFDictionaryCreate(kCFAllocatorDefault,
            keybuffer,
            valuebuffer,
            2,
            &kcKeysBack,
            &kcValuesBack)
        keybuffer.deallocate(capacity: keys.count)
        valuebuffer.deallocate(capacity: values.count)
        
        image = CGImageSourceCreateThumbnailAtIndex(imageSource_not_nil, 0, options)
        lock.unlock()
        return image
    }
    
    /**
     Setting the Properties of an Image Destination
     
     - prameters :properties
     
     - returns: nil
     */
    func associatePropertise(_ property:Dictionary<String,AnyObject>) -> CFMutableData?{
        let lock = SPinLock()
        guard let `self` = self as? UIImage else{
            return nil
        }
        lock.lock()
        
        var kcKeysBack = kCFTypeDictionaryKeyCallBacks,
        kcValuesBack = kCFTypeDictionaryValueCallBacks,
        keys:[CFString] = [],
        values:[CFTypeRef] = []
        
        //set propertise
        self.properties.forEach { (key:String, value:AnyObject) in
            keys.append(key as CFString)
            if property.keys.contains(key) == true{
                if let cur_value = property[key] {
                    values.append(cur_value)
                }
            }else{
                if let cur_value = self.properties[key] { values.append(cur_value) }
            }
        }
        let keybuffer = buffer(to: CFString.self, source: keys)
        let valuebuffer = buffer(to: CFTypeRef.self, source: values)
        let newPropertise = CFDictionaryCreate(
            kCFAllocatorDefault,
            keybuffer,
            valuebuffer,
            self.properties.count,
            &kcKeysBack,
            &kcValuesBack)
        keybuffer.deallocate(capacity: keys.count)
        valuebuffer.deallocate(capacity: values.count)
        guard let data  = UIImageJPEGRepresentation(`self`, 0.9) else{ return nil}
        
        let cfdata = CFDataCreate(
            kCFAllocatorDefault,
            (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count),
            data.count),
        cfmutabledata = CFDataCreateMutableCopy(
            kCFAllocatorDefault,
            1,
            cfdata)
        guard let
            source = CGImageSourceCreateWithData(cfdata!, nil),
            let type = CGImageSourceGetType(source)  else {
            return nil
        }
        
        guard let destination_data = CGImageDestinationCreateWithData(
            cfmutabledata!,
            type,
            1,
            nil)else{
            return nil
        }
        //add to change tiff or exif
        /*
        for i in 0...self.properties.count - 1 {
            CGImageDestinationAddImageFromSource(destination_data, source, i, newPropertise)
        }
        */
        CGImageDestinationSetProperties(destination_data, newPropertise)
        CGImageDestinationFinalize(destination_data)
        lock.unlock()
        return cfmutabledata
    }
    
    //withUnsafePointer 变为一个固定类型的UnsafePointer<T>
    //withUnsafeMutablePointer 变为一个类型的UnsafeMutablePointer<T>
    //withMemoryRebound 类型变化 e.g. UnsafePointer<Int> -> UnsafePointer<Int8>
    fileprivate func buffer<T>(to type:T.Type, source:[T]) -> UnsafeMutablePointer<UnsafeRawPointer?>{
        let buffer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: source.count)
        for idx in 0..<source.count {
            let m_ptr = UnsafeMutableRawPointer.allocate(bytes: MemoryLayout<T>.size, alignedTo: MemoryLayout<T>.alignment)
            let bindptr = m_ptr.bindMemory(to: type, capacity: 1)
            bindptr.initialize(to: source[idx])
            let pty = UnsafeRawPointer(m_ptr)
            buffer.advanced(by: idx).pointee = pty
        }
        return buffer
    }
    
    //UnsafeMutablePointer<UnsafeRawPointer?>!
}


/*
 * CGImageGetWidth = image.size.width * image.scale
 *
 * CGImageGetHeight = image.size.height * image.scale
 */
final class ImageRefer {
    
    var ref:CGImage?
    
    var image:UIImage?
    
    init(ref:CGImage?, image:UIImage?){
        self.ref   = ref
        self.image = image
    }
    
    //这个函数的作用是将crop_rect等函数剪切来的图片再进行到指定尺寸
    //这里需要设置alpha通道的类型，也可以传入nil
    func compression(_ size:CGSize, alphaInfo:CGImageAlphaInfo?) -> ImageRefer {
        var imageRef:CGImage?,
        crop_image:UIImage!
        do{
            imageRef = try imageInfo().0
            crop_image = try imageInfo().1
        }catch{}
        
        let lock = SPinLock()
        lock.lock()
        let width:size_t = Int(size.width),
        height:size_t = Int(size.height),
        alpha:CGImageAlphaInfo = imageRef!.alphaInfo
        var alpha_channel:Bool = false
        if  alpha == .first ||
            alpha == .last ||
            alpha == .premultipliedFirst ||
            alpha == .premultipliedLast  {
            alpha_channel = true
        }
        var bitmapInfo = CGBitmapInfo().rawValue
        if let alpha = alphaInfo {
            bitmapInfo = alpha.rawValue
        }else{
            bitmapInfo |= alpha_channel ? CGImageAlphaInfo.premultipliedFirst.rawValue : CGImageAlphaInfo.noneSkipFirst.rawValue
        }
        //https://developer.apple.com/library/mac/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_images/dq_images.html#//apple_ref/doc/uid/TP30001066-CH212-CJBECCFG
        //Pixel Format
        let context = CGContext(data: nil,
                              width: width,
                              height: height,
                              bitsPerComponent: 8,
                              bytesPerRow: 0,
                              space: CGColorSpaceCreateDeviceRGB(),
                              bitmapInfo: bitmapInfo),
        rect = CGRect(x: 0,
                      y: 0,
                      width: size.width,
                      height: size.height)
        
        context?.draw(imageRef!, in: rect)
        let cgimage = context?.makeImage()
        self.ref = cgimage
        if let c_imageRef = cgimage{
            self.image = UIImage(cgImage: c_imageRef, scale: crop_image.scale, orientation: crop_image.imageOrientation)
        }else{
            self.image = crop_image
        }
        lock.unlock()
        return self
    }
    
    /**
     Creating an Image From Part of a Larger Image
     //这里我用中文解释一下（英文不知道怎么打了）
     //当我们在界面上看到的截取区域的时候，实际上这个图片的scale已经发生了变化（因为imageView的contentMode为了进行界面的适配和我这里的处理），所以这里的crop是在图片原尺寸上进行裁剪（比如：2000x2000）
     https://developer.apple.com/library/mac/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_images/dq_images.html#//apple_ref/doc/uid/TP30001066-CH212-SW1
     - returns: UIImage
     */
    func crop_rect(_ rect:CGRect ,scale:Float) -> ImageRefer {
        var imageRef:CGImage?,
        crop_image:UIImage!
        do{
            imageRef = try imageInfo().0
            crop_image = try imageInfo().1
        }catch{}
        
        let lock = SPinLock()
        lock.lock()
        
        let scale_float = CGFloat(scale)
        let source_refrence = imageRef,
        x = rect.origin.x * scale_float,
        y = rect.origin.y * scale_float,
        cur_rect = CGRect(x: 0, y: 0, width: scale_float * rect.size.width, height: scale_float * rect.size.height)
        //注意这里的第二参数应该要写成false，不然你是生成的rgb图像而非rgba图像，在使用filter的时候会拿不到dataprovider
        UIGraphicsBeginImageContextWithOptions(cur_rect.size, false, crop_image.scale)
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState();
        let sub_image = source_refrence?.cropping(to: CGRect(x: x, y: y, width: cur_rect.size.width, height: cur_rect.size.height))
        self.ref = sub_image
        context?.draw(sub_image!, in: cur_rect)
        context?.restoreGState()
        let last_image = UIGraphicsGetImageFromCurrentImageContext()
        self.image = last_image
        lock.unlock()
        return self
    }
    
    func clip_circle(_ targetSize:CGSize) -> ImageRefer {
        
        var imageRef:CGImage?,
        crop_image:UIImage!
        do{
            imageRef = try imageInfo().0
            crop_image = try imageInfo().1
        }catch{}
        
        let lock = SPinLock()
        lock.lock()
        //注意这里的第二参数应该要写成false，不然你是生成的rgb图像而非rgba图像，在使用filter的时候会拿不到dataprovider
        UIGraphicsBeginImageContextWithOptions(targetSize, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height);
        let background_color = UIColor.clear
        background_color.setFill()
        context?.saveGState();
        context?.fill(rect)
        context?.addEllipse(in: rect)
        context?.clip()
        crop_image.draw(in: rect)
        context?.strokeEllipse(in: rect)
        context?.restoreGState()
        let c_image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.image = c_image
        self.ref = imageRef
        lock.unlock()
        return self
    }
    
    
    func cutterImage(_ mask:UIImage?) -> ImageRefer{
        //CGImage
        var imageRef:CGImage?
        do{
            imageRef = try imageInfo().0
        }catch{}
        print(mask?.size)
        print(mask?.scale)
        let lock = SPinLock()
        lock.lock()
        guard let maskImage = mask else{ return self }
        let mask_feference = maskImage.cgImage
        let source_feference = imageRef
        let width:size_t = mask_feference!.width
        let height:size_t = mask_feference!.height
        let mask = CGImage(
            maskWidth: width,
            height: height,
            bitsPerComponent: (mask_feference?.bitsPerComponent)!,
            bitsPerPixel: (mask_feference?.bitsPerPixel)!,
            bytesPerRow: (mask_feference?.bytesPerRow)!,
            provider: (mask_feference?.dataProvider!)!,
            decode: nil,
            shouldInterpolate: false)
        let alpha:CGImageAlphaInfo = source_feference!.alphaInfo
        var masked_image:CGImage?
        if  alpha != .first &&
            alpha != .last &&
            alpha != .premultipliedFirst &&
            alpha != .premultipliedLast  {
            let rect = CGRect(x: 0, y: 0, width: width, height: height)
            
            let cur_context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: (source_feference?.colorSpace!)!, bitmapInfo: CGBitmapInfo().rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
            cur_context?.draw(source_feference!, in: rect)
            let image_alpha = cur_context?.makeImage()
            masked_image = image_alpha?.masking(mask!)
        }else{
            masked_image = source_feference?.masking(mask!)
        }
        
        lock.unlock()
        self.ref = masked_image
        if let imageValue = masked_image{
            let maskedImage = UIImage(cgImage: imageValue)
            self.image = maskedImage
            return self
        }
        return self
    }
    
    fileprivate func imageInfo()throws -> (CGImage?,UIImage){
        if self.ref == nil && self.image == nil {
            throw PhotoCutterError.ReferResourceNone
        }
        var imageRef:CGImage?
        var crop_image:UIImage!
        if let refrence = self.ref,let image_c = self.image {
            imageRef = refrence
            crop_image = image_c
        }else if let refrence = self.ref{
            imageRef = refrence
            crop_image = UIImage(cgImage: refrence)
        }else if let image_c = self.image{
            crop_image = image_c
            imageRef = crop_image.cgImage
        }
        return (imageRef, crop_image)
    }
}

extension UIImageView{
    
    /// the defualt value is 1
    var contentScale:Float{
        guard let `image` = self.image else { return 1 }
        let image_width = `image`.size.width,
            image_height = `image`.size.height,
            view_width = self.frame.size.width,
            view_height = self.frame.size.height
        switch self.contentMode {
        case .scaleAspectFill:
            return {
                if image_width > view_width || image_height > view_height {
                    return Float(min(image_width, image_height) == image_width ? image_width / view_width : image_height / view_height)
                }else{
                    return Float(image_width / view_width)
                }
            }()
        default:
            return 1
        }
    }
}

extension UIImage:ImageEditor{
    //UTI MobileCoreServices https://developer.apple.com/reference/mobilecoreservices/1652573-uttype/1653539-uti_image_content_types
    var data:Data?{
        let lock = SPinLock()
        lock.lock()
        if self.cgImage == nil{
            return nil
        }
        let mutable_data = CFDataCreateMutable(kCFAllocatorDefault, 0)
        
        if let dest = CGImageDestinationCreateWithData(mutable_data!, kUTTypePNG, 1, nil){
            CGImageDestinationAddImage(dest, self.cgImage!, nil)
            CGImageDestinationFinalize(dest)
        }
        lock.unlock()
        return mutable_data as Data?
    }
    
    var properties:Dictionary<String,AnyObject> {
        get{
            var propertise:Dictionary<String,AnyObject> = [:]
            let lock = SPinLock()
            lock.lock()
            guard let data  = UIImageJPEGRepresentation(self, 0.9) else{ return propertise}
            let cfdata = CFDataCreate(kCFAllocatorDefault, (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), data.count)
            guard let imageSource = CGImageSourceCreateWithData(cfdata!, nil) else{
                return propertise
            }
            if let copy_propertise:NSDictionary = CGImageSourceCopyPropertiesAtIndex(
                imageSource,
                0,
                nil){
                copy_propertise.forEach({ (key: AnyObject, value: AnyObject) in
                    if let key_str = key as? String{
                        propertise.updateValue(value, forKey: key_str)
                    }
                } as! (NSDictionary.Iterator.Element) -> Void)
            }
            lock.unlock()
            return propertise
        }
    }
    
    var type:CutterImageType{
        var c:UInt8 = 0
        guard let data = self.data else{
            return .unknown
        }
        (data as NSData).getBytes(&c, length: 1)
        switch c {
        case 0xFF:
            return .jpeg
        case 0x89:
            return .png
        case 0x47:
            return .gif
        case 0x49 | 0x4D:
            return .tiff
        default:
            return .unknown
        }
    }
    
    var refer:ImageRefer{
        return ImageRefer(ref: self.cgImage, image: self)
    }
}

/// get bitmap context
/// https://developer.apple.com/library/prerelease/content/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_context/dq_context.html#//apple_ref/doc/uid/TP30001066-CH203-CJBHBFFE
func bitmapContext(_ pix_w:Int, _ pix_h:Int) -> CGContext? {
    var context:CGContext?,
    colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB(),
    bitmap_data:UnsafeMutableRawPointer?,
    bitmapBytePerRow:Int = pix_w * 4,
    bitmapByteCount:Int  = bitmapBytePerRow * pix_h
    bitmap_data = malloc(bitmapByteCount)
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
    if bitmap_data == nil {
        return nil
    }
    context = CGContext(
        data: bitmap_data,
        width: pix_w,
        height: pix_h,
        bitsPerComponent: 8,
        bytesPerRow: bitmapBytePerRow,
        space: colorSpace,
        bitmapInfo: bitmapInfo)
    return context
}



