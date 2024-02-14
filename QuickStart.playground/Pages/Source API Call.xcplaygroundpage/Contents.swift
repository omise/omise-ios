import Foundation
import OmiseSDK
import PlaygroundSupport

let publicKey = "pkey_test_<#Omise Public Key#>"

/*: source-api-call
 
 You can do manual credit card tokenization by using our Source Request API.
 */

/*: create-a-client-step
 You need a `Client` object for comminucating with Omise API
 */
let client = Client(publicKey: publicKey)

/*: create-a-request
 You also need a `Request` object which will have the credit card information that you want to tokenize.
 */
let createSourcePayload = CreateSourcePayload(
    amount: amount,
    currency: currency,
    details: .sourceType(.internetBankingBBL) // Bangkok Bank Internet Banking payment method
)
/*: request
 After you create a client and request, you can create a `RequestTask` with those and call resume method to make an API call with a completion handler block
 */
client.createSource(payload: createSourcePayload) { (result) in
  defer {
    PlaygroundPage.current.finishExecution()
  }
  
  switch result {
  case .success(let source):
    print(source.id)
  case .failure(let error):
    print(error)
  }
}

PlaygroundPage.current.needsIndefiniteExecution = true
