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
