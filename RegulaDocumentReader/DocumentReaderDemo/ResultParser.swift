//
//  ResultParser.swift
//  DocumentReader
//
//  Created by Игорь Клещёв on 20.04.16.
//  Copyright © 2016 Regula Forensics. All rights reserved.
//

import Foundation

class ParseResult: NSObject, XMLParserDelegate {
    
    var xmlValue: String? = nil
    var fields = [TextField]()
    var OverallResult: Bool? = nil
    
    func parseXMLToFields() -> [TextField]{
        fields.removeAll()
        if let data = xmlValue?.data(using: String.Encoding.utf8){
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
            OverallResult = nil
            for field in fields
            {
                if field.status > 0 && OverallResult != false
                {
                    OverallResult = field.status == 1
                }
            }
        }
        return fields
    }
    
    var element = String()
    var fType = String()
    var fValue = String()
    var fStatus = String()
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        element = elementName
        if element == "Document_Text_Data_Field" {
            fType = ""
            fValue = ""
            fStatus = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch (element)
        {
        case "wFieldType":
            fType = string
        case "Buf_Text":
            fValue += string.replacingOccurrences(of: "^", with: "\n")
        case "Validity":
            fStatus = string
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "Document_Text_Data_Field" {
            fields.append(TextField(name: fType, value: fValue, status: Int(fStatus)!))
        }
        element = ""
    }
    
}
