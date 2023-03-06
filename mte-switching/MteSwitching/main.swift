//
// ******************************************************
// Copyright © 2023 Eclypses Inc. All rights reserved.
// ******************************************************

import Foundation

print("******  Simple MTE Switching Console Demo  ******\n")

enum PairType: String {
    case encoder = "Enc"
    case decoder = "Dec"
}

extension Data {
    var bytes : [UInt8]{
        return [UInt8](self)
    }
}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

let main = Main()
RunLoop.current.run()

class Main: StreamUploadDelegate, MteEntropyCallback, MteNonceCallback, MteTimestampCallback  {

    var mteHelper: MTEHelper!
    var fileStreamUpload: FileStreamUpload!
    var pairType: PairType!
    var tempEntropy = [UInt8]()
    
    init() {
        
        Settings.clientId = UUID().uuidString.lowercased()
        
        // Instantiate FileStreamUpload class
        fileStreamUpload = FileStreamUpload()
        fileStreamUpload.streamUploadDelegate = self
        
        // Instantiate the MTEHelper class
        do {
            mteHelper = try MTEHelper()
            mteHelper.mteEntropyCallback = self
            mteHelper.mteNonceCallback = self
        } catch {
            print("Unable to Instantiate MteHelper. Error: \(error.localizedDescription)")
            exit(EXIT_FAILURE)
        }
        pairWithServer()
        encodeAndSend(plaintext: "These are our [login credentials] that we need to keep secret!")
    }
    
    func pairWithServer() {
        do {
            try instantiateEncoder()
            try instantiateDecoder()
        } catch {
            print(error.localizedDescription)
            exit(EXIT_FAILURE)
        }
    }
    
    fileprivate func instantiateEncoder() throws {
        pairType = .encoder
        mteHelper.encoderPersonalizationString = UUID().uuidString.lowercased()
        try mteHelper.createEncoder()
        print("Successfully Instantiated Encoder with Elliptic-Curve Diffie-Hellman Handshake\n")
    }
    
    fileprivate func instantiateDecoder() throws {
        pairType = .decoder
        mteHelper.decoderPersonalizationString = UUID().uuidString.lowercased()
        try mteHelper.createDecoder()
        print("Successfully Instantiated Decoder with Elliptic-Curve Diffie-Hellman Handshake\n")
    }
    
    func encodeAndSend(plaintext: String) {
        var encodedData: Data!
        if plaintext != "" {
            do {
                // encode to a string
                let encodedPayloadStr = try mteHelper.encode(message: plaintext)
                
                // and convert back to Data
                encodedData = Data(encodedPayloadStr.utf8)
            } catch {
                print("Unable to encode Data. Error: \(error.localizedDescription)")
            }
            let connectionModel = ConnectionModel(url: Settings.serverUrl,
                                                  method: Constants.POST,
                                                  route: "api/mte/send-data",
                                                  payload: encodedData,
                                                  contentType: "text/plain; charset=utf-8",
                                                  clientId: Settings.clientId,
                                                  mteVersion: MteBase.getVersion())
            
            WebService.call(connectionModel: connectionModel, onCompletion: { callResult in
                switch callResult {
                case .failure(let code, let message):
                    print("Communication with Server failed. ErrorCode: \(code). ErrorMessage: \(message)")
                case .success(let data):
                    do {
                        // In this example, first, we'll convert the response data to a String
                        let dataStr = String(decoding: data, as: UTF8.self)
                        
                        // then decode it
                        let decodedStr = try self.mteHelper.decode(encoded: dataStr)
                        
                        print("Response from Server: \n\(decodedStr)")
                        
                        // Call to upload a file when call to 'login' has completed.
                        self.uploadStream("MobyDickeBook.txt")
                    } catch {
                        print("Unable to decode Data from Server. Error: \(error.localizedDescription)")
                    }
                }
            })
        }
    }
    
    func uploadStream(_ filename: String) {
        let filePath = FileManager.default.currentDirectoryPath + "/\(filename)"
        guard let urlEncodedFilename = filename.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Unable to urlEncode \(filename)")
            exit(EXIT_FAILURE)
        }
        let connectionModel = ConnectionModel(url: Settings.serverUrl,
                                              method: Constants.POST,
                                              route: "api/mke/uploadstream?name=\(urlEncodedFilename)",
                                              payload: nil,
                                              contentType: "text/plain; charset=utf-8",
                                              clientId: Settings.clientId,
                                              mteVersion: MteBase.getVersion())

            fileStreamUpload.upload(connectionModel: connectionModel, filePath: filePath, mteHelper: mteHelper)
    }
    
    
    // MARK: Stream Upload Delegates
    func didUploadToServer(success: Bool, filename: String) {
        print("\nServer reports that the upload of \(filename) was successful.\n")
        
        exit(EXIT_SUCCESS)
    }
    
    func uploadDidFail(message: String) {
        print("Server reports that the upload Failed. Error: \(message)\n")
        exit(EXIT_FAILURE)
    }

    //MARK: Callbacks
    func entropyCallback(_ minEntropy: Int,
                         _ minLength: Int,
                         _ maxLength: UInt64,
                         _ entropyInput: inout [UInt8],
                         _ eiBytes: inout UInt64,
                         _ entropyLong: inout UnsafeMutableRawPointer?) -> mte_status {
        
        var myEntropyRaw: UnsafeMutableRawPointer? = nil
        
        // We have a network call to get entropy so we have to block this thread until it returns.
        // There is likely a better solution.
        let semaphore = DispatchSemaphore(value: 0)
        
        // entropyCallback function does not support concurrency so
        // we will call the server in a Task to exchange ECDH public keys
        Task.init {
            try await getEntropy()
            semaphore.signal()
        }
        
        let timeoutResult = semaphore.wait(timeout: .now() + 15)
        if timeoutResult == .timedOut {
            print("Timeout in getEntropy call for \(pairType.rawValue)")
        }
        
        if tempEntropy.count < minLength {
            print("mte_status_drbg_catastrophic")
        }
        
        // Set the actual entropy length. It cannot exceed the maximum required.
        let buffBytes = eiBytes
        eiBytes = min(UInt64(tempEntropy.count), maxLength)
        
        // If the length is greater than the length of the provided buffer, we have
        // to create our own buffer instead.
        if eiBytes > buffBytes {
            // Get the entropy input as an array.
            let ei = tempEntropy
            
            // If there is previous raw entropy, deallocate it.
            if myEntropyRaw != nil {
                myEntropyRaw!.deallocate()
            }
            
            // Allocate unsafe memory for the entropy.
            myEntropyRaw =
            UnsafeMutableRawPointer.allocate(byteCount: ei.count, alignment: 16)
            
            // Copy from the entropy array to the unsafe memory.
            ei.withUnsafeBytes { buff in
                let raw = myEntropyRaw!.assumingMemoryBound(to: UInt8.self)
                let ei = buff.bindMemory(to: UInt8.self)
                raw.assign(from: ei.baseAddress!, count: ei.count)
            }
            
            // Set the raw pointer to point at the unsafe memory.
            entropyLong = myEntropyRaw
        }
        else {
            
            // Copy the entropy to the buffer.
            entropyInput.replaceSubrange(Range(uncheckedBounds: (0, Int(eiBytes))),
                                         with: tempEntropy.prefix(Int(eiBytes)))
            tempEntropy.resetBytes(in: 0..<tempEntropy.count)
        }
        // Success.
        return mte_status_success
    }
    
    private func getEntropy() async throws {
        var personalizationString: String!
        switch pairType {
        case .decoder:
            personalizationString = mteHelper.decoderPersonalizationString
        default:
            personalizationString = mteHelper.encoderPersonalizationString
        }
        let ecdh = try EcdhHelper(name: "\(pairType.rawValue) Entropy")
        let publicKey = try ecdh.getPublicKey()
        
        
        // Send the public keys and IDs  to the Server
        let request = PairRequest(personalizationString: personalizationString,
                                  publicKey: publicKey,
                                  pairType: pairType.rawValue)
        let payload = try JSONEncoder().encode(request)
        let connectionModel = ConnectionModel(url: Settings.serverUrl,
                                              method: Constants.POST,
                                              route: "api/pairone",
                                              payload: payload,
                                              contentType: "application/json; charset=utf-8",
                                              clientId: Settings.clientId,
                                              mteVersion: MteBase.getVersion())
        
        let result = await WebService.call(connectionModel: connectionModel)
        switch result {
        case .failure(let code, let message):
            print("Could not pair with Server. ErrorCode: \(code), ErrorMessage: \(message).")
            exit(EXIT_FAILURE)
        case .success(let data):
            let response = try JSONDecoder().decode(PairResponse.self, from: data)
            try ecdh.createSharedSecret(remotePublicKeyStr: response.publicKey,
                                        entropy: &tempEntropy)
            switch self.pairType {
            case .decoder:
                self.mteHelper.decoderNonce = UInt64(response.timestamp)!
            default:
                self.mteHelper.encoderNonce = UInt64(response.timestamp)!
            }
        }
    }
    
    func nonceCallback(_ minLength: Int, _ maxLength: Int, _ nonce: inout [UInt8], _ nBytes: inout Int) {
        
        var nCopied: Int = 0
        switch pairType {
        case .decoder:
            // Copy the nonce in little-endian format to the nonce buffer.
            nCopied = min(nonce.count, MemoryLayout.size(ofValue: mteHelper.decoderNonce))
            for i in 0..<nCopied {
                nonce[i] = UInt8(UInt64(mteHelper.decoderNonce >> (i * 8)) & 0xFF)
            }
            mteHelper.decoderNonce = 0
        default:
            // Copy the nonce in little-endian format to the nonce buffer.
            nCopied = min(nonce.count, MemoryLayout.size(ofValue: mteHelper.encoderNonce))
            for i in 0..<nCopied {
                nonce[i] = UInt8(UInt64(mteHelper.encoderNonce >> (i * 8)) & 0xFF)
            }
            mteHelper.encoderNonce = 0
        }
        
        // If the minimum length is greater than the size of the nonce we got, fill
        // up to that length with zeros.
        if nCopied < minLength {
            for i in nCopied..<minLength {
                nonce[i] = 0
            }
            nBytes = minLength
        }
        else {
            nBytes = nCopied
        }
    }
    
    func timestampCallback() -> UInt64 {
        
        // return the timestamp in milliseconds
        return UInt64(Date().timeIntervalSince1970 * 1000.0)
    }
}






