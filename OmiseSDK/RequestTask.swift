import Foundation
import os


public class RequestTask<T: Object> {
    public let request: Request<T>
    let dataTask: URLSessionDataTask
    
    init(request: Request<T>, dataTask: URLSessionDataTask) {
        self.request = request
        self.dataTask = dataTask
    }
    
    public func resume() {
        dataTask.resume()
        if #available(iOS 10.0, *) {
            os_log("Starting/Resuming Request %{public}@", log: sdkLogObject, type: .debug, String(describing: type(of: T.self)))
        }
    }
}

