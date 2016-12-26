//
//  CuterConst.swift
//  PhotoCutter
//
//  Created by 王望 on 16/7/22.
//  Copyright © 2016年 Will. All rights reserved.
//
import UIKit

public enum CutterImageType{
    
    case gif,png,tiff,jpeg,unknown
    
}

final class SPinLock{
    var _spinlock = OS_SPINLOCK_INIT
    
    func lock() {
        withUnsafeMutablePointer(to: &_spinlock, OSSpinLockLock)
    }
    
    func unlock() {
        withUnsafeMutablePointer(to: &_spinlock, OSSpinLockUnlock)
    }
    
    func withLock<T>(_ action: () -> T) -> T {
        withUnsafeMutablePointer(to: &_spinlock, OSSpinLockLock)
        let result = action()
        withUnsafeMutablePointer(to: &_spinlock, OSSpinLockUnlock)
        return result
    }

    func tryLock<T>(_ action: () -> T) -> T? {
        if !withUnsafeMutablePointer(to: &_spinlock, OSSpinLockTry) {
            return nil
        }
        let result = action()
        withUnsafeMutablePointer(to: &_spinlock, OSSpinLockUnlock)
        return result
    }
}

enum PhotoCutterError:String,Error {
    
    case ReferResourceNone = " refer's ref and image all is nil "
    
    var code:Int{
        switch self {
        case .ReferResourceNone:
            return 7001
        }
    }
    
    var description:String{
        return self.rawValue
    }
}
