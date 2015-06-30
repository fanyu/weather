//
//  SearchLocationTableViewController.swift
//  
//
//  Created by FanYu on 6/18/15.
//
//

import UIKit
import Foundation

// coorespond components position of countries list in array
struct cPositions {
    static let ID = 0
    static let City = 1
    static let Country = 4
}

struct CityDetail {
    var city = ""
    var country = ""
    var idCity = -1
}

class SearchLocationViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    //@IBOutlet weak var searchBar: UISearchBar?
    

    var data = [CityDetail]()           // database data
    var filteredData = [CityDetail]()   // show after searching
    var searchController = UISearchController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 45
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.sizeToFit()
        self.searchController.searchBar.searchBarStyle = .Minimal
        self.searchController.searchBar.barTintColor = UIColor.blueColor()
        self.searchController.searchBar.tintColor = UIColor.whiteColor()
        self.searchController.searchBar.showsCancelButton = true
        self.searchController.searchBar.placeholder = "请输入城市拼音"
        self.searchController.searchBar.barStyle = UIBarStyle.Black
        self.searchController.searchBar.keyboardAppearance = UIKeyboardAppearance.Dark
        self.searchController.active = true
        self.tableView.tableHeaderView = self.searchController.searchBar
        
        self.definesPresentationContext = true
        
        // async get country list from the database
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let path = NSBundle.mainBundle().pathForResource("countries", ofType: "txt")
            if let content = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil) {
                // parsing file 
                var temp = content.componentsSeparatedByString("\n")
                temp.removeAtIndex(0)   // remove the title 
                for line in temp {
                    let lineArray = line.componentsSeparatedByString("\t")
                    self.data.append(CityDetail(city   : lineArray[cPositions.City],
                                                country: lineArray[cPositions.Country],
                                                idCity : lineArray[cPositions.ID].toInt()!))
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                //self.tableView.reloadData()
                //self.resultSearchController.active = true
                self.tableView.reloadData()
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Table view protocol
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let record = self.searchController.active ? filteredData[indexPath.row] : data[indexPath.row]
        SavedCity.insertCity(record.city, country: record.country, idCity: record.idCity)
        
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // active to show filteredData which is less than data
        if searchController.active {
            return filteredData.count
        } else {
            return data.count
        }
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->UITableViewCell {
        let c = tableView.dequeueReusableCellWithIdentifier("SearchLocationCell") as! UITableViewCell
        c.textLabel?.textColor = UIColor.whiteColor()
        
        if (self.searchController.active) {
            let record =  filteredData[indexPath.row]
            c.textLabel?.text = record.city + ", " + record.country
        } else {
            let record =  data[indexPath.row]
            c.textLabel!.text = record.city + ", " + record.city
        }
        
        return c
    }

    
    func filterContentForSearchText(searchText: String) {
        // Filter the array using the filter method
        filteredData = data.filter() { (line: CityDetail) -> Bool in
            return line.city.lowercaseString.rangeOfString(searchText) != nil
        }
    }
    // MARK: - Search
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filteredData.removeAll(keepCapacity: false)
        filterContentForSearchText(searchController.searchBar.text.lowercaseString)
        self.tableView.reloadData()
    }

}
