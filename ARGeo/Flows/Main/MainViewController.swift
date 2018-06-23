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
    fileprivate var arViewController: ARViewController!
    
    @IBOutlet weak var arButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingLocationManager()
        arButton.setTitle("AR", for: .normal)
    }
    
    @IBAction func showAR(_ sender: Any) {
        arViewController = ARViewController()
        arViewController.dataSource = self
        arViewController.maxVisibleAnnotations = 30
        arViewController.headingSmoothingFactor = 0.05
        arViewController.setAnnotations(places)
        
        self.present(arViewController, animated: true, completion: nil)
    }
    
    func settingLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        
        mapView.showsUserLocation = true
    }
}

extension MainViewController: ARDataSource {
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        let annotationView = AnnotationView()
        annotationView.annotation = viewForAnnotation
        annotationView.delegate = self
        annotationView.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        
        return annotationView
    }
}

extension MainViewController: AnnotationViewDelegate {
    func didTouch(annotationView: AnnotationView) {
        if let annotation = annotationView.annotation as? Place {
            let placesLoader = PlacesLoader()
            placesLoader.loadDetailInformation(forPlace: annotation) { resultDict, error in
                if let infoDict = resultDict?.object(forKey: "result") as? NSDictionary {
                    annotation.phoneNumber = infoDict.object(forKey: "formatted_phone_number") as? String
                    annotation.website = infoDict.object(forKey: "website") as? String
                    self.showInfoView(forPlace: annotation)
                }
            }
        }
    }
    func showInfoView(forPlace place: Place) {
        let alert = UIAlertController(title: place.placeName , message: place.infoText, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        arViewController.present(alert, animated: true, completion: nil)
    }
}

extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            let location = locations.last!
            print("Accuracy: \(location.horizontalAccuracy)")
            
            if location.horizontalAccuracy < 100 {
                manager.stopUpdatingLocation()
                
                let currentRadius: CLLocationDistance = 1000
                let currentRegion = MKCoordinateRegionMakeWithDistance((location.coordinate),
                                                                       currentRadius * 2.0,
                                                                       currentRadius * 2.0)
                mapView.setRegion(currentRegion, animated: true)
                
                if !startedLoadingPOIs {
                    startedLoadingPOIs = true

                    let loader = PlacesLoader()
                    loader.loadPOIS(location: location, radius: 1000) { placesDict, error in
                        //print(placesDict)
                        if let dict = placesDict {
                            guard let placesArray = dict.object(forKey: "results") as?
                                [NSDictionary]  else { return }
                            
                            for placeDict in placesArray {
                                let latitude = placeDict
                                    .value(forKeyPath: "geometry.location.lat") as! CLLocationDegrees
                                let longitude = placeDict
                                    .value(forKeyPath: "geometry.location.lng") as! CLLocationDegrees
                                
                                let reference = placeDict
                                    .object(forKey: "reference") as! String
                                let name = placeDict.object(forKey: "name") as! String
                                let address = placeDict.object(forKey: "vicinity") as! String
                                let location = CLLocation(latitude: latitude,
                                                         longitude: longitude)
                                
                                let place = Place(location: location,
                                                 reference: reference,
                                                      name: name,
                                                   address: address)
                                
                                self.places.append(place)
                                let annotation = PlaceAnnotation(location: place.location!.coordinate,
                                                                    title: place.placeName)
                                DispatchQueue.main.async {
                                    self.mapView.addAnnotation(annotation)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

