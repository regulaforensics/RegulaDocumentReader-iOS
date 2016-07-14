//
//  MRZ.swift
//  DocumentReader
//
//  Created by Игорь Клещёв on 20.04.16.
//  Copyright © 2016 Regula Forensics. All rights reserved.
//

import Foundation
import UIKit

class MRZReader {
    private static let mrzDetector = MRZDetectorIOS()
    private static var licenseSet = false;
    
    static var outputMrzImage: UIImage? = nil
    static var outputMrzCoord: NSMutableArray? = nil
    static var outputMrzXml: NSString? = nil
    
    static func processMRZ(inImage: UIImage, inputIsSingleImage: Bool = true) -> Bool {
        checkLicense() // License checked only once
        var res = false
        mrzDetector.detectMRZ(inImage, outputMRZImage: &outputMrzImage, outputMRZCoords: &outputMrzCoord, outputXML: &outputMrzXml, writeDebugInfo: false, inputIsSingleImage: inputIsSingleImage)
        res = outputMrzXml != nil
        // For debuf purpose only
        //if res {
        //   print(p_xml)
        //}
        return res
    }

    private static func readLicense() -> NSData? {
        if let licenseFilePath = NSBundle.mainBundle().pathForResource("regula.license", ofType: nil) {
            let licenseData = NSData(contentsOfFile: licenseFilePath)
            return licenseData
        }
        return nil
    }
    
    private static func checkLicense() {
        if licenseSet {
            return;
        }
        if let licenseData = readLicense() {
            mrzDetector.setLicense(licenseData);
        }
        licenseSet = true;
    }
}