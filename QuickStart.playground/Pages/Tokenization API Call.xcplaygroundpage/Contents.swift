import Foundation
import OmiseSDK
import PlaygroundSupport


let publicKey = "pkey_test_<#Omise Public Key#>"

/*: tokenization-api-call
 
 You can do manual credit card tokenization by using our Token Request API.
 */


/*: create-a-client-step
 You need a `Client` object for comminucating with Omise API
 */
let client = Client(publicKey: publicKey)

/*: create-a-request
 You also need a `Request` object which will have the credit card information that you want to tokenize.
 */
let request = Request<Token>(parameter: CreateTokenParameter(
  name: "Customer Name",
  number: "4242424242424242",
  expirationMonth: 12, expirationYear: 2022,
  securityCode: "123")
)

/*: request
 After you create a client and request, you can create a `RequestTask` with those and call resume method to make an API call with a completion handler block
 */
let task = client.requestTask(with: request) { (result) in
  defer {
    PlaygroundPage.current.finishExecution()
  }
  
  switch result {
  case .success(let token):
    print(token.id)
  case .failure(let error):
    print(error)
  }
}

task.resume()


PlaygroundPage.current.needsIndefiniteExecution = true

