//
//  FilterConst.swift
//  PhotoCutter
//
//  Created by 王望 on 16/8/31.
//  Copyright © 2016年 Will. All rights reserved.
//

import Foundation
import UIKit

enum PhotoFilterError:String,Error {
    
    case FilterResourceNone = "in PFImageView Filter's image is nil "
    
    case ControllerImageNone = "PhotoFilterViewController image is nil"
    
    case ReloadImageNone = "when contentView reload and the contentView don't have image"
    
    var code:Int{
        switch self {
        case .FilterResourceNone:
            return 8001
            
        case .ControllerImageNone:
            return 8002
            
        case .ReloadImageNone:
            return 8003
        }
    }

    var description:String{
        return self.rawValue
    }
}

public let FilterQueue = DispatchQueue(label: "PFImageDefaultQueue", attributes: [])
