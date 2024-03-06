import Foundation
import os

protocol NetworkServiceProtocol {
    typealias RequestResultClosure<T: Decodable, E: Error> = (Result<T, E>) -> Void

    func send<T: Decodable>(
        urlRequest: URLRequest,
        dateFormatter: DateFormatter?,
        completion: @escaping RequestResultClosure<T, Error>
    )
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
}

extension NetworkService: NetworkServiceProtocol {
    func send<T: Decodable>(
        urlRequest: URLRequest,
        dateFormatter: DateFormatter?,
        completion: @escaping RequestResultClosure<T, Error>
    ) {
        let dataTask = session.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            guard let self = self else { return }

            var result: Result<T, Error>
            if let error = error {
                result = .failure(error)
            } else if let httpResponse = response as? HTTPURLResponse {
                result = self.processResponse(
                    dateFormatter: dateFormatter,
                    data: data,
                    statusCode: httpResponse.statusCode,
                    error: error,
                    type: T.self
                )
            } else {
                let error = OmiseError.unexpected(error: .noErrorNorResponse, underlying: nil)
                result = .failure(error)
            }

            self.logResponse(result: result)

            DispatchQueue.main.async {
                completion(result)
            }
        }
        dataTask.resume()
        
        os_log(
            "Starting/Resuming Request %{public}@",
            log: sdkLogObject,
            type: .debug,
            String(describing: type(of: T.self))
        )

    }
}

private extension NetworkService {
    func logResponse<T: Decodable>(result: Result<T, Error>) {
        switch result {
        case .success:
            os_log("Request succeed", log: sdkLogObject, type: .debug)
        case .failure(let error):
            os_log("Request failed %{public}@", log: sdkLogObject, type: .info, error.localizedDescription)
        }
    }

    func processResponse<T: Decodable>(dateFormatter: DateFormatter?, data: Data?, statusCode: Int, error: Error?, type: T.Type) -> Result<T, Error> {
        let decoder = JSONDecoder()
        if let dateFormatter = dateFormatter {
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
        }

        switch statusCode {
        case 400..<600:
            return .failure(parseError(decoder: decoder, data: data))

        case 200..<300:
            guard let data = data else {
                let omiseError = OmiseError.unexpected(error: .httpSuccessWithNoData, underlying: nil)
                return .failure(omiseError)
            }

            do {
                let object = try decoder.decode(T.self, from: data)
                return .success(object)
            } catch {
                let omiseError = OmiseError.unexpected(error: .httpSuccessWithInvalidData, underlying: error)
                return .failure(omiseError)
            }

        default:
            let unexpectedError = OmiseError.UnexpectedError.unrecognizedHTTPStatusCode(code: statusCode)
            let error = OmiseError.unexpected(error: unexpectedError, underlying: nil)
            return .failure(error)
        }
    }

    func parseError(decoder: JSONDecoder, data: Data?) -> Error {
        guard let data = data else {
            return OmiseError.unexpected(error: .httpErrorWithNoData, underlying: nil)
        }

        do {
            return try decoder.decode(OmiseError.self, from: data)
        } catch {
            return OmiseError.unexpected(
                error: .httpErrorResponseWithInvalidData, underlying: error
            )
        }
    }
}
