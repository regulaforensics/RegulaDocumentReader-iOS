//
//  ViewController.swift
//  DocumentReader
//
//  Created by Игорь Клещёв on 18.04.16.
//  Copyright © 2016 Regula Forensics. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        prefersStatusBarHidden()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func unwindToMainView(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func openGallery(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.allowsEditing = false
        self.presentViewController(imagePicker, animated: true,
                                   completion: nil)

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetailsFromGallery"{
            let controller = segue.destinationViewController as! DetailsViewController
            controller.croppedMRZImage = MRZReader.outputMrzImage
            controller.xmlValue = MRZReader.outputMrzXml as? String
        }
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let AImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
        if MRZReader.processMRZ(AImage)
        {
           performSegueWithIdentifier("showDetailsFromGallery", sender: self)

        }
        else
        {
            let alert = UIAlertController(title: "Error", message: "MRZ was not found on the image", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

