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

import UIKit
import MapKit

class SettingsViewController: BaseViewController, UIPickerViewDataSource,UIPickerViewDelegate {

    var mapSettingsDelegate: MapSettingsDelegate? = nil

    let pickerAccuracyData = ["kCLLocationAccuracyKilometer","kCLLocationAccuracyBest","kCLLocationAccuracyHundredMeters","kCLLocationAccuracyNearestTenMeters","kCLLocationAccuracyThreeKilometers"]
  
    
    @IBOutlet weak var pickerAccuracy: UIPickerView!
    
    @IBOutlet weak var textFieldDistance: UITextField!
    @IBOutlet weak var textFieldDeferredTime: UITextField!
    @IBOutlet weak var textFieldDeferredDistance: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // view controller title
        self.title = NSLocalizedString("settings_label", comment:  "settings title")
        
        pickerAccuracy.dataSource = self
        pickerAccuracy.delegate = self
        
        textFieldDistance.text = String(self.getUserPreferencesDistance())
        textFieldDeferredDistance.text = String(self.getUserPreferencesDeferredDistance())
        textFieldDeferredTime.text = String(self.getUserPreferencesDeferredTimeout())
       
        
        var selectedAccuracyIndex: Int = 1
        switch self.getUserPreferencesAccuracy() {
        case kCLLocationAccuracyKilometer:
            selectedAccuracyIndex = 0
        case kCLLocationAccuracyBest:
            selectedAccuracyIndex = 1
        case kCLLocationAccuracyHundredMeters:
            selectedAccuracyIndex = 2
        case kCLLocationAccuracyNearestTenMeters:
            selectedAccuracyIndex = 3
        case kCLLocationAccuracyThreeKilometers:
            selectedAccuracyIndex = 4
        default:
            selectedAccuracyIndex = 1
        }
        
        pickerAccuracy.selectRow(selectedAccuracyIndex, inComponent: 0, animated: true)
        
        //pickerAccuracy.select()
       

        
    }
    
    func typeName(some: Any) -> String {
        return (some is Any.Type) ? "\(some)" : "\(some.dynamicType)"
    }

    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerAccuracyData.count
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerAccuracyData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       
        let valueSelected:String = pickerAccuracyData[row]
        var locationAccuracy:CLLocationAccuracy = kCLLocationAccuracyBest //default
        switch valueSelected {
        case "kCLLocationAccuracyKilometer":
            locationAccuracy = kCLLocationAccuracyKilometer
        case "kCLLocationAccuracyBest":
            locationAccuracy = kCLLocationAccuracyBest
        case "kCLLocationAccuracyHundredMeters":
            locationAccuracy = kCLLocationAccuracyHundredMeters
        case "kCLLocationAccuracyNearestTenMeters":
            locationAccuracy = kCLLocationAccuracyNearestTenMeters
        case "kCLLocationAccuracyThreeKilometers":
            locationAccuracy = kCLLocationAccuracyThreeKilometers
        default:
            locationAccuracy = kCLLocationAccuracyBest
        }
        
        
        let preferences = NSUserDefaults.standardUserDefaults()
        preferences.setObject(locationAccuracy, forKey: Constants.Preferences.MapLocationAccuracy)

    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        var titleData:String = pickerAccuracyData[row]
        
        let valueSelected:String = pickerAccuracyData[row]
        //var locationAccuracy:CLLocationAccuracy = kCLLocationAccuracyBest //default
        switch valueSelected {
        case "kCLLocationAccuracyKilometer":
            titleData = NSLocalizedString("location_kCLLocationAccuracyKilometer", comment:  "")
        case "kCLLocationAccuracyBest":
            titleData = NSLocalizedString("location_kCLLocationAccuracyBest", comment:  "")
        case "kCLLocationAccuracyHundredMeters":
            titleData = NSLocalizedString("location_kCLLocationAccuracyHundredMeters", comment:  "")
        case "kCLLocationAccuracyNearestTenMeters":
            titleData = NSLocalizedString("location_kCLLocationAccuracyNearestTenMeters", comment:  "")
        case "kCLLocationAccuracyThreeKilometers":
            titleData = NSLocalizedString("location_kCLLocationAccuracyThreeKilometers", comment:  "")
        default:
            titleData = NSLocalizedString("location_kCLLocationAccuracyBest", comment:  "")
        }
        
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 14.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = NSTextAlignment.Center
        return pickerLabel
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if parent == nil {
            // the back button was pressed.
            if (self.mapSettingsDelegate != nil) {
                
                guard Double(textFieldDistance.text!) != nil else {
                    return
                }
                
                guard Double(textFieldDeferredDistance.text!) != nil else {
                    return
                }
                
                guard Double(textFieldDeferredTime.text!) != nil else {
                    return
                }

                // save diatnae and time prefs
                // distance
                let preferences = NSUserDefaults.standardUserDefaults()
                // distance
                preferences.setDouble(Double(textFieldDistance.text!)!, forKey: Constants.Preferences.MapLocationDistance)
                // deferred distance
                preferences.setDouble(Double(textFieldDeferredDistance.text!)!, forKey: Constants.Preferences.MapLocationDeferredDistance)
                // time
                preferences.setDouble(Double(textFieldDeferredTime.text!)!, forKey: Constants.Preferences.MapLocationDeferredTimeout)
                
                self.mapSettingsDelegate?.onChanged()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

}
