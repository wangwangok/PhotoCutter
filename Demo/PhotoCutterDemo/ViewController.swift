//
//  ViewController.swift
//  PhotoCutter
//
//  Created by Vivien on 16/7/18.
//  Copyright © 2016年 Will. All rights reserved.
//

import UIKit
import PhotoCutter

//swift3 适配纪录
//出现"no such module PhotoCutter"
//http://stackoverflow.com/questions/29500227/xcode-no-such-module-error-but-the-framework-is-there

class ViewController: UITableViewController {
    fileprivate struct PFSize{
        var width:Float
        var height:Float
    }
    
<<<<<<< HEAD
    let contents = ["girl.jpg","IMG_1710.jpg","IMG_1708.jpg"]
=======
    let contents = ["cat.png",
                    "web_youhui.png",
                    "IMG_1710.jpg",
                    "IMG_1708.jpg",
                    "IMG_1736.jpg",
                    "IMG_1720.jpg"]
>>>>>>> 6e8313f475bfd6f5b92fe9db0fdfb43df9681cd2
    
    fileprivate var type:CutterType?

    @IBOutlet weak var title_label: UILabel!
    
    @IBOutlet weak var width_field: UITextField!
    
    @IBOutlet weak var height_field: UITextField!
    
    fileprivate var rect_size:PFSize = PFSize(width: 100, height: 100)
    
    fileprivate var raduis:Float = 50
    
    fileprivate var is_circle:Bool = true
    
<<<<<<< HEAD
=======
    fileprivate let cutterViewController:PhotoCutterViewController = PhotoCutterViewController()
>>>>>>> 6e8313f475bfd6f5b92fe9db0fdfb43df9681cd2
    
    @IBOutlet weak var radius_field: UITextField!
    
    @IBOutlet weak var slider: UISlider!{
        didSet{
            slider.maximumValue = 200
            slider.minimumValue = 50
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func change(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            is_circle = true
        }else{
            is_circle = false
        }
    }
    
    @IBAction func valueChange(_ sender: UISlider) {
        raduis = floor(sender.value)
        radius_field.text = String(format: "%.0f", raduis)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
<<<<<<< HEAD
        let cutterViewController:PhotoCutterViewController = PhotoCutterViewController()
=======
>>>>>>> 6e8313f475bfd6f5b92fe9db0fdfb43df9681cd2
        if is_circle == true {
            cutterViewController.cutterType = CutterType.circle(radius: raduis)
        }else{
            cutterViewController.cutterType = CutterType.rect(width: rect_size.width, height: rect_size.height)
        }
        let cutterImage = UIImage(named: contents[(indexPath as NSIndexPath).row])!
        cutterViewController.image = cutterImage
        self.navigationController?.pushViewController(cutterViewController, animated: true)
    }
}

extension ViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == width_field {
            rect_size.width = Float(textField.text!)!
        }
        
        if textField == height_field {
            rect_size.height = Float(textField.text!)!
        }
        
        if textField == radius_field {
            raduis = Float(textField.text!)!
        }
    }
}

