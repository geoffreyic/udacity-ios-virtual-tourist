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
    
    func getPhotosForLocation(longitude: Double, latitude: Double, page:Int32, perPage:Int32, accuracy:Int32, completionHandler: (object:AnyObject!)->(), errorHandler: (errorMessage:String)->()){
        
        
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
        
        urlString = urlString.stringByAppendingString("&page=0")
        
        urlString = urlString.stringByAppendingString("&format=json")
        urlString = urlString.stringByAppendingString("&nojsoncallback=1")
        
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func displayError(errorMessage: String) {
                print(error)
                self.goToMainThread {
                    errorHandler(errorMessage: errorMessage)
                }
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            print(NSString(data: data, encoding: NSUTF8StringEncoding))
            
            // parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            self.goToMainThread(){
                completionHandler(object: parsedResult)
            }
            
        }
        
        task.resume()
        
    }
    
    func downloadPhoto(url: String, completionHandler: (imageData:NSData?)->(), errorHandler: (errorMessage:String)->()){
        
        
        let url = NSURL(string: url)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func displayError(errorMessage: String) {
                print(error)
                self.goToMainThread {
                    errorHandler(errorMessage: errorMessage)
                }
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error fetching the picture: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            self.goToMainThread(){
                completionHandler(imageData: data)
            }
            
        }
        
        task.resume()
    }
    
    func goToMainThread(handler: () -> Void) {
        dispatch_async(dispatch_get_main_queue()) {
            handler()
        }
    }
}