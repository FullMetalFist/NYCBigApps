//
//  ScannerViewController.swift
//  Recyche
//
//  Created by Zel Marko on 20/09/15.
//  Copyright © 2015 Giving Tree. All rights reserved.
//

import UIKit
import AVFoundation
import FBSDKCoreKit
import FBSDKLoginKit
import CloudKit

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var captureDevice: AVCaptureDevice?
    var lastCapturedCode:String?
    var scannedProduct: CKRecord!
    var barcodeScanned:((String) ->())?
    
    @IBOutlet weak var videoView:UIView!
    @IBOutlet weak var instructionBanner: UILabel!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    private var allowedTypes = [AVMetadataObjectTypeUPCECode,
        AVMetadataObjectTypeCode39Code,
        AVMetadataObjectTypeCode39Mod43Code,
        AVMetadataObjectTypeEAN13Code,
        AVMetadataObjectTypeEAN8Code,
        AVMetadataObjectTypeCode93Code,
        AVMetadataObjectTypeCode128Code,
        AVMetadataObjectTypePDF417Code,
        AVMetadataObjectTypeAztecCode]
    
    // MARK: - UIViewController functions
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.tabBar.tintColor = colorWithHexString("15783D")

        self.captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var error:NSError?
        let input : AnyObject!
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
        }
        catch let error1 as NSError {
            error = error1
            input = nil
        }
        if (error != nil) {
            print("\(error?.localizedDescription)")
            return
        }
        
        captureSession = AVCaptureSession()
        captureSession?.addInput(input as! AVCaptureInput)
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureMetadataOutput.metadataObjectTypes = self.allowedTypes
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResize
        videoPreviewLayer?.frame = videoView.layer.bounds
        videoView.layer.insertSublayer(videoPreviewLayer!, below: instructionBanner.layer)
        videoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "restartScanner"))
        
        captureSession?.startRunning()
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.greenColor().CGColor
        qrCodeFrameView?.layer.borderWidth = 3
        qrCodeFrameView?.autoresizingMask = [UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin]
        
        view.addSubview(qrCodeFrameView!)
        view.bringSubviewToFront(qrCodeFrameView!)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if captureSession != nil {
            restartScanner()
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if (FBSDKAccessToken.currentAccessToken() == nil) {
            performSegueWithIdentifier("toLoginSegue", sender: self)
        }
        else {
            // Need some error notification
        }
    }

    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        videoPreviewLayer?.frame = self.videoView.layer.bounds
        
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        
        switch(orientation){
        case UIInterfaceOrientation.LandscapeLeft:
            videoPreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
            
        case UIInterfaceOrientation.LandscapeRight:
            videoPreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
            
        case UIInterfaceOrientation.Portrait:
            videoPreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
            
        case UIInterfaceOrientation.PortraitUpsideDown:
            videoPreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.PortraitUpsideDown
            
        default:
            print("Unknown orientation state")
        }
    }
    
    // MARK: - Actions
    
    @IBAction func toProductDetail(sender: AnyObject) {
        lastCapturedCode = "0123456789012"
        databaseCheck(lastCapturedCode!)
    }
    
    @IBAction func toAddProduct(sender: AnyObject) {
        lastCapturedCode = "\(arc4random_uniform(892357235))"
        databaseCheck(lastCapturedCode!)
    }
    
    // MARK: - Class Functions
    
    func databaseCheck(upc: String) {
        
        let container = CKContainer.defaultContainer()
        let publicData = container.publicCloudDatabase
        
        publicData.fetchRecordWithID(CKRecordID(recordName: upc)) { (record, error) -> Void in
            if error != nil {
                if error!.userInfo["ServerErrorDescription"]! as! String == "Record not found" {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.performSegueWithIdentifier("toAddProductSegue", sender: self)
                        self.loadingIndicator.stopAnimating()
                        self.loadingView.hidden = true
                    })
                }
                else {
                    print(error!)
                }
                
            }
            else if record != nil {
                if let rec = record {
                    self.scannedProduct = rec
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.performSegueWithIdentifier("toProductInfoSegue", sender: self)
                        self.loadingIndicator.stopAnimating()
                        self.loadingView.hidden = true
                    })
                }
            }
            else {
                print("Wierd Situation")
            }
        }
    }
    
    func restartScanner() {
        if !captureSession!.running {
            captureSession!.startRunning()
            qrCodeFrameView?.frame = CGRectZero
        }
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        videoPreviewLayer?.frame = videoView.layer.bounds
    }
    
    // MARK: - AVCaptureOutput Delegate
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0
        {
            qrCodeFrameView?.frame = CGRectZero
            
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if self.allowedTypes.contains(metadataObj.type) {
            
            let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            
            qrCodeFrameView?.frame = barCodeObject.bounds;
            
            if metadataObj.stringValue != nil {
                loadingView.hidden = false
                loadingIndicator.startAnimating()
                
                captureSession?.stopRunning()
                
                lastCapturedCode = metadataObj.stringValue
                databaseCheck(metadataObj.stringValue)
                
            }
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindViewController(segue: UIStoryboardSegue) { }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toAddProductSegue" {
            let addProductViewController = segue.destinationViewController as! AddProductViewController
            addProductViewController.scannedUPC = lastCapturedCode
        }
        else if segue.identifier == "toProductInfoSegue" {
            let productInfoViewController = segue.destinationViewController as! ProductInfoViewController
            productInfoViewController.scannedProduct = scannedProduct
        }
        
    }

}
