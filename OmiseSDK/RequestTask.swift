import Foundation
import os


/// The class represents the task of a request to the Omise API
public class RequestTask<T: CreatableObject> {
    public let request: Request<T>
    let dataTask: URLSessionDataTask
    
    init(request: Request<T>, dataTask: URLSessionDataTask) {
        self.request = request
        self.dataTask = dataTask
    }
    
    public func resume() {
        dataTask.resume()
        if #available(iOSApplicationExtension 10.0, *) {
            os_log("Starting/Resuming Request %{public}@", log: sdkLogObject, type: .debug, String(describing: type(of: T.self)))
        }
    }
}

