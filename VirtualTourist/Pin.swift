//
//  Pin.swift
//  VirtualTourist
//
//  Created by Geoffrey_Ching on 7/18/16.
//  Copyright © 2016 Geoffrey Ching. All rights reserved.
//

import Foundation
import CoreData
import MapKit


class Pin: NSManagedObject, MKAnnotation {
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var numberPages:Int32
    @NSManaged var toPhoto: [Photo]
    
    convenience init(latitude: Double, longitude: Double, context : NSManagedObjectContext){
        
        if let ent = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context){
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.latitude = latitude
            self.longitude = longitude
        }else{
            fatalError("Unable to find Entity name!")
        }
        
    }
    
    
    var coordinate: CLLocationCoordinate2D {
        get{
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set(newLocation){
            latitude = newLocation.latitude
            longitude = newLocation.longitude
        }
    }
    
}
