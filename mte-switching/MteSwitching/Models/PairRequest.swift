//
// ******************************************************
// Copyright © 2023 Eclypses Inc. All rights reserved.
// ******************************************************


import Foundation

struct PairRequest:Codable {
    let personalizationString: String
    let publicKey: String
    let pairType: String
}
