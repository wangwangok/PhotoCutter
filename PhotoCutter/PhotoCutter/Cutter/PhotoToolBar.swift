//
//  PhotoToolBar.swift
//  PhotoCutter
//
//  Created by 王望 on 16/7/19.
//  Copyright © 2016年 Will. All rights reserved.
//

import UIKit

public class PhotoToolBar: UIView {
    
    open var kConfirmValueCallBacks:(()->Void)?
    
    open var kCancleValueCallBacks:(()->Void)?
    
    fileprivate var cancleItem:UIButton = {
        $0.setTitle("取消", for: UIControlState())
        $0.setTitleColor(UIColor.white, for: UIControlState())
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setContentCompressionResistancePriority(999, for: .horizontal)
        $0.setContentCompressionResistancePriority(999, for: .vertical)
        return $0
    }(UIButton(type: .custom))
    
    fileprivate var confirmItem:UIButton = {
        $0.setTitle("确定", for: UIControlState())
        $0.setTitleColor(UIColor.white, for: UIControlState())
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setContentCompressionResistancePriority(999, for: .horizontal)
        $0.setContentCompressionResistancePriority(999, for: .vertical)
        return $0
    }(UIButton(type: .custom))
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup(){
        cancleItem.backgroundColor = UIColor.clear
        addSubview(cancleItem)
        addConstraints([
            //view1.attr1 = view2.attr2 * multiplier + constant
            NSLayoutConstraint(
                item: self,
                attribute: .leading,
                relatedBy: .equal,
                toItem: cancleItem,
                attribute: .leading,
                multiplier: 1.0,
                constant: -15),
            NSLayoutConstraint(
                item: cancleItem,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: self,
                attribute: .centerY,
                multiplier: 1.0,
                constant: 0)
            ])
        
        addSubview(confirmItem)
        
        addConstraints([
            NSLayoutConstraint(
                item: confirmItem,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: self,
                attribute: .trailing,
                multiplier: 1.0,
                constant: -15),
            NSLayoutConstraint(
                item: confirmItem,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: self,
                attribute: .centerY,
                multiplier: 1.0,
                constant: 0)])
        confirmItem.addTarget(self, action: #selector(PhotoToolBar.confirm), for: .touchUpInside)
        cancleItem.addTarget(self, action: #selector(PhotoToolBar.cancle), for: .touchUpInside)
    }
    
    func confirm(){
        kConfirmValueCallBacks?()
    }
    
    func cancle(){
        kCancleValueCallBacks?()
    }
}
