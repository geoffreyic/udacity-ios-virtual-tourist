//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Geoffrey_Ching on 7/13/16.
//  Copyright © 2016 Geoffrey Ching. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class MapViewController: BaseViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    var pinBeingAdded:Pin? = nil
    
    var stack:CoreDataStack!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the stack
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        stack = delegate.stack
        
        
        // add annotations
        mapView.addAnnotations(fetchPins())
        
        // add gesture recognizer
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.addLocation(_:)))
        mapView.addGestureRecognizer(gesture)
        
        // set region
        mapView.setRegion(AppSettings.instance.getRegion(), animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func fetchPins() -> [Pin]{
        
        let fr = NSFetchRequest(entityName: "Pin")
        
        var pins:[Pin] = []
        
        do{
            let fetched = try stack.context.executeFetchRequest(fr)
            pins = fetched as! [Pin]
        }catch{
            // show alert
            print("error ocurred while trying to fetch pins")
        }
        
        return pins
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "DetailSegue"){
            let vc = segue.destinationViewController as! LocationViewController
            vc.pin = sender! as! Pin
        }
    }
}

// Map Delegate stuff
extension MapViewController: MKMapViewDelegate{
    
    func addLocation(gestureRecognizer: UILongPressGestureRecognizer){
        
        let mapViewLocation = gestureRecognizer.locationInView(mapView)
        let location = mapView.convertPoint(mapViewLocation, toCoordinateFromView: mapView)
        
        if(gestureRecognizer.state == .Began){
            pinBeingAdded = Pin(latitude: location.latitude, longitude: location.longitude, context: stack.context)
        }else if(gestureRecognizer.state == .Changed){
            pinBeingAdded!.latitude = location.latitude
            pinBeingAdded!.longitude = location.longitude
        }else if(gestureRecognizer.state == .Ended){
            
            let pinBeingAddedFixed:Pin = pinBeingAdded!
            
            
            func addLocationsComplete(object: AnyObject!){
                
            }
            
            mapView.addAnnotation(pinBeingAddedFixed)
            
            FlickrAPI.instance.getPhotosForLocation(pinBeingAddedFixed, longitude: location.longitude, latitude: location.latitude, page: 0, perPage: 15, accuracy: 11, errorHandler: displayErrorAlert)
            
        }else if(gestureRecognizer.state == .Cancelled){
            pinBeingAdded = nil
        }
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let annotation = annotation as! Pin
        
        let id = "pin"
        var view: MKPinAnnotationView
        
        if let v = mapView.dequeueReusableAnnotationViewWithIdentifier(id) as? MKPinAnnotationView {
            v.annotation = annotation
            view = v
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: id)
            view.canShowCallout = false
            view.animatesDrop = true
            view.draggable = false
        }
        return view
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        
        let pin = view.annotation! as! Pin
        
        print (pin.latitude)
        
        performSegueWithIdentifier("DetailSegue", sender: pin)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("Saving Map Coordinates")
        
        AppSettings.instance.saveRegion(mapView.region)
    }
}

