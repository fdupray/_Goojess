//
//  Macros.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

let appDelegate = UIApplication.shared.delegate as! AppDelegate

let SERVICE_MANAGER = CCServiceManager.sharedManager()

func SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO (_ v: String) -> Bool {
    
    return Device().systemVersion.compare(v, options: NSString.CompareOptions.numeric) != ComparisonResult.orderedAscending
}

let APP_NAME = "Goojess"


let METERS_PER_MILE = 1609.344

let AREA_IN_MILES = 5


let GOOGLE_ANALYTICS = "UA-64662718-1"


//let FONT_FAMILY_ITALIC = "GillSans-Italic"

//let FONT_FAMILY_BOLD = "GillSans-Bold"

//let FONT_FAMILY_BOLD_ITALIC = "GillSans-BoldItalic"

//let FONT_FAMILY_LIGHT_ITALIC = "GillSans-LightItalic"

let FONT_FAMILY_REGULAR = "Avenir-Medium"

//let FONT_FAMILY_LIGHT = "GillSans-Light"

/*func BOLD_FONT (s: CGFloat) -> UIFont {
    
    return UIFont(name: FONT_FAMILY_BOLD, size: s)!
}

func REGULAR_FONT (s: CGFloat) -> UIFont {
    
    return UIFont(name: FONT_FAMILY_REGULAR, size: s)!
}

func color (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
    
    return UIColor(red: r/255, green: g/255, blue: b/255, alpha: a)
}

let THEME_BLUE_COLOR = color(59, g: 151, b: 243, a: 1.0)*/

func SET_SEPARATOR_VIEW(_ v: UIView, vh: CGFloat, h: CGFloat, c: UIColor) {
    
    let viewBottomLine = UIView(frame: CGRect(x: 0, y: vh - h, width: SCREEN_WIDTH, height: h))
    
    viewBottomLine.backgroundColor = c
    
    viewBottomLine.tag = 11
    
    if (v.viewWithTag(11) == nil) {
        
        v.addSubview(viewBottomLine)
    }
}

//let PARSE_APPLICATION_ID = "WCPmkDeR22mqK54k5HeHno09opDsIy2zQV2qSKax"
//let PARSE_CLIENT_KEY = "kVH8nuchIX0bNUQmcJenvul0xoO2wQ5sFWSbOSeP"

let CURRENT_USER = CCUser.current()

var IS_IPAD: Bool {
    
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad
}

var IS_IPHONE: Bool {
    
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone
}

var IS_RETINA: Bool {
    
    return UIScreen.main.scale >= 2.0
}


let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
let SCREEN_MAX_LENGTH = max(SCREEN_WIDTH, SCREEN_HEIGHT)
let SCREEN_MIN_LENGTH = min(SCREEN_WIDTH, SCREEN_HEIGHT)


var IS_IPHONE_4_OR_LESS: Bool {
    
    return IS_IPHONE && SCREEN_MAX_LENGTH < 568.0
}

var IS_IPHONE_5: Bool {
    
    return IS_IPHONE && SCREEN_MAX_LENGTH == 568.0
}

var IS_IPHONE_6: Bool {
    
    return IS_IPHONE && SCREEN_MAX_LENGTH == 667.0
}

var IS_IPHONE_6P: Bool {
    
    return IS_IPHONE && SCREEN_MAX_LENGTH == 736.0
}
