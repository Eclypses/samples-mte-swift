//
// ******************************************************
// Copyright © 2023 Eclypses Inc. All rights reserved.
// ******************************************************


import Foundation

protocol StreamUploadDelegate: AnyObject {
    func didUploadToServer(success: Bool, filename: String)
    func uploadDidFail(message: String)
}

class FileStreamUpload: NSObject, URLSessionDelegate, StreamDelegate, URLSessionStreamDelegate, URLSessionDataDelegate {
    
    weak var streamUploadDelegate: StreamUploadDelegate?
    var fileHandle: FileHandle!
    var mteHelper: MTEHelper!
    
    lazy var session: URLSession = URLSession(configuration: .default,
                                              delegate: self,
                                              delegateQueue: .main)
    
    struct Streams {
        let input: InputStream
        let output: OutputStream
    }
    
    lazy var boundStreams: Streams = {
        var inputOrNil: InputStream? = nil
        var outputOrNil: OutputStream? = nil
        Stream.getBoundStreams(withBufferSize: Settings.chunkSize,
                               inputStream: &inputOrNil,
                               outputStream: &outputOrNil)
        guard let input = inputOrNil, let output = outputOrNil else {
            fatalError("On return of `getBoundStreams`, both `inputStream` and `outputStream` will contain non-nil streams.")
        }
        // configure and open output stream
        output.delegate = self
        output.schedule(in: .current, forMode: .default)
        output.open()
        return Streams(input: input, output: output)
    }()
    
    func upload(connectionModel: ConnectionModel, filePath: String, mteHelper: MTEHelper) {
        self.mteHelper = mteHelper
        guard let fileUrl = URL(string: filePath) else {
            return
        }
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            do {
                fileHandle = try FileHandle(forReadingFrom: fileUrl)
            } catch {
                print("Unable to read from file. Error: \(error.localizedDescription)")
            }
        }
        let url = URL(string: String(format: "%@%@", connectionModel.url, connectionModel.route))
        var request = URLRequest(url: url!,
                                 cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: 10)
        request.httpMethod = connectionModel.method
        request.httpBody = connectionModel.payload
        request.setValue(connectionModel.contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(connectionModel.clientId, forHTTPHeaderField: "x-client-id")
        request.setValue(connectionModel.mteVersion, forHTTPHeaderField: "x-mte-version")
        session.uploadTask(withStreamedRequest: request).resume()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        completionHandler(boundStreams.input)
        
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        // We'll convert the response data to a String
        let dataStr = String(decoding: data, as: UTF8.self)
        
        // and notify via delegate
        streamUploadDelegate?.didUploadToServer(success: true, filename: dataStr)
    }
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        guard aStream == boundStreams.output else {
            return
        }
        var buffer = [UInt8]()
        if eventCode.contains(.hasSpaceAvailable) {
            do {
                let encoder = try mteHelper.startEncrypt()
                
                buffer = [UInt8](fileHandle.readData(ofLength: Settings.chunkSize))
                while !(buffer.isEmpty) {
                    try mteHelper.encryptChunk(encoder: encoder, buffer: &buffer)
                    self.boundStreams.output.write(buffer, maxLength: buffer.count)
                    
                    // read the next chunk
                    buffer = [UInt8](fileHandle.readData(ofLength: Settings.chunkSize))
                }
                let finalBuffer = try mteHelper.finishEncrypt(encoder: encoder)
                self.boundStreams.output.write(finalBuffer, maxLength: finalBuffer.count)
                self.boundStreams.output.close()
            } catch {
                print("Upload failed. Error: \(error.localizedDescription)")
            }
        }
        if eventCode.contains(.errorOccurred) {
            print("Upload error occurred. Closing Streams. Error: \(eventCode.rawValue)")
            streamUploadDelegate?.uploadDidFail(message: "Upload to Server failed.")
            self.boundStreams.output.close()
            self.boundStreams.input.close()
            do {
                try fileHandle.close()
            } catch {
                print("Unable to Close fileHandle. Error: \(error.localizedDescription)")
            }
        }
        if eventCode.contains(.endEncountered) {
            print("EndOfStream encountered")
            do {
                self.boundStreams.input.close()
                try fileHandle.close()
            } catch {
                print("Unable to Close fileHandle. Error: \(error.localizedDescription)")
            }
        }
    }
}
