//
//  NotificationViewController.swift
//  
//
//  Created by FanYu on 6/29/15.
//
//

import UIKit
import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation
import NotificationCenter

class NotificationViewController: UIViewController, CLLocationManagerDelegate, NCWidgetProviding {

    @IBOutlet weak var time1: UILabel!
    @IBOutlet weak var time2: UILabel!
    @IBOutlet weak var time3: UILabel!
    @IBOutlet weak var condition1: UILabel!
    @IBOutlet weak var condition2: UILabel!
    @IBOutlet weak var condition3: UILabel!
    @IBOutlet weak var temperature1: UILabel!
    @IBOutlet weak var temperature2: UILabel!
    @IBOutlet weak var temperature3: UILabel!
    
    let locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingHeading()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updataNotificationCenter(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let url = "http://api.openweathermap.org/data/2.5/forecast"
        let params = ["lat": latitude, "lon": longitude]
        
        Alamofire.request(.GET, url, parameters: params).responseJSON {
            (_, _, json, err) in
            if err == nil {
                var json = JSON(json!)
                
                // get country
                let country = json["city"]["name"].stringValue
                // get city 
                let city = json["country"].stringValue
    
                // Get forecast
                for index in 0...2 {
                    // Get and convert temperature
                    var temperature = json["list"][index]["mian"]["temp"].doubleValue
                    var temp = weatherService.convertTemperature(country, temperature: temperature).temp
                    
                    // get condition
                    var conditionID = json["list"][index]["weather"][0].intValue
                    var condition = weatherService.conditionJudge(conditionID).condition
                    
                    // get time
                    var timeINterval = json["list"][index]["dt"].doubleValue
                    var rowDate = NSDate(timeIntervalSince1970: timeINterval)
                    var dateFormater = NSDateFormatter()
                    dateFormater.dateFormat = "HH"
                    var time = dateFormater.stringFromDate(rowDate)
                    
                    if (index==0) {
                        self.temperature1.text = "\(temp)°"
                        self.condition1.text = "\(condition)"
                        self.time1.text = "\(time)"
                    }
                    else if (index==1) {
                        self.temperature2.text = "\(temp)°"
                        self.condition2.text = "\(condition)"
                        self.time3.text = "\(time)"
                    }
                    else if (index==2) {
                        self.temperature3.text = "\(temp)°"
                        self.condition3.text = "\(condition)"
                        self.time3.text = "\(time)"
                    }
                }
            } else {
                println("Weather info is not available!")
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var location: CLLocation = locations[locations.count - 1] as! CLLocation
        
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            updataNotificationCenter(location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        locationManager.startUpdatingLocation()
        completionHandler(NCUpdateResult.NewData)
    }
    
}
