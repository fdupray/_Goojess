//
//  CityInColor-BridgingHeader.h
//  City in Colors
//
//  Created by Frederick Dupray on 13/02/16.
//  Copyright © 2016 Carman. All rights reserved.
//

#ifndef CityInColor_BridgingHeader_h
#define CityInColor_BridgingHeader_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SVProgressHUD.h"
#import "SVIndefiniteAnimatedView.h"
#import "SVRadialGradientLayer.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <Parse/PFObject+Subclass.h>
#import "TOCropViewController.h"
#import "JTSImageViewController.h"
#import "ACTReporter.h"

// http://stackoverflow.com/questions/32312378/swift-uidevice-currentdevice-not-compiling

static UIDevice* Device() { return [UIDevice currentDevice]; }

#endif /* CityInColor_BridgingHeader_h */
