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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        print(scannedProduct)
        
        productNameLabel.text = scannedProduct.valueForKey("name") as? String
        let numberOfScans = scannedProduct.valueForKey("numberOfScans") as? Int
        numberOfScansLabel.text = "This product has been recycled \(numberOfScans!) times."
        materialLabel.text = scannedProduct.valueForKey("material") as? String
        
        let imageAsset = scannedProduct.valueForKey("image") as! CKAsset
        productImageView.image = UIImage(contentsOfFile: imageAsset.fileURL.path!)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resour  ces that can be recreated.
    }
}

