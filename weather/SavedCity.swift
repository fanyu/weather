//
//  SavedCity.swift
//  
//
//  Created by FanYu on 6/16/15.
//
//
import Foundation
import CoreData
import UIKit

struct cSavedCity {
    static let SavedCity = "SavedCity"
    static let dbID = "sID"
}

class SavedCity: NSManagedObject {
    @NSManaged var sCityName: String
    @NSManaged var sID: NSNumber
    @NSManaged var sCountry: String

    static func getAllCities() ->[SavedCity]? {
        let c = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName: cSavedCity.SavedCity)
        var error: NSError?
        
        let results = c.executeFetchRequest(fetchRequest, error: &error) as? [SavedCity]
        
        if error != nil {
            println("Could not save \(error), \(error?.userInfo)")
        }
        return results
    }
    
    static func getCityByID(idCity:Int) ->SavedCity? {
        let c = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName: cSavedCity.SavedCity)
        fetchRequest.predicate = NSPredicate(format: "%K == %@", argumentArray: [cSavedCity.dbID, idCity])
        var error: NSError?
        
        let results =  c.executeFetchRequest(fetchRequest, error: &error) as? [SavedCity]
        
        return results?.first
    }
    
    static func insertCity(city:String, country:String, idCity: Int) -> SavedCity? {
        let c = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        if let cityByID = SavedCity.getCityByID(idCity) {
            return nil
        }
        
        let savedCity = NSEntityDescription.insertNewObjectForEntityForName(cSavedCity.SavedCity, inManagedObjectContext: c) as? SavedCity
        
        savedCity?.sCityName = city
        savedCity?.sCountry = country
        savedCity?.sID = idCity
        weatherService.saveContext()
        
        return savedCity
    }
    
    static func removeCity(city: SavedCity) {
        let c = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        c.deleteObject(city)
    }
}