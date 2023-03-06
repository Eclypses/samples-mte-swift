//
// ******************************************************
// Copyright © 2023 Eclypses Inc. All rights reserved.
// ******************************************************

import Foundation


enum Constants {
	
	// Typealias'
	typealias CallWebServiceClosure = (APIResult<Data>) -> Void
	
	// String Constants
	static let GET = "GET"
	static let POST = "POST"
	
	// General Success ResultCode
	static let RC_SUCCESS = "000"
	
	// WebService Error ResultCodes
	static let RC_ERROR_SERVER_NO_LONGER_PAIRED = "400"
	static let RC_ERROR_UNABLE_TO_AUTHENTICATE = "401"
	static let RC_ERROR_INTERNAL_SERVER_ERROR = "500"
	static let RC_ERROR_ESTABLISHING_CONNECTION_WITH_SERVER = "503"	
	static let RC_ERROR_RECEIVED_NO_DATA_FROM_SERVER = "550"
	static let RC_ERROR_HTTP_STATUS_CODE = "560"
}
