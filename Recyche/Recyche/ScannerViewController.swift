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

class ScannerViewController: UIViewController , AVCaptureMetadataOutputObjectsDelegate

{


    @IBOutlet  weak var messageLabel: UILabel!
    @IBOutlet weak var videoView:UIView!
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var captureDevice: AVCaptureDevice?
    
    var lastCapturedCode:String?
    
    
    var barcodeScanned:((String) ->())?
    
    
    private var allowedTypes = [AVMetadataObjectTypeUPCECode,
        AVMetadataObjectTypeCode39Code,
        AVMetadataObjectTypeCode39Mod43Code,
        AVMetadataObjectTypeEAN13Code,
        AVMetadataObjectTypeEAN8Code,
        AVMetadataObjectTypeCode93Code,
        AVMetadataObjectTypeCode128Code,
        AVMetadataObjectTypePDF417Code,
        AVMetadataObjectTypeQRCode,
        AVMetadataObjectTypeAztecCode]
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (FBSDKAccessToken.currentAccessToken() == nil)
        {
            performSegueWithIdentifier("toLoginSegue", sender: self)
            print("Not logged in..")
        }
        else
        {
            print("Logged in..")
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var error:NSError?
        let input : AnyObject!
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
        }
        catch let error1 as NSError{
            error = error1
            input = nil
        }
        if (error != nil)
        {
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
        videoView.layer.addSublayer(videoPreviewLayer!)
        
        
        captureSession?.startRunning()
        
        view.bringSubviewToFront(messageLabel)
        
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.greenColor().CGColor
        qrCodeFrameView?.layer.borderWidth = 3
        qrCodeFrameView?.autoresizingMask = [UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin]
        
        view.addSubview(qrCodeFrameView!)
        view.bringSubviewToFront(qrCodeFrameView!)
        view.bringSubviewToFront(scanButton!)
        view.bringSubviewToFront(messageLabel!)
        
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
    
    
    
    @IBAction func scanClicked(sender: UIButton) {
        
        self.barcodeScanned = { (barcode:String) in
            self.navigationController?.popViewControllerAnimated(true)
            print("Received following barcode: \(barcode)")
            
            dispatch_async(dispatch_get_main_queue(),{
                
                // self.navigationController?.pushViewController(viewcontroller, animated: true)
            })
        }
    }
    
    @IBAction func toProductDetail(sender: AnyObject) {
        lastCapturedCode = "0892685001003"
        performSegueWithIdentifier("toProductInfoSegue", sender: self)
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        videoPreviewLayer?.frame = videoView.layer.bounds
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0
        {
            qrCodeFrameView?.frame = CGRectZero
            messageLabel.text = "No UPC Code is detected"
            
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if self.allowedTypes.contains(metadataObj.type) {
            
            let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            
            qrCodeFrameView?.frame = barCodeObject.bounds;
            
            if metadataObj.stringValue != nil {
                captureSession?.stopRunning()
                lastCapturedCode = metadataObj.stringValue
                performSegueWithIdentifier("toProductInfoSegue", sender: self)
//                messageLabel.text = metadataObj.stringValue
//                lastCapturedCode = metadataObj.stringValue
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
        if segue.identifier == "toProductInfoSegue" {
            let productInfoViewController = segue.destinationViewController as! ProductInfoViewController
            productInfoViewController.scannedUPC = lastCapturedCode
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
