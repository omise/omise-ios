import Foundation


public class RequestTask<T: Object> {
    
    public let request: Request<T>
    let dataTask: URLSessionDataTask
    
    init(request: Request<T>, dataTask: URLSessionDataTask) {
        self.request = request
        self.dataTask = dataTask
    }
}

