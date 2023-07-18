//
// ******************************************************
// Copyright © 2023 Eclypses Inc. All rights reserved.
// ******************************************************

import Foundation

class WebService {
	
    @available(*, renamed: "call(connectionModel:)")
    static func call(connectionModel: ConnectionModel, onCompletion: @escaping Constants.CallWebServiceClosure) -> Void {
        Task {
            let result = await call(connectionModel: connectionModel)
            onCompletion(result)
        }
    }
    
    
    static func call(connectionModel: ConnectionModel) async -> APIResult<Data> {
        let url = URL(string: String(format: "%@%@", connectionModel.url, connectionModel.route))
        var request = URLRequest(url: url!)
        request.httpMethod = connectionModel.method
        request.httpBody = connectionModel.payload
        request.setValue(connectionModel.contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(connectionModel.clientId, forHTTPHeaderField: "x-client-id")
        request.setValue(connectionModel.mteVersion, forHTTPHeaderField: "x-mte-version")
        request.setValue(connectionModel.fixedLength, forHTTPHeaderField: "x-flen")
        return await withCheckedContinuation { continuation in
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    continuation.resume(returning: APIResult.failure(code: Constants.RC_ERROR_ESTABLISHING_CONNECTION_WITH_SERVER, message: error.localizedDescription)); return
                }
                let responseMessage = String(data: data!, encoding: String.Encoding.utf8) ?? "No Response Message from the Server"
                let statusCode = (response as! HTTPURLResponse).statusCode
                    if 200...226 ~= statusCode {
                        guard let data1 = data else {
                            continuation.resume(returning: APIResult.failure(code: Constants.RC_ERROR_RECEIVED_NO_DATA_FROM_SERVER, message: responseMessage)); return
                        }
                        continuation.resume(returning: APIResult.success(data: data1)); return
                    } else {
                        if statusCode == 400 || statusCode == 500 {
                            continuation.resume(returning: APIResult.failure(code: Constants.RC_ERROR_SERVER_NO_LONGER_PAIRED, message: responseMessage)); return
                        }
                        if statusCode == 401 {
                            continuation.resume(returning: APIResult.failure(code: Constants.RC_ERROR_UNABLE_TO_AUTHENTICATE, message: responseMessage)); return
                    }
                    continuation.resume(returning: APIResult.failure(code: String(statusCode), message: responseMessage)); return
                }
            }.resume()
        }
    }

}

extension NSMutableData {
  func appendString(_ string: String) {
    if let data = string.data(using: .utf8) {
      self.append(data)
    }
  }
}
