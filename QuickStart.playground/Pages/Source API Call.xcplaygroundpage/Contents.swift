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
let request = Request<Source>(parameter: CreateSourceParameter(
  paymentInformation: PaymentInformation.internetBanking(.bbl),
  amount: 50_000_00, currency: .thb
  )
)

/*: request
 After you create a client and request, you can create a `RequestTask` with those and call resume method to make an API call with a completion handler block
 */
let task = client.requestTask(with: request) { (result) in
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

task.resume()


PlaygroundPage.current.needsIndefiniteExecution = true

