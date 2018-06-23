//
//  PlaceAnnotation.swift
//  ARGeo
//
//  Created by Александр on 23.06.2018.
//  Copyright © 2018 Александр. All rights reserved.
//
import MapKit

class PlaceAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    
    init(location: CLLocationCoordinate2D, title: String) {
        self.coordinate = location
        self.title = title
        
        super.init()
    }
}
