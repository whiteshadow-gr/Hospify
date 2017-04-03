/**
 * Copyright (C) 2017 HAT Data Exchange Ltd
 *
 * SPDX-License-Identifier: MPL2
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/
 */

import MapKit

// MARK: Class

class CheckInMapViewController: UIViewController, UpdateLocationsDelegate, UISearchBarDelegate, MKMapViewDelegate {
    
    // MARK: - Variables
    
    let locationHelper = UpdateLocations.shared

    var resultSearchController: UISearchController? = nil
    
    // MARK: - IBOutlets

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - IBActions
    
    /**
     <#Function Details#>
     
     - parameter <#Parameter#>: <#Parameter description#>
     */
    @IBAction func doneButtonAction(_ sender: Any) {
        
        
    }
    
    /**
     <#Function Details#>
     
     - parameter <#Parameter#>: <#Parameter description#>
     */
    @IBAction func focusOnUsersLocation(_ sender: Any) {
        
        self.mapView.setCenter((self.locationHelper.locationManager.location?.coordinate)!, animated: true)
    }
    
    // MARK: - ViewController methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.mapView.showsUserLocation = true
        self.locationHelper.locationDelegate = self
        self.locationHelper.requestLocation()
        
        resultSearchController = UISearchController(searchResultsController: nil)
        
        self.searchBar = resultSearchController?.searchBar
        self.searchBar.delegate = self

        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        let rect = MKCoordinateRegionMakeWithDistance((self.locationHelper.locationManager.location?.coordinate)!, 500, 500)
        self.mapView.setRegion(rect, animated: true)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        if self.mapView.annotations.count != 0 {
            
            for annotation in self.mapView.annotations {
                
                self.mapView.removeAnnotation(annotation)
            }
        }
        
        //2
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearchRequest.region = self.mapView.region
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil {
                
                self.createClassicOKAlertWith(alertMessage: "Place Not Found", alertTitle: "", okTitle: "OK", proceedCompletion: {})
                return
            }
            
            //3
            
            for mapItem in (localSearchResponse?.mapItems)! {
                
                let pointAnnotation = MKPointAnnotation()
                pointAnnotation.title = mapItem.placemark.title
                pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: mapItem.placemark.coordinate.latitude, longitude: mapItem.placemark.coordinate.longitude)
                
                let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
                self.mapView.centerCoordinate = pointAnnotation.coordinate
                self.mapView.addAnnotation(pinAnnotationView.annotation!)
            }
        }
    }
    
    // MARK: - Protocol's function
    
    func updateLocations(locations: [CLLocation]) {
        
        if locations.count > 0 {
            
            let lastLocation = locations.last
            
            CLGeocoder().reverseGeocodeLocation(lastLocation!, completionHandler: {(placemarks, error) -> Void in
                print(lastLocation!)
                
                if error != nil {
                    
                    print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                    return
                }
                
                if (placemarks?.count)! > 0 {
                    
//                    let pm = placemarks?[0]
//                    print(placemarks)
                } else {
                    
                    print("Problem with the data received from geocoder")
                }
            })
        }
    }

}
