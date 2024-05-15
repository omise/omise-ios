import Foundation
import CommonCrypto

enum CryptoError: Error {
    case invalidKeyLength
    case creationError(Int)
    case updateError(Int)
    case finalError(Int)
}

// swiftlint:disable:next function_parameter_count function_body_length
func cryptData(
    _ dataIn: Data,
    operation: CCOperation, // kCCEncrypt, kCCDecrypt
    mode: CCMode,          // kCCModeECB, kCCModeCBC, etc.
    algorithm: CCAlgorithm, // kCCAlgorithmAES, kCCAlgorithmDES, etc.
    padding: CCPadding,     // ccNoPadding, ccPKCS7Padding
    keyLength: size_t,
    iv: Data?,
    key: Data
) throws -> Data {
    guard key.count == keyLength else {
        throw CryptoError.invalidKeyLength
    }

    var cryptor: CCCryptorRef?
    var status = CCCryptorCreateWithMode(operation,
                                         mode,
                                         algorithm,
                                         padding,
                                         iv?.withUnsafeBytes { $0.baseAddress },
                                         key.withUnsafeBytes { $0.baseAddress },
                                         keyLength,
                                         nil,
                                         0,
                                         0,  // tweak XTS mode, numRounds
                                         0,  // CCModeOptions
                                         &cryptor)

    if status != kCCSuccess {
        throw CryptoError.creationError(Int(status))
    }

    guard let cryptor = cryptor else {
        throw CryptoError.creationError(Int(status))
    }

    defer {
        CCCryptorRelease(cryptor)
    }

    let dataOutLength = CCCryptorGetOutputLength(cryptor, dataIn.count, true)
    var dataOut = Data(count: dataOutLength)
    var dataOutMoved = 0

    status = dataOut.withUnsafeMutableBytes { dataOutPointer in
        dataIn.withUnsafeBytes { dataInPointer -> CCCryptorStatus in
            guard let dataInPointerBaseAddress = dataInPointer.baseAddress,
                  let dataOutPointerBaseAddress = dataOutPointer.baseAddress else {
                return Int32(kCCParamError)
            }
            return CCCryptorUpdate(
                cryptor,
                dataInPointerBaseAddress,
                dataIn.count,
                dataOutPointerBaseAddress,
                dataOutLength,
                &dataOutMoved
            )
        }
    }

    if status != kCCSuccess {
        throw CryptoError.updateError(Int(status))
    }

    var dataOutMovedFinal = 0
    status = dataOut.withUnsafeMutableBytes { dataOutPointer in
        guard let dataOutPointerBaseAddress = dataOutPointer.baseAddress else {
            return Int32(kCCParamError)
        }

        return CCCryptorFinal(
            cryptor,
            dataOutPointerBaseAddress.advanced(by: dataOutMoved),
            dataOutLength - dataOutMoved,
            &dataOutMovedFinal
        )
    }

    if status != kCCSuccess {
        throw CryptoError.finalError(Int(status))
    }

    dataOut.count = dataOutMoved + dataOutMovedFinal

    return dataOut
}
