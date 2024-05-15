import Foundation

extension URL {
    func match(string: String) -> Bool {
        guard
            let expectedURLComponents = URLComponents(string: string),
            let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return false
        }

        return expectedURLComponents.match(components: components)
    }
}

extension URLComponents {
    func match(string: String) -> Bool {
        guard let expectedURLComponents = URLComponents(string: string) else { return false }
        return match(components: expectedURLComponents)
    }

    func match(components expectedURLComponents: URLComponents) -> Bool {
        return expectedURLComponents.scheme?.lowercased() == scheme?.lowercased()
        && expectedURLComponents.host?.lowercased() == host?.lowercased()
        && path.lowercased().hasPrefix(expectedURLComponents.path.lowercased())
    }
}

extension URL {
    var removeLastPathComponent: URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }

        // Remove query items to eliminate GET parameters
        components.queryItems = nil

        // Split the path into components, replace the last one, and reassemble the path
        var pathComponents = components.path.split(separator: "/").map(String.init)

        if !pathComponents.isEmpty {
            pathComponents.removeLast()
            components.path = "/" + pathComponents.joined(separator: "/")
        }

        return components.url ?? self
    }

    func appendingLastPathComponent(_ lastPathComponent: String) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }

        var pathComponents = components.path.split(separator: "/").map(String.init)

        if !pathComponents.isEmpty {
            pathComponents.append(lastPathComponent)
            components.path = "/" + pathComponents.joined(separator: "/")
        } else {
            // If there are no path components, just add the new endpoint
            components.path = lastPathComponent
        }

        return components.url ?? self
    }

    func appendQueryItem(name: String, value: String?) -> URL? {

        guard var urlComponents = URLComponents(string: absoluteString) else { return nil }

        // Create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ?? []

        // Create query item
        let queryItem = URLQueryItem(name: name, value: value)

        // Append the new query item in the existing query items array
        queryItems.append(queryItem)

        // Append updated query items array in the url component object
        urlComponents.queryItems = queryItems

        // Returns the url from new url components
        return urlComponents.url
    }
}
