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
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
                
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resour  ces that can be recreated.
    }
}

