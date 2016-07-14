//
//  MRZDetailsTableViewController.swift
//  MRZ
//
//  Created by Игорь Клещёв on 12.05.15.
//  Copyright (c) 2015 Regula Forensics. All rights reserved.
//

import UIKit

class MRZDetailsTableViewController: UITableViewController, NSXMLParserDelegate {
    
    var fields = [TextField]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = false
        navigationController?.hidesBarsOnSwipe = true

        self.tableView.reloadData()
    }

    var darkGreen: UIColor = UIColor.greenColor()
    
    func darkerColor(color: UIColor) -> UIColor{
        var h: CGFloat = 0.0
        var s: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: b * 0.75, alpha: a)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 50
        
        darkGreen = darkerColor(darkGreen)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.fields.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TableViewCell

        // Configure the cell...
        let field = self.fields[indexPath.row]
        
        cell.lFieldName!.text = FieldHelper.fieldNameByType(FieldTypes(rawValue: Int(field.name)!)!)
        cell.lFieldValue!.text = field.value
        switch(field.status)
        {
        case 1:
            cell.lFieldValue!.textColor = darkGreen
        case 0:
            cell.lFieldValue!.textColor = UIColor.blackColor()
        default:
            cell.lFieldValue!.textColor = UIColor.redColor()
        }
        return cell
    }
    
}
