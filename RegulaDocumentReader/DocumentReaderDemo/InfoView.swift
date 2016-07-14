//
//  InfoView.swift
//  MRZ
//
//  Created by Игорь Клещёв on 25.05.15.
//  Copyright (c) 2015 Regula Forensics. All rights reserved.
//

import UIKit
import MessageUI

class InfoView: UIViewController, MFMailComposeViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    @IBAction func openLinkedIn(sender: AnyObject) {
        let urlWeb = NSURL(string: "https://www.linkedin.com/company/1653568")
        if UIApplication.sharedApplication().canOpenURL(urlWeb!){
                UIApplication.sharedApplication().openURL(urlWeb!)
        }

    }
    @IBAction func openWebsite(sender: AnyObject) {
        let urlWeb = NSURL(string: "http://www.regulaforensics.com")
        if UIApplication.sharedApplication().canOpenURL(urlWeb!){
            UIApplication.sharedApplication().openURL(urlWeb!)
        }

    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["support@regulaforensics.com"])
        mailComposerVC.setSubject("iOS Document Reader")
        mailComposerVC.setMessageBody("Hello, \n\r Like your app, need some info", isHTML: false)
        
        return mailComposerVC
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func sendMail(sender: AnyObject) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func openTWITTER(sender: AnyObject) {
        let urlApp = NSURL(string: "twitter://user?screen_name=regulaforensics")
        let urlWeb = NSURL(string: "https://twitter.com/regulaforensics")
        if UIApplication.sharedApplication().canOpenURL(urlApp!){
            UIApplication.sharedApplication().openURL(urlApp!)
        }
        else
            if UIApplication.sharedApplication().canOpenURL(urlWeb!){
                UIApplication.sharedApplication().openURL(urlWeb!)
        }

    }
    
    @IBAction func openFB(sender: AnyObject) {
        let urlApp = NSURL(string: "fb://profile/356561294452774")
        let urlWeb = NSURL(string: "https://www.facebook.com/regulaforensics")
        if UIApplication.sharedApplication().canOpenURL(urlApp!){
            UIApplication.sharedApplication().openURL(urlApp!)
        }
        else
            if UIApplication.sharedApplication().canOpenURL(urlWeb!){
                UIApplication.sharedApplication().openURL(urlWeb!)
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
