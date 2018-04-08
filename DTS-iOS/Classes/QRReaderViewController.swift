//
//  QRReaderViewController.swift
//  POC-iOS
//
//  Created by Viktor on 06/03/2016.
//  Copyright © 2016 Rapidzz. All rights reserved.
//

import UIKit
import AVFoundation
import KVNProgress

struct PreferencesKeys {
    static let savedItems = "savedItems"
}

protocol QRReaderDelegate {
    func didFoundQRCode(_ qrCode: String)
    func didCancelTappedForQRReader()
}

class QRReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var lblAlert: UILabel!
    @IBOutlet weak var lblStatus: UIImageView!
    @IBOutlet weak var ivStamp: UIImageView!
    @IBOutlet weak var viewOverlay: UIView!
    @IBOutlet weak var btnCancel: UIButton!
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    @IBOutlet weak var viewPrview: UIView!
    var qrCodeFrameView:UIView?
    var delegate: QRReaderDelegate?
    var isAlreadyScanned: Bool?
    var isNotRootVC: Bool?
    var mainQRCode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        isAlreadyScanned = false
        captureSession = AVCaptureSession()
        
        let videoCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed();
            return;
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)
        
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.green.cgColor
        qrCodeFrameView?.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView!)
        self.view.bringSubview(toFront: self.viewOverlay)
        view.bringSubview(toFront: qrCodeFrameView!)
        
        captureSession.startRunning();
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func getScanCrop(_ rect:CGRect, readerViewBounds:CGRect) -> (CGRect)
    {
        return CGRect(x: rect.origin.x / readerViewBounds.size.width, y: rect.origin.y / readerViewBounds.size.height, width: rect.size.width / readerViewBounds.size.width, height: rect.size.height / readerViewBounds.size.height)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isAlreadyScanned = false;
        if (captureSession?.isRunning == false) {
            captureSession.startRunning();
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning();
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        self.lblAlert.isHidden = true
        if let metadataObject = metadataObjects.first {
            let barCodeObject = previewLayer.transformedMetadataObject(for: metadataObject as! AVMetadataMachineReadableCodeObject)
            qrCodeFrameView?.frame = (barCodeObject?.bounds)!;
        }
        if isAlreadyScanned == false {
            isAlreadyScanned = true
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(900 * Int64(NSEC_PER_MSEC)) / Double(NSEC_PER_SEC), execute: { () -> Void in
                
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                self.ivStamp.image = UIImage(named: "qr-stamp-green")
                self.lblStatus.image = UIImage(named: "qr-label-found")
                self.doneWithScanning(captureOutput, didOutputMetadataObjects: metadataObjects! as [AnyObject], fromConnection: connection)
            })

        }
    }
    
    func doneWithScanning(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        captureSession.stopRunning()
        self.dismiss(animated: true) {
            if let metadataObject = metadataObjects.first {
                let readableObject = metadataObject as! AVMetadataMachineReadableCodeObject;
                
                UIView.beginAnimations("bringUp", context: nil)
                UIView.setAnimationDuration(0.3)
                UIView.setAnimationBeginsFromCurrentState(true)
                self.ivStamp.frame = (self.qrCodeFrameView?.frame)!
                UIView.commitAnimations()
                self.mainQRCode = readableObject.stringValue
                
                if self.delegate != nil {
                    self.delegate?.didFoundQRCode(self.mainQRCode ?? "")
                }
            }
        }
    }

    @IBAction func btnCancel_Tapped(_ sender: AnyObject) {
        self.dismiss(animated: true) { () -> Void in
            
        }
    }
}



extension QRReaderViewController {
    func getStamps(code: String) -> Void {
        KVNProgress.show()
        
    }
}
