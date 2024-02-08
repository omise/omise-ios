import Foundation
import os

protocol NetworkServiceProtocol {
    var urlRequest: URLRequest { get }
}

class NetworkService {
    let session: URLSession
    let queue: OperationQueue

    init(queue: OperationQueue = OperationQueue()) {
        self.queue = queue
        self.session = URLSession(
            configuration: URLSessionConfiguration.ephemeral,
            delegate: nil,
            delegateQueue: queue
        )
    }

    func get<T: Codable>(
        urlRequest: URLRequest,
        dateFormatter: DateFormatter? = nil,
        completionHandler: @escaping (Result<T, Error>) -> Void
    ) {
        let dataTask = session.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            guard let self = self else { return }

            var result: Result<T, Error>

            defer {
                switch result {
                case .success:
                    os_log("Request succeed", log: sdkLogObject, type: .debug)
                case .failure(let error):
                    os_log("Request failed %{public}@", log: sdkLogObject, type: .info, error.localizedDescription)
                }

                DispatchQueue.main.async {
                    completionHandler(result)
                }
            }

            if let error = error {
                result = .failure(error)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                let error = OmiseError.unexpected(error: .noErrorNorResponse, underlying: nil)
                result = .failure(error)
                return
            }

            let decoder = JSONDecoder()
            if let dateFormatter = dateFormatter {
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
            }

            switch httpResponse.statusCode {
            case 400..<600:
                guard let data = data else {
                    let error = OmiseError.unexpected(error: .httpErrorWithNoData, underlying: nil)
                    result = .failure(error)
                    return
                }

                do {
                    result = .failure(try decoder.decode(OmiseError.self, from: data))
                } catch {
                    let omiseError = OmiseError.unexpected(error: .httpErrorResponseWithInvalidData, underlying: error)
                    result = .failure(omiseError)
                }

            case 200..<300:
                guard let data = data else {
                    let error = OmiseError.unexpected(error: .httpSuccessWithNoData, underlying: nil)
                    result = .failure(error)
                    return
                }

                do {
                    let capability = try decoder.decode(T.self, from: data)
//                    Self.sharedCapability = capability
                    result = .success(capability)
                } catch {
                    let omiseError = OmiseError.unexpected(error: .httpSuccessWithInvalidData, underlying: error)
                    result = .failure(omiseError)
                }

            default:
                let error = OmiseError.unexpected(error: .unrecognizedHTTPStatusCode(code: httpResponse.statusCode), underlying: nil)
                result = .failure(error)
            }
        }
        dataTask.resume()
    }
}
