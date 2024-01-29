//  Created by Евгений Капанов on 23.01.2024.

import Foundation

public protocol Request {
    var host: String { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var queryItems: [String: String]? { get }
    var headers: [String: String]? { get }
    var httpBody: [String: Any]? { get }
    var urlRequest: URLRequest? { get }
}

// MARK: - urlRequest

extension Request {
    public var urlRequest: URLRequest? {
        guard var urlComponents = URLComponents(string: host + path) else { return nil }
        
        urlComponents.queryItems = queryItems?.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let url = urlComponents.url else { return nil }
        
        var urlRequest = URLRequest(url: url)
        
        headers?.forEach { key, value in urlRequest.setValue(value, forHTTPHeaderField: key) }
        
        urlRequest.httpMethod = httpMethod.rawValue
        
        if let httpBody = httpBody, JSONSerialization.isValidJSONObject(httpBody) {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: httpBody)
            } catch {
                return nil
            }
        }
        
        return urlRequest
    }
}
