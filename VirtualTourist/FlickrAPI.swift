//
//  FlickrAPI.swift
//  VirtualTourist
//
//  Created by Geoffrey_Ching on 7/14/16.
//  Copyright © 2016 Geoffrey Ching. All rights reserved.
//

import Foundation
import UIKit

public class FlickrAPI{
    
    public static let instance = FlickrAPI()
    
    func getPhotosForLocation(pin: Pin, longitude: Double, latitude: Double, page:Int32?, perPage:Int32, accuracy:Int32, errorHandler: (errorMessage:String)->()){
        
        let page2:Int
        
        print("pin number pages")
        print(pin.numberPages)
        
        if(page == nil && pin.numberPages != nil){
            var numberPages = pin.numberPages?.unsignedIntValue
            
            if(numberPages > 260){
                numberPages = 260
            }
            
            print("number pages")
            print(numberPages)
            
            page2 = Int(arc4random_uniform(numberPages!))
        }else{
            page2 = 0
        }
        
        print("page being selected")
        print(page2)
        
        var urlString = "https://api.flickr.com/services/rest/"
        
        urlString = urlString.stringByAppendingString("?method=flickr.photos.search")
        urlString = urlString.stringByAppendingString("&api_key=")
        urlString = urlString.stringByAppendingString(FlickrConstants.ApiKey)
        
        urlString = urlString.stringByAppendingString("&lat=")
        urlString = urlString.stringByAppendingString(NSNumber(double:latitude).stringValue)
        
        urlString = urlString.stringByAppendingString("&lon=")
        urlString = urlString.stringByAppendingString(NSNumber(double:longitude).stringValue)
        
        urlString = urlString.stringByAppendingString("&accuracy=")
        urlString = urlString.stringByAppendingString(NSNumber(int: accuracy).stringValue)
        
        urlString = urlString.stringByAppendingString("&per_page=")
        urlString = urlString.stringByAppendingString(NSNumber(int: perPage).stringValue)
        
        urlString = urlString.stringByAppendingString("&page=")
        urlString = urlString.stringByAppendingString(NSNumber(integer: page2).stringValue)
        
        urlString = urlString.stringByAppendingString("&format=json")
        urlString = urlString.stringByAppendingString("&nojsoncallback=1")
        urlString = urlString.stringByAppendingString("&sort=interestingness-desc")
        
        print(urlString)
        
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        
        
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                self.displayError("There was an error with your request: \(error)", errorHandler: errorHandler)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                self.displayError("Your request returned a status code other than 2xx!", errorHandler: errorHandler)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                self.displayError("No data was returned by the request!", errorHandler: errorHandler)
                return
            }
            
            print(NSString(data: data, encoding: NSUTF8StringEncoding))
            
            // parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                self.displayError("Could not parse the data as JSON: '\(data)'", errorHandler: errorHandler)
                return
            }

            self.addLocationCompletion(parsedResult, pin: pin, errorHandler: errorHandler)
//            self.goToMainThread(){
//                completionHandler(object: parsedResult)
//            }
            
        }
        
        task.resume()
        
    }
    
    
    
    func addLocationCompletion(object: AnyObject!, pin: Pin, errorHandler: (errorMessage:String)->()){
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stack = delegate.stack
        
        
        
        guard let object1 = object as? [String:AnyObject],
            let photos = object1["photos"] as? [String:AnyObject],
            let pages = photos["pages"] as? Int,
            let photo = photos["photo"] as? [AnyObject]
            else{
                self.displayError("could not parse Flickr API results", errorHandler: errorHandler)
                return
        }
        
        pin.numberPages = NSNumber(integer: pages)
        
        
        for obj in photo{
            if let obj1 = obj as? [String:AnyObject],
                let id = obj1["id"] as? String,
                let secret = obj1["secret"] as? String,
                let server = obj1["server"] as? String,
                let farm = obj1["farm"] as? Int
                
            {
                let url = "http://farm" + NSNumber(integer: farm).stringValue + ".static.flickr.com/" + server + "/" + id + "_" + secret + "_m.jpg"
                
                
                let photo:Photo = Photo(toLocation: pin, context: stack.context)
                
                FlickrAPI.instance.downloadPhoto(url, photo: photo, errorHandler: errorHandler)
                
                stack.save()
                
            }else{
                print("could not parse...")
            }
            
        }
        
        stack.save()
    }
    
    
    func fetchPicturesComplete(imageData: NSData?, photo: Photo){
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stack = delegate.stack
        
        photo.imageData = imageData
        
        stack.save()
    }
    
    func downloadPhoto(url: String, photo: Photo, errorHandler: (errorMessage:String)->()){
        
        
        let url = NSURL(string: url)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                self.displayError("There was an error fetching the picture: \(error)", errorHandler: errorHandler)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                self.displayError("Your request returned a status code other than 2xx!", errorHandler: errorHandler)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                self.displayError("No data was returned by the request!", errorHandler: errorHandler)
                return
            }

            self.fetchPicturesComplete(data, photo: photo)
            
//            self.goToMainThread(){
//                completionHandler(imageData: data)
//            }
            
        }
        
        task.resume()
    }
    
    
    func displayError(errorMessage: String, errorHandler: (errorMessage:String)->()) {
        print(errorMessage)
        self.goToMainThread {
            errorHandler(errorMessage: errorMessage)
        }
    }
    
    func goToMainThread(handler: () -> Void) {
        dispatch_async(dispatch_get_main_queue()) {
            handler()
        }
    }
}