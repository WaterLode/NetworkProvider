import Foundation

public protocol ResponseInterceptor {
    func intercept(urlRequest: URLRequest, data: Data?, urlResponse: URLResponse?, error: Error?)
}
