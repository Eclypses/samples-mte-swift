//
// ******************************************************
// Copyright © 2023 Eclypses Inc. All rights reserved.
// ******************************************************
    

import Foundation

print("******  Simple MTE Sequencing Create Encoder Console Demo  ******")
print("Using MTE Version \(MteBase.getVersion())")

var status = mte_status_success

// Inputs.
let inputs = ["message 1", "message 2", "message 3", "message 4"]
var encodings = [String]()

// MARK: Initial Values

// Create the cryptographically secure entropy we need. Because it will be zeroized
// when set by the Encoder or Decoder, we will copy it from encoderEntropy to decoderEntropy
var encoderEntropy = [UInt8](repeating: 0, count: 32)
let copyStatus = SecRandomCopyBytes(kSecRandomDefault, encoderEntropy.count, &encoderEntropy)
if copyStatus != errSecSuccess {
    print("Unable to create Entropy. Error code: \(status)")
}
// In later Samples we will decode the above encodings so we'll go ahead and create the
// Decoder Initial Values for each Decoder Sample as well
var decoderVEntropy = encoderEntropy
var decoderFEntropy = encoderEntropy
var decoderAEntropy = encoderEntropy

// Create the Nonces we need. Decoder Nonce is copied as well since it of course needs match the Encoder
let encoderNonce = UInt64.random(in: 1..<9999999999999999)
let decoderVNonce = encoderNonce
let decoderFNonce = encoderNonce
let decoderANonce = encoderNonce

// Finally, we need a PersonalizationString, also copied
let encoderPersonalizationString = UUID().uuidString.lowercased()
let decoderVPersonalizationString = encoderPersonalizationString
let decoderFPersonalizationString = encoderPersonalizationString
let decoderAPersonalizationString = encoderPersonalizationString

// MARK: License Check
if !MteBase.initLicense("YOUR_COMPANY", "YOUR_LICENSE") {
    print("License Check Failed")
}

// MARK: Default Encoder
let encoder = try! MteEnc()
encoder.setEntropy(&encoderEntropy)
encoder.setNonce(encoderNonce)
status = encoder.instantiate(encoderPersonalizationString)
if status != mte_status_success {
    print("""
"Encoder Instantiate error: Status: \(MteBase.getStatusName(status)). \
Description: \(MteBase.getStatusDescription(status))
""")
}

// MARK: Encode and store the input values

inputs.forEach {
    let encodeResult = encoder.encodeB64($0)
    if status != mte_status_success {
        print("""
    Encoder Encode error: Status: \(MteBase.getStatusName(status)).
    Description: \(MteBase.getStatusDescription(status))
    """)
    }
    encodings.append(encodeResult.encoded)
    print("\n\nClear input: '\($0)'\nEncoded Value: \n\(encodeResult.encoded)")
}

encodings.forEach {
    print($0)
}

// MARK: Verification Only Decoder
// Create Decoder with Verification-Only sequencing
// When constructing an MteDec the second argument is
// the sequence window (the first is the timestamp window)
let decoderV = try! MteDec(0, 0)
decoderV.setEntropy(&decoderVEntropy)
decoderV.setNonce(decoderVNonce)
status = decoderV.instantiate(decoderVPersonalizationString)
if status != mte_status_success {
    print("""
DecoderV instantiate error: Status: \(MteBase.getStatusName(status)).
Description: \(MteBase.getStatusDescription(status))
""")
}

print("\nVerification-only mode (sequence window = 0):")

// MARK: Decodings
// #1
print("\nDecode the first message")
print("Expected Output: mte_status_success, '\(inputs[0])'")
let decodeResult1 = decoderV.decodeStrB64(encodings[0])
print("Decoded results: \(MteBase.getStatusName(decodeResult1.status)), '\(decodeResult1.str)'")

// #2
print("\nAttempt to decode the first message again. This should fail.")
print("Expected Output: mte_status_seq_outside_window, ''")
let decodeResult2 = decoderV.decodeStrB64(encodings[0])
print("Decoded results: \(MteBase.getStatusName(decodeResult2.status)), '\(decodeResult2.str)'")

// #3
print("\nAttempt to decode the third message -- out of sequence, should not work")
print("Expected Output: mte_status_seq_outside_window, ''")
let decodeResult3 = decoderV.decodeStrB64(encodings[2])
print("Decoded results: \(MteBase.getStatusName(decodeResult3.status)), '\(decodeResult3.str)'")

// #4
print("\nDecode the second message")
print("Expected Output: mte_status_success, '\(inputs[1])'")
let decodeResult4 = decoderV.decodeStrB64(encodings[1])
print("Decoded results: \(MteBase.getStatusName(decodeResult4.status)), '\(decodeResult4.str)'")

// #5
print("\nDecode the third message")
print("Expected Output: mte_status_success, '\(inputs[2])'")
let decodeResult5 = decoderV.decodeStrB64(encodings[2])
print("Decoded results: \(MteBase.getStatusName(decodeResult5.status)), '\(decodeResult5.str)'")

// #6
print("\nDecode the fourth message")
print("Expected Output: mte_status_success, '\(inputs[3])'")
let decodeResult6 = decoderV.decodeStrB64(encodings[3])
print("Decoded results: \(MteBase.getStatusName(decodeResult6.status)), '\(decodeResult6.str)'")


// MARK: Forward Only Decoder
// Create Forward-only Decoder
// For this sample, sequence window is being set to 2
let decoderF = try! MteDec(0, 2)
decoderF.setEntropy(&decoderFEntropy)
decoderF.setNonce(decoderFNonce)
status = decoderF.instantiate(decoderFPersonalizationString)
if status != mte_status_success {
    print("""
DecoderF instantiate error: Status: \(MteBase.getStatusName(status)).
Description: \(MteBase.getStatusDescription(status))
""")
}

// String to decode to
var decoded: String = ""

// Create a corrupt version of message #2.
// Doing this will ensure decode fails
let corrupt = String(encodings[2].reversed())

print("\nForward-only mode (sequence window = 2):")

// MARK: Decodings
// #7
print("\nDecode the first message")
print("Expected Output: mte_status_success, '\(inputs[0])'")
let decodeResult7 = decoderF.decodeStrB64(encodings[0])
print("Decoded results: \(MteBase.getStatusName(decodeResult7.status)), '\(decodeResult7.str)'")

// #8
print("\nAttempt to Decode the first message again. This should fail.")
print("Expected Output: mte_status_seq_outside_window, ''")
let decodeResult8 = decoderF.decodeStrB64(encodings[0])
print("Decoded results: \(MteBase.getStatusName(decodeResult8.status)), '\(decodeResult8.str)'")

// #9
print("\nAttempt to decode the corrupt message -- out of sequence, should not work")
print("Expected Output: mte_status_seq_outside_window, ''")
let decodeResult9 = decoderF.decodeStrB64(corrupt)
print("Decoded results: \(MteBase.getStatusName(decodeResult9.status)), '\(decodeResult9.str)'")

// #410
print("\nDecode the third message (within the sequence window)")
print("Expected Output: mte_status_success, '\(inputs[2])'")
let decodeResult10 = decoderF.decodeStrB64(encodings[2])
print("Decoded results: \(MteBase.getStatusName(decodeResult10.status)), '\(decodeResult10.str)'")

// #11
print("\nDecode the second message (after already decoding the third - out of sequence)")
print("Expected Output: mte_status_seq_outside_window, ''")
let decodeResult11 = decoderF.decodeStrB64(encodings[1])
print("Decoded results: \(MteBase.getStatusName(decodeResult11.status)), '\(decodeResult11.str)'")

// #12
print("\nDecode the third message again (out of sequence) Should not work")
print("Expected Output: mte_status_seq_outside_window, ''")
let decodeResult12 = decoderF.decodeStrB64(encodings[2])
print("Decoded results: \(MteBase.getStatusName(decodeResult12.status)), '\(decodeResult12.str)'")

// #13
print("\nDecode the fourth message")
print("Expected Output: mte_status_success, '\(inputs[3])'")
let decodeResult13 = decoderF.decodeStrB64(encodings[3])
print("Decoded results: \(MteBase.getStatusName(decodeResult13.status)), '\(decodeResult13.str)'")


// MARK: Async Decoder
// Create async decoder
// For this sample sequence window is being set to -2
let decoderA = try! MteDec(0, -2)
decoderA.setEntropy(&decoderAEntropy)
decoderA.setNonce(decoderANonce)
status = decoderA.instantiate(decoderAPersonalizationString)
if status != mte_status_success {
    print("""
DecoderA instantiate error: Status: \(MteBase.getStatusName(status)).
Description: \(MteBase.getStatusDescription(status))
""")
}

// Save the async Decoder state. We will need the original state for the second half of this Sample.
let decState = decoderA.saveState()!

print("\nAsync mode (sequence window = -2):")

// MARK: Decodings
// #14
print("\nDecode the first message")
print("Expected Output: mte_status_success, '\(inputs[0])'")
let decodeResult14 = decoderA.decodeStrB64(encodings[0])
print("Decoded results: \(MteBase.getStatusName(decodeResult14.status)), '\(decodeResult14.str)'")

// #15
print("\nAttempt to decode the first message again. This should fail.")
print("Expected Output: mte_status_seq_outside_window, ''")
let decodeResult15 = decoderA.decodeStrB64(encodings[0])
print("Decoded results: \(MteBase.getStatusName(decodeResult15.status)), '\(decodeResult15.str)'")

// #16
print("\nAttempt to decode the corrupt message -- out of sequence, should not work")
print("Expected Output: mte_status_seq_outside_window, ''")
let decodeResult16 = decoderA.decodeStrB64(corrupt)
print("Decoded results: \(MteBase.getStatusName(decodeResult16.status)), '\(decodeResult16.str)'")

// #17
print("\nDecode the third message (within the sequence window)")
print("Expected Output: mte_status_success, '\(inputs[2])'")
let decodeResult17 = decoderA.decodeStrB64(encodings[2])
print("Decoded results: \(MteBase.getStatusName(decodeResult17.status)), '\(decodeResult17.str)'")

// #18
print("\nDecode the second message (after already decoding the third - should work due to async decoder)")
print("Expected Output: mte_status_success, '\(inputs[1])'")
let decodeResult18 = decoderA.decodeStrB64(encodings[1])
print("Decoded results: \(MteBase.getStatusName(decodeResult18.status)), '\(decodeResult18.str)'")

// #19
print("\nDecode the third message again (out of sequence) Should not work")
print("Expected Output: mte_status_seq_outside_window, ''")
let decodeResult19 = decoderA.decodeStrB64(encodings[2])
print("Decoded results: \(MteBase.getStatusName(decodeResult19.status)), '\(decodeResult19.str)'")

// #20
print("\nDecode the fourth message")
print("Expected Output: mte_status_success, '\(inputs[3])'")
let decodeResult20 = decoderA.decodeStrB64(encodings[3])
print("Decoded results: \(MteBase.getStatusName(decodeResult20.status)), '\(decodeResult20.str)'")

// Restore the Decoder to its initial state  and decode again in a different order
status = decoderA.restoreState(decState)
print("\nRestored Decoder state")

// #21
print("\nDecode the fourth message first this time")
print("Expected Output: mte_status_success, '\(inputs[3])'")
let decodeResult21 = decoderA.decodeStrB64(encodings[3])
print("Decoded results: \(MteBase.getStatusName(decodeResult21.status)), '\(decodeResult21.str)'")

// #22
print("\nAttempt to Decode the first message next. Should fail (sequence too large).")
print("Expected Output: mte_status_seq_outside_window, ''")
let decodeResult22 = decoderA.decodeStrB64(encodings[0])
print("Decoded results: \(MteBase.getStatusName(decodeResult22.status)), '\(decodeResult22.str)'")

// #23
print("\nDecode the third message (within the sequence window) Should work")
print("Expected Output: mte_status_success, '\(inputs[2])'")
let decodeResult23 = decoderA.decodeStrB64(encodings[2])
print("Decoded results: \(MteBase.getStatusName(decodeResult23.status)), '\(decodeResult23.str)'")

// #24
print("\nDecode the second message (after already decoding the third) Should work.")
print("Expected Output: mte_status_success, '\(inputs[1])'")
let decodeResult24 = decoderA.decodeStrB64(encodings[1])
print("Decoded results: \(MteBase.getStatusName(decodeResult24.status)), '\(decodeResult24.str)'")

print("\n\nCompleted. Application will close")
