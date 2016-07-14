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
    var processQueue: dispatch_queue_t?

    var pauseProcessing: Bool = false
    var flashON: Bool = false
    

    @IBAction func startCapture(){
        captureSession.startRunning()
    }

    @IBOutlet weak var bStopButton: UIBarButtonItem!
    @IBAction func stopCapture(sender: AnyObject) {
        captureSession.stopRunning()
    }
    
    @IBOutlet weak var bFlashButton: UIBarButtonItem!
    @IBAction func bFlash(sender: AnyObject) {
        flashON = !flashON
        do{
        if let cd = captureDevice {
        if (flashON && cd.isTorchModeSupported(AVCaptureTorchMode.On)){
            try cd.lockForConfiguration()
            cd.torchMode = AVCaptureTorchMode.On
            bFlashButton.image = UIImage(named: "flashOn.png");
            cd.unlockForConfiguration()
        }
        else
            if (!flashON && cd.isTorchModeSupported(AVCaptureTorchMode.Off)){
                try cd.lockForConfiguration()
                cd.torchMode = AVCaptureTorchMode.Off
                bFlashButton.image = UIImage(named: "flashOff.png");
                cd.unlockForConfiguration()
            }
        }
        }
        catch _ {}
    }
    
    @IBAction func unwindToCameraView(segue: UIStoryboardSegue) {
        startProcessing()
    }
    
    func stopProcessing(){
        pauseProcessing = true
        previewLayer?.connection.enabled = false
    }

    func startProcessing(){
        pauseProcessing = false
        previewLayer?.connection.enabled = true
    }
    
    override func viewWillAppear(animated: Bool) {
        self.startProcessing()
        self.addNotificationObservers()
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.stopProcessing()
        self.removeNotificationObservers()
        super.viewWillDisappear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        processQueue = dispatch_queue_create("processQueue", DISPATCH_QUEUE_SERIAL)
        
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                    initDevice()
                    initSession()
                    captureSession.startRunning()
                }
            }
        }
    }
    
    
    func imageFromSampleBuffer(sampleBuffer :CMSampleBufferRef) -> UIImage? {
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        var outputImage: CIImage? = CIImage(CVPixelBuffer: imageBuffer!)

        let orientation = UIDevice.currentDevice().orientation
        var t: CGAffineTransform!
        if orientation == UIDeviceOrientation.Portrait {
            t = CGAffineTransformMakeRotation(CGFloat(-M_PI / 2.0))
        } else if orientation == UIDeviceOrientation.PortraitUpsideDown {
            t = CGAffineTransformMakeRotation(CGFloat(M_PI / 2.0))
        } else if (orientation == UIDeviceOrientation.LandscapeRight) {
            t = CGAffineTransformMakeRotation(CGFloat(M_PI))
        } else {
            t = CGAffineTransformMakeRotation(0)
        }
        outputImage = outputImage!.imageByApplyingTransform(t)
        let imageContext = CIContext(options: nil)

        let cgim = imageContext.createCGImage(outputImage!, fromRect: outputImage!.extent)
        return UIImage(CGImage: cgim)
    }
    
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    
    @IBAction func focusOnTap(sender: AnyObject) {
                if let point = previewLayer?.captureDevicePointOfInterestForPoint(tapRecognizer.locationInView(self.view)){
                    focus(point, continuousAuto: false)
        }
        
    }
    
    func focus(devicePoint: CGPoint, continuousAuto: Bool){
        if let cd = captureDevice{
            var focusMode: AVCaptureFocusMode
            
            if continuousAuto{
                focusMode = AVCaptureFocusMode.ContinuousAutoFocus
            }
            else{
                focusMode = AVCaptureFocusMode.AutoFocus
            }
            
            var exposureMode: AVCaptureExposureMode
            
            if continuousAuto{
                exposureMode = AVCaptureExposureMode.ContinuousAutoExposure
            }
            else{
                exposureMode = AVCaptureExposureMode.AutoExpose
            }
            
            
            do {
                try cd.lockForConfiguration()
                if cd.focusPointOfInterestSupported && cd.isFocusModeSupported(focusMode){
                    cd.focusPointOfInterest = devicePoint
                    cd.focusMode = focusMode
                }
                
                if cd.exposurePointOfInterestSupported && cd.isExposureModeSupported(exposureMode) {
                    cd.exposurePointOfInterest = devicePoint
                    cd.exposureMode = exposureMode
                }
                cd.subjectAreaChangeMonitoringEnabled = !continuousAuto
                
            } catch _ {}
            cd.unlockForConfiguration()
        }
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetails"{
        let controller = segue.destinationViewController as! DetailsViewController
            controller.croppedMRZImage = MRZReader.outputMrzImage
            controller.xmlValue = MRZReader.outputMrzXml as? String
            }
    }
    
    
    func captureOutput(captureOutput: AVCaptureOutput!,
        didOutputSampleBuffer sampleBuffer: CMSampleBuffer!,
        fromConnection connection: AVCaptureConnection!)
    {
        if let cd = captureDevice{
            if !pauseProcessing && !cd.adjustingFocus && !cd.adjustingExposure && !cd.adjustingWhiteBalance {
                autoreleasepool { () -> () in
                    let AImage = self.imageFromSampleBuffer(sampleBuffer)
                    var result: Bool = false
                    dispatch_sync(dispatch_get_main_queue(), {
                        result = MRZReader.processMRZ(AImage!, inputIsSingleImage: false)
                        if result{
                            self.stopProcessing()
                        self.performSegueWithIdentifier("showDetails", sender: self)
                        }
                    })
                    
                }
            }
        }
    }
    
    func subjectAreaDidChange(notification: NSNotification) {
        let devicePoint : CGPoint = CGPoint(x: 0.5, y: 0.5)
        self.focus(devicePoint, continuousAuto: true)
    }
    
    func addNotificationObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CameraViewController.subjectAreaDidChange(_:)), name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: self.captureDevice)
    }
    
    func removeNotificationObservers() {
       NSNotificationCenter.defaultCenter().removeObserver(self, name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: self.captureDevice)
    }
    
    func initOutput(){
        let videoOutput = AVCaptureVideoDataOutput()
        
        let captureQueue=dispatch_queue_create("captureQueue", DISPATCH_QUEUE_SERIAL)
        
        //setup delegate
        videoOutput.setSampleBufferDelegate(self, queue: captureQueue)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey: Int(kCVPixelFormatType_32BGRA)]

        if captureSession.canAddOutput(videoOutput as AVCaptureOutput){
            captureSession.addOutput(videoOutput as AVCaptureOutput)}

    }

    func initDevice(){
        if let cd=captureDevice {
            
            do {
                try cd.lockForConfiguration()
                if cd.isFocusModeSupported(AVCaptureFocusMode.ContinuousAutoFocus){
                    cd.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
                }
                
                if cd.smoothAutoFocusSupported
                    {cd.smoothAutoFocusEnabled = true}
                
                if cd.autoFocusRangeRestrictionSupported{
                    cd.autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestriction.Near
                }
            
                bFlashButton.enabled = cd.hasTorch && cd.torchAvailable
            
                if cd.isExposureModeSupported(AVCaptureExposureMode.ContinuousAutoExposure){
                    cd.exposureMode = AVCaptureExposureMode.ContinuousAutoExposure
                }
                
                if cd.isWhiteBalanceModeSupported(AVCaptureWhiteBalanceMode.ContinuousAutoWhiteBalance){
                    cd.whiteBalanceMode = AVCaptureWhiteBalanceMode.ContinuousAutoWhiteBalance
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
            print("error: \(err?.localizedDescription)")
        }
        
        initOutput()
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.insertSublayer(previewLayer!, atIndex: 0)
        previewLayer?.frame = self.view.bounds
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
    }

}






