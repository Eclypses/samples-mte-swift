//
// ******************************************************
// Copyright © 2023 Eclypses Inc. All rights reserved.
// ******************************************************

import Foundation

enum EncoderType {
    case mte
    case mke
    case flen
}

enum DecoderType {
    case mte
    case mke
    // No flen Decoder type necessary
}

// MTE Defaults
let defEncType = EncoderType.mte
let defDecType = DecoderType.mte
let defFixLen = 100

class MTEHelper {
    
    var mteEntropyCallback: MteEntropyCallback!
    var mteNonceCallback: MteNonceCallback!
    
    // Set up some class variables we will be needing
    private var encoderState: [UInt8]!
    private var decoderState: [UInt8]!

    var encoderEntropy = [UInt8](repeating: 0, count: 32)
    var encoderNonce: UInt64 = 0
    var encoderPersonalizationString: String!

    var decoderEntropy = [UInt8](repeating: 0, count: 32)
    var decoderNonce: UInt64 = 0
    var decoderPersonalizationString: String!
    
    // Encoders
    private var mteEncoder: MteEnc!
    private var mkeEncoder: MteMkeEnc!
    private var flenEncoder: MteFlenEnc!

    // Decoders
    private var mteDecoder: MteDec!
    private var mkeDecoder: MteMkeDec!
        // no flen Decoder is necessary
    
    // MARK: init
    init() throws {
        
        // Get version of MTE we are using
        let mteVersion: String = MteBase.getVersion()
        print("Using MTE Version \(mteVersion)\n")
        
        // Check mte license
        if !MteBase.initLicense(Settings.licCompanyName, Settings.licCompanyKey) {
            throw "License Check failed."
        }
    }
    
    // MARK: Create Encoder
    func createEncoder() throws {
        let encoder = try MteEnc()
        try instantiateEncoder(encoder: encoder)
    }
    
    func createEncoder(drbg: mte_drbgs,
                       tokBytes: Int,
                       verifiers: mte_verifiers) throws {
        let encoder = try MteEnc(drbg,
                                 tokBytes,
                                 verifiers)
        try instantiateEncoder(encoder: encoder)
    }
    
    private func instantiateEncoder(encoder: MteEnc) throws {
        var status = mte_status_success
        encoder.setEntropyCallback(mteEntropyCallback)
        encoder.setNonceCallback(mteNonceCallback)
        
        
        // Instantiate MTE encoder
        status = encoder.instantiate(encoderPersonalizationString)
        if status != mte_status_success {
            throw "\(#function) error: \(resolveErrorMessage(status: status))"
        }
        
//         print("EncoderState: \(encoder.saveStateB64()!)") // Uncomment to confirm Encoder state value and
        // and compare with Server Decoder state. This is a particularly useful debugging tool.
        encoderState = encoder.saveState()
        status = encoder.uninstantiate()
        if status != mte_status_success {
            throw "\(#function) error: \(resolveErrorMessage(status: status))"
        }
    }
    
    // MARK: Create Decoder
    func createDecoder() throws {
        let decoder = try MteDec()
        try instantiateDecoder(decoder: decoder)
    }
    
    func createDecoder(timestampWindow: UInt64,
                       sequenceWindow: Int) throws {
        let decoder = try MteDec(timestampWindow, sequenceWindow)
        try instantiateDecoder(decoder: decoder)
    }
    
    func createDecoder(drbg: mte_drbgs,
                       tokBytes: Int,
                       verifiers: mte_verifiers,
                       timestampWindow: UInt64,
                       sequenceWindow: Int) throws {
        let decoder = try MteDec(drbg,
                                 tokBytes,
                                 verifiers,
                                 timestampWindow,
                                 sequenceWindow)
        try instantiateDecoder(decoder: decoder)
    }
    
    private func instantiateDecoder(decoder: MteDec) throws {
        var status = mte_status_success
        decoder.setEntropyCallback(mteEntropyCallback)
        decoder.setNonceCallback(mteNonceCallback)
        
        // Instantiate MTE encoder
        status = decoder.instantiate(decoderPersonalizationString)
        if status != mte_status_success {
            throw "\(#function) error: \(resolveErrorMessage(status: status))"
        }
        
//         print("DecoderState: \(decoder.saveStateB64()!)") // Uncomment to confirm Decoder state value and
        // and compare with Server Encoder state. This is a particularly useful debugging tool.
        decoderState = decoder.saveState()
        status = decoder.uninstantiate()
        if status != mte_status_success {
            throw "\(#function) error: \(resolveErrorMessage(status: status))"
        }
    }
    
    // MARK: Encode
    func encode(encoderType: EncoderType = defEncType, message: String, fixedLength:  Int = defFixLen) throws -> String {
        var encodeResult: (encoded: String, status: mte_status)!
        var status: mte_status!
        
        switch encoderType {
        case .mte:
        let encoder = try MteEnc()
            status = encoder.restoreState(encoderState)
            if status != mte_status_success {
                throw "\(#function) error: \(resolveErrorMessage(status: status))"
            }
            encodeResult = encoder.encodeB64(message)
            encoderState = encoder.saveState()
            status = encoder.uninstantiate()
        case .mke:
            let encoder = try MteMkeEnc()
            status = encoder.restoreState(encoderState)
            if status != mte_status_success {
                throw "\(#function) error: \(resolveErrorMessage(status: status))"
            }
            encodeResult = encoder.encodeB64(message)
            encoderState = encoder.saveState()
            status = encoder.uninstantiate()
        case .flen:
            let encoder = try MteFlenEnc(fixedLength)
            status = encoder.restoreState(encoderState)
            if status != mte_status_success {
                throw "\(#function) error: \(resolveErrorMessage(status: status))"
            }
            encodeResult = encoder.encodeB64(message)
            encoderState = encoder.saveState()
            status = encoder.uninstantiate()
        }
        if encodeResult.status != mte_status_success {
            throw "\(#function) error: \(resolveErrorMessage(status: status))"
        }
        if status != mte_status_success {
            throw "\(#function) error: \(resolveErrorMessage(status: status))"
        }
        return encodeResult.encoded
    }
    
    func encode(encoderType: EncoderType = defEncType, message: [UInt8]) throws -> [UInt8] {
        var encodeResult: (encoded: ArraySlice<UInt8>, status: mte_status)!
        var status: mte_status!
        
        switch encoderType {
        case .mte:
        let encoder = try MteEnc()
            status = encoder.restoreState(encoderState)
            if status != mte_status_success {
                throw "\(#function) error: \(resolveErrorMessage(status: status))"
            }
            encodeResult = encoder.encode(message)
            encoderState = encoder.saveState()
            status = encoder.uninstantiate()
        case .mke:
            let encoder = try MteMkeEnc()
            status = encoder.restoreState(encoderState)
            if status != mte_status_success {
                throw "\(#function) error: \(resolveErrorMessage(status: status))"
            }
            encodeResult = encoder.encode(message)
            encoderState = encoder.saveState()
            status = encoder.uninstantiate()
        case .flen:
            let encoder = try MteMkeEnc()
            status = encoder.restoreState(encoderState)
            if status != mte_status_success {
                throw "\(#function) error: \(resolveErrorMessage(status: status))"
            }
            encodeResult = encoder.encode(message)
            encoderState = encoder.saveState()
            status = encoder.uninstantiate()
        }
        if encodeResult.status != mte_status_success {
            throw "\(#function) error: \(resolveErrorMessage(status: status))"
        }
        if status != mte_status_success {
            throw "\(#function) error: \(resolveErrorMessage(status: status))"
        }
        return Array(encodeResult.encoded)
    }
    
    // MARK: Decode
    func decode(decoderType: DecoderType = defDecType, encoded: String) throws -> String {
        var decodeResult: (str: String, status: mte_status)!
        var status: mte_status!
        
        switch decoderType {
        case .mte:
        let decoder = try MteDec()
            status = decoder.restoreState(decoderState)
            if status != mte_status_success {
                throw "\(#function) error: \(resolveErrorMessage(status: status))"
            }
            decodeResult = decoder.decodeStrB64(encoded)
            decoderState = decoder.saveState()
            status = decoder.uninstantiate()
        case .mke:
            let decoder = try MteMkeDec()
            status = decoder.restoreState(decoderState)
            if status != mte_status_success {
                throw "\(#function) error: \(resolveErrorMessage(status: status))"
            }
            decodeResult = decoder.decodeStrB64(encoded)
            decoderState = decoder.saveState()
            status = decoder.uninstantiate()
        }
        if decodeResult.status != mte_status_success {
            throw "\(#function) error: \(resolveErrorMessage(status: status))"
        }
        if status != mte_status_success {
            throw "\(#function) error: \(resolveErrorMessage(status: status))"
        }
        return decodeResult.str
    }
    
    func decode(decoderType: DecoderType = defDecType, encoded: [UInt8]) throws -> [UInt8] {
        var decodeResult: (decoded: ArraySlice<UInt8>, status: mte_status)!
        var status: mte_status!
        
        switch decoderType {
        case .mte:
        let decoder = try MteDec()
            status = decoder.restoreState(decoderState)
            if status != mte_status_success {
                throw "\(#function) error: \(resolveErrorMessage(status: status))"
            }
            decodeResult = decoder.decode(encoded)
            decoderState = decoder.saveState()
            status = decoder.uninstantiate()
        case .mke:
            let decoder = try MteMkeDec()
            status = decoder.restoreState(decoderState)
            if status != mte_status_success {
                throw "\(#function) error: \(resolveErrorMessage(status: status))"
            }
            decodeResult = decoder.decode(encoded)
            decoderState = decoder.saveState()
            status = decoder.uninstantiate()
        }
        if decodeResult.status != mte_status_success {
            throw "\(#function) error: \(resolveErrorMessage(status: status))"
        }
        if status != mte_status_success {
            throw "\(#function) error: \(resolveErrorMessage(status: status))"
        }
        return Array(decodeResult.decoded)
    }
    
    // MARK: Chunking
    func startEncrypt() throws -> MteMkeEnc {
        var status: mte_status!
        
        let encoder = try MteMkeEnc()
        status = encoder.restoreState(encoderState)
        if status != mte_status_success {
            throw "\(#function) error: \(resolveErrorMessage(status: status))"
        }
        status = encoder.startEncrypt()
        if status != mte_status_success {
            throw "\(#function) error: \(resolveErrorMessage(status: status))"
        }
        return encoder
    }
    
    func encryptChunk(encoder: MteMkeEnc, buffer: inout [UInt8]) throws {

        let status = encoder.encryptChunk(&buffer)
        if status != mte_status_success {
            throw "\(#function) error: \(resolveErrorMessage(status: status))"
        }
    }
    
    func finishEncrypt(encoder: MteMkeEnc) throws -> [UInt8] {
        let encryptFinishResult = encoder.finishEncrypt()
        if encryptFinishResult.status != mte_status_success {
            throw "\(#function) error: \(resolveErrorMessage(status: encryptFinishResult.status))"
        }
        encoderState = encoder.saveState()
        let status = encoder.uninstantiate()
        if status != mte_status_success {
            throw "\(#function) error: \(resolveErrorMessage(status: status))"
        }
        return Array(encryptFinishResult.encoded)
    }
    
    func startDecrypt() throws -> MteMkeDec {
        var status: mte_status!
        
        let decoder = try MteMkeDec()
        status = decoder.restoreState(decoderState)
        if status != mte_status_success {
            throw "\(#function) error: \(resolveErrorMessage(status: status))"
        }
        status = decoder.startDecrypt()
        if status != mte_status_success {
            throw "\(#function) error: \(resolveErrorMessage(status: status))"
        }
        return decoder
    }
    
    func decryptChunk(decoder: MteMkeDec, data: Data) throws -> [UInt8] {
        let decodeResult = decoder.decryptChunk(data.bytes)
        if decodeResult.status != mte_status_success {
            throw "\(#function) error: \(resolveErrorMessage(status: decodeResult.status))"
        }
        return Array(decodeResult.data)
    }
    
    func finishDecrypt(decoder: MteMkeDec) throws -> [UInt8] {
        let finishDecryptResult = decoder.finishDecrypt()
        if finishDecryptResult.status != mte_status_success {
            throw "\(#function) error: \(resolveErrorMessage(status: finishDecryptResult.status))"
        }
        decoderState = decoder.saveState()
        let status = decoder.uninstantiate()
        if status != mte_status_success {
            throw "\(#function) error: \(resolveErrorMessage(status: status))"
        }
        return Array(finishDecryptResult.data)
    }
    
    func restoreEncoderState(state: [UInt8]) {
        encoderState = state
    }
    
    func restoreDecoderState(state: [UInt8]) {
        decoderState = state
    }
    
    func getEncoderState(state: inout [UInt8]) {
        state = encoderState
    }
    
    func getDecoderState(state: inout [UInt8]) {
        state = decoderState
    }
    
    private func resolveErrorMessage(status: mte_status) -> String {
        return "Status: \(MteBase.getStatusName(status)). Description: \(MteBase.getStatusDescription(status))"
    }
}
