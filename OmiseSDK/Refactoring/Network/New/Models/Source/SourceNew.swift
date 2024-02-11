import Foundation

/// Represents an Omise Source object
public struct SourceNew: Decodable {
    /// Omise Source ID
    public let id: String
    /// Processing Flow of this source
    public let flow: Flow
    /// The payment information of this source describes how the payment is processed
    //    public let paymentInformation: SourceNew.PaymentInformation


    enum CodingKeys: String, CodingKey {
        case id
        case flow
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

//        paymentInformation = try SourceNew.PaymentInformation(from: decoder)
        id = try container.decode(String.self, forKey: .id)
        flow = try container.decode(Flow.self, forKey: .flow)
    }

}
