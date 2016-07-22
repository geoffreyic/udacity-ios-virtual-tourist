//
//  LocationViewController.swift
//  VirtualTourist
//
//  Created by Geoffrey_Ching on 7/18/16.
//  Copyright © 2016 Geoffrey Ching. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class LocationViewController: BaseViewController {
    
    var pin:Pin!
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    var fetchedResultsController: NSFetchedResultsController!
    var blockOperations:[NSBlockOperation] = []
    
    var stack:CoreDataStack!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sizeAndSpaceItems(self.view.frame.size)
        
        // Get the stack
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        stack = delegate.stack
        
        // Create a fetchrequest
        let fr = NSFetchRequest(entityName: "Photo")
        fr.sortDescriptors = []
        
        let pred = NSPredicate(format: "toLocation = %@", argumentArray: [pin!])
        
        fr.predicate = pred
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        
        fetchedResultsController.delegate = self
        
        do{
            try fetchedResultsController.performFetch()
        }catch let e as NSError{
            print("Error while fetching photos \n\(e)\n\(fetchedResultsController)")
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func sizeAndSpaceItems(size: CGSize){
        
        let itemsInRow:CGFloat = size.width > size.height ? 5.0 : 3.0
        
        let space: CGFloat = 6.0
        let itemDimension = (size.width - itemsInRow*space-space) / itemsInRow
        
        collectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(space, space, space, space)
        
        collectionViewFlowLayout.minimumLineSpacing = space
        collectionViewFlowLayout.minimumInteritemSpacing = space
        
        collectionViewFlowLayout.itemSize = CGSizeMake(itemDimension, itemDimension)
    }
    
    @IBAction func deleteLocation(sender: AnyObject) {
        askDeleteConfirmation(
            "Do you want to delete this location?",
            cancelAction: {},
            deleteAction: {
                let mapVC = self.navigationController!.viewControllers[0] as! MapViewController
                
                mapVC.mapView.removeAnnotation(self.pin)
                
                self.fetchedResultsController.managedObjectContext.deleteObject(self.pin)
                self.navigationController?.popViewControllerAnimated(true)
                
                self.stack.save()
            }
        )
        
    }
    
    @IBAction func refreshAction(sender: AnyObject) {
        
        for obj in fetchedResultsController.fetchedObjects!{
            fetchedResultsController.managedObjectContext.deleteObject(obj as! Photo)
        }
        
        stack.save()
        
        FlickrAPI.instance.getPhotosForLocation(pin, longitude: pin.longitude, latitude: pin.latitude, page: nil, perPage: 15, accuracy: 11, errorHandler: displayErrorAlert)
    }
    
}


// Collection View Updates from Coredata  - Delegate
extension LocationViewController: NSFetchedResultsControllerDelegate{
    
    // ideas from http://stackoverflow.com/questions/20554137/nsfetchedresultscontollerdelegate-for-collectionview
    
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        blockOperations.removeAll(keepCapacity: false)
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        if type == NSFetchedResultsChangeType.Insert {
            print("Insert Object: \(newIndexPath)")
            
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.insertItemsAtIndexPaths([newIndexPath!])
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.Update {
            print("Update Object: \(indexPath)")
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.reloadItemsAtIndexPaths([indexPath!])
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.Move {
            print("Move Object: \(indexPath)")
            
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.moveItemAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.Delete {
            print("Delete Object: \(indexPath)")
            
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.deleteItemsAtIndexPaths([indexPath!])
                    }
                })
            )
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        if type == NSFetchedResultsChangeType.Insert {
            print("Insert Section: \(sectionIndex)")
            
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.insertSections(NSIndexSet(index: sectionIndex))
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.Update {
            print("Update Section: \(sectionIndex)")
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.reloadSections(NSIndexSet(index: sectionIndex))
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.Delete {
            print("Delete Section: \(sectionIndex)")
            
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.deleteSections(NSIndexSet(index: sectionIndex))
                    }
                })
            )
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView!.performBatchUpdates(
            { () -> Void in
                for operation: NSBlockOperation in self.blockOperations {
                    operation.start()
                }
            },
            completion: { (finished) -> Void in
                self.blockOperations.removeAll(keepCapacity: false)
            }
        )
        
        
    }
}


// collection delegate section

extension LocationViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if fetchedResultsController.sections == nil{
            print ("no sections in collection")
            return 0
        }else{
            print ("there are sections in the collection: ")
            print(fetchedResultsController.sections!.count)
            return fetchedResultsController.sections!.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print ("there are photos in the section: ")
        print(fetchedResultsController.sections![section].numberOfObjects)
        return fetchedResultsController.sections![section].numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
        
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        if let data = photo.imageData{
            cell.cellImageView.image = UIImage(data: data)
        }else{
            cell.cellImageView.image = UIImage(named: "Placeholder")
        }
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        askDeleteConfirmation(
            "Do you want to delete this photo?",
            cancelAction: {},
            deleteAction: {
                self.fetchedResultsController.managedObjectContext.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! Photo)
            }
        )
    }
    
}


