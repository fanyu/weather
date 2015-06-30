//
//  User.swift
//  weather
//
//  Created by FanYu on 6/16/15.
//  Copyright (c) 2015 FanYu. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct cUser {
    static let User = "User"
    static let ChosenLocationCurrent = -1
}


class User: NSManagedObject {
    @NSManaged var uChosenLocationName: String
    @NSManaged var uChosenLocationID: NSNumber
    
    @NSManaged var uCurrentLatitude: NSNumber
    @NSManaged var uCurrentLongitude: NSNumber
    
    @NSManaged var uCurrentTemperature: String
    @NSManaged var uCurrentCondition: String
    @NSManaged var uCurrentWind: String
    @NSManaged var uCurrentPollution: String
    @NSManaged var uCurrentHumidity: String
    
    
    static func getUser() -> User? {
        let c = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName: cUser.User)
        var error: NSError?
        
        let results =  c.executeFetchRequest(fetchRequest, error: &error) as? [User]
        
        if error != nil {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        return results?.first
    }
}


