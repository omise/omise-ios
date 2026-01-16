import ThreeDS_SDK

public enum NetceteraSDKConfigError: Error, Equatable {
    case invalidKeyEncoding
    case apiKeyInvalid
    case cryptoError(Error)
}

public enum NetceteraSDKBridgeError: Error, Equatable {
    case cancelled
    case timedOut
    case protocolError(event: ProtocolErrorEvent?)
    case runtimeError(event: RuntimeErrorEvent?)
    case incomplete(event: CompletionEvent?)
}

// Manual Equatable implementations to avoid forcing underlying SDK errors to conform.
extension NetceteraSDKConfigError {
    public static func == (lhs: NetceteraSDKConfigError, rhs: NetceteraSDKConfigError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidKeyEncoding, .invalidKeyEncoding),
             (.apiKeyInvalid, .apiKeyInvalid):
            return true
        case (.cryptoError(let lErr), .cryptoError(let rErr)):
            return lErr.localizedDescription == rErr.localizedDescription
        default:
            return false
        }
    }
}

extension NetceteraSDKBridgeError {
    public static func == (lhs: NetceteraSDKBridgeError, rhs: NetceteraSDKBridgeError) -> Bool {
        switch (lhs, rhs) {
        case (.cancelled, .cancelled),
             (.timedOut, .timedOut):
            return true
        case (.protocolError(let l), .protocolError(let r)):
            return l?.getErrorMessage() == r?.getErrorMessage()
        case (.runtimeError(let l), .runtimeError(let r)):
            return l?.getErrorMessage() == r?.getErrorMessage()
        case (.incomplete(let l), .incomplete(let r)):
            return l?.getTransactionStatus() == r?.getTransactionStatus()
        default:
            return false
        }
    }
}

public struct NetceteraSDKSessionContext {
    public let transaction: Transaction
    public let sdkTransactionId: String
    public let sdkAppId: String
    public let sdkEphemeralPublicKey: String
    public let deviceInfo: String
}
