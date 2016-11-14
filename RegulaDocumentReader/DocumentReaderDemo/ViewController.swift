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
        //prefersStatusBarHidden
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToMainView(_ segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func openGallery(_ sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true,
                     completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsFromGallery"{
            let controller = segue.destination as! DetailsViewController
            controller.croppedMRZImage = MRZReader.outputMrzImage
            controller.xmlValue = MRZReader.outputMrzXml as? String
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let AImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.dismiss(animated: true, completion: nil)
        if MRZReader.processMRZ(AImage)
        {
            performSegue(withIdentifier: "showDetailsFromGallery", sender: self)
            
        }
        else
        {
            let alert = UIAlertController(title: "Error", message: "MRZ was not found on the image", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

