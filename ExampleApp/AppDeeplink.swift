import Foundation

enum AppDeeplink: String {
    case threeDSChallenge = "3ds_challenge"

    var scheme: String {
        "omiseExampleApp"
    }

    var urlString: String {
        "\(scheme)://\(rawValue)"
    }

    var url: URL? {
        URL(string: urlString)
    }
}
