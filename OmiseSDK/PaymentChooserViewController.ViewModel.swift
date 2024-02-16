import Foundation
extension PaymentChooserViewController {
    class ViewModel: PaymentSourceChooser {
        var capability: Capability?
        var flowSession: PaymentCreatorFlowSession?
        var duitNowOBWBanks: [PaymentInformation.DuitNowOBW.Bank] = PaymentInformation.DuitNowOBW.Bank.allCases

    }
}
