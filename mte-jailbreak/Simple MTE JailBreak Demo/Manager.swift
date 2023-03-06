//
// ******************************************************
// Copyright © 2023 Eclypses Inc. All rights reserved.
// ******************************************************

import Foundation

class Manager: ObservableObject {
    
    @Published var message = Settings.appPurposeText

    var encoder: MteEnc!
    var encoderEntropy: [UInt8] = [UInt8](repeating: 0, count: 32)
    var encoderNonce: UInt64 = 0
    var encoderPersonalizationString: String = ""
    
    var decoder: MteDec!
    var decoderEntropy: [UInt8] = [UInt8](repeating: 0, count: 32)
    var decoderNonce: UInt64 = 0
    var decoderPersonalizationString: String = ""
    
    var jb: MteJail!
    
    let valueToEncode = "hello"
    var status = mte_status_success
    
    func runWithoutJailbreakDetection() {
        setInitialValues()
        instantiateEncoder()
        instantiateDecoder()
        let encoded = encode(plaintext: valueToEncode)
        let decoded = decode(encoded: encoded)
        compare(plaintext: valueToEncode, decoded: decoded)
    }
    
    func runWithJailbreakDetection() {
        setInitialValues()
        instantiateJailbreak()
        instantiateEncoderJail()
        instantiateDecoderJail()
        let encoded = encode(plaintext: valueToEncode)
        let decoded = decode(encoded: encoded)
        compare(plaintext: valueToEncode, decoded: decoded)
    }
    
    func setInitialValues() {
        // Create the entropy we need. Because it will be zeroized when set by the Encoder or Decoder
        // we will copy it from encoderEntropy to decoderEntropy
        let copyStatus = SecRandomCopyBytes(kSecRandomDefault, encoderEntropy.count, &encoderEntropy)
        if copyStatus != errSecSuccess {
            message = "Unable to create Entropy. Error code: \(status)"
            return
        }
        decoderEntropy = encoderEntropy

        // Create the Nonce we need. These are copied as well since they of course need to be the same
        encoderNonce = UInt64.random(in: 1..<9999999999999999)
        decoderNonce = encoderNonce

        // Finally, we need a PersonalizationString, also copied
        encoderPersonalizationString = UUID().uuidString.lowercased()
        decoderPersonalizationString = encoderPersonalizationString
        message = "Initial Values have been set"
    }
    
    func instantiateJailbreak() {
        jb = MteJail()
        jb.setNonceSeed(encoderNonce)
    }
    
    func instantiateEncoder() {
        encoder = try! MteEnc()
        encoder.setEntropy(&encoderEntropy)
        encoder.setNonce(encoderNonce)
        status = encoder.instantiate(encoderPersonalizationString)
        if status != mte_status_success {
            print("Encoder Instantiate error: Status: \(MteBase.getStatusName(status)). Description: \(MteBase.getStatusDescription(status))")
        }
        message = message + "\nEncoder instantiated"
    }
    
    func instantiateEncoderJail() {
        encoder = try! MteEnc()
        encoder.setEntropy(&encoderEntropy)
        encoder.setNonceCallback(jb)
        status = encoder.instantiate(encoderPersonalizationString)
        if status != mte_status_success {
            print("Encoder Instantiate error: Status: \(MteBase.getStatusName(status)). Description: \(MteBase.getStatusDescription(status))")
        }
        message = message + "\nEncoder instantiated with Jailbreak Detection enabled."
    }
    
    func instantiateDecoder() {
        decoder = try! MteDec()
        decoder.setEntropy(&decoderEntropy)
        decoder.setNonce(decoderNonce)
        status = decoder.instantiate(decoderPersonalizationString)
        if status != mte_status_success {
            print("Decoder Instantiate error: Status: \(MteBase.getStatusName(status)). Description: \(MteBase.getStatusDescription(status))")
        }
        message = message + "\nDecoder instantiated."
    }
    
    func instantiateDecoderJail() {
        decoder = try! MteDec()
        decoder.setEntropy(&decoderEntropy)
        decoder.setNonceCallback(jb)
        status = decoder.instantiate(decoderPersonalizationString)
        if status != mte_status_success {
            print("Decoder Instantiate error: Status: \(MteBase.getStatusName(status)). Description: \(MteBase.getStatusDescription(status))")
        }
        message = message + "\nDecoder instantiated with Jailbreak Detection enabled."
    }

    func encode(plaintext: String) -> String {
        let encodeResult = encoder.encodeB64(plaintext)
        if encodeResult.status != mte_status_success {
            message = "Encode error: Status: \(MteBase.getStatusName(status)). Description: \(MteBase.getStatusDescription(status))"
        }
        return encodeResult.encoded
    }
    
    func decode(encoded: String) -> String {
        let decodeResult = decoder.decodeStrB64(encoded)
        if decodeResult.status != mte_status_success {
            message = "Decode error: Status: \(MteBase.getStatusName(status)). Description: \(MteBase.getStatusDescription(status))"
        }
        return decodeResult.str
    }
    
    func compare(plaintext: String, decoded: String) {
        if plaintext == decoded {
            message = message + "\nSUCCESS! - Decoded value matches original plaintext."
        } else {
            message = "\nFAILURE! - Decoded value DOES NOT MATCH original plaintext."
        }
    }

}
