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
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    @IBAction func openLinkedIn(_ sender: AnyObject) {
        let urlWeb = URL(string: "https://www.linkedin.com/company/1653568")
        if UIApplication.shared.canOpenURL(urlWeb!){
            UIApplication.shared.openURL(urlWeb!)
        }
        
    }
    @IBAction func openWebsite(_ sender: AnyObject) {
        let urlWeb = URL(string: "http://www.regulaforensics.com")
        if UIApplication.shared.canOpenURL(urlWeb!){
            UIApplication.shared.openURL(urlWeb!)
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
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendMail(_ sender: AnyObject) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func openTWITTER(_ sender: AnyObject) {
        let urlApp = URL(string: "twitter://user?screen_name=regulaforensics")
        let urlWeb = URL(string: "https://twitter.com/regulaforensics")
        if UIApplication.shared.canOpenURL(urlApp!){
            UIApplication.shared.openURL(urlApp!)
        }
        else
            if UIApplication.shared.canOpenURL(urlWeb!){
                UIApplication.shared.openURL(urlWeb!)
        }
        
    }
    
    @IBAction func openFB(_ sender: AnyObject) {
        let urlApp = URL(string: "fb://profile/356561294452774")
        let urlWeb = URL(string: "https://www.facebook.com/regulaforensics")
        if UIApplication.shared.canOpenURL(urlApp!){
            UIApplication.shared.openURL(urlApp!)
        }
        else
            if UIApplication.shared.canOpenURL(urlWeb!){
                UIApplication.shared.openURL(urlWeb!)
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
