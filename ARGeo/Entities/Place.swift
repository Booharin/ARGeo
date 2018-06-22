//
//  Place.swift
//  ARGeo
//
//  Created by Александр on 05.06.2018.
//  Copyright © 2018 Александр. All rights reserved.
//

import CoreLocation

class Place: ARAnnotation {
    let reference: String
    let placeName: String
    let address: String
    var phoneNumber: String?
    var website: String?
    
    var infoText: String {
        get {
            var info = "Address: \(address)"
            
            if phoneNumber != nil {
                info += "\nPhone: \(phoneNumber!)"
            }
            
            if website != nil {
                info += "\nweb: \(website!)"
            }
            return info
        }
    }
    
    init(location: CLLocation, reference: String, name: String, address: String) {
        placeName = name
        self.reference = reference
        self.address = address
        
        super.init()
        
        self.location = location
    }
    
    override var description: String {
        return placeName
    }
}
