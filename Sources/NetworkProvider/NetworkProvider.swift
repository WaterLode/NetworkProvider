//  Created by Евгений Капанов on 23.01.2024.

import Combine
import Foundation

public final class NetworkProvider {
    
    // MARK: - Typealias
    
    typealias RequestPublisher = AnyPublisher<URLRequest, NetworkProviderError>
    typealias RequestAndResponsePublisher = AnyPublisher<(URLRequest, Data?, URLResponse?, Error?), NetworkProviderError>
    typealias ResponsePublisher = AnyPublisher<(Data?, URLResponse?, Error?), NetworkProviderError>
    
    // MARK: - Private properties
    
    private let urlSession: URLSessionProtocol
    private let jsonDecoder: JSONDecoderProtocol
    private let requestInterceptors: [RequestInterceptor]
    private let responseInterceptors: [ResponseInterceptor]
    
    
    // MARK: - Initialization
    
    public init(
        urlSession: URLSessionProtocol,
        jsonDecoder: JSONDecoderProtocol,
        requestInterceptors: [RequestInterceptor],
        responseInterceptors: [ResponseInterceptor]
    ) {
        self.urlSession = urlSession
        self.jsonDecoder = jsonDecoder
        self.requestInterceptors = requestInterceptors
        self.responseInterceptors = responseInterceptors
    }
}

// MARK: - CombinedNetworkProvider

extension NetworkProvider: CombinedNetworkProvider {
    public func send<T: Decodable>(request: Request) -> AnyPublisher<T, NetworkProviderError> {
        let requestType = type(of: request)
        
        return makeURLRequestPublisher(request: request)
            .flatMap { [weak self] urlRequest -> RequestPublisher in
                guard let self else { return .error(.hasBeenReleased) }
                return self.applyRequestInterceptors(urlRequest: urlRequest, requestType: requestType)
            }
            .flatMap { [weak self] urlRequest -> RequestAndResponsePublisher in
                guard let self else { return .error(.hasBeenReleased) }
                return self.resumeDataTask(urlRequest: urlRequest)
            }
            .flatMap { [weak self] urlRequest, data, urlResponse, error -> ResponsePublisher in
                guard let self else { return .error(.hasBeenReleased) }
                return self.applyResponseInterceptors(
                    urlRequest: urlRequest,
                    requestType: requestType,
                    data: data, 
                    urlResponse: urlResponse,
                    error: error
                )
            }
            .flatMap { [weak self] data, urlResponse, error -> AnyPublisher<T, NetworkProviderError> in
                guard let self else { return .error(.hasBeenReleased) }
                return self.decodeIfPossible(data: data, urlResponse: urlResponse, error: error)
            }
            .eraseToAnyPublisher()
    }
    
    private func makeURLRequestPublisher(request: Request) -> RequestPublisher {
        guard let urlRequest = request.urlRequest else { return .error(.failedToCreateURLRequest) }
        
        return .just(urlRequest)
    }
    
    private func applyRequestInterceptors(urlRequest: URLRequest, requestType: Request.Type) -> RequestPublisher {
        return requestInterceptors.reduce(.just(urlRequest)) { urlRequestPublisher, requestInterceptor in
            urlRequestPublisher.flatMap { requestInterceptor.intercept(urlRequest: $0, requestType: requestType) }.eraseToAnyPublisher()
        }
    }
    
    private func resumeDataTask(urlRequest: URLRequest) -> RequestAndResponsePublisher {
        return Future() { promise in
            self.urlSession.dataTask(with: urlRequest) { data, urlResponse, error in
                promise(.success((urlRequest, data, urlResponse, error)))
            }.resume()
        }.eraseToAnyPublisher()
    }
    
    private func applyResponseInterceptors(
        urlRequest: URLRequest,
        requestType: Request.Type,
        data: Data?,
        urlResponse: URLResponse?,
        error: Error?
    ) -> ResponsePublisher {
        let publisher: AnyPublisher<Void, NetworkProviderError> = .just(())
        
        return responseInterceptors.reduce(publisher) { voidPublisher, responseInterceptor in
            voidPublisher.flatMap {
                responseInterceptor.intercept(
                    urlRequest: urlRequest,
                    requestType: requestType,
                    data: data,
                    urlResponse: urlResponse,
                    error: error
                )
            }
            .eraseToAnyPublisher()
        }
        .map { return (data, urlResponse, error) }
        .eraseToAnyPublisher()
    }
    
    private func decodeIfPossible<T: Decodable>(
        data: Data?,
        urlResponse: URLResponse?,
        error: Error?
    ) -> AnyPublisher<T, NetworkProviderError> {
        if let error { return .error(.system(error: error)) }

        guard let data = data else { return .error(.dataIsEmpty) }
    
        do {
            return .just(try jsonDecoder.decode(T.self, from: data))
        } catch {
            return .error(.decoding(error: error))
        }
    }
}
