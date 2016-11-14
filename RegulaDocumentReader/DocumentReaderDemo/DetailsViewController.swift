//
//  DetailsViewController.swift
//  MRZ
//
//  Created by Игорь Клещёв on 12.05.15.
//  Copyright (c) 2015 Regula Forensics. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    var croppedMRZImage: UIImage?
    var xmlValue: String?
    
    @IBOutlet weak var mrzImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        mrzImage.image = croppedMRZImage!
    }
    
    @IBAction func dismiss(_ sender: AnyObject) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "embedseg" {
            let controller = segue.destination as? MRZDetailsTableViewController
            let r = ParseResult()
            r.xmlValue = xmlValue
            controller?.fields = r.parseXMLToFields()
            if (r.OverallResult != nil)
            {
                if r.OverallResult == true
                {mrzImage.backgroundColor = UIColor.green}
                else
                {mrzImage.backgroundColor = UIColor.red}
            }
            else
            {mrzImage.backgroundColor = UIColor.white}
            
        }
    }
    
}
