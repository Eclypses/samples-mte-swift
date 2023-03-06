// The MIT License (MIT)
//
// Copyright (c) Eclypses, Inc.
//
// All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
import Foundation

// Imports when creating a Swift Package Manager package.
#if MTE_SWIFT_PACKAGE_MANAGER
import Mte
import Core
import MKE
#endif

// Class MteSdr
//
// This is the MTE Secure Data Replacement Add-On.
//
// To use, create an object of this type. Next, call initSdr() to initialize.
// Call any of the read*() and write() methods to read and write data and
// strings. Call remove() to remove items. The entire SDR may be removed with
// removeSdr().
//
// The internal methods may be overridden to provide a different backing store
// and timestamp if desired.
open class MteSdr {
  // Initialize taking the directory for the SDR to use.
  //
  // Default-initialized MKE encoder and decoder are created.
  public convenience init(_ sdrDir: String) throws {
    self.init(try MteMkeEnc(), try MteMkeDec(), sdrDir)
  }

  // Initialize taking the MKE encoder/decoder and directory for the SDR to
  // use.
  //
  // Note: the MKE encoder/decoder provided to this object cannot be used
  // outside this object as this object will change their states.
  public init(_ enc: MteMkeEnc, _ dec: MteMkeDec, _ sdrDir: String) {
    // Save the encoder and decoder.
    myEnc = enc
    myDec = dec

    // Set the callbacks to nil to ensure our entropy and nonce will be used
    // and to ensure timestamps are disabled.
    myEnc.setEntropyCallback(nil)
    myDec.setEntropyCallback(nil)
    myEnc.setNonceCallback(nil)
    myDec.setNonceCallback(nil)
    myEnc.setTimestampCallback(nil)
    myDec.setTimestampCallback(nil)

    // Save the SDR path.
    mySdrPath = sdrDir
  }

  // Deallocate.
  deinit {
    // Zeroize the entropy.
    myEntropy.resetBytes(in: 0..<myEntropy.count)
  }

  // Returns the MKE encoder/decoder in use. These should only be used for
  // information.
  public func getEncoder() -> MteMkeEnc {
    return myEnc
  }
  public func getDecoder() -> MteMkeDec {
    return myDec
  }

  // Initializes the SDR with the entropy and nonce to use. Throws an
  // exception if the SDR cannot be created.
  public func initSdr(_ entropy: [UInt8], _ nonce: UInt64) throws {
    // Save the entropy and nonce.
    myEntropy = entropy
    myNonce = nonce

    // If the SDR directory does not exist, create it.
    if !dirExists(mySdrPath) {
      try createDir(mySdrPath)
    }
  }

  // Read from storage or memory as data or a string. If the same name exists in
  // memory and on storage, the memory version is read. Throws an exception on
  // I/O error.
  public func readData(_ name: String) throws -> ArraySlice<UInt8> {
    var status: mte_status
    var encodedAll: [UInt8]?
    var decoded: ArraySlice<UInt8>

    // Read the data.
    encodedAll = myMemFiles[name]
    if encodedAll == nil {
      encodedAll = try readFile(mySdrPath, name)
    }

    // Extract the timestamp. XOR the nonce into it.
    var nonce = UInt64(0)
    for i in 0..<MemoryLayout<UInt64>.size {
      nonce += UInt64(encodedAll![i]) << (i * 8)
    }
    nonce ^= myNonce

    // Copy the entropy because it will be zeroized. Instantiate with this name
    // and the SDR entropy and nonce.
    var eCopy = myEntropy
    myDec.setEntropy(&eCopy)
    myDec.setNonce(nonce)
    status = myDec.instantiate(name)
    if status != mte_status_success {
      throw MteError.runtimeError("Error instantiating decoder (" +
                                  MteBase.getStatusName(status) +
                                  "): " +
                                  MteBase.getStatusDescription(status))
    }

    // Remove the timestamp that is prepended.
    let encoded = [UInt8](encodedAll![MemoryLayout<UInt64>.size...])

    // Decode the data.
    (decoded, status) = myDec.decode(encoded)
    if status != mte_status_success {
      throw MteError.runtimeError("Error decoding data (" +
                                  MteBase.getStatusName(status) +
                                  "): " +
                                  MteBase.getStatusDescription(status))
    }

    // Return the data.
    return decoded
  }
  public func readString(_ name: String) throws -> String {
    var status: mte_status
    var encodedAll: [UInt8]?
    var decoded: String

    // Read the data.
    encodedAll = myMemFiles[name]
    if encodedAll == nil {
      encodedAll = try readFile(mySdrPath, name)
    }

    // Extract the timestamp. XOR the nonce into it.
    var nonce = UInt64(0)
    for i in 0..<MemoryLayout<UInt64>.size {
      nonce += UInt64(encodedAll![i]) << (i * 8)
    }
    nonce ^= myNonce

    // Copy the entropy because it will be zeroized. Instantiate with this name
    // and the SDR entropy and nonce.
    var eCopy = myEntropy
    myDec.setEntropy(&eCopy)
    myDec.setNonce(nonce)
    status = myDec.instantiate(name)
    if status != mte_status_success {
      throw MteError.runtimeError("Error instantiating decoder (" +
                                  MteBase.getStatusName(status) +
                                  "): " +
                                  MteBase.getStatusDescription(status))
    }

    // Remove the timestamp that is prepended.
    let encoded = [UInt8](encodedAll![MemoryLayout<UInt64>.size...])

    // Decode the data.
    (decoded, status) = myDec.decodeStr(encoded)
    if status != mte_status_success {
      throw MteError.runtimeError("Error decoding data (" +
                                  MteBase.getStatusName(status) +
                                  "): " +
                                  MteBase.getStatusDescription(status))
    }

    // Return the data.
    return decoded
  }

  // Write the given data or string to storage or memory. If the name matches
  // the name of a previously written file, this will overwrite it. If toMemory
  // is true, the data or string is saved to memory and not written to permanent
  // storage; there are no restrictions on the contents of the name argument.
  // If toMemory is false, the data or string is saved to permanent storage in
  // the SDR directory set in the initializer; the name argument must be a
  // valid filename. Throws an exception on I/O error or MTE error.
  public func write(_ name: String,
                    _ data: [UInt8],
                    toMemory: Bool = false) throws {
    var status: mte_status
    var encoded: ArraySlice<UInt8>

    // Get the timestamp. XOR the nonce into it.
    let ts = getTimestamp()
    let nonce = ts ^ myNonce

    // Copy the entropy because it will be zeroized. Instantiate with this name
    // and the SDR entropy and nonce.
    var eCopy = myEntropy
    myEnc.setEntropy(&eCopy)
    myEnc.setNonce(nonce)
    status = myEnc.instantiate(name)
    if status != mte_status_success {
      throw MteError.runtimeError("Error instantiating encoder (" +
                                  MteBase.getStatusName(status) +
                                  "): " +
                                  MteBase.getStatusDescription(status))
    }

    // Encode the data.
    (encoded, status) = myEnc.encode(data)
    if status != mte_status_success {
      throw MteError.runtimeError("Error encoding data (" +
                                  MteBase.getStatusName(status) +
                                  "): " +
                                  MteBase.getStatusDescription(status))
    }

    // Prepend the timestamp to the encoded version.
    var encodedAll = withUnsafeBytes(of: ts.littleEndian, Array.init)
    encodedAll.append(contentsOf: encoded)

    // If saving to memory, add it to the memory map.
    if toMemory {
      myMemFiles[name] = encodedAll
    }
    else {
      // Otherwise write it to the SDR.
      try writeFile(mySdrPath, name, encodedAll)
    }
  }
  public func write(_ name: String,
                    _ str: String,
                    toMemory: Bool = false) throws {
    var status: mte_status
    var encoded: ArraySlice<UInt8>

    // Get the timestamp. XOR the nonce into it.
    let ts = getTimestamp()
    let nonce = ts ^ myNonce

    // Copy the entropy because it will be zeroized. Instantiate with this name
    // and the SDR entropy and nonce.
    var eCopy = myEntropy
    myEnc.setEntropy(&eCopy)
    myEnc.setNonce(nonce)
    status = myEnc.instantiate(name)
    if status != mte_status_success {
      throw MteError.runtimeError("Error instantiating encoder (" +
                                  MteBase.getStatusName(status) +
                                  "): " +
                                  MteBase.getStatusDescription(status))
    }

    // Encode the data.
    (encoded, status) = myEnc.encode(str)
    if status != mte_status_success {
      throw MteError.runtimeError("Error encoding data (" +
                                  MteBase.getStatusName(status) +
                                  "): " +
                                  MteBase.getStatusDescription(status))
    }

    // Prepend the timestamp to the encoded version.
    var encodedAll = withUnsafeBytes(of: ts.littleEndian, Array.init)
    encodedAll.append(contentsOf: encoded)

    // If saving to memory, add it to the memory map.
    if toMemory {
      myMemFiles[name] = encodedAll
    }
    else {
      // Otherwise write it to the SDR.
      try writeFile(mySdrPath, name, encodedAll)
    }
  }

  // Remove an SDR item. If the same name exists in memory and on storage, the
  // memory version is removed.
  //
  // It is not an error to remove an item that does not exist. An exception is
  // thrown if the file exists and cannot be removed.
  public func remove(_ name: String) throws {
    // Remove from memory if it exists there.
    if myMemFiles[name] != nil {
      myMemFiles[name] = nil
    }
    else {
      // Remove from the SDR if it exists there.
      try removeFile(mySdrPath, name)
    }
  }

  // Remove the SDR. All memory and storage items are removed. This object is
  // not usable until a new call to initSdr().
  //
  // It is not an error to remove an SDR that does not exist. An exception is
  // thrown if any file in the SDR cannot be removed.
  public func removeSdr() throws {
    // If the SDR directory exists, remove.
    if dirExists(mySdrPath) {
      // Remove each file.
      let files = try listFiles(mySdrPath)
      for file in files {
        try removeFile(mySdrPath, file)
      }

      // Remove the SDR directory.
      try removeDir(mySdrPath)
    }
  }

  // Returns true if the directory exists, false if not.
  internal func dirExists(_ dir: String) -> Bool {
    return FileManager.default.fileExists(atPath: dir)
  }

  // Returns true if the file exists in the directory, false if not.
  internal func fileExists(_ dir: String, _ file: String) -> Bool {
    let path = URL(fileURLWithPath: file,
                   relativeTo: URL(fileURLWithPath: dir, isDirectory: true))
    return FileManager.default.fileExists(atPath: path.path)
  }

  // Returns a list of file basenames in a directory. Throws an exception on
  // failure.
  internal func listFiles(_ dir: String) throws -> [String] {
    return try FileManager.default.contentsOfDirectory(atPath: dir)
  }

  // Creates a directory, including any intermediate directories as necessary.
  // Throws an exception on failure.
  internal func createDir(_ dir: String) throws {
    try FileManager.default.createDirectory(atPath: dir,
                                            withIntermediateDirectories: true)
  }

  // Reads a file. Returns the file contents. Throws an exception on failure.
  internal func readFile(_ dir: String, _ file: String) throws -> [UInt8] {
    let path = URL(fileURLWithPath: file,
                   relativeTo: URL(fileURLWithPath: dir, isDirectory: true))
    return try [UInt8](Data(contentsOf: path))
  }

  // Writes a file. Throws an exception on failure.
  internal func writeFile(_ dir: String,
                          _ file: String,
                          _ contents: [UInt8]) throws {
    let path = URL(fileURLWithPath: file,
                   relativeTo: URL(fileURLWithPath: dir, isDirectory: true))
    try Data(contents).write(to: path)
  }

  // Removes a directory. Throws an exception on failure.
  internal func removeDir(_ dir: String) throws {
    if dirExists(dir) {
      try FileManager.default.removeItem(atPath: dir)
    }
  }

  // Removes a file. Throws an exception on failure.
  internal func removeFile(_ dir: String, _ file: String) throws {
    if fileExists(dir, file) {
      let path = URL(fileURLWithPath: file,
                     relativeTo: URL(fileURLWithPath: dir, isDirectory: true))
      try FileManager.default.removeItem(at: path)
    }
  }

  // Returns the timestamp, byte swapped to increase the entropy in the upper
  // bytes.
  internal func getTimestamp() -> UInt64 {
    let ts = UInt64(Date().timeIntervalSince1970 * 1000.0)
    return ts.byteSwapped
  }

  // The encoder and decoder.
  private var myEnc: MteMkeEnc
  private var myDec: MteMkeDec
  private var myEntropy = [UInt8]()
  private var myNonce: UInt64 = 0

  // The SDR path.
  private var mySdrPath: String

  // Memory files.
  private var myMemFiles: [String: [UInt8]] = [:]
}

