//
//  AppSettings.swift
//  VirtualTourist
//
//  Created by Geoffrey_Ching on 7/18/16.
//  Copyright © 2016 Geoffrey Ching. All rights reserved.
//

import Foundation
import MapKit

class AppSettings{
    
    static var instance:AppSettings = AppSettings()
    
    func initializeDefaults(){
        NSUserDefaults.standardUserDefaults().setDouble(49, forKey: "centerLatitude")
        NSUserDefaults.standardUserDefaults().setDouble(-123, forKey: "centerLongitude")
        NSUserDefaults.standardUserDefaults().setDouble(100, forKey: "centerLatitudeDelta")
        NSUserDefaults.standardUserDefaults().setDouble(100, forKey: "centerLongitudeDelta")
        
    }
    
    func saveRegion(region: MKCoordinateRegion){
        NSUserDefaults.standardUserDefaults().setDouble(region.center.latitude, forKey: "centerLatitude")
        NSUserDefaults.standardUserDefaults().setDouble(region.center.longitude, forKey: "centerLongitude")
        NSUserDefaults.standardUserDefaults().setDouble(region.span.latitudeDelta, forKey: "centerLatitudeDelta")
        NSUserDefaults.standardUserDefaults().setDouble(region.span.longitudeDelta, forKey: "centerLongitudeDelta")
    }
    
    func getRegion()-> MKCoordinateRegion{
        let lat = NSUserDefaults.standardUserDefaults().doubleForKey("centerLatitude")
        let long = NSUserDefaults.standardUserDefaults().doubleForKey("centerLongitude")
        let latDelta = NSUserDefaults.standardUserDefaults().doubleForKey("centerLatitudeDelta")
        let longDelta = NSUserDefaults.standardUserDefaults().doubleForKey("centerLongitudeDelta")
        
        let coordSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        return MKCoordinateRegion(center: coord, span: coordSpan)
    }
}