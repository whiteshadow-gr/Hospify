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
import FBAnnotationClusteringSwift
import RealmSwift

// MARK: Class

/// The MapView to render the DataPoints
class MapViewController: UIViewController, MKMapViewDelegate, MapSettingsDelegate, DataSyncDelegate, CLLocationManagerDelegate {
    
    // MARK: - IBOutlets

    /// An IBOutlet for handling the labelErrors UILabel
    @IBOutlet weak var labelErrors: UILabel!
    /// An IBOutlet for handling the labelUserHATDomain UILabel
    @IBOutlet weak var labelUserHATDomain: UILabel!
    /// An IBOutlet for handling the labelLastSyncInformation UILabel
    @IBOutlet weak var labelLastSyncInformation: UILabel!
    /// An IBOutlet for handling the labelMostRecentInformation UILabel
    @IBOutlet weak var labelMostRecentInformation: UILabel!
    
    /// An IBOutlet for handling the mapView MKMapView
    @IBOutlet weak var mapView: MKMapView!
    
    /// An IBOutlet for handling the buttonYesterday UIButton
    @IBOutlet weak var buttonYesterday: UIButton!
    /// An IBOutlet for handling the buttonToday UIButton
    @IBOutlet weak var buttonToday: UIButton!
    /// An IBOutlet for handling the buttonLastWeek UIButton
    @IBOutlet weak var buttonLastWeek: UIButton!
    
    // MARK: - Variables
    
    /// The FBClusteringManager object constant
    private let clusteringManager = FBClusteringManager()
    /// The SyncDataHelper object constant
    private let syncDataHelper = SyncDataHelper()
    /// The concurrentDataPointQueue object constant
    private let concurrentDataPointQueue = DispatchQueue(label: "com.hat.app.data-point-queue", attributes: DispatchQueue.Attributes.concurrent)
    
    /// The timer DispatchSource object
    private var timer: DispatchSource!
    /// The timerSYnc DispatchSource object
    private var timerSync: DispatchSource!
    /// The selected enum category of Helper.TimePeriodSelected object
    private var timePeriodSelectedEnum: TimePeriodSelected = TimePeriodSelected.none
    /// The error message, if any
    private var lastErrorMessage: String = ""
    
    /// Create and setup the LocationManager for handling the location updates
    private lazy var locationManager: CLLocationManager! = {
        
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = MapsHelper.GetUserPreferencesAccuracy()
        locationManager.distanceFilter = MapsHelper.GetUserPreferencesDistance()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestAlwaysAuthorization()
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = CLActivityType.other /* see https://developer.apple.com/reference/corelocation/clactivitytype */
        
        return locationManager
    }()
    
    // MARK: - Auto generated methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // view controller title
        super.title = "Location"

        // hide back button
        self.navigationItem.setHidesBackButton(true, animated: false);
        
        // user HAT domain
        self.labelUserHATDomain.text = HatAccountService.TheUserHATDomain()
        
        // sync feedback delegate
        self.syncDataHelper.dataSyncDelegate = self
    
        self.startTimer()
        
        // cancel all notifications
        UIApplication.shared.cancelAllLocalNotifications()
        
        // add notification observer for refreshUI
        NotificationCenter.default.addObserver( self, selector: #selector(refreshUI),
            name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver( self, selector: #selector(goToSettings),
                                                name: NSNotification.Name("goToSettings"), object: nil)
        
        // add gesture recognizers to today button
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.LongPressOnToday))
        buttonToday.addGestureRecognizer(longGesture)
        buttonTodayTouchUp(UIBarButtonItem())
        
        // add gesture recognizers to last sync label
        let labelLastSyncInformationTap = UITapGestureRecognizer(target: self, action: #selector(MapViewController.LastSyncLabelTap))
        labelLastSyncInformation.addGestureRecognizer(labelLastSyncInformationTap)
        labelLastSyncInformation.isUserInteractionEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if (segue.identifier == "SettingsSequeID") {
            
            // pass data to next view
            let settingsVC = segue.destination as! SettingsViewController
            
            settingsVC.mapSettingsDelegate = self
        }
    }
    
    // MARK: - Notification methods
    
    /**
     Triggers a refresh in UI drawing the points on the map
     */
    @objc private func refreshUI() {
        
        self.mapView(self.mapView, regionDidChangeAnimated: true)
    }
    
    /**
     Presents the settings view controller
     */
    @objc private func goToSettings() {
        
        self.performSegue(withIdentifier: "SettingsSequeID", sender: self)
    }
    
    // MARK: - Show last data point time
    
    /**
     Display the last entry from the map DataPoint
     */
    private func displayLastDataPointTime() -> Void {
        
        // get last data point
        if let dataPoint: DataPoint = RealmHelper.GetLastDataPoint() {
            
            // update on ui thread
            let addedOn: Date = dataPoint.dateAdded
            DispatchQueue.main.async(execute: {[unowned self]
                () -> Void in
                
                self.labelMostRecentInformation.text = NSLocalizedString("information_label", comment:  "info") + " " + addedOn.TimeAgoSinceDate()
            })
        }
        
        // sync date
        // last sync date
        DispatchQueue.main.async(execute: {[unowned self]
            () -> Void in
            
            if let dateSynced: Date = SyncDataHelper.getLastSuccessfulSyncDate() {
                
                self.labelLastSyncInformation.text = NSLocalizedString("information_synced_label", comment:  "info") + " " +
                     dateSynced.TimeAgoSinceDate() +
                    " (" +
                    String(SyncDataHelper.getSuccessfulSyncCount()) +
                " points)"
            }
        })
    }
    
    // MARK: - Tap gesture recognizers
    
    /**
     Fired if user holds on lastSync label
     
     - parameter sender: The UITapGestureRecognizer that called this method
     */
    @objc private func LastSyncLabelTap(_ sender: UITapGestureRecognizer) -> Void {
        
        if !lastErrorMessage.isEmpty {
            
            // create alert
            self.createClassicOKAlertWith(alertMessage: lastErrorMessage, alertTitle: "Last Message", okTitle: "Ok", proceedCompletion: {() -> Void in return})
        }
    }
    
    /**
     Fired if user holds on Today button
     
     - parameter sender: The UITapGestureRecognizer that called this method
     */
    @objc private func LongPressOnToday(_ sender: UILongPressGestureRecognizer) -> Void {
        
        if (sender.state == UIGestureRecognizerState.ended) {
            
           _ = self.syncDataHelper.CheckNextBlockToSync()
        }
    }
    
    // MARK: - IBActions
    
    /**
     Today tap event
     Create predicte for 7 days for now
     
     - parameter sender: The UIBarButtonItem that called this method
     */
    @IBAction func buttonLastWeekTouchUp(_ sender: UIBarButtonItem) {
        
        // filter data
        self.timePeriodSelectedEnum = TimePeriodSelected.lastWeek
        
        let lastWeek = Date().addingTimeInterval(FutureTimeInterval.init(days: Double(7), timeType: TimeType.past).interval)
        let predicate = NSPredicate(format: "dateAdded >= %@", lastWeek as CVarArg)
        self.fetchAndClusterPoints(predicate)
    }
    
    /**
     Today tap event
     Create predicte for today
     
     - parameter sender: The UIBarButtonItem that called this method
     */
    @IBAction func buttonTodayTouchUp(_ sender: UIBarButtonItem) {
        
        // filter data
        self.timePeriodSelectedEnum = TimePeriodSelected.today
        
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let predicate = NSPredicate(format: "dateAdded >= %@", startOfToday as CVarArg)
        self.fetchAndClusterPoints(predicate)
    }
    
    /**
     Today tap event
     Create predicte for yesterday *only*
     
     - parameter sender: The UIBarButtonItem that called this method
     */
    @IBAction func buttonYesterdayTouchUp(_ sender: UIBarButtonItem) {
        
        // filter data
        self.timePeriodSelectedEnum = TimePeriodSelected.yesterday
        
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let yesteday = startOfToday.addingTimeInterval(FutureTimeInterval.init(days: Double(1), timeType: TimeType.past).interval) // remove 24hrs
        let predicate = NSPredicate(format: "dateAdded >= %@ and dateAdded <= %@", yesteday as CVarArg, startOfToday as CVarArg)
        self.fetchAndClusterPoints(predicate)
    }
    
    // MARK: - MapView delegate methods
    
    /**
     Called when the map region changes...pan..zoom, etc
     
     - parameter mapView: the mapview
     - parameter animated: animated
     */
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        OperationQueue().addOperation({
            
            // calculate map size and scale
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            let mapRectWidth: Double = self.mapView.visibleMapRect.size.width
            let scale: Double = mapBoundsWidth / mapRectWidth
            let annotationArray = self.clusteringManager.clusteredAnnotations(withinMapRect: self.mapView.visibleMapRect, zoomScale: scale)
            DispatchQueue.main.sync(execute: { [unowned self]
                () -> Void in
                
                // display map
                self.clusteringManager.display(annotations: annotationArray, onMapView: self.mapView)
            })
        })
    }
    
    /**
     Called through map delegate to update its annotations
     
     - parameter mapView: the maoview object
     - parameter annotation: annotation to render
     
     - returns: An optional object of type MKAnnotationView
     */
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var reuseId = "Pin"
        if annotation.isKind(of: FBAnnotationCluster.self) {
            
            reuseId = "Cluster"
            var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId)
            return clusterView
        } else {
            
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .green
            return pinView
        }
    }
    
    // MARK: - Protocol methods
    
    func onUpdateCount(_ count: Int) {
        
        displayLastDataPointTime()
        
        // only update if today
        if self.timePeriodSelectedEnum == TimePeriodSelected.today {
            
            // refresh map UI too on changed
            DispatchQueue.main.async(execute: { [unowned self]
                () -> Void in
                
                // refresh map UI too
                self.buttonToday.sendActions(for: .touchUpInside)
            })
        }
    }
    
    func onUpdateError(_ error: String) {
        
        // used for debug only
        //self.labelErrors.text = error
    }
    
    func onChanged() {
        
        // restart LocationManager and apply changes
        
        // Location stop
        self.locationManager.stopUpdatingLocation()
        // apply changes
        self.locationManager.desiredAccuracy = MapsHelper.GetUserPreferencesAccuracy()
        self.locationManager.distanceFilter = MapsHelper.GetUserPreferencesDistance()
        
        if let result = KeychainHelper.GetKeychainValue(key: "trackDevice") {
            
            if result == "true" {
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.locationManager.startUpdatingLocation()
            }
        }
    }

    func onDataSyncFeedback(_ isSuccess: Bool, message: String) {
        
        // if not a success show message and update UI
        if !isSuccess {
            
            lastErrorMessage = message;
            labelLastSyncInformation.textColor = UIColor.red;
        } else {
            
            lastErrorMessage = "";
            labelLastSyncInformation.textColor = UIColor.white;
        }
    }
    
    // MARK: - Add annotations on map
    
    /**
     Fetches and adds the annotations to the map view/
     Takes a predicate, e.g. day, yesterday, week 
     Fetch the DataPoints in a background thread and update the UI once complete
     
     - parameter predicate: The predicate to filter the data points with
     */
    private func fetchAndClusterPoints(_ predicate: NSPredicate) -> Void {
        
        concurrentDataPointQueue.async(flags: .barrier, execute: { // 1
            
            var annottationArray: [FBAnnotation] = []
            
            //Get the results. Results list is optional
            if let results: Results <DataPoint> = RealmHelper.GetResults(predicate) {
                
                for dataPoint: DataPoint in results {
                    
                    // add pin into results array
                    let pin = FBAnnotation()
                    pin.coordinate = CLLocationCoordinate2D(latitude: dataPoint.lat, longitude: dataPoint.lng)
                    annottationArray.append(pin)
                }
                // we must set annotations to replace old ones
                self.clusteringManager.removeAll()
                self.clusteringManager.add(annotations: annottationArray)
                // force map changed to refresh the map and any pins
                self.mapView(self.mapView, regionDidChangeAnimated: true)
                
                DispatchQueue.main.async(execute: { [unowned self]
                    () -> Void in
                    
                    if(annottationArray.count > 0) {
                        
                        self.fitMapViewToAnnotaionList(annottationArray)
                    }
                })
            }
        })
    }
    
    /**
     Updates map view with the annotations provided
     
     - parameter annotations: The annotations to add on the map in an array of FBAnnotation
     */
    private func fitMapViewToAnnotaionList(_ annotations: [FBAnnotation]) -> Void {
        
        // calculate map padding and zoom
        let mapEdgePadding = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        var zoomRect: MKMapRect = MKMapRectNull
        
        // create a point for each annotation
        for index in 0..<annotations.count {
            
            let annotation = annotations[index]
            let aPoint: MKMapPoint = MKMapPointForCoordinate(annotation.coordinate)
            let rect: MKMapRect = MKMapRectMake(aPoint.x, aPoint.y, 0.1, 0.1)
            
            if MKMapRectIsNull(zoomRect) {
                
                zoomRect = rect
            } else {
                
                zoomRect = MKMapRectUnion(zoomRect, rect)
            }
        }
        
        // focus map on the added points
        mapView.setVisibleMapRect(zoomRect, edgePadding: mapEdgePadding, animated: true)
    }
    
    // MARK: - Handle timers
    
    /**
     Times for syncing data with HAT and timer to update UI to reflect any changes
     */
    private func startTimer() {
        
        let queue = DispatchQueue(label: "com.hat.app.timer", attributes: [])
        
        // user info
        timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: queue) /*Migrator FIXME: Use DispatchSourceTimer to avoid the cast*/ as! DispatchSource
        timer.scheduleRepeating(deadline: DispatchTime.now(),
                                interval: .seconds(10),
                                leeway: .seconds(1)
        )
        timer.setEventHandler {
            // update UI
            self.displayLastDataPointTime()
        }
        timer.resume()
        
        // sync
        timerSync = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: queue) /*Migrator FIXME: Use DispatchSourceTimer to avoid the cast*/ as! DispatchSource
       // timerSync.scheduleRepeating(start: DispatchTime.now(), interval: Constants.DataSync.DataSyncPeriod * NSEC_PER_SEC, leeway: 1 * NSEC_PER_SEC) // every 10 seconds, with leeway of 1 second
        timerSync.scheduleRepeating(deadline: DispatchTime.now(),
                                interval: .seconds(10),
                                leeway: .seconds(1)
        )
        timerSync.setEventHandler {
            
            // sync with HAT
            DispatchQueue.main.async(execute: { [unowned self]
                () -> Void in
                
                _ = self.syncDataHelper.CheckNextBlockToSync()
            })
        }
        timerSync.resume()
    }
    
    /**
     Stop any timers
     */
    private func stopTimer() {
        
        if timer != nil {
            
            timer.cancel()
            timer = nil
        }
        
        if timerSync != nil {
            
            timerSync.cancel()
            timerSync = nil
        }
    }
}
