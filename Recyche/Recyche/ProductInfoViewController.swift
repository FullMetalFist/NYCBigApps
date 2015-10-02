//
//  ProductInfoViewController.swift
//  Recyche
//
//  Created by Zel Marko on 20/09/15.
//  Copyright © 2015 Giving Tree. All rights reserved.
//

import UIKit
import Alamofire

let URLString = "http://www.searchupc.com/handlers/upcsearch.ashx?request_type=3"
let access_token = "C6D5DA80-A126-4235-A35A-26E73FC64C2F"
let UPC_code =  "037000088806"
let UPC = "0892685001003"



class ProductInfoViewController: UIViewController {
    
    var scannedUPC: String!
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print(scannedUPC)
        Alamofire.request(.GET, URLString, parameters: ["access_token" : access_token ,"upc": scannedUPC])
            .responseJSON { response in
                
                if let data = response.data {
                    let json = JSON(data: data)
//                    print(json)
                    if let name = json["0"]["productname"].string {
                        print(name)
                        self.productNameLabel.text = name
                    }
                    
                    if let imageURL = json["0"]["imageurl"].string {
//                        print(imageURL)
                        if self.verifyUrl(imageURL) {
                            self.productImageView.image = UIImage(data: NSData(contentsOfURL: NSURL(string: imageURL)!)!)
                        }
                        else {
                            self.productNameLabel.text = "No Product Found!"
                        }
                        
                    }
                    
                }
                
                
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resour  ces that can be recreated.
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

