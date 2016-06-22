//
//  ViewController+Additions.swift
//  GoogleNewsFeed
//
//  Created by Harish Vitta on 6/6/16.
//  Copyright © 2016 Harish Vitta. All rights reserved.
//

import UIKit

extension UIViewController{
    //MARK: UIAlertController
    
    // Takes in title and message strings and presents a UIAlertController
    func alertUserWithTitleAndMessage(title: String?, message: String?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}
