//
// ******************************************************
// Copyright © 2023 Eclypses Inc. All rights reserved.
// ******************************************************
	

import Foundation

enum Settings {
    static let appName = "File Upload Console Demo"
    
    static let serverUrl = "http://localhost:5000/"
//    static let serverUrl = "https://dev-echo.eclypses.com/"
//    static let serverUrl = "https://dev-jumpstart-csharp.eclypses.com/"
    
    private static var helperName = "MTEHelper"
    static var clientId = "This will be set by \(helperName) init"
    
    static var chunkSize: Int = 1024
    
    // These values must be set to the values compiled into the library.
    static let licCompanyName: String = "LicenseCompanyName"
    static let licCompanyKey: String = "LicenseKey"
}

