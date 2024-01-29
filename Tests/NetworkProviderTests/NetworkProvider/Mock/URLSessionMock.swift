//  Created by Евгений Капанов on 25.01.2024.

import Foundation

@testable import NetworkProvider

final class URLSessionMock: URLSessionProtocol {
    var data: Data?
    var urlResponse: URLResponse?
    var error: Error?
    private(set) var dataTaskCalled = false
    private(set) var dataTaskCallCount = 0
    
    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTaskProtocol {
        dataTaskCalled = true
        dataTaskCallCount += 1
        
        let urlSessionDataTask = URLSessionDataTaskMock(data: data, urlResponse: urlResponse, error: error)
        urlSessionDataTask.completionHandler = completionHandler
        
        return urlSessionDataTask
    }
}

final class URLSessionDataTaskMock: URLSessionDataTaskProtocol {
    var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?
    private(set) var resumeCalled = false
    private(set) var resumeCallCount = 0
    
    private var data: Data?
    private var urlResponse: URLResponse?
    private var error: Error?
    
    fileprivate init(data: Data?, urlResponse: URLResponse?, error: Error?) {
        self.data = data
        self.urlResponse = urlResponse
        self.error = error
    }
    
    func resume() {
        resumeCalled = true
        resumeCallCount += 1
        completionHandler?(data, urlResponse, error)
    }
}
