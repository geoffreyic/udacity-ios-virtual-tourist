//
//  BaseViewController.swift
//  VirtualTourist
//
//  Created by Geoffrey_Ching on 7/21/16.
//  Copyright © 2016 Geoffrey Ching. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController{
    
    
    func displayErrorAlert(message: String){
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (result : UIAlertAction) -> Void in
            print("OK pressed for error message: " + message)
        }
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}