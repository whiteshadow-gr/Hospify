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

struct StripeModel {
    
    var token: String = ""
    var sku: String = ""
    
    var name: String = ""
    var email: String = ""
    
    var address: String = ""
    var city: String = ""
    var postCode: String = ""
    var country: String = ""
    var state: String = ""
    
    var cardNumber: String = ""
    var cardCVV: String = ""
    var cardExpiryMonth: String = ""
    var cardExpiryYear: String = ""
}
