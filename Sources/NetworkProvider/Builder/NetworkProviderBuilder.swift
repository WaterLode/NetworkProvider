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
