//
//  CutterType.swift
//  PhotoCutter
//
//  Created by 王望 on 16/7/18.
//  Copyright © 2016年 Will. All rights reserved.
//

import Foundation

public enum CutterType{
    
    case rect(width:Float,height:Float) //Clipping rectangle ,width ,height
    
    case circle(radius:Float) //Crop circle ,radius
}
