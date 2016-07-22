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
    
    
    
    func askDeleteConfirmation(message: String, cancelAction: ()->(), deleteAction: ()->()){
        let alertController = UIAlertController(title: "Are you sure?", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (result : UIAlertAction) -> Void in
            print("Cancel pressed for confirmation message: " + message)
            cancelAction()
        }
        alertController.addAction(cancelAction)

        
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { (result : UIAlertAction) -> Void in
            print("Delete pressed for confirmation message: " + message)
            deleteAction()
        }
        alertController.addAction(deleteAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}