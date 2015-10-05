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
import CoreData

class AddProductViewController: UIViewController, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productPicker: UIPickerView!
    @IBOutlet weak var addProductToDatabaseButton: UIButton!
    @IBOutlet weak var productNameTextField: UITextField!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let pickerData = ["PETE SPI CODE:1","HDPE SPI CODE:2," ,"PVC SPI CODE:3" , "LDPE SPI CODE:4",  "PP SPI CODE:5" , "PS SPI CODE:6" , "SHELF-STABLE CARTON", "REFRIGERATED CARTON" ,"GLASS GREEN", "GLASS CLEAR","GLASS BROWN", "PAPER" , "CARDBOARD" , "NEWSPRINT" ,"ALUMINUM", "TIN OR STEEL", "PAINT OR AEROESOL CANS" ]
    
    var scannedUPC: String!
    var material: String!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addProductToDatabaseButton.enabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.hidden = false
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        
        Alamofire.request(.GET, URLString, parameters: ["access_token" : access_token ,"upc": scannedUPC]).responseJSON { response in
            
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
            self.loadingView.hidden = true
            
            if let data = response.data {
                let json = JSON(data: data)
                
                if let name = json["0"]["productname"].string, let imageURL = json["0"]["imageurl"].string {
                    self.productNameLabel.text = name
                    
                    if self.verifyUrl(imageURL) {
                        self.productImageView.image = UIImage(data: NSData(contentsOfURL: NSURL(string: imageURL)!)!)
                    }
                }
                else {
                    self.productNameLabel.text = "Add Product Name"
                    if UIImagePickerController.isSourceTypeAvailable(.Camera) {
                        self.addImageButton.enabled = true
                    }
                    self.productNameTextField.enabled = true
                }
            }
        }
    }
    
    @IBAction func addProductToDatabase(sender: AnyObject) {
        
        loadingView.hidden = false
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        
        let container = CKContainer.defaultContainer()
        let publicData = container.publicCloudDatabase
        
        let product = CKRecord(recordType: "Product", recordID: CKRecordID(recordName: scannedUPC))
        product.setValue(productNameLabel.text, forKey: "name")
        product.setValue(material, forKey: "material")
        product.setValue(1, forKey: "numberOfScans")
        
        if productImageView.image != nil {
            let imageData = UIImageJPEGRepresentation(productImageView.image!, 1)
            let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let fileURL = documentsURL.URLByAppendingPathComponent("imageasset")
            imageData?.writeToURL(fileURL, atomically: true)
            
            let asset = CKAsset(fileURL: fileURL)
            product.setValue(asset, forKey: "image")
        }
        
        publicData.saveRecord(product) { (record, error) -> Void in
            if error != nil {
                print(error)
            }
            else {
                print(record?.recordID.recordName)
                self.addToPersonalDatabase()
            }
            self.activityIndicator.stopAnimating()
            self.loadingView.hidden = true
        }
    }
    
    func addToPersonalDatabase() {
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        Product.createInManagedObjectContext(managedObjectContext, _name: productNameLabel.text!, _material: material, _numberOfScans: 1)
        
        do {
            try managedObjectContext.save()
        }
        catch _ {
            print("Error?")
        }
    }
    
    @IBAction func addImage(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            imagePicker.sourceType = .Camera
            presentViewController(imagePicker, animated: true, completion: nil)
        }
        else {
            print("No Camera available!")
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        
        productImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        productNameTextField.resignFirstResponder()
        return true
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.sharedApplication().canOpenURL(url)
            }
        }
        return false
    }
}

