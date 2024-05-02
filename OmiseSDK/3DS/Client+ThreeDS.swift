import Foundation
import os

// Client's implementation from V5.0.0
extension Client {
    typealias ResponseClosure<T: Decodable, E: Error> = (Result<T, E>) -> Void

    static func modifyURL(_ originalURL: String, withNewEndpoint newEndpoint: String) -> String? {
        guard var components = URLComponents(string: originalURL) else {
            return nil
        }

        // Remove query items to eliminate GET parameters
        components.queryItems = nil

        // Split the path into components, replace the last one, and reassemble the path
        var pathComponents = components.path.split(separator: "/").map(String.init)
        if !pathComponents.isEmpty {
            pathComponents[pathComponents.count - 1] = newEndpoint
            components.path = "/" + pathComponents.joined(separator: "/")
        } else {
            // If there are no path components, just add the new endpoint
            components.path = newEndpoint
        }

        // Return the new URL string
        return components.url?.absoluteString
    }
    static func send<T: Decodable>(
        session: URLSession,
        urlRequest: URLRequest,
        dateFormatter: DateFormatter?,
        completion: @escaping ResponseClosure<T, Error>
    ) {
        let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
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

    static func logResponse<T: Decodable>(result: Result<T, Error>) {
        switch result {
        case .success:
            os_log("Request succeed", log: sdkLogObject, type: .debug)
        case .failure(let error):
            os_log("Request failed %{public}@", log: sdkLogObject, type: .info, error.localizedDescription)
        }
    }

    static func processResponse<T: Decodable>(dateFormatter: DateFormatter?, data: Data?, statusCode: Int, error: Error?, type: T.Type) -> Result<T, Error> {
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

    static func parseError(decoder: JSONDecoder, data: Data?) -> Error {
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
