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
import SwiftSpinner
import JLToast
import SwiftyJSON

/*
    The MapView to render the DataPoints
 
 */
class MapViewController: BaseLocationViewController, MKMapViewDelegate, UpdateCountDelegate, MapSettingsDelegate, DataSyncDelegate {

    @IBOutlet weak var labelMostRecentInformation: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var buttonYesterday: UIButton!
    @IBOutlet weak var buttonToday: UIButton!
    @IBOutlet weak var buttonData: UIBarButtonItem!
    @IBOutlet weak var buttonLastWeek: UIButton!
    @IBOutlet weak var buttonLogout: UIBarButtonItem!
    @IBOutlet weak var labelErrors: UILabel!
    @IBOutlet weak var labelUserHATDomain: UILabel!
    @IBOutlet weak var labelLastSyncInformation: UILabel!
    
    let clusteringManager = FBClusteringManager()
    let syncDataHelper = SyncDataHelper()
    let concurrentDataPointQueue = dispatch_queue_create("com.hat.app.data-point-queue", DISPATCH_QUEUE_CONCURRENT)
    var timer: dispatch_source_t!
    var timerSync: dispatch_source_t!
    var timePeriodSelectedEnum: Helper.TimePeriodSelected = Helper.TimePeriodSelected.None
    var lastErrorMessage:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // view controller title
        self.title = NSLocalizedString("map_label", comment:  "map title")

        // UI asset labels
        buttonYesterday.setTitle(NSLocalizedString("yesterday_label", comment:  "yesterday"), forState: UIControlState.Normal)
        buttonToday.setTitle(NSLocalizedString("today_label", comment:  "today"), forState: UIControlState.Normal)
        buttonLastWeek.setTitle(NSLocalizedString("lastweek_label", comment:  "last week"), forState: UIControlState.Normal)
        buttonLogout.title = NSLocalizedString("logout_label", comment:  "out")
        

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
        
        // UI progress view
        SwiftSpinner.useContainerView(self.view)
        
        
        self.startAnyTimers()
        
        // cancel all notifications
        UIApplication.sharedApplication().cancelAllLocalNotifications()


        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.LongPressOnToday)) //Long function will call when user long press on button.
        buttonToday.addGestureRecognizer(longGesture)
        
        // notifiy if entered background mode
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(didEnterBackgroundNotification),
            name: UIApplicationDidEnterBackgroundNotification,
            object: nil)
        
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(didBecomeActiveNotification),
            name: UIApplicationDidBecomeActiveNotification,
            object: nil)
        
        // label click
        labelLastSyncInformation.userInteractionEnabled = true
        let labelLastSyncInformationTap = UITapGestureRecognizer(target: self, action: #selector(MapViewController.LastSyncLabelTap))
        labelLastSyncInformation.addGestureRecognizer(labelLastSyncInformationTap)
        
        buttonTodayTouchUp(UIBarButtonItem())
        
    }
    
    func LastSyncLabelTap(sender: UITapGestureRecognizer) -> Void {
        
        if !lastErrorMessage.isEmpty {
            let alert = UIAlertController(title: "Last Message", message: lastErrorMessage, preferredStyle: .Alert)
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok_label", comment:  "ok"), style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    /**
     Fired if user holds on Today button
     
     - parameter sender: <#sender description#>
     */
    func LongPressOnToday(sender: UILongPressGestureRecognizer) -> Void {
        
        if (sender.state == UIGestureRecognizerState.Ended) {
            self.syncDataHelper.CheckNextBlockToSync()
        } else if (sender.state == UIGestureRecognizerState.Began) {
            // do ended
        }
    }
        
    
    /// Utility Queie var
    var GlobalMainQueue: dispatch_queue_t {
        return dispatch_get_main_queue()
    }
   
    /**
     Logout procedure
     
     - parameter sender: <#sender description#>
     */
    @IBAction func buttonLogoutPressed(sender: UIBarButtonItem) {
        
        // show alert
        let alert = UIAlertController(title: NSLocalizedString("logout_label", comment:  "logout"), message: NSLocalizedString("logout_message_label", comment:  "logout message"), preferredStyle: .Alert)

        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: NSLocalizedString("no_label", comment:  "no"), style: UIAlertActionStyle.Default, handler: nil))
        // yes button with action
        let yesButtonOnAlertAction = UIAlertAction(title: NSLocalizedString("yes_label", comment:  "yes"), style: .Default)
        { (action) -> Void in
            // yes..
            // stop location updating
            self.stopUpdating()
            
            // any timers
            self.stopAnyTimers()
            
            // clear the user hat domain 
            let preferences = NSUserDefaults.standardUserDefaults()
            preferences.setObject("", forKey: Constants.Preferences.UserHATDomain)
            
            // reset the stack to avoid allowing back
            let vc: LoginViewController = self.getMainStoryboard().instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            self.navigationController!.setViewControllers([vc], animated: false)
            self.navigationController?.pushViewController(vc, animated: true)

        }
        // add and present
        alert.addAction(yesButtonOnAlertAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    /**
     Today tap event
     Create predicte for 7 days for now
     
     - parameter sender: UIBarButtonItem
     */
    @IBAction func buttonLastWeekTouchUp(sender: UIBarButtonItem) {
        
        self.timePeriodSelectedEnum = Helper.TimePeriodSelected.LastWeek
        
        let lastWeek = NSDate().dateByAddingTimeInterval(Helper.FutureTimeInterval.init(days: Double(7), timeType: Helper.TimeType.Past).interval)
        let predicate = NSPredicate(format: "dateAdded >= %@", lastWeek)
        self.fetchAndClusterPoints(predicate)

    }
    
    /**
     Today tap event
     Create predicte for today
     
     - parameter sender: UIBarButtonItem
     */
    @IBAction func buttonTodayTouchUp(sender: UIBarButtonItem) {
        
        self.timePeriodSelectedEnum = Helper.TimePeriodSelected.Today
        
        let startOfToday = NSCalendar.currentCalendar().startOfDayForDate(NSDate())
        let predicate = NSPredicate(format: "dateAdded >= %@", startOfToday)
        self.fetchAndClusterPoints(predicate)
    }
    
    /**
     Today tap event
     Create predicte for yesterdasy *only*
     
     - parameter sender: <#sender description#>
     */
    @IBAction func buttonYesterdayTouchUp(sender: UIBarButtonItem) {
        
        
        self.timePeriodSelectedEnum = Helper.TimePeriodSelected.Yesyerday
        
        let startOfToday = NSCalendar.currentCalendar().startOfDayForDate(NSDate())
        let yesteday = startOfToday.dateByAddingTimeInterval(Helper.FutureTimeInterval.init(days: Double(1), timeType: Helper.TimeType.Past).interval) // remove 24hrs
        let predicate = NSPredicate(format: "dateAdded >= %@ and dateAdded <= %@", yesteday, startOfToday)
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
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        NSOperationQueue().addOperationWithBlock({
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            let mapRectWidth:Double = self.mapView.visibleMapRect.size.width
            let scale:Double = mapBoundsWidth / mapRectWidth
            let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(self.mapView.visibleMapRect, withZoomScale:scale)
            self.clusteringManager.displayAnnotations(annotationArray, onMapView:self.mapView)
        })
    }
    
    /**
     Called through map delegate to update its annotations
     
     - parameter mapView:    the maoview object
     - parameter annotation: annotation to render
     
     - returns: <#return value description#>
     */
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var reuseId = ""
        if annotation.isKindOfClass(FBAnnotationCluster) {
            reuseId = "Cluster"
            var clusterView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, options: nil)
            return clusterView
        } else {
            reuseId = "Pin"
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinColor = .Green
            return pinView
        }
    }

    
    /**
     UpdateCountDelegate method
     
     - parameter count: the current point count
     */
    func onUpdateCount(count: Int) {
        
        displayLastDataPointTime()
        
        
        // only update if today
        if self.timePeriodSelectedEnum == Helper.TimePeriodSelected.Today {
            // refresh map UI too on changed
            dispatch_async(dispatch_get_main_queue(), {
                
                // refresh map UI too
                self.buttonToday.sendActionsForControlEvents(.TouchUpInside)
            })
        }
        
    }
    

    func onUpdateError(error: String) {
        // used for debug only
        //self.labelErrors.text = error
    }
    
    /**
     MapSettingsDelegate
     */
    func onChanged()
    {
        // restart LocationManager and apply changes
        
        // stop
        self.locationManager.stopUpdatingLocation()
        // apply changes
        self.locationManager.desiredAccuracy = self.getUserPreferencesAccuracy()
        self.locationManager.distanceFilter = self.getUserPreferencesDistance()
        // begin again
        self.beginLocationTracking()
    }

    /**
     DataSyncDelegate
     */
    func onDataSyncFeedback(isSuccess: Bool, message: String)
    {
        
        if !isSuccess {
            lastErrorMessage = message;
            labelLastSyncInformation.textColor = UIColor.redColor();
        }else{
            lastErrorMessage = "";
            labelLastSyncInformation.textColor = UIColor.whiteColor();
        }

    }

    
    /**
     Fetches and adds the annotations to the map view/
     Takes a predicate, e.g. day, yesterday, week 
     Fetch the DataPoints in a background thread and update the UI once complete
     
     - parameter predicate: <#predicate description#>
     */
    func fetchAndClusterPoints(predicate: NSPredicate) -> Void
    {
        
        //SwiftSpinner.show(NSLocalizedString("fetching_points_label", comment:  "fetch message"))
        
        
        dispatch_barrier_async(concurrentDataPointQueue) { // 1
            
            var annottationArray:[FBAnnotation] = []
            //var datePointCount:Int = 0;
            
            //Get the results. Results list is optional
            if let results:Results<DataPoint> = RealmHelper.GetResults(predicate)
            {
                //datePointCount = results.count;
                for dataPoint:DataPoint in results {
                    let pin = FBAnnotation()
                    pin.coordinate = CLLocationCoordinate2D(latitude: dataPoint.lat, longitude: dataPoint.lng)
                    annottationArray.append(pin)
                }
                // we must set annotations to replace old ones
                self.clusteringManager.setAnnotations(annottationArray)
                // force map changed to refresh the map and any pins
                self.mapView(self.mapView, regionDidChangeAnimated: true)
                
                dispatch_async(dispatch_get_main_queue(), {
                    //self.mapView.showAnnotations(annottationArray, animated: true)
                    if(annottationArray.count > 0){
                        self.fitMapViewToAnnotaionList(annottationArray)
                    }
                })

            }
            
            dispatch_async(self.GlobalMainQueue) { // 3
                SwiftSpinner.hide()
                
                //JLToast.makeText(String(datePointCount) + " " +  NSLocalizedString("date_points_returned_label", comment:  "dp message")).show()
                

            }
        }

    }
    
    func fitMapViewToAnnotaionList(annotations: [FBAnnotation]) -> Void {
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "SettingsSequeID") {
            // pass data to next view
            let settingsVC = segue.destinationViewController as! SettingsViewController
            
            settingsVC.mapSettingsDelegate = self
        }
    }
    
    /**
     Display the last entry from the map DataPoint
     */
    func displayLastDataPointTime() -> Void {
        
        if let dataPoint:DataPoint = RealmHelper.GetLastDataPoint()
        {
            // update on ui thread
            if let addedOn:NSDate = dataPoint.dateAdded
            {
                dispatch_async(dispatch_get_main_queue(), {
                    self.labelMostRecentInformation.text = NSLocalizedString("information_label", comment:  "info") + " " + Helper.TimeAgoSinceDate(addedOn)
                    
                                   })
            }            

        }
        
        // sync date
        // last sync date
        dispatch_async(dispatch_get_main_queue(), {
            if let dateSynced:NSDate = self.getLastSuccessfulSyncDate()
            {

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
        let queue = dispatch_queue_create("com.hat.app.timer", nil)
        
        // user info
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC, 1 * NSEC_PER_SEC) // every 10 seconds, with leeway of 1 second
        dispatch_source_set_event_handler(timer) {
            // update UI
            self.displayLastDataPointTime()
        }
        dispatch_resume(timer)
        
        // sync
        timerSync = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
        dispatch_source_set_timer(timerSync, DISPATCH_TIME_NOW, Constants.DataSync.DataSyncPeriod * NSEC_PER_SEC, 1 * NSEC_PER_SEC) // every 10 seconds, with leeway of 1 second
        dispatch_source_set_event_handler(timerSync) {
            // sync with HAT
            dispatch_async(dispatch_get_main_queue(), {
                self.syncDataHelper.CheckNextBlockToSync()
            })
            
            
        }
        dispatch_resume(timerSync)
    }
    
    /**
     Stop any timers
     */
    func stopTimer() {
        
        if timer != nil{
            dispatch_source_cancel(timer)
            timer = nil
        }
        
        if timerSync != nil{
            dispatch_source_cancel(timerSync)
            timerSync = nil
        }
        
        
    }
    
    override func stopAnyTimers() -> Void {
        //
        self.stopTimer()
    }
    
    override func startAnyTimers() -> Void {
        //
        self.startTimer()
    }
    
       

}
