//
//  AuthorData.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 22/11/16.
//  Copyright © 2016 Green Custard Ltd. All rights reserved.
//

import SwiftyJSON

struct AuthorData {

    var nickName: String
    var name: String
    var photoURL: String
    var id: Int
    // required
    var phata: String
    
    init() {
        
        nickName = ""
        name = ""
        photoURL = ""
        id = -1
        phata = ""
    }
    
    init(dict: Dictionary<String, Any>) {
        
        let tempNickName: JSON = dict["nick"] as! JSON
        let tempname: JSON = dict["name"] as! JSON
        let tempPhotoURL: JSON = dict["photo_url"] as! JSON
        let tempID: JSON = dict["id"] as! JSON
        let tempPhata: JSON = dict["phata"] as! JSON
        
        nickName = tempNickName.string!
        name = tempname.string!
        photoURL = tempPhotoURL.string!
        id = -1
        if tempID.stringValue != "" {
            
            id = Int(tempID.stringValue)!
        }
        phata = tempPhata.string!
    }
}
