//
//  AddProductViewController.swift
//  Recyche
//
//  Created by Zel Marko on 20/09/15.
//  Copyright © 2015 Giving Tree. All rights reserved.
//

import UIKit
import Alamofire


class AddProductViewController: UIViewController, UIPickerViewDelegate {
    
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productPicker: UIPickerView!
    
    
    let pickerData = ["PETE SPI CODE:1","HDPE SPI CODE:2," ,"PVC SPI CODE:3" , "LDPE SPI CODE:4",  "PP SPI CODE:5" , "PS SPI CODE:6" , "SHELF-STABLE CARTON", "REFRIGERATED CARTON" ,"GLASS GREEN", "GLASS CLEAR","GLASS BROWN", "PAPER" , "CARDBOARD" , "NEWSPRINT" ,"ALUMINUM", "TIN OR STEEL", "PAINT OR AEROESOL CANS" ]
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        Alamofire.request(.GET, URLString, parameters: ["access_token" : access_token ,"upc": UPC_code])
            .responseJSON { response in
//                print(response.request)  // original URL request
//                print(response.response) // URL response
//                print(response.data)     // server data
//                print(response.result)   // result of response serialization
                
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                }
        }
        
    }
    @IBAction func addProductToDatabase(sender: AnyObject) {
        print(productPicker)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resour  ces that can be recreated.
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return pickerData[row]
        
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let titleData = pickerData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Arial", size: 14.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = .Center
        return pickerLabel
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        print(pickerData[row])
    }
}

