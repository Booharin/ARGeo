//
//  ViewController.swift
//  ARGeo
//
//  Created by Александр on 05.06.2018.
//  Copyright © 2018 Александр. All rights reserved.
//

import MapKit

class MainViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    fileprivate let locationManager = CLLocationManager()
    fileprivate var startedLoadingPOIs = false
    fileprivate var places = [Place]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingLocationManager()
    }
    
    @IBAction func showAR(_ sender: Any) {
    }
    
    func settingLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
    }
}

extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            let location = locations.last!
            print("Accuracy: \(location.horizontalAccuracy)")
            
            if location.horizontalAccuracy < 100 {
                manager.stopUpdatingLocation()
                let span = MKCoordinateSpan(latitudeDelta: 0.014, longitudeDelta: 0.014)
                let region = MKCoordinateRegion(center: location.coordinate, span: span)
                mapView.region = region
                
                if !startedLoadingPOIs {
                    startedLoadingPOIs = true

                    let loader = PlacesLoader()
                    loader.loadPOIS(location: location, radius: 1000) { placesDict, error in

                        if let dict = placesDict {
                            print(dict)
                        }
                    }
                }
            }
        }
    }
}

