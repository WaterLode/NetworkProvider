//  Created by Евгений Капанов on 29.01.2024.

import Foundation

public enum NetworkProviderBuilder {
    public static func build(
        urlSession: URLSession,
        jsonDecoder: JSONDecoder,
        requestInterceptors: [RequestInterceptor],
        responseInterceptors: [ResponseInterceptor]
    ) -> NetworkProvider & CombinedNetworkProvider {
        let provider = Provider(
            urlSession: urlSession,
            jsonDecoder: jsonDecoder,
            requestInterceptors: requestInterceptors,
            responseInterceptors: responseInterceptors
        )
        
        return provider
    }
}

// MARK: - URLSession + URLSessionProtocol

extension URLSession: URLSessionProtocol {
    public func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        let dataTask: URLSessionDataTask = dataTask(with: request, completionHandler: completionHandler)
        return dataTask
    }
}

// MARK: - URLSessionDataTask + URLSessionDataTaskProtocol

extension URLSessionDataTask: URLSessionDataTaskProtocol {}

// MARK: - JSONDecoder + JSONDecoderProtocol

extension JSONDecoder: JSONDecoderProtocol {}
