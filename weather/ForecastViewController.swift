//
//  ForecastViewController.swift
//  
//
//  Created by FanYu on 6/26/15.
//
//

import UIKit
import Alamofire
import SwiftyJSON

class ForecastViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func tapGesture(sender: AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBOutlet var activity: UIActivityIndicatorView!
//    @IBOutlet weak var hidedText: UILabel!

//    @IBAction func buttonTapped(sender: AnyObject) {
//        hidedText.hidden = false
//    }
    
    
    // 1 = Sunday, adjusted to our structure -> added +1
    let dateOfWeek = weatherService.getDayOfWeek() - 1
    var days = ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"]
    var data = [[NSObject: AnyObject?]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "needReloadData", name: cGeneral.NeedReloadForecastTVC, object: nil)
        updateUI()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        activity.startAnimating()
    }
    
    
    func updateUI() {
        
        data.removeAll(keepCapacity: true)
        let u = User.getUser()
        var url = ""
        if let user = u where user.uChosenLocationID.integerValue == cUser.ChosenLocationCurrent{
            
            url = "http://api.openweathermap.org/data/2.5/forecast/daily?lat=" + user.uCurrentLatitude.description + "&lon=" + user.uCurrentLongitude.description
            
        } else {
            
            url = "http://api.openweathermap.org/data/2.5/forecast/daily?id=" + (User.getUser()?.uChosenLocationID.stringValue ?? "")
        }
        
        Alamofire.request(.GET, url).responseJSON() {
            (_, _, json, e) in
            if e == nil {
                
                self.activity.stopAnimating()
                self.activity.hidden = true
                
                var json = JSON(json!)
                var list = json["list"]
                if list.count > 5 {
                    for i in 0...6 {
                        var country = json["country"].stringValue
                        var city = json["city"]["name"].stringValue
                        var temp = weatherService.convertTemperature(country, temperature: list[i]["temp"]["day"].doubleValue).0
                        var tempMin = weatherService.convertTemperature(country, temperature: list[i]["temp"]["min"].doubleValue).0
                        var tempMax = weatherService.convertTemperature(country, temperature: list[i]["temp"]["max"].doubleValue).0
                        var condition = weatherService.conditionJudge(list[i]["weather"][0]["id"].intValue).0
                        
                        self.data.append([
                            cForecast.kTemp: temp,
                            cForecast.KTempLow: tempMin,
                            cForecast.KTempHigh: tempMax,
                            cForecast.kDesc: condition,
                            ])
                    }
                    self.tableView.reloadData()
                }
            } else {
                weatherService.showAlertWithText("雷公电母休息中", sender: self)
            }

        }
    }
    
    func needReloadData() {
        updateUI()
    }


    // MARK: - UITableView Protocols
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ForecastCell") as! ForecastCell
        
        cell.iDay.text = days[(indexPath.row + dateOfWeek) % 7]
        cell.iTemperatureLow.text = data[indexPath.row][cForecast.KTempLow] as? String
        cell.iTemperatureHigh.text = data[indexPath.row][cForecast.KTempHigh] as? String
        cell.iCondition.text = data[indexPath.row][cForecast.kDesc] as? String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let cellSize: CGFloat
        let deviseSize = UIScreen.mainScreen().bounds.height
        
        switch deviseSize {
        case 480: cellSize = 55 // 4
        case 568: cellSize = 70 // 5
        case 667: cellSize = 83 // 6
        case 736: cellSize = 93 // plus
        default: cellSize = 100 // ipad
        }
        
        return cellSize
    }
}
