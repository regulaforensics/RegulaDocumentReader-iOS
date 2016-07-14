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
    override func viewWillAppear(animated: Bool) {
        mrzImage.image = croppedMRZImage!
    }

    @IBAction func dismiss(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "embedseg" {
            let controller = segue.destinationViewController as? MRZDetailsTableViewController
            let r = ParseResult()
            r.xmlValue = xmlValue
            controller?.fields = r.parseXMLToFields()
            if (r.OverallResult != nil)
            {
                if r.OverallResult == true
                    {mrzImage.backgroundColor = UIColor.greenColor()}
                else
                    {mrzImage.backgroundColor = UIColor.redColor()}
            }
            else
            {mrzImage.backgroundColor = UIColor.whiteColor()}

       }
    }

}
