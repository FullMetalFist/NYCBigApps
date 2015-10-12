//
//  AddProductViewController.swift
//  Recyche
//
//  Created by Zel Marko on 20/09/15.
//  Copyright © 2015 Giving Tree. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CloudKit
import CoreData

class AddProductViewController: UIViewController, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productPicker: UIPickerView!
    @IBOutlet weak var addProductToDatabaseButton: UIButton!

    
    var scannedUPC: String!
    var material: String!
    var newProduct: CKRecord!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addProductToDatabaseButton.enabled = false
        addProductToDatabaseButton.alpha = 0.3
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Alamofire.request(.GET, URLString, parameters: ["access_token" : access_token ,"upc": scannedUPC]).responseJSON { response in
            
            if let data = response.data {
                let json = JSON(data: data)

                if let name = json["0"]["productname"].string, let imageURL = json["0"]["imageurl"].string {
                    if name == " " {
                        self.productNameLabel.text = "No product found!\nPlease choose the appropriate recycling code and save it in our database for future reference."
                        self.productImageView.image = UIImage(named: "NoImage")
                    }
                    else {
                        self.productNameLabel.text = name
                    }
                    
                    
                    if self.verifyUrl(imageURL) {
                        self.productImageView.image = UIImage(data: NSData(contentsOfURL: NSURL(string: imageURL)!)!)
                    }
                }
                else {
                    self.productNameLabel.text = "No product found!\nPlease choose the appropriate recycling code and save it in our database for future reference."
                    self.productImageView.image = UIImage(named: "NoImage")
                }
            }
        }
    }
    
    
    @IBAction func addProductToDatabase(sender: AnyObject) {
        
        let container = CKContainer.defaultContainer()
        let publicData = container.publicCloudDatabase
        
        let product = CKRecord(recordType: "Product", recordID: CKRecordID(recordName: scannedUPC))
        product.setValue(material, forKey: "material")
        product.setValue(1, forKey: "numberOfScans")
        product.setValue("Product", forKey: "name")
        
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
                self.newProduct = record
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.performSegueWithIdentifier("addToInfoSegue", sender: self)
                })
            }
            
        }
    }
    
    func addToPersonalDatabase() {
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        Product.createInManagedObjectContext(managedObjectContext, _name: productNameLabel.text!, _material: material, _date: NSDate())
        
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
        return recycleCodes.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return recycleCodes[row]
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let titleData = recycleCodes[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Arial", size: 14.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = .Center
        pickerLabel.backgroundColor = colorForCode(titleData)
        
        
        return pickerLabel
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        material = recycleCodes[row]
        
        if !addProductToDatabaseButton.enabled && row != 0 {
            addProductToDatabaseButton.enabled = true
            addProductToDatabaseButton.alpha = 1
        }
        else if addProductToDatabaseButton.enabled && row == 0 {
            addProductToDatabaseButton.enabled = false
            addProductToDatabaseButton.alpha = 0.3
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        
        productImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
    
    func colorForCode(code: String) -> UIColor {
        switch code {
        case _ where code == "PETE 1", "HDPE 2", "PVC 3", "LDPE 4", "PP 5", "PS 6", "PLASTIC":
            return colorWithHexString("88D5EC")
        case _ where code == "SHELF-STABLE CARTON", "REFRIGERATED CARTON", "CARTON":
            return colorWithHexString("7EA0D2")
        case _ where code == "GLASS GREEN", "GLASS CLEAR", "GLASS BROWN", "GLASS":
            return colorWithHexString("CFDE4E")
        case _ where code == "PAPER", "PAPER BACK BOOK", "NEWSPRINT":
            return colorWithHexString("D8914F")
        case _ where code == "CARDBOARD":
            return colorWithHexString("D8914F")
        case _ where code == "ALUMINUM", "TIN OR STEEL", "PAINT OR AEROESOL CANS", "METAL":
            return colorWithHexString("E486B7")
        default:
            return colorWithHexString("F3F7DE")
        }
    }
    
    func colorWithHexString (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }
        
        if (cString.characters.count != 6) {
            return UIColor.grayColor()
        }
        
        let rString = (cString as NSString).substringToIndex(2)
        let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addToInfoSegue" {
            let productInfoViewController = segue.destinationViewController as! ProductInfoViewController
            productInfoViewController.scannedProduct = newProduct
        }
    }
}

