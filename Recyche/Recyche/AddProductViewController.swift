//
//  AddProductViewController.swift
//  Recyche
//
//  Created by Zel Marko on 20/09/15.
//  Copyright © 2015 Giving Tree. All rights reserved.
//

import UIKit
import Alamofire
import CloudKit

class AddProductViewController: UIViewController, UIPickerViewDelegate {
    
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productPicker: UIPickerView!
    @IBOutlet weak var addProductToDatabaseButton: UIButton!
    
    let pickerData = ["PETE SPI CODE:1","HDPE SPI CODE:2," ,"PVC SPI CODE:3" , "LDPE SPI CODE:4",  "PP SPI CODE:5" , "PS SPI CODE:6" , "SHELF-STABLE CARTON", "REFRIGERATED CARTON" ,"GLASS GREEN", "GLASS CLEAR","GLASS BROWN", "PAPER" , "CARDBOARD" , "NEWSPRINT" ,"ALUMINUM", "TIN OR STEEL", "PAINT OR AEROESOL CANS" ]
    
    var UPC: String!
    var material: String!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addProductToDatabaseButton.enabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let container = CKContainer.defaultContainer()
        let publicData = container.publicCloudDatabase
        
        let query = CKQuery(recordType: "Product", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        publicData.performQuery(query, inZoneWithID: nil) { (records, error) -> Void in
            if error == nil {
                if let results = records {
                    print(results[0].recordID.recordName)
                }
            }
        }
        
    }
    
    @IBAction func addProductToDatabase(sender: AnyObject) {
        
        let container = CKContainer.defaultContainer()
        let publicData = container.publicCloudDatabase
        
        let product = CKRecord(recordType: "Product", recordID: CKRecordID(recordName: UPC))
        product.setValue("Product Name", forKey: "name")
        product.setValue(material, forKey: "material")
        
        publicData.saveRecord(product) { (record, error) -> Void in
            if error != nil {
                print(error)
            }
        }
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
        
        material = pickerData[row]
        
        if !addProductToDatabaseButton.enabled {
            addProductToDatabaseButton.enabled = true
        }
    }
}

