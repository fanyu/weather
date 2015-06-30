//
//  ListOfCitiesViewController.swift
//  
//
//  Created by FanYu on 6/12/15.
//
//

import UIKit
import Alamofire
import SwiftyJSON

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var segueButton: UIButton!
    var data = SavedCity.getAllCities() ?? [SavedCity]()
    var currentData = [[NSObject: AnyObject?]]()    
    var firstlaunch: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        //tableView.addSubview(self.tableView.tableFooterView!)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        if firstlaunch {
            firstlaunch = false
            activity.hidden = true
        } else {
            activity.startAnimating()
        }
        
        data = SavedCity.getAllCities() ?? [SavedCity]()
        tableView.reloadData()
        
        
        var allCities = SavedCity.getAllCities()
        if let cities = allCities where cities.count > 0 {
            var idValues = [String]()
            currentData.removeAll(keepCapacity: true)
            for c in cities {
                idValues.append(c.sID.stringValue)
            }
            
            // multiple city id
            let url = "http://api.openweathermap.org/data/2.5/group?id=" + (",".join(idValues)) + "&lang=zh_cn"
            Alamofire.request(.GET, url).responseJSON() {
                (_, _, json, error) in
                if error == nil {
                    
                    self.activity.stopAnimating()
                    self.activity.hidden = true
                    
                    var l = JSON(json!)["list"]
                    for (i,_) in enumerate(l) {
                        var country = l[i]["sys"]["country"].stringValue
                        var city = l[i]["name"].stringValue
                        var temp = weatherService.convertTemperature(country, temperature: l[i]["main"]["temp"].doubleValue).0
                        var condition = weatherService.conditionJudge(l[i]["weather"][0]["id"].intValue).0
                        //var pollution = self.getPollutionInfo(city, token: pm25Params.token, stations: pm25Params.stations).str
                        
                        self.currentData.append([
                            cForecast.kTemp: temp,
                            cForecast.kDesc: condition,
                            //cForecast.kPoll: pollution
                        ])
                        self.tableView.reloadData()
                    }
                } else {
                    weatherService.showAlertWithText("雷公电母休息中", sender: self)
                }
            }
        }
    }
    
    // MARK: - UITableView Protocols
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let u = User.getUser()
        if indexPath.row == 0 {
            u?.uChosenLocationID = cUser.ChosenLocationCurrent
            u?.uChosenLocationName = ""
            u?.uCurrentLatitude = 0
            u?.uCurrentLongitude = 0
        } else {
            u?.uChosenLocationName = data[indexPath.row - 1].sCityName
            u?.uChosenLocationID = data[indexPath.row - 1].sID
        }
        weatherService.saveContext()
        
        NSNotificationCenter.defaultCenter().postNotificationName(cGeneral.ChangeSelectedCity, object: self)
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell") as! LocationCell
        
        if indexPath.row == 0 {
            let user = User.getUser()!
            if user.uChosenLocationID.integerValue == cUser.ChosenLocationCurrent {
                cell.iCity.text = user.uChosenLocationName
                cell.iTemp.text = "\(user.uCurrentTemperature)"
                cell.iCondition.text = user.uCurrentCondition
            } else {
                cell.iCity.hidden = true
                cell.iTemp.hidden = true
                cell.iCondition.text = "当前所在的位置"
            }
    
        } else {
            cell.iCity.text = data[indexPath.row - 1].sCityName
            if SavedCity.getAllCities()?.count == currentData.count {
                let temp = currentData[indexPath.row - 1][cForecast.kTemp] as! String
                cell.iTemp.text = "\(temp)"
                cell.iCondition.text = currentData[indexPath.row - 1][cForecast.kDesc] as? String
            } else {
                cell.iTemp.text = "xxx"
                cell.iCondition.text = "xxx"
                
            }
        }
        

        return cell
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        }
        return true
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "删除") { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            SavedCity.removeCity(self.data[indexPath.row - 1])
            self.data.removeAtIndex(indexPath.row - 1)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        return [deleteAction]
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count + 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //return 60
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
    
    // scroll view
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        segueButton.hidden = true
    }

    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        segueButton.hidden = false
    }

}
