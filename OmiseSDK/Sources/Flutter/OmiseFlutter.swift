enum OmiseFlutter {
    static let engineName: String = "OmiseFlutter"
    static let channelName: String = "omiseFlutterChannel"
    static let selectPaymentMethodResultCancelled: Int = 1120
}

enum OmiseFlutterMethod: String {
    case selectPaymentMethod
    case openCardPage
    
    var name: String {
        self.rawValue
    }
    
    var result: String {
        switch self {
        case .selectPaymentMethod: "selectPaymentMethodResult"
        case .openCardPage: "openCardPageResult"
        }
    }
}
