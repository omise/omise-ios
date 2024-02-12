import Foundation

extension Source.Payload {
    /// Payloads for Installment payment methods
    /// https://docs.opn.ooo/installment-payments
    public struct Installment: Codable, Equatable {
    }
}

/*
{"phone_number":null,"email":null,"platform_type":"IOS","amount":500000,"shipping":null,"items":null,"installment_term":9,"currency":"THB","name":null,"type":"installment_scb"}
*/
