/** Copyright (C) 2016 HAT Data Exchange Ltd
 * SPDX-License-Identifier: AGPL-3.0
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * RumpelLite is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License
 * as published by the Free Software Foundation, version 3 of
 * the License.
 *
 * RumpelLite is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See
 * the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General
 * Public License along with this program. If not, see
 * <http://www.gnu.org/licenses/>.
 */

import MapKit
import FBAnnotationClusteringSwift
import RealmSwift
import Toaster
import SwiftyJSON

/// The MapView to render the DataPoints
class MapViewController: BaseLocationViewController, MKMapViewDelegate, UpdateCountDelegate, MapSettingsDelegate, DataSyncDelegate, UINavigationBarDelegate {

    @IBOutlet weak var labelMostRecentInformation: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var buttonYesterday: UIButton!
    @IBOutlet weak var buttonToday: UIButton!
    @IBOutlet weak var buttonLastWeek: UIButton!
    @IBOutlet weak var labelErrors: UILabel!
    @IBOutlet weak var labelUserHATDomain: UILabel!
    @IBOutlet weak var labelLastSyncInformation: UILabel!
    
    let clusteringManager = FBClusteringManager()
    let syncDataHelper = SyncDataHelper()
    let concurrentDataPointQueue = DispatchQueue(label: "com.hat.app.data-point-queue", attributes: DispatchQueue.Attributes.concurrent)
    var timer: DispatchSource!
    var timerSync: DispatchSource!
    var timePeriodSelectedEnum: Helper.TimePeriodSelected = Helper.TimePeriodSelected.none
    var lastErrorMessage:String = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // view controller title
        super.title = "Location"

        // UI asset labels
        buttonYesterday.setTitle(NSLocalizedString("yesterday_label", comment:  "yesterday"), for: UIControlState())
        buttonToday.setTitle(NSLocalizedString("today_label", comment:  "today"), for: UIControlState())
        buttonLastWeek.setTitle(NSLocalizedString("lastweek_label", comment:  "last week"), for: UIControlState())

        // hide back button
        self.navigationItem.setHidesBackButton(true, animated:false);
        
        // user HAT domain
        self.labelUserHATDomain.text = Helper.TheUserHATDomain()
            
        // Set map view delegate
        self.mapView.delegate = self
        
        // begin tracking
        self.beginLocationTracking()

        // the count delegate
        self.updateCountDelegate = self
        
        // sync feedback delegate
        self.syncDataHelper.dataSyncDelegate = self
    
        self.startAnyTimers()
        
        // cancel all notifications
        UIApplication.shared.cancelAllLocalNotifications()

        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.LongPressOnToday)) //Long function will call when user long press on button.
        buttonToday.addGestureRecognizer(longGesture)
        
        // notifiy if entered background mode
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterBackgroundNotification),
            name: NSNotification.Name.UIApplicationDidEnterBackground,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActiveNotification),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshUI),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
        
        // label click
        labelLastSyncInformation.isUserInteractionEnabled = true
        let labelLastSyncInformationTap = UITapGestureRecognizer(target: self, action: #selector(MapViewController.LastSyncLabelTap))
        labelLastSyncInformation.addGestureRecognizer(labelLastSyncInformationTap)
        
        buttonTodayTouchUp(UIBarButtonItem())
        
    }
    
    func refreshUI() {
        
        self.mapView(self.mapView, regionDidChangeAnimated: true)
    }
    
    func LastSyncLabelTap(_ sender: UITapGestureRecognizer) -> Void {
        
        if !lastErrorMessage.isEmpty {
            
            let alert = UIAlertController(title: "Last Message", message: lastErrorMessage, preferredStyle: .alert)
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok_label", comment:  "ok"), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /**
     Fired if user holds on Today button
     
     - parameter sender: <#sender description#>
     */
    func LongPressOnToday(_ sender: UILongPressGestureRecognizer) -> Void {
        
        if (sender.state == UIGestureRecognizerState.ended) {
            
           _ = self.syncDataHelper.CheckNextBlockToSync()
        } else if (sender.state == UIGestureRecognizerState.began) {
            
            // do ended
        }
    }
    
    /// Utility Queie var
    var GlobalMainQueue: DispatchQueue {
        
        return DispatchQueue.main
    }
    
    /**
     Today tap event
     Create predicte for 7 days for now
     
     - parameter sender: UIBarButtonItem
     */
    @IBAction func buttonLastWeekTouchUp(_ sender: UIBarButtonItem) {
        
        self.timePeriodSelectedEnum = Helper.TimePeriodSelected.lastWeek
        
        let lastWeek = Date().addingTimeInterval(Helper.FutureTimeInterval.init(days: Double(7), timeType: Helper.TimeType.past).interval)
        let predicate = NSPredicate(format: "dateAdded >= %@", lastWeek as CVarArg)
        self.fetchAndClusterPoints(predicate)
    }
    
    /**
     Today tap event
     Create predicte for today
     
     - parameter sender: UIBarButtonItem
     */
    @IBAction func buttonTodayTouchUp(_ sender: UIBarButtonItem) {
        
        self.timePeriodSelectedEnum = Helper.TimePeriodSelected.today
        
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let predicate = NSPredicate(format: "dateAdded >= %@", startOfToday as CVarArg)
        self.fetchAndClusterPoints(predicate)
    }
    
    /**
     Today tap event
     Create predicte for yesterdasy *only*
     
     - parameter sender: <#sender description#>
     */
    @IBAction func buttonYesterdayTouchUp(_ sender: UIBarButtonItem) {
        
        
        self.timePeriodSelectedEnum = Helper.TimePeriodSelected.yesyerday
        
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let yesteday = startOfToday.addingTimeInterval(Helper.FutureTimeInterval.init(days: Double(1), timeType: Helper.TimeType.past).interval) // remove 24hrs
        let predicate = NSPredicate(format: "dateAdded >= %@ and dateAdded <= %@", yesteday as CVarArg, startOfToday as CVarArg)
        self.fetchAndClusterPoints(predicate)
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /**
     Called when the map region changes...pan..zoom, etc
     
     - parameter mapView:  the mapview
     - parameter animated: animated
     */
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        OperationQueue().addOperation({
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            let mapRectWidth:Double = self.mapView.visibleMapRect.size.width
            let scale:Double = mapBoundsWidth / mapRectWidth
            let annotationArray = self.clusteringManager.clusteredAnnotations(withinMapRect: self.mapView.visibleMapRect, zoomScale: scale)
            DispatchQueue.main.sync(execute: {
                self.clusteringManager.display(annotations: annotationArray, onMapView: self.mapView)
            })
        })
    }
    
    /**
     Called through map delegate to update its annotations
     
     - parameter mapView:    the maoview object
     - parameter annotation: annotation to render
     
     - returns: <#return value description#>
     */
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var reuseId = ""
        if annotation.isKind(of: FBAnnotationCluster.self) {
            
            reuseId = "Cluster"
            var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId)
            return clusterView
        } else {
            
            reuseId = "Pin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .green
            return pinView
        }
    }
    
    /**
     UpdateCountDelegate method
     
     - parameter count: the current point count
     */
    func onUpdateCount(_ count: Int) {
        
        displayLastDataPointTime()
        
        // only update if today
        if self.timePeriodSelectedEnum == Helper.TimePeriodSelected.today {
            // refresh map UI too on changed
            DispatchQueue.main.async(execute: {
                
                // refresh map UI too
                self.buttonToday.sendActions(for: .touchUpInside)
            })
        }
    }
    
    func onUpdateError(_ error: String) {
        
        // used for debug only
        //self.labelErrors.text = error
    }
    
    /**
     MapSettingsDelegate
     */
    func onChanged() {
        
        // restart LocationManager and apply changes
        
        //Location
        // stop
        self.locationManager.stopUpdatingLocation()
        // apply changes
        self.locationManager.desiredAccuracy = Helper.GetUserPreferencesAccuracy()
        self.locationManager.distanceFilter = Helper.GetUserPreferencesDistance()
        // begin again
        self.beginLocationTracking()
    }

    /**
     DataSyncDelegate
     */
    func onDataSyncFeedback(_ isSuccess: Bool, message: String) {
        
        if !isSuccess {
            
            lastErrorMessage = message;
            labelLastSyncInformation.textColor = UIColor.red;
        } else {
            
            lastErrorMessage = "";
            labelLastSyncInformation.textColor = UIColor.white;
        }
    }
    
    /**
     Fetches and adds the annotations to the map view/
     Takes a predicate, e.g. day, yesterday, week 
     Fetch the DataPoints in a background thread and update the UI once complete
     
     - parameter predicate: <#predicate description#>
     */
    func fetchAndClusterPoints(_ predicate: NSPredicate) -> Void {
        
        concurrentDataPointQueue.async(flags: .barrier, execute: { // 1
            
            var annottationArray:[FBAnnotation] = []
            //var datePointCount:Int = 0;
            
            //Get the results. Results list is optional
            if let results:Results<DataPoint> = RealmHelper.GetResults(predicate) {
                
                //datePointCount = results.count;
                for dataPoint:DataPoint in results {
                    
                    let pin = FBAnnotation()
                    pin.coordinate = CLLocationCoordinate2D(latitude: dataPoint.lat, longitude: dataPoint.lng)
                    annottationArray.append(pin)
                }
                // we must set annotations to replace old ones
                //self.clusteringManager.setAnnotations(annottationArray)
                self.clusteringManager.add(annotations: annottationArray)
                // force map changed to refresh the map and any pins
                self.mapView(self.mapView, regionDidChangeAnimated: true)
                
                DispatchQueue.main.async(execute: {
                    
                    //self.mapView.showAnnotations(annottationArray, animated: true)
                    if(annottationArray.count > 0) {
                        
                        self.fitMapViewToAnnotaionList(annottationArray)
                    }
                })
            }
    
            (self.GlobalMainQueue).async { // 3
            }
        })
    }
    
    func fitMapViewToAnnotaionList(_ annotations: [FBAnnotation]) -> Void {
        
        let mapEdgePadding = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        var zoomRect:MKMapRect = MKMapRectNull
        
        for index in 0..<annotations.count {
            
            let annotation = annotations[index]
            let aPoint:MKMapPoint = MKMapPointForCoordinate(annotation.coordinate)
            let rect:MKMapRect = MKMapRectMake(aPoint.x, aPoint.y, 0.1, 0.1)
            
            if MKMapRectIsNull(zoomRect) {
                
                zoomRect = rect
            } else {
                
                zoomRect = MKMapRectUnion(zoomRect, rect)
            }
        }
        
        mapView.setVisibleMapRect(zoomRect, edgePadding: mapEdgePadding, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if (segue.identifier == "SettingsSequeID") {
            
            // pass data to next view
            let settingsVC = segue.destination as! SettingsViewController
            
            settingsVC.mapSettingsDelegate = self
        }
    }
    
    /**
     Display the last entry from the map DataPoint
     */
    func displayLastDataPointTime() -> Void {
        
        if let dataPoint:DataPoint = RealmHelper.GetLastDataPoint() {
            
            // update on ui thread
            let addedOn:Date = dataPoint.dateAdded as Date
            DispatchQueue.main.async(execute: {
                
                    self.labelMostRecentInformation.text = NSLocalizedString("information_label", comment:  "info") + " " + Helper.TimeAgoSinceDate(addedOn)
                    })
        }
        
        // sync date
        // last sync date
        DispatchQueue.main.async(execute: {
            if let dateSynced:Date = self.getLastSuccessfulSyncDate() as Date? {

                self.labelLastSyncInformation.text = NSLocalizedString("information_synced_label", comment:  "info") + " " +
                    Helper.TimeAgoSinceDate(dateSynced) +
                    " (" +
                    String(self.getSuccessfulSyncCount()) +
                    " points)"
                
            }
        })
    }
    
    /**
     Times for syncing data with HAT and timer to update UI to reflect any changes
     */
    func startTimer() {
        
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
            DispatchQueue.main.async(execute: {
                _ = self.syncDataHelper.CheckNextBlockToSync()
            })
        }
        timerSync.resume()
    }
    
    /**
     Stop any timers
     */
    func stopTimer() {
        
        if timer != nil {
            
            timer.cancel()
            timer = nil
        }
        
        if timerSync != nil {
            
            timerSync.cancel()
            timerSync = nil
        }
    }
    
    func stopAnyTimers() -> Void {
        
        //
        self.stopTimer()
    }
    
    func startAnyTimers() -> Void {
        
        //
        self.startTimer()
    }
}
