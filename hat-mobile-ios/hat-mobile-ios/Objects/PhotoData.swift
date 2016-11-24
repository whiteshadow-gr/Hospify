//
//  PhotoData.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 22/11/16.
//  Copyright © 2016 Green Custard Ltd. All rights reserved.
//

struct PhotoData {

    var link: String
    var source: String
    var caption: String
    var shared: String
    
    init() {
        
        link = ""
        source = ""
        caption = ""
        shared = ""
    }
    
    init(dict: Dictionary<String, String>) {
        
        link = dict["link"]!
        source = dict["source"]!
        caption = dict["caption"]!
        shared = dict["shared"]!
    }
}
