//
//  ViewController.swift
//  MRZ
//
//  Created by Игорь Клещёв on 06.04.15.
//  Copyright (c) 2015 Regula Forensics. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia
import CoreGraphics
import MobileCoreServices
import ImageIO


class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate
{
    
    let captureSession = AVCaptureSession()
    var captureDevice:AVCaptureDevice?
    var processQueue: DispatchQueue?
    
    var pauseProcessing: Bool = false
    var flashON: Bool = false


    @IBAction func actionClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func startCapture(){
        captureSession.startRunning()
    }
    
    @IBOutlet weak var bStopButton: UIBarButtonItem!
    @IBAction func stopCapture(_ sender: AnyObject) {
        captureSession.stopRunning()
    }

    @IBOutlet weak var bFlashButton: UIButton!
    @IBAction func bFlash(_ sender: AnyObject) {
        flashON = !flashON
        do{
            if let cd = captureDevice {
                if (flashON && cd.isTorchModeSupported(AVCaptureTorchMode.on)){
                    try cd.lockForConfiguration()
                    cd.torchMode = AVCaptureTorchMode.on
                    bFlashButton.setImage(UIImage(named: "flashOn.png"), for: .normal)
                    cd.unlockForConfiguration()
                }
                else
                    if (!flashON && cd.isTorchModeSupported(AVCaptureTorchMode.off)){
                        try cd.lockForConfiguration()
                        cd.torchMode = AVCaptureTorchMode.off
                        bFlashButton.setImage(UIImage(named: "flashOff.png"), for: .normal)
                        cd.unlockForConfiguration()
                }
            }
        }
        catch _ {}
    }
    
    @IBAction func unwindToCameraView(_ segue: UIStoryboardSegue) {
        startProcessing()
    }
    
    func stopProcessing(){
        pauseProcessing = true
        previewLayer?.connection.isEnabled = false
    }
    
    func startProcessing(){
        pauseProcessing = false
        previewLayer?.connection.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.startProcessing()
        self.addNotificationObservers()
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.stopProcessing()
        self.removeNotificationObservers()
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        processQueue = DispatchQueue(label: "processQueue", attributes: [])
        
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices! {
            // Make sure this particular device supports video
            if ((device as AnyObject).hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if((device as AnyObject).position == AVCaptureDevicePosition.back) {
                    captureDevice = device as? AVCaptureDevice
                    initDevice()
                    initSession()
                    captureSession.startRunning()
                }
            }
        }
    }
    
    
    func imageFromSampleBuffer(_ sampleBuffer :CMSampleBuffer) -> UIImage? {
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        var outputImage: CIImage? = CIImage(cvPixelBuffer: imageBuffer!)
        
        let orientation = UIDevice.current.orientation
        var t: CGAffineTransform!
        if orientation == UIDeviceOrientation.portrait {
            t = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2.0))
        } else if orientation == UIDeviceOrientation.portraitUpsideDown {
            t = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2.0))
        } else if (orientation == UIDeviceOrientation.landscapeRight) {
            t = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        } else {
            t = CGAffineTransform(rotationAngle: 0)
        }
        outputImage = outputImage!.applying(t)
        let imageContext = CIContext(options: nil)
        
        let cgim = imageContext.createCGImage(outputImage!, from: outputImage!.extent)
        return UIImage(cgImage: cgim!)
    }
    
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    
    @IBAction func focusOnTap(_ sender: AnyObject) {
        if let point = previewLayer?.captureDevicePointOfInterest(for: tapRecognizer.location(in: self.view)){
            focus(point, continuousAuto: false)
        }
        
    }
    
    func focus(_ devicePoint: CGPoint, continuousAuto: Bool){
        if let cd = captureDevice{
            var focusMode: AVCaptureFocusMode
            
            if continuousAuto{
                focusMode = AVCaptureFocusMode.continuousAutoFocus
            }
            else{
                focusMode = AVCaptureFocusMode.autoFocus
            }
            
            var exposureMode: AVCaptureExposureMode
            
            if continuousAuto{
                exposureMode = AVCaptureExposureMode.continuousAutoExposure
            }
            else{
                exposureMode = AVCaptureExposureMode.autoExpose
            }
            
            
            do {
                try cd.lockForConfiguration()
                if cd.isFocusPointOfInterestSupported && cd.isFocusModeSupported(focusMode){
                    cd.focusPointOfInterest = devicePoint
                    cd.focusMode = focusMode
                }
                
                if cd.isExposurePointOfInterestSupported && cd.isExposureModeSupported(exposureMode) {
                    cd.exposurePointOfInterest = devicePoint
                    cd.exposureMode = exposureMode
                }
                cd.isSubjectAreaChangeMonitoringEnabled = !continuousAuto
                
            } catch _ {}
            cd.unlockForConfiguration()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails"{
            let controller = segue.destination as! DetailsViewController
            controller.croppedMRZImage = MRZReader.outputMrzImage
            controller.xmlValue = MRZReader.outputMrzXml as String?
        }
    }
    
    
    func captureOutput(_ captureOutput: AVCaptureOutput!,
                       didOutputSampleBuffer sampleBuffer: CMSampleBuffer!,
                       from connection: AVCaptureConnection!)
    {
        if let cd = captureDevice{
            if !pauseProcessing && !cd.isAdjustingFocus && !cd.isAdjustingExposure && !cd.isAdjustingWhiteBalance {
                autoreleasepool { () -> () in
                    let AImage = self.imageFromSampleBuffer(sampleBuffer)
                    var result: Bool = false
                    DispatchQueue.main.sync(execute: {
                        result = MRZReader.processMRZ(AImage!, inputIsSingleImage: false)
                        if result{
                            self.stopProcessing()
                            self.performSegue(withIdentifier: "showDetails", sender: self)
                        }
                    })
                    
                }
            }
        }
    }
    
    func subjectAreaDidChange(_ notification: Notification) {
        let devicePoint : CGPoint = CGPoint(x: 0.5, y: 0.5)
        self.focus(devicePoint, continuousAuto: true)
    }
    
    func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(CameraViewController.subjectAreaDidChange(_:)), name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: self.captureDevice)
    }
    
    func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: self.captureDevice)
    }
    
    func initOutput(){
        let videoOutput = AVCaptureVideoDataOutput()
        
        let captureQueue=DispatchQueue(label: "captureQueue", attributes: [])
        
        //setup delegate
        videoOutput.setSampleBufferDelegate(self, queue: captureQueue)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: Int(kCVPixelFormatType_32BGRA)]
        
        if captureSession.canAddOutput(videoOutput as AVCaptureOutput){
            captureSession.addOutput(videoOutput as AVCaptureOutput)}
        
    }
    
    func initDevice(){
        if let cd=captureDevice {
            
            do {
                try cd.lockForConfiguration()
                if cd.isFocusModeSupported(AVCaptureFocusMode.continuousAutoFocus){
                    cd.focusMode = AVCaptureFocusMode.continuousAutoFocus
                }
                
                if cd.isSmoothAutoFocusSupported
                {cd.isSmoothAutoFocusEnabled = true}
                
                if cd.isAutoFocusRangeRestrictionSupported{
                    cd.autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestriction.near
                }
                
                bFlashButton.isEnabled = cd.hasTorch && cd.isTorchAvailable
                
                if cd.isExposureModeSupported(AVCaptureExposureMode.continuousAutoExposure){
                    cd.exposureMode = AVCaptureExposureMode.continuousAutoExposure
                }
                
                if cd.isWhiteBalanceModeSupported(AVCaptureWhiteBalanceMode.continuousAutoWhiteBalance){
                    cd.whiteBalanceMode = AVCaptureWhiteBalanceMode.continuousAutoWhiteBalance
                }
                
                cd.activeVideoMaxFrameDuration = CMTimeMake(1, 30)
                cd.activeVideoMinFrameDuration = CMTimeMake(1, 30)
                
                cd.unlockForConfiguration()
            } catch _ {
            }
        }
        
    }
    
    var previewLayer:AVCaptureVideoPreviewLayer?
    
    func initSession() {
        let err : NSError? = nil
        
        do{
            captureSession.addInput(try AVCaptureDeviceInput(device: captureDevice))
        }
        catch _ {}
        
        if err != nil {
            print("error: \(String(describing: err?.localizedDescription))")
        }
        
        initOutput()
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.insertSublayer(previewLayer!, at: 0)
        previewLayer?.frame = self.view.bounds
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
    }
    
}






