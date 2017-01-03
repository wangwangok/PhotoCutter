//
//  PhotoCutterViewController.swift
//  PhotoCutter
//
//  Created by 王望 on 16/7/18.
//  Copyright © 2016年 Will. All rights reserved.
//

import UIKit

//关于open的解释最经典的一句话:"more public than public"
//https://github.com/apple/swift-evolution/blob/master/proposals/0117-non-public-subclassable-by-default.md

open class PhotoCutterViewController: UIViewController {
    //MARK: - public Propertise-
    open var image:UIImage?
    
    open var cutterType:CutterType = CutterType.circle(radius: 100)
    
    //MARK: - private propertise -
    fileprivate var toolBar:PhotoToolBar = {
        let screen_width  = UIScreen.main.bounds.width
        let screen_height = UIScreen.main.bounds.height
        let rect          = CGRect(
            x: 0,
            y: screen_height - 44,
            width: screen_width,
            height: 44)
        let bar = PhotoToolBar(frame: rect)
        bar.backgroundColor = UIColor(
            red:   78 / 255.0,
            green: 75 / 255.0,
            blue:  74 / 255.0,
            alpha: 0.8)
        return bar
    }()
    
    fileprivate var cutterView:PhotoCutterView!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        initializers()
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    open override var shouldAutorotate : Bool {
        return false
    }
    
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }
    
    deinit{
        print("deinit")
    }
}


private typealias UISet = PhotoCutterViewController
extension UISet{
    fileprivate func initializers(){
        if image == nil {
            return
        }
        view.backgroundColor = UIColor.black
        if let navi = navigationController{
            navi.setNavigationBarHidden(true, animated: true)
        }
        view.addSubview(toolBar)
        
        let screen_width    = UIScreen.main.bounds.width
        let screen_height   = UIScreen.main.bounds.height
        let rect            = CGRect(x: 0, y: 0, width: screen_width, height: screen_height - 44)
        cutterView = {
            $0.delegate     = self
            $0.cutterType   = cutterType
            return $0
        }(PhotoCutterView(frame: rect, image: image))
        
        view.addSubview(cutterView)
        
        //confirm
        toolBar.kConfirmValueCallBacks = {[weak self]() in
            if let weak_self = self{
                weak_self.confirm()
            }
        }
        
        //cancle
        toolBar.kCancleValueCallBacks = {[weak self]() in
            if let weak_self = self{
                weak_self.image = nil
                weak_self.cancle()
            }
        }
    }
    
    fileprivate func confirm(){
        let converPoint = cutterView.contentImageView.convert(cutterView.contentView.center, from: cutterView.contentView)
        if let image = cutterView.cutter(converPoint){
            let filter = PhotoFilterViewController()
            filter.image = image
            if let navi = navigationController{
                navi.pushViewController(filter, animated: true)
            }else{
                present(filter, animated: true, completion: nil)
            }
        }
    }
    
    fileprivate func cancle(){
        if let navi = navigationController{
            navi.setNavigationBarHidden(false, animated: false)
            navi.popViewController(animated: true)
        }else{
            dismiss(animated: true, completion: nil)
        }
    }
}

private typealias ActionFunction = PhotoCutterViewController
extension ActionFunction{
    
    
}

private typealias ScrollViewDelegate = PhotoCutterViewController
extension ScrollViewDelegate:UIScrollViewDelegate{
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    //MARK : - Zoom -
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        cutterView.reloadView()
    }
  
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return cutterView.contentImageView
    }
}
