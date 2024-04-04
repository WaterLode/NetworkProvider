import Foundation

public protocol RequestInterceptor {
    func intercept(urlRequest: inout URLRequest)
}
