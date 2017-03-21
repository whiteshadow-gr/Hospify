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

import Foundation

public enum AuthenicationError: Error {
    
    case noTokenDetectedError
    case noIssuerDetectedError(String)
    case generalError(String, Int?, Error?)
    case cannotDecodeToken(String)
    case cannotSplitToken([String])
    case tokenValidationFailed(String)
}

public enum JSONParsingError: Error {
    
    case expectedFieldNotFound
    case generalError(String, Int?, Error?)
}

public enum HATTableError: Error {
    
    case noValuesFound
    case tableDoesNotExist
    case noTableIDFound
    case generalError(String, Int?, Error?)
}

public enum FacebookError: Error {
    
    case generalError(String, Int?, Error?)
}

public enum TwitterError: Error {
    
    case generalError(String, Int?, Error?)
}

public enum DataPlugError: Error {
    
    case generalError(String, Int?, Error?)
    case noValueFound
}
