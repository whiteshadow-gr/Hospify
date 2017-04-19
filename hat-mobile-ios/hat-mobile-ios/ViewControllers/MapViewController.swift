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
import SwiftyJSON
import HatForIOS

// MARK: Class

/// The MapView to render the DataPoints
class MapViewController: UIViewController, MKMapViewDelegate, MapSettingsDelegate, DataSyncDelegate {

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
    
    /// An IBOutlet for handling the calendarImageView UIImageView
    @IBOutlet weak var calendarImageView: UIImageView!
    
    /// An IBOutlet for handling the hidden textField UITextField
    @IBOutlet weak var textField: UITextField!
    
    // MARK: - IBActions
    
    /**
     Shows a pop up with the available settings
     
     - parameter sender: The object that called this method
     */
    @IBAction func settingsButtonAction(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Settings", message: nil, preferredStyle: .actionSheet)
        
        let dataAction = UIAlertAction(title: "Show Data", style: .default, handler: {[weak self](alert: UIAlertAction) -> Void in
            
            self!.performSegue(withIdentifier: "dataSegue", sender: self!)
        })
        
        let settingsAction = UIAlertAction(title: "Location Settings", style: .default, handler: {[weak self](alert: UIAlertAction) -> Void in
            
            self!.performSegue(withIdentifier: "settingsSegue", sender: self!)
        })
        
        let logOutAction = UIAlertAction(title: "Log out", style: .default, handler: {[weak self](alert: UIAlertAction) -> Void in
            
            TabBarViewController.logoutUser(from: self!)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addActions(actions: [dataAction, settingsAction, logOutAction, cancelAction])
        alertController.addiPadSupport(barButtonItem: self.navigationItem.rightBarButtonItem!, sourceView: self.view)
        
        // present alert controller
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Variables
    
    /// The FBClusteringManager object constant
    private let clusteringManager = FBClusteringManager()
    /// The SyncDataHelper object constant
    private let syncDataHelper = SyncDataHelper()
    
    /// The timer DispatchSource object
    private var timer: DispatchSource!
    /// The timerSYnc DispatchSource object
    private var timerSync: DispatchSource!
    /// The selected enum category of Helper.TimePeriodSelected object
    private var timePeriodSelectedEnum: TimePeriodSelected = TimePeriodSelected.none
    /// The error message, if any
    private var lastErrorMessage: String = ""
    
    /// The uidatepicker used in toolbar
    private var datePicker: UIDatePicker? = nil
    
    /// The uidatepicker used in toolbar
    private var segmentControl: UISegmentedControl? = nil
    
    /// The start date to filter for points
    private var filterDataPointsFrom: Date? = nil
    /// The end date to filter for points
    private var filterDataPointsTo: Date? = nil
    
    // MARK: - Auto generated methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // view controller title
        self.title = "Location"
        
        // user HAT domain
        self.labelUserHATDomain.text = HATAccountService.TheUserHATDomain()
        
        // sync feedback delegate
        self.syncDataHelper.dataSyncDelegate = self
        
        // cancel all notifications
        UIApplication.shared.cancelAllLocalNotifications()
        
        // add notification observer for refreshUI
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
        
        let recogniser = UITapGestureRecognizer()
        recogniser.addTarget(self, action: #selector(self.selectDatesToViewLocations(gesture:)))
        self.calendarImageView.isUserInteractionEnabled = true
        self.calendarImageView.addGestureRecognizer(recogniser)
        
        datePicker = UIDatePicker(frame: CGRect(x: 0, y: 200, width: view.frame.width, height: 220))
        datePicker!.backgroundColor = .white
        
        // Set some of UIDatePicker properties
        datePicker!.timeZone = NSTimeZone.local
        datePicker!.backgroundColor = UIColor.white
        datePicker!.datePickerMode = .date
        
        // Add an event to call onDidChangeDate function when value is changed.
        datePicker!.addTarget(self, action: #selector(self.datePickerValueChanged(sender:)), for: .valueChanged)
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.donePickerButton(sender:)))
        doneButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.tealColor()], for: .normal)
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        spaceButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.tealColor()], for: .normal)
        
        self.segmentControl = UISegmentedControl(items: ["From", "To"])
        self.segmentControl!.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.tealColor()], for: .normal)
        self.segmentControl!.selectedSegmentIndex = 0
        self.segmentControl!.addTarget(self, action: #selector(segmentedControlDidChange(sender:)), for: UIControlEvents.valueChanged)
        self.segmentControl!.tintColor = .tealColor()
        
        let barButtonSegmentedControll = UIBarButtonItem(customView: segmentControl!)
        
        let spaceButton2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        spaceButton2.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.tealColor()], for: .normal)
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(self.cancelPickerButton(sender:)))
        cancelButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.tealColor()], for: .normal)

        toolBar.setItems([cancelButton, spaceButton, barButtonSegmentedControll, spaceButton2, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        textField.inputView = datePicker
        textField.inputAccessoryView = toolBar
    }
    
    deinit {
        
        self.mapView.removeFromSuperview()
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.showsUserLocation = false
        self.mapView.delegate = nil
        self.mapView = nil
        self.removeFromParentViewController()
        
        print("hello")
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Toolbar methods
    
    /**
     Called everytime the segmented control changes value. Saves the from and to date to filter the locations
     
     - parameter sender: The object that called this method
     */
    func segmentedControlDidChange(sender: UISegmentedControl) {
        
        if self.segmentControl!.selectedSegmentIndex == 0 {
            
            if self.filterDataPointsFrom != nil {
                
                self.datePicker!.setDate(self.filterDataPointsFrom!, animated: true)
            }
        } else {
            
            if self.filterDataPointsTo != nil {
                
                self.datePicker!.setDate(self.filterDataPointsTo!, animated: true)
            }
        }
    }
    
    /**
    The method executed when user taps the done button on the toolbar to filter the locations
     
     - parameter sender: The object that called this method
     */
    func donePickerButton(sender: UIBarButtonItem) {
        
        self.textField.resignFirstResponder()
        let userToken = HATAccountService.getUsersTokenFromKeychain()
        let userDomain = HATAccountService.TheUserHATDomain()
        
        let view = UIView()
        view.createFloatingView(frame: CGRect(x: self.view.frame.midX - 60, y: self.view.frame.midY - 15, width: 120, height: 30), color: .tealColor(), cornerRadius: 15)
        
        let label = UILabel().createLabel(frame: CGRect(x: 0, y: 0, width: 120, height: 30), text: "Getting locations...", textColor: .white, textAlignment: .center, font: UIFont(name: "OpenSans", size: 12))
        
        view.addSubview(label)
        
        self.view.addSubview(view)
        
        func getLocationsFromTable(tableID: NSNumber, renewedUserToken: String?) {
            
            func receivedLocations(json: [JSON], renewedUserToken: String?) {
                
                var array: [HATLocationsObject] = []
                
                for item in json {
                    
                    array.append(HATLocationsObject(dict: item.dictionaryValue))
                }
                
                if array.count == 0 {
                    
                    if self.filterDataPointsTo! > Date() {
                        
                        self.createClassicOKAlertWith(alertMessage: "There are no points for the selected dates, time travelling mode is deactivated", alertTitle: "No points found", okTitle: "OK", proceedCompletion: {})
                    }
                    self.createClassicOKAlertWith(alertMessage: "There are no points for the selected dates", alertTitle: "No points found", okTitle: "OK", proceedCompletion: {})
                }
                
                let pins = self.createAnnotationsFrom(objects: array)
                self.addPointsToMap(annottationArray: pins)
                
                // refresh user token
                if renewedUserToken != nil {
                    
                    _ = KeychainHelper.SetKeychainValue(key: "UserToken", value: renewedUserToken!)
                }
                
                view.removeFromSuperview()
            }
            
            func requestLocations(token: String, renewedUserToken: String?) {
                
                if self.filterDataPointsFrom != nil && self.filterDataPointsTo != nil {
                    
                    let starttime = FormatterHelper.formatDateToEpoch(date: self.filterDataPointsFrom!)
                    let endtime = FormatterHelper.formatDateToEpoch(date: self.filterDataPointsTo!)
                    let parameters: Dictionary<String, String> = ["starttime" : starttime, "endtime" : endtime, "limit" : "2000"]
                    
                    HATAccountService.getHatTableValues(token: token, userDomain: userDomain, tableID: tableID, parameters: parameters, successCallback: receivedLocations, errorCallback: {(error) in
                        
                        view.removeFromSuperview()
                        _ = CrashLoggerHelper.hatTableErrorLog(error: error)
                    })
                }
            }
            HATService.getApplicationTokenFor(serviceName: "locations", userDomain: userDomain, token: userToken, resource: "iphone", succesfulCallBack: requestLocations, failCallBack: {(error) in
                
                view.removeFromSuperview()
                _ = CrashLoggerHelper.JSONParsingErrorLog(error: error)
            })
        }
        
        HATAccountService.checkHatTableExists(userDomain: userDomain, tableName: "locations", sourceName: "iphone", authToken: userToken, successCallback: getLocationsFromTable, errorCallback: {(error) in
            
            view.removeFromSuperview()
            _ = CrashLoggerHelper.hatTableErrorLog(error: error)
        })
    }
    
    /**
     The method executed when user taps the cancel button on the toolbar to filter the locations
     
     - parameter sender: The object that called this method
     */
    func cancelPickerButton(sender: UIBarButtonItem) {
        
        self.textField.resignFirstResponder()
        self.filterDataPointsFrom = nil
        self.filterDataPointsTo = nil
    }
    
    // MARK: - Date picker method
    
    /**
     The method executed when the picker value changes to save the date to the correct value
     
     - parameter sender: The object that called this method
     */
    func datePickerValueChanged(sender: UIDatePicker) {
        
        if self.segmentControl!.selectedSegmentIndex == 0 {
            
            self.filterDataPointsFrom = self.datePicker!.date.startOfTheDay()
            if let endOfDay = self.datePicker!.date.endOfTheDay() {
                
                self.filterDataPointsTo = endOfDay
            }
        } else {
            
            if let endOfDay = self.datePicker!.date.endOfTheDay() {
                
                self.filterDataPointsTo = endOfDay
            }
        }
    }
    
    // MARK: - Hidden Text Field method
    
    /**
     Init from and to values
     
    - parameter sender: The object that called this method
     */
    func selectDatesToViewLocations(gesture: UITapGestureRecognizer) {
        
        self.textField.becomeFirstResponder()
        self.filterDataPointsFrom = Date().startOfTheDay()
        if let endOfDay = Date().endOfTheDay() {
            
            self.filterDataPointsTo = endOfDay
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if (segue.identifier == "settingsSegue") {
            
            // pass data to next view
            let settingsVC = segue.destination as! SettingsViewController
            
            settingsVC.mapSettingsDelegate = self
        }
    }
    
    // MARK: - Notification methods
    
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
        if let dataPoint: DataPoint = RealmHelper.getLastDataPoint() {
            
            // update on ui thread
            let addedOn: Date = dataPoint.dateAdded
            DispatchQueue.main.async(execute: {[unowned self] () -> Void in
                
                self.labelMostRecentInformation.text = NSLocalizedString("information_label", comment:  "info") + " " + addedOn.TimeAgoSinceDate()
            })
        }
        
        // sync date
        // last sync date
        DispatchQueue.main.async(execute: {[unowned self] () -> Void in
            
            if let dateSynced: Date = SyncDataHelper.getLastSuccessfulSyncDate() {
                
                self.labelLastSyncInformation.text = NSLocalizedString("information_synced_label", comment:  "info") + " " +
                     dateSynced.TimeAgoSinceDate() + " (" + String(SyncDataHelper.getSuccessfulSyncCount()) + " points)"
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
            self.createClassicOKAlertWith(alertMessage: lastErrorMessage, alertTitle: "Last Message", okTitle: "Ok", proceedCompletion: {})
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
        
        if self.textField.isFirstResponder {
            
            DispatchQueue.main.async { [unowned self] () -> Void in
                
                self.textField.resignFirstResponder()
                self.filterDataPointsFrom = nil
                self.filterDataPointsTo = nil
            }
        }
        
        OperationQueue().addOperation({ [weak self] () -> Void in
            
            if let wSelf = self {
                
                // calculate map size and scale
                let mapBoundsWidth = Double(wSelf.mapView.bounds.size.width)
                let mapRectWidth: Double = wSelf.mapView.visibleMapRect.size.width
                let scale: Double = mapBoundsWidth / mapRectWidth
                let annotationArray = wSelf.clusteringManager.clusteredAnnotations(withinMapRect: wSelf.mapView.visibleMapRect, zoomScale: scale)
                DispatchQueue.main.sync(execute: { [weak self] () -> Void in
                    
                    if let weakSelf = self {
                        
                        // display map
                        weakSelf.clusteringManager.display(annotations: annotationArray, onMapView: weakSelf.mapView)
                    }
                })
            }
        })
    }
    
    /**
     Called through map delegate to update its annotations
     
     - parameter mapView: the maoview object
     - parameter annotation: annotation to render
     
     - returns: An optional object of type MKAnnotationView
     */
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "Pin"
        if annotation.isKind(of: FBAnnotationCluster.self) {
            
            return FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId)
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
            DispatchQueue.main.async(execute: { [unowned self] () -> Void in
                
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
        
        UpdateLocations.shared.resumeLocationServices()
    }

    func onDataSyncFeedback(_ isSuccess: Bool, message: String) {
        
        // if not a success show message and update UI
        if !isSuccess {
            
            lastErrorMessage = message
            labelLastSyncInformation.textColor = .red
        } else {
            
            lastErrorMessage = ""
            labelLastSyncInformation.textColor = .white
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
        
        DispatchQueue.global().async { [weak self] () -> Void in
            
            if let weakSelf = self {
                
                var annottationArray: [FBAnnotation] = []
                
                //Get the results. Results list is optional
                if let results: Results <DataPoint> = RealmHelper.getResults(predicate) {
                    
                    for dataPoint: DataPoint in results {
                        
                        // add pin into results array
                        let pin = FBAnnotation()
                        pin.coordinate = CLLocationCoordinate2D(latitude: dataPoint.lat, longitude: dataPoint.lng)
                        annottationArray.append(pin)
                    }
                    
                    weakSelf.addPointsToMap(annottationArray: annottationArray)
                }
            }
        }
    }
    
    /**
     Adds the pins to the map
     
     - parameter annottationArray: The anottations, pins, to add to the map
     */
    private func addPointsToMap(annottationArray: [FBAnnotation]) {
        
        // we must set annotations to replace old ones
        self.clusteringManager.removeAll()
        self.clusteringManager.add(annotations: annottationArray)
        // force map changed to refresh the map and any pins
        self.mapView(self.mapView, regionDidChangeAnimated: true)
        
        DispatchQueue.main.async(execute: { [weak self] () -> Void in
            
            if(annottationArray.count > 0) {
                
                self!.fitMapViewToAnnotaionList(annottationArray)
            }
        })
    }
    
    /**
     Converts the LocationsObjects to pins to add in the map later
     
     - parameter objects: The LocationsObjects to convert to FBAnnotation, pins
     - returns: An array of FBAnnotation, pins
     */
    private func createAnnotationsFrom(objects: [HATLocationsObject]) -> [FBAnnotation] {
        
        var arrayToReturn: [FBAnnotation] = []
        
        for item in objects {
            
            let pin = FBAnnotation()
            pin.coordinate = CLLocationCoordinate2D(latitude: Double(item.data.locations.latitude)!, longitude: Double(item.data.locations.longitude)!)
            arrayToReturn.append(pin)
        }
        
        return arrayToReturn
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
}
