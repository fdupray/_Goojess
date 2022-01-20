//
//  CCAnnotation.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//

import UIKit
import MapKit
import Foundation
import Parse

class CCAnnotation: MKPointAnnotation {
    
    var poster: CCUser!
    
    var name: String?
    var posterName: String?
    var address: String?
    //var coordinate: CLLocationCoordinate2D?
    
    var location: CCLocation?
    var geoPointNew: PFGeoPoint?
    
    var startDate: Date?
    var endDate: Date?
    
    
    init (name: String, address: String, coordinate: CLLocationCoordinate2D) {
        super.init()
        
        self.name = name
        self.address = address
        self.coordinate = coordinate
    }
    
    init (newLocation: CCLocation) {
        super.init()
        
        self.location = newLocation
    }
    
    
    /*- (NSString *)title {
     return _location.strLocationName;
     }
     
     - (NSString *)subtitle {
     return _location.strLocationDetail;
     }*/
}
