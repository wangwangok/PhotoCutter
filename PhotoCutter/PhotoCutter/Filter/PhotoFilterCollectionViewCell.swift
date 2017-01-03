//
//  PhotoFilterCollectionViewCell.swift
//  PhotoCutter
//
//  Created by 王望 on 16/9/1.
//  Copyright © 2016年 Will. All rights reserved.
//

import UIKit

internal class PhotoFilterCollectionViewCell: UICollectionViewCell {
    
    internal var filterView:PFImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        filterView = PFImageView(frame: CGRect(x: 0, y: 0, width: itemSize.width, height: itemSize.height))
        filterView.aspectMode = .scaleAspectFill
        contentView.addSubview(filterView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
}
