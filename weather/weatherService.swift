//
//  weatherConvert.swift
//  weather
//
//  Created by FanYu on 5/30/15.
//  Copyright (c) 2015 FanYu. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire
import SwiftyJSON
import CoreData
import UIKit
import Social

struct cGeneral {
    static let ChangeUnitNotification = "ChangeUnitNotification"
    static let ChangeSelectedCity = "ChangeSelectedCity"
    static let NeedReloadForecastTVC = "NeedReloadForecastVC"
    static let appBlackColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
}

public enum Status {
    case success
    case failure
}

struct cForecast {
    static let kTemp = "temp"
    static let KTempLow = "tempLow"
    static let KTempHigh = "tempHigh"
    static let kDesc = "desc"
    static let kPoll = "poll"
}

struct pm25Params {
    static let token = "5j1znBVAsnSf5xQyNQyq"
    static let stations = "no"

}
public class Response {
    public var status: Status?
    public var object: JSON?
    public var error: NSError?
}

public class weatherService {
    
    static func shareToWeibo(view: UIView) ->SLComposeViewController {
        var shareControler: SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        shareControler.setInitialText("#WeatherBubble#")
        let image = screenShot(view)
        shareControler.addImage(image)
        return shareControler
    }
    
    static func screenShot(view: UIView) ->UIImage {
        // create the uiimage
        UIGraphicsBeginImageContextWithOptions(view.frame.size, true, 0)
        // get the context
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        // get the image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        UIGraphicsEndImageContext()
        
        return image
    }
    
    static func conditionJudge(condition: Int) ->(condition: String, str: String){
        
        if condition < 300 {
            return ("雷阵雨", "等等呗")
        } else if condition < 500 {
            return ("毛毛雨", "漫步吧")
        } else if condition == 500 {
            return ("小雨", "看书吧")
        } else if condition == 501 {
            return ("中雨", "打伞哦")
        } else if condition == 502 {
            return ("大雨", "打伞哦")
        } else if condition <= 511 {
            return ("冻雨", "加衣服")
        } else if condition <= 531 {
            return ("阵雨", "等等呗")
        } else if condition == 600 {
            return ("小雪", "温馨啊")
        } else if condition == 601 {
            return ("中雪", "啤酒炸鸡")
        } else if condition == 602 {
            return ("大雪", "打雪仗")
        } else if condition < 620 {
            return ("雨夹雪", "打伞哦")
        } else if condition == 620 {
            return ("小阵雪", "无所谓")
        } else if condition == 621 {
            return ("中阵雪", "等等呗")
        } else if condition == 622 {
            return ("大阵雪", "等等呗")
        } else if condition == 701 {
            return ("薄雾", "迷离中")
        } else if condition < 741 {
            return ("雾霾", "带口罩")
        } else if condition == 741 {
            return ("大雾", "看路哦")
        } else if condition < 771 {
            return ("沙尘暴", "待家呗")
        } else if condition < 800 {
            return ("龙卷风", "要当心")
        } else if condition == 800 {
            return ("晴朗", "好天气")
        } else if condition < 804 {
            return ("少云", "好天气")
        } else if condition == 804 {
            return ("多云", "挺凉快")
        } else if condition < 902 {
            return ("龙卷风", "待家呗")
        } else if condition == 902 {
            return ("飓风", "待家呗")
        } else if condition == 903 {
            return ("寒冷", "加衣哦")
        } else if condition == 904 {
            return ("炎热", "防中暑")
        } else if condition == 905 {
            return ("多风天", "墨镜呢")
        } else if condition == 906 {
            return ("冰雹", "当心啊")
        } else if condition == 951 {
            return ("无风", "不起浪")
        } else if condition <= 952 {
            return ("小风", "舒服啊")
        } else if condition == 953 {
            return ("微风", "惬意哦")
        } else if condition == 954 {
            return ("和风", "凉爽啊")
        } else if condition == 955 {
            return ("清风", "风略大")
        } else if condition < 958 {
            return ("强风", "待屋里")
        } else if condition <= 959 {
            return ("烈风", "待屋里")
        } else if condition == 960 {
            return ("暴风", "待屋里")
        } else if condition <= 962 {
            return ("飓风", "待屋里")
        } else {
            return ("什么鬼", "无用")
        }
    }
    
    static func humidityJudge(humidity: Int) ->String {
        if humidity <= 20 {
            return "极干燥"
        } else if humidity <= 40 {
            return "较干燥"
        } else if humidity <= 50 {
            return "舒适啊"
        } else if humidity <= 70 {
            return "湿度大"
        } else {
            return "极潮湿"
        }
    }
    
    static func windJudge(windSpeed: Float) ->String {
        if windSpeed < 1 {
            return "无风"
        } else if windSpeed < 12 {
            return "轻风"
        } else if windSpeed < 20 {
            return "微风"
        } else if windSpeed < 29 {
            return "和风"
        } else if windSpeed < 39 {
            return "清风"
        } else if windSpeed < 50 {
            return "强风"
        } else if windSpeed < 62 {
            return "疾风"
        } else if windSpeed < 75 {
            return "大风"
        } else if windSpeed < 89 {
            return "烈风"
        } else if windSpeed < 103 {
            return "狂风"
        } else if windSpeed < 118 {
            return "暴风"
        } else {
            return "飓风"
        }
    }
    

    
    static func convertTemperature(country: String, temperature: Double) ->(temp: String, str: String) {
        var str: String?
        var temp: String?
        var convertedT: Int?
        if country == "US" {
            convertedT = Int(round(((temperature - 273.5) * 1.8) + 32))
            temp = "\(convertedT!)"
        } else {
            convertedT = Int(round(temperature - 273.5))
            temp = "\(convertedT!)"
        }
        
        if convertedT < -20 {
            str = "极其冷"
        } else if convertedT < -10 {
            str = "非常冷"
        } else if convertedT < 0 {
            str = "结冰啦"
        } else if convertedT < 10 {
            str = "降温了"
        } else if convertedT < 26 {
            str = "舒适哦"
        } else if convertedT < 30 {
            str = "有点热"
        } else if convertedT < 35 {
            str = "非常热"
        } else if convertedT < 40{
            str = "热死啦"
        } else {
            str = "已热死"
        }
        return (temp!, str!)
    }
    
    static func sunUpSetTime(sunRise: Double, sunSet: Double) ->(up: String, down: String, riseTime: String, setTime: String) {
        
        var dataFormater = NSDateFormatter()
        dataFormater.dateFormat = "h:mm"
        var riseTime = dataFormater.stringFromDate(NSDate(timeIntervalSince1970: sunRise))
        var setTime = dataFormater.stringFromDate(NSDate(timeIntervalSince1970: sunSet))
        
        var riseHour = riseTime.componentsSeparatedByString(":")[0]
        var setHour = setTime.componentsSeparatedByString(":")[0]
        
        var hourUpStr: String = " "
        var hourDownStr: String = " "
        
        switch riseHour {
        case "3": hourUpStr = "三时升"
        case "4": hourUpStr = "四时升"
        case "5": hourUpStr = "五时升"
        case "6": hourUpStr = "六时升"
        case "7": hourUpStr = "七时升"
        default:hourUpStr = "无数据"
        }
        switch setHour {
        case "3": hourDownStr = "三时落"
        case "4": hourDownStr = "四时落"
        case "5": hourDownStr = "五时落"
        case "6": hourDownStr = "六时落"
        case "7": hourDownStr = "七时落"
        case "8": hourDownStr = "八时落"
        default:hourDownStr = "无数据"
        }
        
        return (hourUpStr, hourDownStr, riseTime, setTime)
    }
    
    static func getDayOfWeek() ->Int {
        let todayDate = NSDate()
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let myWeek = myCalendar!.component(NSCalendarUnit.CalendarUnitWeekday, fromDate: todayDate)
        return myWeek
    }
    
    static func saveContext() {
        (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
    }
    
    static func initializeDatabaze() {
        
        let c = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        var u =  NSEntityDescription.insertNewObjectForEntityForName(cUser.User, inManagedObjectContext: c) as! User
        u.uChosenLocationID =  cUser.ChosenLocationCurrent
        saveContext()
    }

    static func showAlertWithText(text: String, sender: AnyObject) {
        
        let a = UIAlertController(title: "抱歉", message: text ?? "", preferredStyle: .Alert)
        let ok = UIAlertAction(title: "检查网络", style: .Default, handler: { (ok) -> Void in})
        a.addAction(ok)
        if let s = sender as? UIViewController {
            sender.presentViewController(a, animated: true, completion: nil)
        }
    }
}