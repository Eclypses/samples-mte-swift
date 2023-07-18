//
// ******************************************************
// Copyright © 2023 Eclypses Inc. All rights reserved.
// ******************************************************

import Foundation

enum APIResult<T> {
	case success(data: T)
	case failure(code: String, message: String)
}

