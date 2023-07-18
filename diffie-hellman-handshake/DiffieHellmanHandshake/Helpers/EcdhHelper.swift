//
// ******************************************************
// Copyright © 2023 Eclypses Inc. All rights reserved.
// ******************************************************
    
import Foundation
import CryptoKit

public class EcdhHelper {
    
    private var sePrivateKey: SecureEnclave.P256.KeyAgreement.PrivateKey!
    private var privateKey: P256.KeyAgreement.PrivateKey!
    private var remotePublicKey: P256.KeyAgreement.PublicKey!
    private var name: String
    
    public init(name: String) throws {
        
        // We use the 'name' param just for debugPrint.
        self.name = name

        // Create privateKey using Secure Enclave if it's available and we aren't on a simulator
        if SecureEnclave.isAvailable && TARGET_OS_SIMULATOR != 1 {
            do {
                sePrivateKey = try SecureEnclave.P256.KeyAgreement.PrivateKey()
            } catch {
                debugPrint("Unable to create private Key with Secure Enclave. Error: \(error.localizedDescription)")
                throw ECDHErrors.unableToInitializeEcdhHelper
            }
        } else {
            privateKey = P256.KeyAgreement.PrivateKey()
        }
        debugPrint("EcdhHelper has been instantiated for \(name)")
    }
    
    deinit {
        // This is included primarily to demonstrate the short lifecycle of this class
        debugPrint("EcdhHelper has been destroyed for \(name)")
    }
    
    public func getPublicKey() throws -> String {
        var publicKeyData = Data()
        if SecureEnclave.isAvailable && TARGET_OS_SIMULATOR != 1 {
            publicKeyData = sePrivateKey.publicKey.derRepresentation
        } else {
            publicKeyData = privateKey.publicKey.derRepresentation
        }
        return publicKeyData.base64EncodedString()
    }

    public func createSharedSecret(remotePublicKeyStr: String, entropy: inout [UInt8]) throws {
        do {
            try setRemotePublicKey(keyString: remotePublicKeyStr)
            var sharedSecret: SharedSecret
            
            // create the shared secret
            if SecureEnclave.isAvailable && TARGET_OS_SIMULATOR != 1 {
                sharedSecret = try sePrivateKey.sharedSecretFromKeyAgreement(with: remotePublicKey)
            } else {
                sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: remotePublicKey)
            }
            
            // because C# does it this way, we'll grab the shared secret data and hash it,
            // then convert it to a [UInt8] to use as entropy
            var sharedSecretData = sharedSecret.withUnsafeBytes {Data(Array($0))}
            let sharedSecretDataHash = SHA256.hash(data: sharedSecretData)
            entropy = sharedSecretDataHash.withUnsafeBytes {Data(Array($0))}.bytes
            
            // While not strictly necessary because this class is about to be destroyed, we'll zero out the 'sensitive' data.
            // entropy byte array will be zeroized immediately after using it.
            sharedSecretData.resetBytes(in: 0...sharedSecretData.count-1)
            var hashData = sharedSecretDataHash.withUnsafeBytes {Data(Array($0))}
            hashData.resetBytes(in: 0...hashData.count-1)
        } catch {
            debugPrint("Unable to create Shared Secret. Error: \(error.localizedDescription)")
            throw ECDHErrors.unableToCreateSharedSecret
        }
    }

    private func setRemotePublicKey(keyString: String) throws {
        do {
            guard let publicKeyData = Data(base64Encoded: keyString) else {
                throw ECDHErrors.unableToCreateRemotePublicKeyData
            }
            remotePublicKey = try P256.KeyAgreement.PublicKey(derRepresentation: publicKeyData)
        } catch {
            debugPrint("Unable to create Remote Public Key with Secure Enclave. Error: \(error.localizedDescription)")
            throw ECDHErrors.unableToCreateRemotePublicKey
        }
    }
}

enum ECDHErrors: Error {
    case unableToInitializeEcdhHelper
    case unableToCreateLocalPublicKey
    case unableToCreateRemotePublicKeyData
    case unableToCreateRemotePublicKey
    case unableToCreateSharedSecret
    
    var resultCode: String {
        switch self {
        case .unableToInitializeEcdhHelper:
            return "Unable to Initialize an Elliptic Curve Diffie-Hellman Helper. Unable to Continue."
        case .unableToCreateLocalPublicKey:
            return "Unable to Create an Elliptic Curve Diffie-Hellman Public Key with Secure Enclave for this Device. Unable to Continue."
        case .unableToCreateRemotePublicKeyData:
            return "Unable to convert the provided string to Public Key data. Unable to Continue."
        case .unableToCreateRemotePublicKey:
            return "Unable to Create an Elliptic Curve Diffie-Hellman Public Key using Secure Enclave with public key from the remote endpoint. Unable to Continue."
        case .unableToCreateSharedSecret:
            return "Unable to Create a Elliptic Curve Diffie-Hellman Shared Secret. Unable to Continue."
        }
    }
}

