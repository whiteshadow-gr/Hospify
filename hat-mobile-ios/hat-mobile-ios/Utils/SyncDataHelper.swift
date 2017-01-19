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

import Alamofire
import SwiftyJSON
import RealmSwift

internal class SyncDataHelper {
        
    var dataSyncDelegate: DataSyncDelegate? = nil
    
    // MARK: - Sync functions
    
    /**
     Gets the last successful sync count from preferences
     
     - returns: Int
     */
    class func getSuccessfulSyncCount() -> Int {
        
        // get standard user defaults
        let preferences = UserDefaults.standard
        
        // returns an integer if the key existed, or 0 if not.
        let successfulSyncCount:Int = preferences.integer(forKey: Constants.Preferences.SuccessfulSyncCount)
        
        return successfulSyncCount
    }
    
    /**
     Gets the last successful sync count from preferences
     
     - returns: The date of last successful sync. Optional
     */
    class func getLastSuccessfulSyncDate() -> Date! {
        
        // get standard user defaults
        let preferences = UserDefaults.standard
        
        // search for the particular key, if found return it
        if let successfulSyncDate:Date = preferences.object(forKey: Constants.Preferences.SuccessfulSyncDate) as? Date {
            
            return successfulSyncDate
        }
        
        return nil
    }
    
    /**
     Check if we have any DataPoints to sync
     
     NB:
     Since queries in Realm are lazy, performing paginating behavior isn’t necessary at all,
     as Realm will only load objects from the results of the query once they are explicitly accessed.
     */
    internal func CheckNextBlockToSync() -> Bool {
        
        var iCount:Int = 0
        
        // predicate to check for nil sync field
        let predicate = NSPredicate(format: "lastSynced == %@")
        //Get the results. Results list is optional
        if let results:Results<DataPoint> = RealmHelper.GetResults(predicate) {
            
            var theBlockDataPoints:[DataPoint] = []
            
            for dataPoint:DataPoint in results {
                
                // inc
                iCount += 1
                
                // append
                theBlockDataPoints.append(dataPoint)
                
                // check break
                if iCount >= Constants.DataPointBlockSize.MaxBlockSize {
                    
                    break
                }
            }
            
            // only sync if we have data
            if theBlockDataPoints.count > 0 {
                
                self.SyncDataItems(theBlockDataPoints)
                return true
            }
        }
        
        return false
    }
    
    /**
     Sync with HAT, a block of DataPoints
     
     - parameter dataPoints: <#dataPoints description#>
     */
    internal func SyncDataItems(_ dataPoints: [DataPoint]) {
        
        /*
            A few steps involved
            
            1. Get access_token for current user (HAT_domain) [func GetAccesstokenForUser]
            2. Check if DataSource we are going to POST to exists [func CheckIfUserDataSourceExists]
            2.1. If it doesn't exsit, call [func ConfigureANewDatasource] Configure DataSource. (Send structure to HAT.. get field ids back)
            2.2 If data structure does exist, call [func GetFieldInformationUsingTableID]
            2.3 CheckIfUserDataSourceExists will call
            4. POST the lat/lng data. (if one persist fails, they all fail) [func PostOurData]
         
            We can only do 4. if all others have Success
 
        */
        
        // 1. Get access_token for current user (HAT_domain)
        self.GetAccesstokenForUser(dataPoints)
    }
    
    /**
     1. Get HAT access token for user
     */
    internal func GetAccesstokenForUser(_ dataPoints: [DataPoint]) {
    
        // parameters..
        let parameters = ["": ""]
        
        // auth header
        let headers:[String: String] = NetworkHelper.ConstructRequestHeaders(Helper.TheMarketAccessToken())

        // construct url
        let url = Helper.TheUserHATAccessTokenURL()
        
        //print(url)
        
        // make asynchronous call to get token
        NetworkHelper.AsynchronousRequest(url, method: HTTPMethod.get, encoding: Alamofire.URLEncoding.default, contentType: Constants.ContentType.JSON, parameters: parameters, headers: headers) { (r: Helper.ResultType) -> Void in
            
            // the result from asynchronous call to login
            
            let checkResult:String = "accessToken"
            
            switch r {
                
            case .isSuccess(let isSuccess, _, let result):
                if isSuccess{
                    
                    //print("JSON res: \(theResult)")
                        
                    // belt and braces.. check we have a accessToken in the returned JSON
                    if result[checkResult].exists() {
                        
                        // get the user HAT access token ..
                        let userHATAccessToken = result[checkResult].stringValue
                        
                        // 2. Check if DateSource exists
                        self.CheckIfUserDataSourceExists(userHATAccessToken, dataPoints: dataPoints)
                        
                        // inform user
                        if (self.dataSyncDelegate != nil) {
                            
                            self.dataSyncDelegate?.onDataSyncFeedback(true, message: result.rawString()!)
                        }
                    }else{
                        
                        if (self.dataSyncDelegate != nil) {
                            
                            self.dataSyncDelegate?.onDataSyncFeedback(false, message: checkResult +  " not found")
                        }
                    }
                        
                }else{
                    
                    if (self.dataSyncDelegate != nil) {
                        
                        self.dataSyncDelegate?.onDataSyncFeedback(false, message: result.rawString()!)
                    }
                }
                
            case .error(let error, let statusCode):
                
                if (self.dataSyncDelegate != nil) {
                    
                    let msg:String = NetworkHelper.ExceptionFriendlyMessage(statusCode, defaultMessage: error.localizedDescription)
                    self.dataSyncDelegate?.onDataSyncFeedback(false, message: msg)
                }
            }
        }
 
    }
    
    /**
        e.g.
        http://${DOMAIN}/data/table?name=${NAME}&source=${SOURCE}`
     name=HyperDataBrowser&source=HyperDataBrowser`
     
        If 404 error, then the DS does not exist
     */
    internal func CheckIfUserDataSourceExists(_ userHATAccessToken: String, dataPoints: [DataPoint]) {
        
        // parameters..
        let parameters = ["": ""]
        
        //print(userHATAccessToken)
        // auth header
        let headers:[String: String] = NetworkHelper.ConstructRequestHeaders(userHATAccessToken)

        // construct url
        let url = Helper.TheUserHATCheckIfDataStructureExistsURL()
        
        //print(url)
        
        // make asynchronous call to get token
        NetworkHelper.AsynchronousRequest(url, method: HTTPMethod.get, encoding: Alamofire.URLEncoding.default, contentType: Constants.ContentType.JSON, parameters: parameters , headers: headers) { (r: Helper.ResultType) -> Void in
            
            // the result from asynchronous call to login
            
            let checkResult:String = "id"
            
            switch r {
                
            case .isSuccess(let isSuccess, _, let result):
                if isSuccess{
                    
                    // print("JSON res: \(theResult)")
                        
                    // belt and braces.. check we have a accessToken in the returned JSON
                    if result[checkResult].exists() {
                        
                        // 2. Check if DateSource exists
                        
                        // get the tableID from json
                        let tableId:Int = result[checkResult].intValue

                        self.GetFieldInformationUsingTableID(userHATAccessToken, fieldID: tableId, dataPoints: dataPoints)
                        
                        // inform user
                        if (self.dataSyncDelegate != nil) {
                            
                            self.dataSyncDelegate?.onDataSyncFeedback(true, message: result.rawString()!)
                        }
                    }else{
                        
                        if (self.dataSyncDelegate != nil) {
                            
                            self.dataSyncDelegate?.onDataSyncFeedback(false, message: checkResult + " not found")
                        }
                    }
                } else {
                    
                    if (self.dataSyncDelegate != nil) {
                        
                        self.dataSyncDelegate?.onDataSyncFeedback(false, message: result.rawString()!)
                    }
                }
                
            case .error(let error, let statusCode):
                
                //print("error res: \(error)")
                
                // 404 error is thrown when the datasource does not exist
                if statusCode == 404 {
                    
                    // the DS does not exist, we can configure a new datasource
                    self.ConfigureANewDatasource(userHATAccessToken, dataPoints: dataPoints)
                } else{
                    
                    // else it's a more general error
                    if (self.dataSyncDelegate != nil) {
                        
                        let msg:String = NetworkHelper.ExceptionFriendlyMessage(statusCode, defaultMessage: error.localizedDescription)
                        self.dataSyncDelegate?.onDataSyncFeedback(false, message: msg)
                    }
                }
            }
        }
    }

    /**
        Step 3.
     e.g.
     http://${DOMAIN}/data/table?name=${NAME}&source=${SOURCE}`
 
     */
    internal func ConfigureANewDatasource(_ userHATAccessToken: String, dataPoints: [DataPoint]) {
        //let test:JSON = JSON(Constants.HATDataSource().toJSON())
        
        let parameters1 = Constants.HATDataSource().toJSON()

        //Alamofire.request(.POST, "https://httpbin.org/post", parameters: parameters1)
        // parameters..
        //let parameters = test// ["": ""] // Constants.HATDataSource().toJSON()
        
        // auth header
        let headers:[String: String] = NetworkHelper.ConstructRequestHeaders(userHATAccessToken)

        // construct url
        let url = Helper.TheConfigureNewDataSourceURL()
        
        //print(url)
        
        // make asynchronous call to get token
        NetworkHelper.AsynchronousRequest(url, method: HTTPMethod.post, encoding: Alamofire.JSONEncoding.default, contentType: Constants.ContentType.JSON, parameters: parameters1, headers: headers) { (r: Helper.ResultType) -> Void in
            
            // the result from asynchronous call to login
            
            let checkResult:String = "name"
            
            switch r {
            case .isSuccess(let isSuccess, _, let result):
                if isSuccess {
                    
                    //print("JSON res: \(theResult)")
                        
                    // belt and braces.. check we have a accessToken in the returned JSON
                    if result[checkResult].exists() {
                        
                        // 2. Check if DateSource exists
                        self.CheckIfUserDataSourceExists(userHATAccessToken, dataPoints: dataPoints)
                            
                        // inform user
                        if (self.dataSyncDelegate != nil) {
                            
                            self.dataSyncDelegate?.onDataSyncFeedback(true, message: result.rawString()!)
                        }
                    } else {
                        
                        if (self.dataSyncDelegate != nil) {
                            
                            self.dataSyncDelegate?.onDataSyncFeedback(false, message: checkResult +  " not found")
                        }
                    }
                } else {
                    
                    if (self.dataSyncDelegate != nil) {
                        
                        self.dataSyncDelegate?.onDataSyncFeedback(false, message: result.rawString()!)
                    }
                }
                
            case .error(let error, let statusCode):
                
                //print("error res: \(error)")
                if (self.dataSyncDelegate != nil) {
                    
                    let msg:String = NetworkHelper.ExceptionFriendlyMessage(statusCode, defaultMessage: error.localizedDescription)
                    self.dataSyncDelegate?.onDataSyncFeedback(false, message: msg)
                }
            }
        }
    }
    
    // get field id
    /**
     Step 3.2
     e.g.
     http://${DOMAIN}/data/table?name=${NAME}&source=${SOURCE}`
     */
    internal func GetFieldInformationUsingTableID(_ userHATAccessToken: String, fieldID: Int, dataPoints: [DataPoint]) {
        
        let parameters = ["": ""]
        
        // auth header
        let headers:[String: String] = NetworkHelper.ConstructRequestHeaders(userHATAccessToken)
        
        // construct url
        let url = Helper.TheGetFieldInformationUsingTableIDURL(fieldID)
        
        //print(url)
        
        // make asynchronous call to get token
        NetworkHelper.AsynchronousRequest(url, method: HTTPMethod.get, encoding: Alamofire.URLEncoding.default, contentType: Constants.ContentType.JSON, parameters: parameters, headers: headers) { (r: Helper.ResultType) -> Void in
            
            // the result from asynchronous call to login
            
            let checkResult:String = "fields"
            
            switch r {
                
            case .isSuccess(let isSuccess, _, let result):
                
                if isSuccess{
                    
                    // Note: as? ..i know it's a  JSON.. so cast
                    //print("JSON res: \(theResult)")
                        
                    // belt and braces.. check we have a accessToken in the returned JSON
                    if result[checkResult].exists() {
                        
                        // 2. Check if DateSource exists
                        // we have the field info back. Ge the field id from the json for eacvh field in our request
                        
                        let theHATSource:Constants.HATDataSource = Constants.HATDataSource()
                        for requsetField:JSONDataSourceRequestField in theHATSource.fields {
                            
                            let fieldsArray:Array = result["fields"].arrayValue
                            for arrayItem in fieldsArray {
                                
                                let fieldName:String = arrayItem["name"].stringValue
                                let fieldID:Int = arrayItem["id"].intValue
                                
                                if fieldName == requsetField.name {
                                    
                                    // update it and exit to next
                                    requsetField.id = fieldID
                                    break
                                }
                            }
                        }
                        
                        // POST data
                        self.PostOurData(userHATAccessToken, hatDataSource: theHATSource, dataPoints: dataPoints)
                            
                            
                        // inform user
                        if (self.dataSyncDelegate != nil) {
                            
                            self.dataSyncDelegate?.onDataSyncFeedback(true, message: result.rawString()!)
                        }
                    } else {
                        
                        if (self.dataSyncDelegate != nil) {
                            
                            self.dataSyncDelegate?.onDataSyncFeedback(false, message: checkResult +  " not found")
                        }
                    }
                        
                } else{
                    
                    if (self.dataSyncDelegate != nil) {
                        
                        self.dataSyncDelegate?.onDataSyncFeedback(false, message: result.rawString()!)
                    }
                }
                
            case .error(let error, let statusCode):
                
                //print("error res: \(error)")
                if (self.dataSyncDelegate != nil) {
                    
                    let msg:String = NetworkHelper.ExceptionFriendlyMessage(statusCode, defaultMessage: error.localizedDescription)
                    self.dataSyncDelegate?.onDataSyncFeedback(false, message: msg)
                }
            }
        }
    }
    
    internal func PostOurData(_ userHATAccessToken: String, hatDataSource: Constants.HATDataSource, dataPoints: [DataPoint]) {
        
        var jsonObject: [Any] = []
        var iCount:Int = 0
        for dataPoint:DataPoint in dataPoints {
            
            // inc counter for record name
            iCount += 1
            
            // the record name
            let dateStr = FormatterHelper.getDateString(dataPoint.dateAdded, format: Constants.DateFormats.UTC)
            let record: [String : Any] = ["name": "record " + String(iCount), "lastUpdated" : dateStr]
            
            var jsonObjectInner: [Any] = []
            
            // iterate over the JSONDataSourceRequestField object (it will have the new ids from HAT. SeeGetFieldInformationUsingTableID(..))
            for requsetField:JSONDataSourceRequestField in hatDataSource.fields {
                
                let retFieldValue = getFieldInfo(requsetField, dataPoint: dataPoint)
                let field: [String : Any] = ["id": retFieldValue.fieldId, "name" : retFieldValue.fieldName]
                
                jsonObjectInner.append(["field": field, "value": retFieldValue.value])
            }
            
            jsonObject.append(["record": record, "values" : jsonObjectInner])
        }
        
        let dataToPOSTToHAT:JSON = JSON(jsonObject)
        
        // ready to POST our data to HAT
        // auth header
        let headers:[String: String] = NetworkHelper.ConstructRequestHeaders(userHATAccessToken)
        
        // construct url
        let url = Helper.ThePOSTDataToHATURL()
        
            // make asynchronous call to get token
            NetworkHelper.AsynchronousRequestData(url, method: HTTPMethod.post, encoding: Alamofire.JSONEncoding.default, contentType: Constants.ContentType.JSON, parameters: dataToPOSTToHAT.arrayObject! as [AnyObject], headers: headers, userHATAccessToken:  userHATAccessToken) { (r: Helper.ResultType) -> Void in
                
                // the result from asynchronous call to login
                
                let checkResult:String = "record"
                
                switch r {
                    
                case .isSuccess(let isSuccess, let statusCode, let result):
                    
                    if isSuccess {
                        
                        //  print("JSON res: \(theResult)")
                            
                        // belt and braces.. check we have a accessToken in the returned JSON
                        if result[0][checkResult].exists() {
                            
                            // 2. Check if DateSource exists
                            
                            // get the last updated date from response
                            //let lastUpdatedDate:String = theResult[checkResult]..stringValue

                            if let array:[JSON] = result.array {
                                
                                // get last updtedate
                                let recordsUpdated:Int = array.count

                                // get lastUpdatedDate
                                func getLastUpdatedDate(_ array: [JSON]) -> (String?) {
                                    
                                    // Find the latest date
                                    var result:String? = nil
                                    for item in array {
                                        
                                        if let dateString = item["record"]["lastUpdated"].string {
                                            
                                            if let r = result {
                                                
                                                // Is our latest date newer? Use it if so
                                                let currentDate:NSDate? = FormatterHelper.getDateFromString(r) as NSDate?
                                                let potentialDate:NSDate? = FormatterHelper.getDateFromString(dateString) as NSDate?

                                                if let c:NSDate = currentDate {
                                                    
                                                    if let p:NSDate = potentialDate {
                                                        
                                                        if p.compare(c as Date) == ComparisonResult.orderedDescending {
                                                            
                                                            // Both dates are valid and our new one is later in time, so use it
                                                            result = dateString
                                                        }
                                                    }
                                                }
                                            } else {
                                                
                                                result = dateString
                                            }
                                        }
                                    }

                                    return result
                                }
                                    
                                if let dateUpdatedString:String = getLastUpdatedDate(array) {
                                    
                                    if let dateUpdated:NSDate = FormatterHelper.getDateFromString(dateUpdatedString) as NSDate? {
                                            
                                        // if we get here, we can update our local DB with the last sync date
                                        RealmHelper.UpdateData(dataPoints, lastUpdated: dateUpdated as Date)
                                            
                                        // count
                                        let preferences = UserDefaults.standard//.standardUserDefaults()
                                        preferences.set(recordsUpdated, forKey: Constants.Preferences.SuccessfulSyncCount)
                                            
                                        // date
                                        preferences.set(dateUpdated, forKey: Constants.Preferences.SuccessfulSyncDate)
                                            
                                        if (self.dataSyncDelegate != nil) {
                                            
                                            self.dataSyncDelegate?.onDataSyncFeedback(true, message: result.rawString()!)
                                        }
                                    }
                                }
                            }
                        } else { // if check result exists
                            
                            if (self.dataSyncDelegate != nil) {
                                
                                self.dataSyncDelegate?.onDataSyncFeedback(false, message: result.rawString()!)
                            }
                        }
                    } else { // is success
                        
                        if (self.dataSyncDelegate != nil) {
                            
                            self.dataSyncDelegate?.onDataSyncFeedback(false, message: result.rawString()!)
                        }
                    }
                    
                case .error(let error, let statusCode):
                    
                    //print("error res: \(error)")
                    if (self.dataSyncDelegate != nil) {
                        
                        let msg:String = NetworkHelper.ExceptionFriendlyMessage(statusCode, defaultMessage: error.localizedDescription)
                        self.dataSyncDelegate?.onDataSyncFeedback(false, message: msg)
                    }
                }
        }
    }
    
    /**
     A quick lookup for the fields in in our datasource
 
     - parameter requsetField: <#requsetField description#>
     - parameter dataPoint:    <#dataPoint description#>
     
     - returns: <#return value description#>
     */
    func getFieldInfo(_ requsetField: JSONDataSourceRequestField, dataPoint: DataPoint) -> (fieldId: Int, fieldName: String, value: String) {
        
        switch requsetField.fieldEnum {
            
            case Constants.RequestFields.Latitude:
                
                return (requsetField.id, requsetField.name, String(dataPoint.lat))
            case Constants.RequestFields.Longitude:
                
                return (requsetField.id, requsetField.name, String(dataPoint.lng))
            case Constants.RequestFields.Accuracy:
                
                return (requsetField.id, requsetField.name, String(dataPoint.accuracy))
            case Constants.RequestFields.Timestamp:
                
                // do conversion to UTC
                let dateStr = FormatterHelper.getDateString(dataPoint.dateAdded, format: Constants.DateFormats.UTC) 
                return (requsetField.id, requsetField.name, dateStr)
        }
    }
}
