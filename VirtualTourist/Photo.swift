//
//  Photo.swift
//  VirtualTourist
//
//  Created by Geoffrey_Ching on 7/18/16.
//  Copyright © 2016 Geoffrey Ching. All rights reserved.
//

import Foundation
import CoreData


class Photo: NSManagedObject {
    
    @NSManaged var imageData: NSData?
    @NSManaged var toLocation: Pin
    
    
    
    convenience init(toLocation: Pin, context : NSManagedObjectContext){
        
        if let ent = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context){
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.toLocation = toLocation
        }else{
            fatalError("Unable to find Entity name!")
        }
        
    }
    convenience init(imageData: NSData?, toLocation: Pin, context : NSManagedObjectContext){
        
        if let ent = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context){
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.imageData = imageData
            self.toLocation = toLocation
        }else{
            fatalError("Unable to find Entity name!")
        }
        
    }
}
