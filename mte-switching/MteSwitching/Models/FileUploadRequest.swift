//
// ******************************************************
// Copyright © 2023 Eclypses Inc. All rights reserved.
// ******************************************************


import Foundation

struct FileUploadRequest: Codable {
    
    let fileName: String
    let fileContents: String
}
