//
//  ProductInfoViewController.swift
//  Recyche
//
//  Created by Zel Marko on 20/09/15.
//  Copyright © 2015 Giving Tree. All rights reserved.
//

import UIKit
import Alamofire
import CloudKit
import CoreData

let URLString = "http://www.searchupc.com/handlers/upcsearch.ashx?request_type=3"
let access_token = "C6D5DA80-A126-4235-A35A-26E73FC64C2F"
let UPC_code =  "037000088806"
let UPC = "0892685001003"

class ProductInfoViewController: UIViewController {
    
    var scannedProduct: CKRecord!
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productNameDetail: UILabel!
    @IBOutlet weak var materialLabel: UILabel!
    @IBOutlet weak var materialDetailLabel: UILabel!
    @IBOutlet weak var recycleInstructionsLabel: UILabel!
    @IBOutlet weak var recycleInstructionsTextView: UITextView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("loading")
        for code in recycleCodes {
            if code == scannedProduct.valueForKey("material") as! String {
                recycleInstructionsTextView.text! = instructionForCode(code)
            }
        }
        
        if let name = scannedProduct.valueForKey("name") as? String {
            productNameLabel.text = name
            productNameDetail.hidden = true
        }
        else {
            productNameLabel.text = "No product name available for this product."
            productNameDetail.text = "Check the recycling instructions below."
        }
        
        if let mat = scannedProduct.valueForKey("material") as? String {
            materialLabel.text = materialForCode(mat)
            materialDetailLabel.text = mat
        }
        
        if scannedProduct.valueForKey("image") != nil {
            let imageAsset = scannedProduct.valueForKey("image") as! CKAsset
            productImageView.image = UIImage(contentsOfFile: imageAsset.fileURL.path!)
        }
        else {
            productImageView.image = UIImage(named: "NoImage")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addToPersonalDatabase(scannedProduct)
    }
    
    @IBAction func toScanner(sender: AnyObject) {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resour  ces that can be recreated.
    }
    
    func addToPersonalDatabase(product: CKRecord!) {
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        Product.createInManagedObjectContext(managedObjectContext, _name: product.valueForKey("name") as! String, _material: product.valueForKey("material") as! String, _date: NSDate())
        
        do {
            try managedObjectContext.save()
        }
        catch _ {
            print("Error?")
        }
    }

}

