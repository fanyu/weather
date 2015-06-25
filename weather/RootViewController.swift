//
//  ViewController.swift
//  weather
//
//  Created by FanYu on 5/26/15.
//  Copyright (c) 2015 FanYu. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

class RootViewController: UIViewController,CLLocationManagerDelegate {
    
    // label
    @IBOutlet weak var currentLocation: UILabel!
    // button title
    @IBOutlet weak var temperatureTitle: BubbleButton!
    @IBOutlet weak var humidityTitle: BubbleButton!
    @IBOutlet weak var conditionTitle: BubbleButton!
    @IBOutlet weak var windTitle: BubbleButton!
    @IBOutlet weak var pollutionTitle: BubbleButton!
    @IBOutlet weak var sunriseTitle: BubbleButton!
    @IBOutlet weak var sunsetTitle: BubbleButton!
    // loading stuffs
    @IBOutlet weak var tryLoading: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
        
    // weather info update when tap button
    var country: String = ""
    
    var tempeture: (String, String) = ("", "") { didSet {temperatureTitle.setTitle(tempeture.1, forState: UIControlState.Highlighted) } }
    
    var windSpeed: Float = 0 { didSet { windTitle.setTitle("\(windSpeed)级", forState: UIControlState.Highlighted) } }
    
    var humidity: Int = 0 { didSet { humidityTitle.setTitle("\(humidity)%", forState: UIControlState.Highlighted) } }
    
    var pm2_5: Int = 0 { didSet { pollutionTitle.setTitle("PM2.5\n\(pm2_5)", forState: UIControlState.Highlighted) } }
    
    var conditionStr = ("", "") { didSet { conditionTitle.setTitle(conditionStr.1, forState: UIControlState.Highlighted) } }
    
    var up: String = "" { didSet { sunriseTitle.setTitle(up, forState: UIControlState.Highlighted) } }
    var down: String = "" { didSet { sunsetTitle.setTitle(down, forState: UIControlState.Highlighted) } }

    // pollution token
//    var token: String = "5j1znBVAsnSf5xQyNQyq"
//    var stations: String = "no"
    
    // servise
    let service = weatherService()
    
    // refresh
    var refreshControl: UIRefreshControl!
    
    // first time launch 
    var appFirstTimeLaunched = true
    var canUpdateUI = true
    
    // MARK: - instant locationManager
    let locationManager: CLLocationManager = CLLocationManager()

    
    // MARK: - dataButtonTapped
    @IBAction func dataButtonTapped(sender: AnyObject) {
        switch sender.tag {
        case 0: humidityTitle.setTitle("\(humidity)%", forState: UIControlState.Highlighted)
        case 1: conditionTitle.setImage(nil, forState: UIControlState.Highlighted)
        case 2: windTitle.setTitle("\(windSpeed)级", forState: UIControlState.Highlighted)
        case 3: temperatureTitle.setImage(nil, forState: UIControlState.Highlighted)
        case 4: pollutionTitle.setImage(nil, forState: UIControlState.Highlighted)
        case 5: sunriseTitle.setTitle(up, forState: UIControlState.Highlighted)
        default : sunsetTitle.setTitle(down, forState: UIControlState.Highlighted)
        }
    }

    // MARK: - viewDidload and memoryWarning
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        if CLLocationManager.authorizationStatus() == .Denied {
            let settingUrl = NSURL(string: UIApplicationOpenSettingsURLString)
            if let url = settingUrl {
                UIApplication.sharedApplication().openURL(url)
            }
            tryLoading.text = "Location not determined"
        }
        
        // icurrent image 
        //iCurrent.hidden = User.getUser()?.uChosenLocationID.integerValue == cUser.ChosenLocationCurrent ? false : true ?? true
        
        // spinner indicator
        spinner.startAnimating()
        
        // notificaiton 
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectedCityChanged", name: cGeneral.ChangeSelectedCity, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appBecomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func appBecomeActive() {
        if appFirstTimeLaunched == true {
            appFirstTimeLaunched = false
            return
        }
        canUpdateUI = true
        // it's the current location
        if User.getUser()?.uChosenLocationID.integerValue == cUser.ChosenLocationCurrent {
            locationManager.startUpdatingLocation()
        } else { // other location
            updateUI()
        }
    }
    
    func updateUI() {
        var url: String?
        if let u = User.getUser() where u.uChosenLocationID.integerValue == cUser.ChosenLocationCurrent {
            url = "http://api.openweathermap.org/data/2.5/weather?lat=" + u.uCurrentLatitude.description + "&lon=" + u.uCurrentLongitude.description + "&lang=zh_cn"
        } else {
            url  = "http://api.openweathermap.org/data/2.5/weather?id=" + (User.getUser()?.uChosenLocationID.stringValue ?? "") + "&lang=zh_cn"
        }
        
        //getSunUpSetTimeInfo(User.getUser()!.uCurrentLatitude, longitude: User.getUser()!.uCurrentLongitude)
        
        Alamofire.request(.GET, url!).responseJSON() {
            (_, _, json, error) in
            if error != nil { // cannot get data
                self.tryLoading.text = "雷公电母睡觉中"
            } else { // successful get data
                
                self.tryLoading.text = nil   // set nil
                self.spinner.stopAnimating() // stop animating
                self.spinner.hidden = true   // hide spinner
        
                var u = User.getUser()
                var json = JSON(json!)
                
                if let tempResult = json["main"]["temp"].double {
                    
                    // description
                    var description = json["weather"][0]["description"].stringValue
                    
                    // get country
                    self.country = json["sys"]["country"].stringValue
                    
                    // get city name
                    let city = json["name"].stringValue
                    self.currentLocation.text = city
                    u?.uChosenLocationName = city
                    
                    // get pm2.5
                    var pollutionStr = self.getPollutionInfo(city, token: pm25Params.token, stations: pm25Params.stations).str
                    self.pm2_5 = self.getPollutionInfo(city, token: pm25Params.token, stations: pm25Params.stations).pm2_5
                    //self.pollutionTitle.setTitle("\(pollutionStr)", forState: .Normal)
                    u?.uCurrentPollution = pollutionStr
                    
                    // get and convert tempeture
                    self.tempeture = self.service.convertTemperature(self.country, temperature: tempResult)
                    let temp = self.tempeture.0
                    self.temperatureTitle.setTitle("\(temp)", forState: .Normal)
                    u?.uCurrentTemperature = "\(temp)"
                    
                    // get condition
                    var condition = json["weather"][0]["id"].intValue
                    self.conditionStr = self.service.conditionJudge(condition)
                    self.conditionTitle.setTitle(self.conditionStr.0, forState: .Normal)
                    u?.uCurrentCondition = self.conditionStr.0
                    
                    // get wind
                    self.windSpeed = json["wind"]["speed"].floatValue
                    var windStr = self.service.windJudge(self.windSpeed)
                    self.windTitle.setTitle(windStr, forState: .Normal)
                    u?.uCurrentWind = windStr
                    
                    // get humidity 
                    self.humidity = json["main"]["humidity"].intValue
                    var humidityStr = self.service.humidityJudge(self.humidity)
                    self.humidityTitle.setTitle("\(humidityStr)", forState: .Normal)
                    u?.uCurrentHumidity = humidityStr
                    
                    // get sunrise and sunset 
                    var sunrise = json["sys"]["sunrise"].doubleValue
                    var sunset = json["sys"]["sunset"].doubleValue
                    
                    var rise: NSDate = NSDate(timeIntervalSince1970: sunrise)
                    var set: NSDate = NSDate(timeIntervalSince1970: sunset)
                    
                    println("Sunrise:\(rise)")
                    println("Sunset:\(set)")
                    
                    
                    var hourUp: Int = NSCalendar.currentCalendar().components(.CalendarUnitHour, fromDate: NSDate(timeIntervalSince1970: sunrise)).hour
                    var hourDown: Int = NSCalendar.currentCalendar().components(.CalendarUnitHour, fromDate: NSDate(timeIntervalSince1970: sunset)).hour
                    
                    var minUp = NSCalendar.currentCalendar().components(.CalendarUnitMinute, fromDate: NSDate(timeIntervalSince1970: sunrise)).minute
                    var minDown: Int = NSCalendar.currentCalendar().components(.CalendarUnitMinute, fromDate: NSDate(timeIntervalSince1970: sunset)).minute
                    
                    var day = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitDay, fromDate: NSDate(timeIntervalSince1970: sunset)).day

                    var dateFormator = NSDateFormatter()
                    dateFormator.stringFromDate(rise)
                    
                    println("day\(day)")
                    println("HourUp:\(hourUp)")
                    println("HourDown:\(hourDown)")
                    println("MinUp:\(minUp)")
                    println("MinDown:\(minDown)")
                    
                    self.up = "\(hourUp):\(minUp)"
                    self.down = "\(hourDown):\(minDown)"
                    
                    var hourUpStr: String = " "
                    var hourDownStr: String = " "
                    
                    
                    switch hourUp {
                    case 3: hourUpStr = "三时升"
                    case 4: hourUpStr = "四时升"
                    case 5: hourUpStr = "五时升"
                    case 6: hourUpStr = "六时升"
                    case 7: hourUpStr = "七时升"
                    default:hourUpStr = "无数据"
                    }
                    switch hourDown {
                    case 15: hourDownStr = "三时落"
                    case 16: hourDownStr = "四时落"
                    case 17: hourDownStr = "五时落"
                    case 18: hourDownStr = "六时落"
                    case 19: hourDownStr = "七时落"
                    case 20: hourDownStr = "八时落"
                    default:hourDownStr = "无数据"
                    }
                    self.sunriseTitle.setTitle(hourUpStr, forState: .Normal)
                    self.sunsetTitle.setTitle(hourDownStr, forState: .Normal)

                    
                    weatherService.saveContext()
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(cGeneral.NeedReloadForecastTVC, object: nil)
                }
            }
        }
    }
    
    func getPollutionInfo(city: String, token: String, stations: String) ->(str:String, pm2_5: Int)  {
        let url = "http://www.pm25.in/api/querys/pm2_5.json"
        let params = ["city":city, "token":token, "stations":stations]
        var pmStr = "A"
        var pm2_5 = 0
        
        Alamofire.request(.GET, url, parameters: params)
            .responseJSON { (request, response, json, error) in
                if let errStr = error {
                    pmStr = "无数据"
                    pm2_5 = 0
                    self.pollutionTitle.setTitle("\(pmStr)", forState: .Normal)

                } else {
                    let json = JSON(json!)
                    pm2_5 = json["pm2_5"].intValue
                    
                    if pm2_5 < 50 {
                        pmStr = "空气优"
                    } else if pm2_5 < 100 {
                        pmStr = "空气良"
                    } else if pm2_5 < 150 {
                        pmStr = "微污染"
                    } else if pm2_5 < 200 {
                        pmStr = "轻污染"
                    } else if pm2_5 < 300 {
                        pmStr = "中污染"
                    } else {
                        pmStr = "重污染"
                    }
                    self.pollutionTitle.setTitle("\(pmStr)", forState: .Normal)
                }
        }
        return (pmStr, pm2_5)
    }

    
    func selectedCityChanged() {
        canUpdateUI = true
        if User.getUser()?.uChosenLocationID.integerValue == cUser.ChosenLocationCurrent {
            locationManager.startUpdatingLocation()
        } else {
            updateUI()
        }
    }
    
    
    
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var location: CLLocation = locations[locations.count - 1] as! CLLocation
        
        if location.horizontalAccuracy > 0 { //the location is valid
            
            if canUpdateUI == true && locations.count > 0 {
                canUpdateUI = false
                
                // stop updating after successful load
                self.locationManager.stopUpdatingLocation()
                
                // getlocationJsonInfo from location coordinate
                var u = User.getUser()
                u?.uCurrentLatitude = (locations.first as? CLLocation)?.coordinate.latitude ?? 0
                u?.uCurrentLongitude = (locations.first as? CLLocation)?.coordinate.longitude ?? 0
                
                weatherService.saveContext()
                updateUI()
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Somthing wrong: \(error)")
    }

}
