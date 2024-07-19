import Foundation

final class Provider {
    
    // MARK: - Private properties
    
    private let urlSession: URLSession
    private let requestInterceptors: [RequestInterceptor]
    private let responseInterceptors: [ResponseInterceptor]
    
    // MARK: - Initialization
    
    public init(
        urlSession: URLSession,
        requestInterceptors: [RequestInterceptor],
        responseInterceptors: [ResponseInterceptor]
    ) {
        self.urlSession = urlSession
        self.requestInterceptors = requestInterceptors
        self.responseInterceptors = responseInterceptors
    }
}

// MARK: - NetworkProvider

extension Provider: NetworkProvider {
    func send(urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var urlRequest = urlRequest
        
        applyRequestInterceptors(urlRequest: &urlRequest)
        
        urlSession.dataTask(with: urlRequest) { [weak self] data, urlResponse, error in
            guard let self = self else { return }
            
            self.applyResponseInterceptors(urlRequest: urlRequest, data: data, urlResponse: urlResponse, error: error)
            
            completionHandler(data, urlResponse, error)
        }.resume()
    }
    
    func upload(urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var urlRequest = urlRequest
        
        applyRequestInterceptors(urlRequest: &urlRequest)
        
        urlSession.uploadTask(with: urlRequest, from: nil) { [weak self] data, urlResponse, error in
            guard let self = self else { return }
            
            self.applyResponseInterceptors(urlRequest: urlRequest, data: data, urlResponse: urlResponse, error: error)
            
            completionHandler(data, urlResponse, error)
        }.resume()
    }
    
    private func applyRequestInterceptors(urlRequest: inout URLRequest) {
        requestInterceptors.forEach { $0.intercept(urlRequest: &urlRequest) }
    }
    
    private func applyResponseInterceptors(urlRequest: URLRequest, data: Data?, urlResponse: URLResponse?, error: Error?) {
        responseInterceptors.forEach { $0.intercept(urlRequest: urlRequest, data: data, urlResponse: urlResponse, error: error) }
    }
}
