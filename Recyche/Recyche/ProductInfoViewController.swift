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
//                print(response.request)  // original URL request
//                print(response.response) // URL response
//                print(response.data)     // server data
//                print(response.result)   // result of response serialization
                
                if let data = response.data {
                    let json = JSON(data: data)
                    print(json["0"]["productname"])
                    
                    self.productNameLabel.text = json["0"]["productname"].stringValue
                    self.productImageView.image = UIImage(data: NSData(contentsOfURL: NSURL(string: json["0"]["imageurl"].stringValue)!)!)
                }
                
                
//                if let JSON = response.result.value {
//                    print("JSON: \(JSON)")
//                    
//                    print(JSON[0]["0 ="])
////                    self.productImageView.image = UIImage(data: NSData(contentsOfURL: NSURL(string: JSON["imageurl"] as! String)!)!)
//                    self.productNameLabel.text = JSON["productname"] as? String
//                }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resour  ces that can be recreated.
    }
    
    
}

