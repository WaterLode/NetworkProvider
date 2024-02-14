//  Created by Евгений Капанов on 29.01.2024.

import Foundation

public enum NetworkProviderBuilder {
    public static func build(
        urlSession: URLSession,
        requestInterceptors: [RequestInterceptor],
        responseInterceptors: [ResponseInterceptor]
    ) -> NetworkProvider {
        let provider = Provider(
            urlSession: urlSession,
            requestInterceptors: requestInterceptors,
            responseInterceptors: responseInterceptors
        )
        
        return provider
    }
}
