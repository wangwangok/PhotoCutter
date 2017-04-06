//
//  PhotoFilterViewController.swift
//  PhotoCutter
//
//  Created by 王望 on 16/8/2.
//  Copyright © 2016年 Will. All rights reserved.
//

import UIKit

internal let itemSize:CGSize = CGSize(width: 44, height: 44)

private let sectionInsetTop:CGFloat = 8

private let sectionInsetBottom:CGFloat = 8

let toobarHeight:CGFloat = 44

let listHeight:CGFloat = 60

private let minimumLineSpacing:CGFloat = 10

private let listReuseIdentifier:String = "PhotoCutterFilterListIdentifier"

public final class PhotoFilterViewController: UIViewController {
    //MARK: - public Propertise-
    public var image:UIImage?
    
    //MARK: - private propertise -
    fileprivate var toolBar:PhotoToolBar = {
        let screen_width  = UIScreen.main.bounds.width
        let screen_height = UIScreen.main.bounds.height
        let rect          = CGRect(
            x: 0,
            y: screen_height - toobarHeight,
            width: screen_width,
            height: toobarHeight)
        let bar = PhotoToolBar(frame: rect)
        bar.backgroundColor = UIColor(
            red:   78 / 255.0,
            green: 75 / 255.0,
            blue:  74 / 255.0,
            alpha: 0.8)
        return bar
    }()
    
    fileprivate var filterList:UICollectionView!
    
    fileprivate var defaults:[PFImageFilter?] = []
    
    fileprivate var contentView:PFContentView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        do{
            try initializers()
        }catch{
            print(error)
        }
    }
    
    public override var shouldAutorotate : Bool {
        return false
    }
    
    public override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }
    
    deinit{
        print("deinit")
    }
}

private typealias PrivateFunction = PhotoFilterViewController
extension PrivateFunction{
    fileprivate func initializers()throws{
        if image == nil{
            throw PhotoFilterError.ControllerImageNone
        }
        view.backgroundColor = UIColor.black
        if let navi = navigationController{
            navi.setNavigationBarHidden(true, animated: true)
        }
        contentView = PFContentView(image: image)
        self.view.addSubview(contentView)
        self.view.addSubview(toolBar)
        self.view.backgroundColor = UIColor.black
        filterList = {
            let screen_width  = UIScreen.main.bounds.width
            let screen_height = UIScreen.main.bounds.height
            let rect = CGRect(
                x: 0,
                y: screen_height - listHeight - toobarHeight,
                width: screen_width,
                height: listHeight)
            let flowLaout = UICollectionViewFlowLayout()
            flowLaout.minimumLineSpacing = minimumLineSpacing
            flowLaout.sectionInset = UIEdgeInsets(
                top: sectionInsetTop,
                left: 0,
                bottom: sectionInsetBottom,
                right: 0)
            flowLaout.itemSize = itemSize
            flowLaout.scrollDirection = .horizontal
            let collectionView = UICollectionView(frame: rect, collectionViewLayout: flowLaout)
            collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: listReuseIdentifier)
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.backgroundColor = UIColor.black
            collectionView.register(PhotoFilterCollectionViewCell.self, forCellWithReuseIdentifier: listReuseIdentifier)
            return collectionView
        }()
        self.view.addSubview(filterList)
        
        //confirm
        toolBar.kConfirmValueCallBacks = {[weak self]() in
            
        }
        
        //cancle
        toolBar.kCancleValueCallBacks = {[weak self]() in
            guard let weak_self = self else{
                return
            }
            if weak_self.navigationController != nil {
                weak_self.navigationController?.popViewController(animated: true)
            }else{
                weak_self.dismiss(animated: true, completion: nil)
            }
        }
        FilterQueue.async { 
            self.getdefaults()
        }
    }
    
    fileprivate func getdefaults(){
        defaults.removeAll()
        guard let cur_image = image else{
            defaults = []
            return
        }
        let ciImage = CIImage(image: cur_image)
        self.defaults = [
            ciImage?.InstantFilter,
            ciImage?.ProcessFilter,
            ciImage?.ChromeFilter,
            ciImage?.MonoFilter,
            ciImage?.TonalFilter,
            ciImage?.FadeFilter,
            ciImage?.NoirFilter,
            ciImage?.TransferFilter
        ]
        self.filterList.reloadData()
    }
}

private typealias CollectionViewDataSourceDelegate = PhotoFilterViewController
extension CollectionViewDataSourceDelegate:UICollectionViewDataSource,UICollectionViewDelegate{
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return defaults.count + 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: listReuseIdentifier, for: indexPath)
        cell.contentView.backgroundColor = UIColor.clear
        guard let photocell = cell as? PhotoFilterCollectionViewCell else{
            return cell
        }
        var cur_image:CIImage?
        if (indexPath as NSIndexPath).item == 0 {
            cur_image = CIImage(image: image!)
        }else{
            cur_image = defaults[(indexPath as NSIndexPath).item - 1]?.outputImage
        }
        if photocell.filterView.image == nil {
            photocell.filterView.image = cur_image
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var cur_image:CIImage?
        if (indexPath as NSIndexPath).item == 0 {
            cur_image = CIImage(image: image!)
        }else{
            cur_image = defaults[(indexPath as NSIndexPath).item - 1]?.outputImage
        }
        contentView.reloadData(cur_image)
    }
}
