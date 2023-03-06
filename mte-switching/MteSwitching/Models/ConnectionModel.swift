//
// ******************************************************
// Copyright © 2023 Eclypses Inc. All rights reserved.
// ******************************************************

import Foundation

struct ConnectionModel:Codable {
    var url: String
    var method: String
    var route: String
    var payload: Data?
    var contentType: String
    var clientId: String?
    var mteVersion: String?
    var fixedLength: String?
}
