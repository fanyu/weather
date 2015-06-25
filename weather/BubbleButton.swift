//
//  BubbleButton.swift
//  weather
//
//  Created by FanYu on 5/29/15.
//  Copyright (c) 2015 FanYu. All rights reserved.
//

import Foundation
import UIKit

class BubbleButton: UIButton {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //self.frame = CGRect(x: 80, y: 100, width: 200, height: 200)
        self.layer.cornerRadius = 45
        //self.layer.backgroundColor = UIColor.purpleColor().CGColor
        self.layer.borderWidth = 1
        //self.titleLabel?.text = "Hello World"
        //self.backgroundColor = UIColor.purpleColor()
        self.tintColor = UIColor.whiteColor()
        //self.setTitle(title: String?, forState: UIControlState)
        //self.backgroundColor = UIColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 1)
        //self.titleLabel?.numberOfLines = 2
        self.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.titleLabel?.textAlignment = NSTextAlignment.Center
        self.titleLabel?.font = UIFont.systemFontOfSize(20)
    }
    
}

