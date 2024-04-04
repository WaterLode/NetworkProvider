import Foundation

public protocol ResponseInterceptor {
    func intercept(data: Data?, urlResponse: URLResponse?, error: Error?)
}
