import Foundation
import Security
import CommonCrypto


let pinnedPublicKeyHash = "maqNsxEnwszR+xCmoGUiV636PvSM5zvBIBuupBn9AB8="

private let omiseKeychainPublicKeyTag = "co.omise.sdk.public-key"

let rsa2048Asn1Header:[UInt8] = [
    0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
    0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
]

private func sha256(data : Data) -> String {
    #if swift(>=5.0)
    var keyWithHeader = Data(rsa2048Asn1Header)
    #else
    var keyWithHeader = Data(bytes: rsa2048Asn1Header)
    #endif
    keyWithHeader.append(data)
    var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
    #if swift(>=5.0)
    keyWithHeader.withUnsafeBytes({ (bytes: UnsafeRawBufferPointer) -> Void in
        guard let bytesPointer = bytes.baseAddress else { return }
        _ = CC_SHA256(bytesPointer, CC_LONG(keyWithHeader.count), &hash)
    })
    #else
    keyWithHeader.withUnsafeBytes {
        _ = CC_SHA256($0, CC_LONG(keyWithHeader.count), &hash)
    }
    #endif
    return Data(hash).base64EncodedString()
}


extension Client {
    class PublicKeyPinningSessionDelegate: NSObject, URLSessionDelegate {
        public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            let authChallengeDisposition: URLSession.AuthChallengeDisposition
            let credential: URLCredential?
            
            defer {
                completionHandler(authChallengeDisposition, credential)
            }
            
            var result: SecTrustResultType = SecTrustResultType.invalid
            guard (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust),
                let serverTrust = challenge.protectionSpace.serverTrust,
                SecTrustEvaluate(serverTrust, &result) == errSecSuccess,
                let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
                    authChallengeDisposition = .cancelAuthenticationChallenge
                    credential = nil
                    return
            }
            
            // Public key pinning
            let extractedServerPublicKeyData: Data?
            if #available(iOS 10.3, *) {
                extractedServerPublicKeyData = extractPubliKeyFrom(serverCertificate)
            } else {
                extractedServerPublicKeyData = legacyExtractPubliKeyFrom(serverCertificate)
            }
            
            guard let serverPublicKeyData = extractedServerPublicKeyData else {
                    authChallengeDisposition = .cancelAuthenticationChallenge
                    credential = nil
                    return
            }
            
            let keyHash = sha256(data: serverPublicKeyData)
            if (keyHash == pinnedPublicKeyHash) {
                authChallengeDisposition = .useCredential
                credential = URLCredential(trust:serverTrust)
            } else {
                authChallengeDisposition = .cancelAuthenticationChallenge
                credential = nil
            }
        }
        
        @available(iOS 10.3, *)
        private func extractPubliKeyFrom(_ cerificate: SecCertificate) -> Data? {
            let serverPublicKey = SecCertificateCopyPublicKey(cerificate)
            return serverPublicKey.flatMap({ SecKeyCopyExternalRepresentation($0, nil ) as Data? })
        }
        
        private func legacyExtractPubliKeyFrom(_ certificate: SecCertificate) -> Data? {
            var tempTrust: SecTrust?
            let policy = SecPolicyCreateBasicX509();
            SecTrustCreateWithCertificates(certificate as CFTypeRef, policy, &tempTrust)
            
            guard let scratchPadTrust = tempTrust else {
                return nil
            }
            var result: SecTrustResultType = SecTrustResultType.invalid
            SecTrustEvaluate(scratchPadTrust, &result);
            let publicKey = SecTrustCopyPublicKey(scratchPadTrust);
            let peerPublicKeyAdd = [
                kSecClass: String(kSecClassKey),
                kSecAttrApplicationTag: omiseKeychainPublicKeyTag,
                kSecValueRef: publicKey as Any,
                kSecAttrAccessible: String(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly),
                kSecReturnData: kCFBooleanTrue as Any,
                ] as [String: Any]
            
            let peerPublicKeyDelete = [
                kSecClass: String(kSecClassKey),
                kSecAttrApplicationTag: omiseKeychainPublicKeyTag as CFString,
                kSecReturnData: kCFBooleanTrue as Any,
                ] as [String: Any]
            
            var publicKeyDataType: CFTypeRef?
            if SecItemAdd(peerPublicKeyAdd as CFDictionary, &publicKeyDataType) == errSecSuccess &&
                SecItemDelete(peerPublicKeyDelete as CFDictionary) == errSecSuccess,
                publicKeyDataType is Data? {
                return publicKeyDataType as! Data?
            } else {
                return nil
            }
        }
    }
}

