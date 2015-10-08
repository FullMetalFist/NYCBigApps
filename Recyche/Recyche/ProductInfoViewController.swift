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

let URLString = "http://www.searchupc.com/handlers/upcsearch.ashx?request_type=3"
let access_token = "C6D5DA80-A126-4235-A35A-26E73FC64C2F"
let UPC_code =  "037000088806"
let UPC = "0892685001003"

class ProductInfoViewController: UIViewController {
    
    var scannedProduct: CKRecord!
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var numberOfScansLabel: UILabel!
    @IBOutlet weak var materialLabel: UILabel!
    @IBOutlet weak var recycleInstructionsLabel: UILabel!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        print(recycleCodesInfo["metal"]!)
        
        for code in recycleCodes {
            if code == scannedProduct.valueForKey("material") as! String {
                switch code {
                case _ where code == "PETE SPI CODE: 1", "HDPE SPI CODE: 2", "PVC SPI CODE: 3", "LDPE SPI CODE: 4", "PP SPI CODE: 5", "PS SPI CODE: 6":
                    print("plastic")
                    recycleInstructionsLabel.text! = recycleCodesInfo["plastic"]!
                case _ where code == "SHELF-STABLE CARTON", "REFRIGERATED CARTON":
                    print("carton")
                    recycleInstructionsLabel.text! = recycleCodesInfo["carton"]!
                case _ where code == "GLASS GREEN", "GLASS CLEAR", "GLASS BROWN":
                    print("glass")
                    recycleInstructionsLabel.text! = recycleCodesInfo["glass"]!
                case _ where code == "PAPER":
                    print("paper")
                    recycleInstructionsLabel.text! = recycleCodesInfo["paper"]!
                case _ where code == "CARDBOARD":
                    print("cardboard")
                    recycleInstructionsLabel.text! = recycleCodesInfo["cardbord"]!
                case _ where code == "ALUMINUM", "TIN OR STEEL", "PAINT OR AEROESOL CANS":
                    print("metal")
                    recycleInstructionsLabel.text! = recycleCodesInfo["metal"]!
                default:
                    print("crap")
                }
            }
            
        }
        
        productNameLabel.text = scannedProduct.valueForKey("name") as? String
        let numberOfScans = scannedProduct.valueForKey("numberOfScans") as? Int
        numberOfScansLabel.text = "This product has been recycled \(numberOfScans!) times."
        materialLabel.text = scannedProduct.valueForKey("material") as? String
        
        
        if scannedProduct.valueForKey("image") != nil {
            let imageAsset = scannedProduct.valueForKey("image") as! CKAsset
            productImageView.image = UIImage(contentsOfFile: imageAsset.fileURL.path!)
        }
        
        let dataAdded = scannedProduct.valueForKey("dateadded") as? NSDate
        print(dataAdded)
        
        updateProduct()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    func updateProduct() {
        let publicData = CKContainer.defaultContainer().publicCloudDatabase
        
        var timesScaned = scannedProduct.valueForKey("numberOfScans") as! Int
        
        scannedProduct.setValue(++timesScaned, forKey: "numberOfScans")
        
        publicData.saveRecord(scannedProduct) { (record, error) -> Void in
            if error != nil {
                print(error)
            }
            else {
                print("Record updated!")
                if let product = record, let numberOfScans = product.valueForKey("numberOfScans") {
                    self.numberOfScansLabel.text = "This product has been recycled \(numberOfScans) times."
                }
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resour  ces that can be recreated.
    }
}

