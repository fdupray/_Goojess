//
//  Goojess_BridgingHeader.h
//  Goojess
//
//  Created by Frederick Dupray on 21/02/17.
//  Copyright © 2017 Simon Blomqvist. All rights reserved.
//

#ifndef Goojess_BridgingHeader_h
#define Goojess_BridgingHeader_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
//#import "SVProgressHUD.h"
//#import "SVIndefiniteAnimatedView.h"
//#import "SVRadialGradientLayer.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <Parse/PFObject+Subclass.h>
//#import "TOCropViewController.h"
#import "JTSImageViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

// http://stackoverflow.com/questions/32312378/swift-uidevice-currentdevice-not-compiling

static UIDevice* Device() { return [UIDevice currentDevice]; }

#endif /* Goojess_BridgingHeader_h */
