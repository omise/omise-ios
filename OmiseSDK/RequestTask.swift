import Foundation


public class ReqeustTask<T: Object> {
    public let request: Request<T>
    
    public let dataTask: URLSessionDataTask
    
    init(request: Request<T>, dataTask: URLSessionDataTask) {
        self.request = request
        self.dataTask = dataTask
    }
}

