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

import Alamofire
import SwiftyJSON
import RealmSwift

internal class SyncDataHelper {
        
    var dataSyncDelegate: DataSyncDelegate? = nil

    let contentTypeApplicationJSON:String = "application/json"
    let contentTypePlainText:String = "plain/text"
    
    /**
     Check if we have any DataPoints to sync
     
     NB:
     Since queries in Realm are lazy, performing paginating behavior isn’t necessary at all,
     as Realm will only load objects from the results of the query once they are explicitly accessed.
     
     
     */
    internal func CheckNextBlockToSync()
    {
        var iCount:Int = 0

        // predicate to check for nil sync field
        let predicate = NSPredicate(format: "lastSynced == %@", nil as COpaquePointer)
        //Get the results. Results list is optional
        if let results:Results<DataPoint> = RealmHelper.GetResults(predicate)
        {
            
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
            }
            
           
        }
        
    }
    
    /**
     Sync with HAT, a block of DataPoints
     
     - parameter dataPoints: <#dataPoints description#>
     */
    internal func SyncDataItems(dataPoints: [DataPoint])
    {
        
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
    internal func GetAccesstokenForUser(dataPoints: [DataPoint])
    {
    
        // parameters..
        let parameters = ["": ""]
        
        // auth header
        let headers:[String: String] = Helper.ConstructRequestHeaders(Helper.TheMarketAccessToken())

        // construct url
        let url = Helper.TheUserHATAccessTokenURL()
        
        //print(url)
        
        // make asynchronous call to get token
        NetworkHelper.AsynchronousRequest(url, method: Alamofire.Method.GET, encoding: Alamofire.ParameterEncoding.URLEncodedInURL, contentType: contentTypeApplicationJSON, parameters: parameters, headers: headers) { (r: Helper.ResultType) -> Bool in
            
            // the result from asynchronous call to login
            
            let checkResult:String = "accessToken"
            
            switch r {
            case .IsSuccess(let isSuccess, _, let result):
                if isSuccess{
                    
                    // Note: as? ..i know it's a  JSON.. so cast
                    if let theResult:JSON = result as JSON{
                        //print("JSON res: \(theResult)")
                        
                        // belt and braces.. check we have a accessToken in the returned JSON
                        if theResult[checkResult].isExists()
                        {
                            // get the user HAT access token ..
                            let userHATAccessToken = theResult[checkResult].stringValue
                            
                            // 2. Check if DateSource exists
                            self.CheckIfUserDataSourceExists(userHATAccessToken, dataPoints: dataPoints)
                            
                            // inform user
                            if (self.dataSyncDelegate != nil) {
                            //    self.dataSyncDelegate?.onDataSyncFeedback(true, message: theResult.rawString()!)
                            }
                        }else{
                            if (self.dataSyncDelegate != nil) {
                                self.dataSyncDelegate?.onDataSyncFeedback(false, message: checkResult +  " not found")
                            }
                        }
                        
                    }
                }else{
                    if (self.dataSyncDelegate != nil) {
                        self.dataSyncDelegate?.onDataSyncFeedback(false, message: result.rawString()!)
                    }
                }
                
                return true
            case .Error(let error, let statusCode):
                if let error:NSError = error as NSError{
                    //print("error res: \(error)")
                    if (self.dataSyncDelegate != nil) {
                        let msg:String = Helper.ExceptionFriendlyMessage(statusCode, defaultMessage: error.localizedDescription)
                        self.dataSyncDelegate?.onDataSyncFeedback(false, message: msg)
                    }
                }
                return false
            }

            
        }
        
        
 
    }
    
    /**

        e.g.
        http://${DOMAIN}/data/table?name=${NAME}&source=${SOURCE}`
     name=HyperDataBrowser&source=HyperDataBrowser`
     
        If 404 error, then the DS does not exist
     

     */
    internal func CheckIfUserDataSourceExists(userHATAccessToken: String, dataPoints: [DataPoint])
    {
        // parameters..
        let parameters = ["": ""]
        
        //print(userHATAccessToken)
        // auth header
        let headers:[String: String] = Helper.ConstructRequestHeaders(userHATAccessToken)

        // construct url
        let url = Helper.TheUserHATCheckIfDataStructureExistsURL()
        

        //print(url)
        
        // make asynchronous call to get token
        NetworkHelper.AsynchronousRequest(url, method: Alamofire.Method.GET, encoding: Alamofire.ParameterEncoding.URLEncodedInURL, contentType: contentTypeApplicationJSON, parameters: parameters, headers: headers) { (r: Helper.ResultType) -> Bool in
            
            // the result from asynchronous call to login
            
            let checkResult:String = "id"
            
            switch r {
            case .IsSuccess(let isSuccess, _, let result):
                if isSuccess{
                    
                    // Note: as? ..i know it's a  JSON.. so cast
                    if let theResult:JSON = result as JSON{
                       // print("JSON res: \(theResult)")
                        
                        // belt and braces.. check we have a accessToken in the returned JSON
                        if theResult[checkResult].isExists()
                        {
                            // 2. Check if DateSource exists
                            
                            // get the tableID from json
                            let tableId:Int = theResult[checkResult].intValue

                            self.GetFieldInformationUsingTableID(userHATAccessToken, fieldID: tableId, dataPoints: dataPoints)
                            
                            // inform user
                            if (self.dataSyncDelegate != nil) {
                               // self.dataSyncDelegate?.onDataSyncFeedback(true, message: theResult.rawString()!)
                            }
                        }else{
                            if (self.dataSyncDelegate != nil) {
                                self.dataSyncDelegate?.onDataSyncFeedback(false, message: checkResult +  " not found")
                            }
                        }
                        
                    }
                }else{
                    if (self.dataSyncDelegate != nil) {
                        self.dataSyncDelegate?.onDataSyncFeedback(false, message: result.rawString()!)
                    }
                }
                
                return true
            case .Error(let error, let statusCode):
                
                if let error:NSError = error as NSError{
                    //print("error res: \(error)")
                    
                    // 404 error is thrown when the datasource does not exist
                    if statusCode == 404
                    {
                        // the DS does not exist, we can configure a new datasource
                        self.ConfigureANewDatasource(userHATAccessToken, dataPoints: dataPoints)
                        
                    }else{
                        // else it's a more general error
                        if (self.dataSyncDelegate != nil) {
                            let msg:String = Helper.ExceptionFriendlyMessage(statusCode, defaultMessage: error.localizedDescription)
                            self.dataSyncDelegate?.onDataSyncFeedback(false, message: msg)
                        }
                    }
                }
                return false
            }
            
        }

    }

    /**
        Step 3.
     e.g.
     http://${DOMAIN}/data/table?name=${NAME}&source=${SOURCE}`
 
     */
    internal func ConfigureANewDatasource(userHATAccessToken: String, dataPoints: [DataPoint])
    {
        //let test:JSON = JSON(Constants.HATDataSource().toJSON())
        
        
        let parameters1 = Constants.HATDataSource().toJSON()
        

        //Alamofire.request(.POST, "https://httpbin.org/post", parameters: parameters1)
        // parameters..
        //let parameters = test// ["": ""] // Constants.HATDataSource().toJSON()
        
        // auth header
        let headers:[String: String] = Helper.ConstructRequestHeaders(userHATAccessToken)

        // construct url
        let url = Helper.TheConfigureNewDataSourceURL()
        
        //print(url)
        
        // make asynchronous call to get token
        NetworkHelper.AsynchronousRequest(url, method: Alamofire.Method.POST, encoding: Alamofire.ParameterEncoding.JSON, contentType: contentTypeApplicationJSON, parameters: parameters1, headers: headers) { (r: Helper.ResultType) -> Bool in
            
            // the result from asynchronous call to login
            
            let checkResult:String = "name"
            
            switch r {
            case .IsSuccess(let isSuccess, _, let result):
                if isSuccess{
                    
                    // Note: as? ..i know it's a  JSON.. so cast
                    if let theResult:JSON = result as JSON{
                        //print("JSON res: \(theResult)")
                        
                        // belt and braces.. check we have a accessToken in the returned JSON
                        if theResult[checkResult].isExists()
                        {
                            // 2. Check if DateSource exists
                            self.CheckIfUserDataSourceExists(userHATAccessToken, dataPoints: dataPoints)
                            
                            // inform user
                            if (self.dataSyncDelegate != nil) {
                                   //self.dataSyncDelegate?.onDataSyncFeedback(true, message: theResult.rawString()!)
                            }
                        }else{
                            if (self.dataSyncDelegate != nil) {
                                self.dataSyncDelegate?.onDataSyncFeedback(false, message: checkResult +  " not found")
                            }
                        }
                        
                    }
                }else{
                    if (self.dataSyncDelegate != nil) {
                        self.dataSyncDelegate?.onDataSyncFeedback(false, message: result.rawString()!)
                    }
                }
                
                return true
            case .Error(let error, let statusCode):
                if let error:NSError = error as NSError{
                    //print("error res: \(error)")
                    if (self.dataSyncDelegate != nil) {
                        let msg:String = Helper.ExceptionFriendlyMessage(statusCode, defaultMessage: error.localizedDescription)
                        self.dataSyncDelegate?.onDataSyncFeedback(false, message: msg)
                    }
                }
                return false
            }

            
        }
        
    }
    
    
    // get field id
    
    /**
     Step 3.2
     e.g.
     http://${DOMAIN}/data/table?name=${NAME}&source=${SOURCE}`
     
     */
    internal func GetFieldInformationUsingTableID(userHATAccessToken: String, fieldID: Int, dataPoints: [DataPoint])
    {
        
        let parameters = ["": ""]
        
        
        // auth header
        let headers:[String: String] = Helper.ConstructRequestHeaders(userHATAccessToken)
        
        // construct url
        let url = Helper.TheGetFieldInformationUsingTableIDURL(fieldID)
        
        //print(url)
        
        // make asynchronous call to get token
        NetworkHelper.AsynchronousRequest(url, method: Alamofire.Method.GET, encoding: Alamofire.ParameterEncoding.URLEncodedInURL, contentType: contentTypeApplicationJSON, parameters: parameters, headers: headers) { (r: Helper.ResultType) -> Bool in
            
            // the result from asynchronous call to login
            
            let checkResult:String = "fields"
            
            switch r {
            case .IsSuccess(let isSuccess, _, let result):
                if isSuccess{
                    
                    // Note: as? ..i know it's a  JSON.. so cast
                    if let theResult:JSON = result as JSON{
                        //print("JSON res: \(theResult)")
                        
                        // belt and braces.. check we have a accessToken in the returned JSON
                        if theResult[checkResult].isExists()
                        {
                            // 2. Check if DateSource exists
                            // we have the field info back. Ge the field id from the json for eacvh field in our request
                            
                            let theHATSource:Constants.HATDataSource = Constants.HATDataSource()
                            for requsetField:JSONDataSourceRequestField in theHATSource.fields
                            {
                                if let fieldsArray:Array = theResult["fields"].arrayValue
                                {
                                    //var test:Int =  fieldsArray.count
                                    
                                    for arrayItem in fieldsArray{
                                        
                                        let fieldName:String = arrayItem["name"].stringValue
                                        let fieldID:Int = arrayItem["id"].intValue
                                        
                                        if fieldName == requsetField.name {
                                            // update it and exit to next
                                            requsetField.id = fieldID
                                            break
                                        }
                                        
                                    }
                                    
                                }
                            }
                            
                            
                            // POST data
                            self.PostOurData(userHATAccessToken, hatDataSource: theHATSource, dataPoints: dataPoints)
                            
                            
                            // inform user
                            if (self.dataSyncDelegate != nil) {
                                //self.dataSyncDelegate?.onDataSyncFeedback(true, message: theResult.rawString()!)
                            }
                        }else{
                            if (self.dataSyncDelegate != nil) {
                                self.dataSyncDelegate?.onDataSyncFeedback(false, message: checkResult +  " not found")
                            }
                        }
                        
                    }
                }else{
                    if (self.dataSyncDelegate != nil) {
                        self.dataSyncDelegate?.onDataSyncFeedback(false, message: result.rawString()!)
                    }
                }
                
                return true
            case .Error(let error, let statusCode):
                if let error:NSError = error as NSError{
                    //print("error res: \(error)")
                    if (self.dataSyncDelegate != nil) {
                        let msg:String = Helper.ExceptionFriendlyMessage(statusCode, defaultMessage: error.localizedDescription)
                        self.dataSyncDelegate?.onDataSyncFeedback(false, message: msg)
                    }
                }
                return false
            }
            
        }
        
    }
    
    
    internal func PostOurData(userHATAccessToken: String, hatDataSource: Constants.HATDataSource, dataPoints: [DataPoint])
    {
        
        var jsonObject: [AnyObject] = []
        var iCount:Int = 0
        for dataPoint:DataPoint in dataPoints {
            
            // inc counter for record name
            iCount += 1
            //    pin.coordinate = CLLocationCoordinate2D(latitude: dataPoint.lat, longitude: dataPoint.lng)
            // the record name
            let record = ["name": "record " + String(iCount)]
            
            var jsonObjectInner: [AnyObject] = []
            
            // iterate over the JSONDataSourceRequestField object (it will have the new ids from HAT. SeeGetFieldInformationUsingTableID(..))
            for requsetField:JSONDataSourceRequestField in hatDataSource.fields
            {
                let retFieldValue = getFieldInfo(requsetField, dataPoint: dataPoint)
                let field = ["id": retFieldValue.fieldId, "name" : retFieldValue.fieldName]
                
                jsonObjectInner.append(["field": field, "value": retFieldValue.value])
            }
            
            jsonObject.append(["record": record, "values" : jsonObjectInner])
        }
        
        let dataToPOSTToHAT:JSON = JSON(jsonObject)
        
        // ready to POST our data to HAT
        // auth header
        let headers:[String: String] = Helper.ConstructRequestHeaders(userHATAccessToken)
        
            // construct url
            let url = Helper.ThePOSTDataToHATURL()
            
        
            // make asynchronous call to get token
            NetworkHelper.AsynchronousRequestData(url, method: Alamofire.Method.POST, encoding: Alamofire.ParameterEncoding.JSON, contentType: contentTypeApplicationJSON, parameters: dataToPOSTToHAT.arrayObject!, headers: headers, userHATAccessToken:  userHATAccessToken) { (r: Helper.ResultType) -> Bool in
                
                // the result from asynchronous call to login
                
                let checkResult:String = "record"
                
                switch r {
                case .IsSuccess(let isSuccess, let statusCode, let result):
                    if isSuccess{
                        
                        // Note: as? ..i know it's a  JSON.. so cast
                        if let theResult:JSON = result as JSON{
                          //  print("JSON res: \(theResult)")
                            
                            // belt and braces.. check we have a accessToken in the returned JSON
                            if theResult[checkResult].isExists()
                            {
                                // 2. Check if DateSource exists
                                
                                // get the last updated date from response
                                //let lastUpdatedDate:String = theResult[checkResult]..stringValue

                                if let array:[JSON] = theResult.array
                                {
                                    // get last updtedate
                                    let recordsUpdated:Int = array.count

                                    // get lastUpdatedDate
                                    func getLastUpdatedDate(array: [JSON]) -> (String!) {
                                        for item in array {
                                            if let dateString = item["record"]["lastUpdated"].string {
                                                return dateString
                                            }
                                        }
                                        
                                        return nil

                                    }
                                    
                                    if let dateUpdatedString:String = getLastUpdatedDate(array)
                                    {
                                        if let dateUpdated:NSDate = Helper.getDateFromString(dateUpdatedString)
                                        {
                                            
                                            // if we get here, we can update our local DB with the last sync date
                                            RealmHelper.UpdateData(dataPoints, lastUpdated: dateUpdated)
                                            
                                            // count
                                            let preferences = NSUserDefaults.standardUserDefaults()
                                            preferences.setInteger(recordsUpdated, forKey: Constants.Preferences.SuccessfulSyncCount)
                                            
                                            // date
                                            preferences.setObject(dateUpdated, forKey: Constants.Preferences.SuccessfulSyncDate)
                                            
                                            if (self.dataSyncDelegate != nil) {
                                                self.dataSyncDelegate?.onDataSyncFeedback(true, message: result.rawString()!)
                                            }

                                        }
                                    }
                                  
                                }
                                
                            }else{
                                if (self.dataSyncDelegate != nil) {
                                    self.dataSyncDelegate?.onDataSyncFeedback(false, message: result.rawString()!)
                                }
                            }
                            
                        }
                    }else{
                        if (self.dataSyncDelegate != nil) {
                            self.dataSyncDelegate?.onDataSyncFeedback(false, message: result.rawString()!)
                        }
                    }
                    
                    return true
                case .Error(let error, let statusCode):
                    if let error:NSError = error as NSError{
                        //print("error res: \(error)")
                        if (self.dataSyncDelegate != nil) {
                            let msg:String = Helper.ExceptionFriendlyMessage(statusCode, defaultMessage: error.localizedDescription)
                            self.dataSyncDelegate?.onDataSyncFeedback(false, message: msg)
                        }
                    }
                    return false
                }

           
        }

        
    }


    /**
     A quick lookup for the fields in in our datasource
 
     - parameter requsetField: <#requsetField description#>
     - parameter dataPoint:    <#dataPoint description#>
     
     - returns: <#return value description#>
     */
    func getFieldInfo(requsetField: JSONDataSourceRequestField, dataPoint: DataPoint) -> (fieldId: Int, fieldName: String, value: String) {
        
        
        switch requsetField.fieldEnum {
            case Constants.RequestFields.Latitude:
                return (requsetField.id, requsetField.name, String(dataPoint.lat))
            case Constants.RequestFields.Longitude:
                return (requsetField.id, requsetField.name, String(dataPoint.lng))
            case Constants.RequestFields.Accuracy:
                return (requsetField.id, requsetField.name, String(dataPoint.accuracy))
            case Constants.RequestFields.Timestamp:
                // do conversion to UTC
                let dateStr = Helper.getDateString(dataPoint.dateAdded, format: Constants.DateFormats.UTC) 
                return (requsetField.id, requsetField.name, dateStr)

        }
        
    }

}
