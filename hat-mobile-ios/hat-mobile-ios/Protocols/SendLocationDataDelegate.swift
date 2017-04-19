//
//  SendLocationDataDelegate.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 13/4/17.
//  Copyright © 2017 HATDeX. All rights reserved.
//

import HatForIOS

protocol SendLocationDataDelegate {

    func locationDataReceived(latitude: Double, longitude: Double, accuracy: Double)
}
