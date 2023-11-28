import Foundation

enum AppDeeplink: String {
    case threeDSChallenge = "omise_3ds_challenge"

    var scheme: String {
        "omiseExampleApp"
    }

    var url: URL? {
        URL(string: "\(scheme)://\(rawValue)")
    }
}
