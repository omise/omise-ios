import Foundation
@testable import OmiseSDK

class MockClient: ClientProtocol {
    var latestLoadedCapability: Capability?
    
    var shouldShowError: Bool = false
    
    let error = NSError(domain: "Error", code: 0)
    
    func capability(_ completion: @escaping ResponseClosure<Capability, any Error>) {
        if shouldShowError {
            completion(.failure(error))
        } else {
            do {
                let capability: Capability = try sampleFromJSONBy(.capability)
                latestLoadedCapability = capability
                completion(.success(capability))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func createSource(payload: CreateSourcePayload, _ completion: @escaping ResponseClosure<Source, any Error>) {
        if shouldShowError {
            completion(.failure(error))
        } else {
            do {
                completion(.success(try getSource(type: payload.details.sourceType)))
            } catch {
                completion(.failure(error))
            }
        }
        
    }
    
    func createToken(payload: CreateTokenPayload, _ completion: @escaping ResponseClosure<Token, any Error>) {
        if shouldShowError {
            completion(.failure(error))
        } else {
            do {
                completion(.success(try getToken()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func createToken(applePayToken: CreateTokenApplePayPayload, _ completion: @escaping ResponseClosure<Token, any Error>) {
        if shouldShowError {
            completion(.failure(error))
        } else {
            do {
                completion(.success(try getToken()))
            } catch {
                completion(.failure(error))
            }
        }
        
    }
    
    func token(tokenID: String, _ completion: @escaping ResponseClosure<Token, any Error>) {
        if shouldShowError {
            completion(.failure(error))
        } else {
            do {
                completion(.success(try getToken()))
            } catch {
                completion(.failure(error))
            }
        }
        
    }
    
    func observeChargeStatus(tokenID: String, _ completion: @escaping ResponseClosure<Token.ChargeStatus, any Error>) {
        if shouldShowError {
            completion(.failure(error))
        } else {
            completion(.success(.successful))
        }
    }
    
}
 
extension MockClient {
    func getToken() throws -> Token {
        let token: Token = try sampleFromJSONBy(.token)
        return token
    }
    
    func getSource(type: SourceType = .applePay) throws -> Source {
        let source: Source = try sampleFromJSONBy(.source(type: type))
        return source
    }
}
