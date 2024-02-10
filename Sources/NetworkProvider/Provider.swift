//  Created by Евгений Капанов on 03.02.2024.

import Combine
import Foundation

final class Provider {
    
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

// MARK: - NetworkProvider

extension Provider: NetworkProvider {
    func send<T: Decodable>(request: Request, completionHandler: @escaping (Result<T, NetworkProviderError>) -> Void) {
        var urlRequest: URLRequest
        
        do {
            urlRequest = try makeURLRequest(request: request)
        } catch {
            Provider.handle(error: error, completionHandler: completionHandler)
            return
        }
        
        do {
            try applyRequestInterceptors(request: request, urlRequest: &urlRequest)
        } catch {
            Provider.handle(error: error, completionHandler: completionHandler)
            return
        }
        
        urlSession.dataTask(with: urlRequest) { [weak self] data, urlResponse, error in
            guard let self = self else {
                Provider.handle(error: NetworkProviderError.hasBeenReleased, completionHandler: completionHandler)
                return
            }
            
            do {
                try self.applyResponseInterceptors(request: request, data: data, urlResponse: urlResponse, error: error)
            } catch {
                Provider.handle(error: error, completionHandler: completionHandler)
                return
            }
            
            do {
                let decodedData: T = try decodeIfPossible(data: data, urlResponse: urlResponse, error: error)
                completionHandler(.success(decodedData))
            } catch {
                Provider.handle(error: error, completionHandler: completionHandler)
                return
            }
        }.resume()
    }
    
    private func makeURLRequest(request: Request) throws -> URLRequest {
        guard let urlRequest = request.urlRequest else { throw NetworkProviderError.failedToCreateURLRequest }
        return urlRequest
    }
    
    private func applyRequestInterceptors(request: Request, urlRequest: inout URLRequest) throws {
        return try requestInterceptors.forEach { interceptor in
            try interceptor.intercept(request: request, urlRequest: &urlRequest)
        }
    }
    
    private func applyResponseInterceptors(request: Request, data: Data?, urlResponse: URLResponse?, error: Error?) throws {
        return try responseInterceptors.forEach { interceptor in
            try interceptor.intercept(request: request, data: data, urlResponse: urlResponse, error: error)
        }
    }
    
    private func decodeIfPossible<T: Decodable>(data: Data?, urlResponse: URLResponse?, error: Error?) throws -> T {
        if let error { throw NetworkProviderError.system(error: error) }

        guard let data = data else { throw NetworkProviderError.dataIsEmpty }
    
        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            throw NetworkProviderError.decoding(error: error)
        }
    }
    
    private static func handle<T: Decodable>(error: Error, completionHandler: @escaping (Result<T, NetworkProviderError>) -> Void) {
        if let networkProviderError = error as? NetworkProviderError {
            completionHandler(.failure(networkProviderError))
        } else {
            completionHandler(.failure(.unknown(error: error)))
        }
    }
}

// MARK: - CombinedNetworkProvider

extension Provider: CombinedNetworkProvider {
    func send<T: Decodable>(request: Request) -> AnyPublisher<T, NetworkProviderError> {
        return Future { [weak self] promise in
            self?.send(request: request, completionHandler: { (result: Result<T, NetworkProviderError>) in
                switch result {
                case .success(let success):
                    promise(.success(success))
                case .failure(let failure):
                    promise(.failure(failure))
                }
            })
        }.eraseToAnyPublisher()
    }
}














//public final class NetworkProviderOld {
//    
//    // MARK: - Typealias
//    
//    typealias RequestPublisher = AnyPublisher<URLRequest, NetworkProviderError>
//    typealias RequestAndResponsePublisher = AnyPublisher<(URLRequest, Data?, URLResponse?, Error?), NetworkProviderError>
//    typealias ResponsePublisher = AnyPublisher<(Data?, URLResponse?, Error?), NetworkProviderError>
//    
//    // MARK: - Private properties
//    
//    private let urlSession: URLSessionProtocol
//    private let jsonDecoder: JSONDecoderProtocol
//    private let requestInterceptors: [RequestInterceptor]
//    private let responseInterceptors: [ResponseInterceptor]
//    
//    
//    // MARK: - Initialization
//    
//    public init(
//        urlSession: URLSessionProtocol,
//        jsonDecoder: JSONDecoderProtocol,
//        requestInterceptors: [RequestInterceptor],
//        responseInterceptors: [ResponseInterceptor]
//    ) {
//        self.urlSession = urlSession
//        self.jsonDecoder = jsonDecoder
//        self.requestInterceptors = requestInterceptors
//        self.responseInterceptors = responseInterceptors
//    }
//}
//
//// MARK: - CombinedNetworkProvider
//
//extension NetworkProviderOld: CombinedNetworkProvider {
//    public func send<T: Decodable>(request: Request) -> AnyPublisher<T, NetworkProviderError> {
//        return makeURLRequestPublisher(request: request)
//            .flatMap { [weak self] urlRequest -> RequestPublisher in
//                guard let self else { return .error(.hasBeenReleased) }
//                return self.applyRequestInterceptors(urlRequest: urlRequest, request: request)
//            }
//            .flatMap { [weak self] urlRequest -> RequestAndResponsePublisher in
//                guard let self else { return .error(.hasBeenReleased) }
//                return self.resumeDataTask(urlRequest: urlRequest)
//            }
//            .flatMap { [weak self] urlRequest, data, urlResponse, error -> ResponsePublisher in
//                guard let self else { return .error(.hasBeenReleased) }
//                return self.applyResponseInterceptors(
//                    urlRequest: urlRequest,
//                    request: request,
//                    data: data,
//                    urlResponse: urlResponse,
//                    error: error
//                )
//            }
//            .flatMap { [weak self] data, urlResponse, error -> AnyPublisher<T, NetworkProviderError> in
//                guard let self else { return .error(.hasBeenReleased) }
//                return self.decodeIfPossible(data: data, urlResponse: urlResponse, error: error)
//            }
//            .eraseToAnyPublisher()
//    }
//    
//    private func makeURLRequestPublisher(request: Request) -> RequestPublisher {
//        guard let urlRequest = request.urlRequest else { return .error(.failedToCreateURLRequest) }
//        
//        return .just(urlRequest)
//    }
//    
////    private func applyRequestInterceptors(urlRequest: URLRequest, request: Request) -> RequestPublisher {
////        return requestInterceptors.reduce(.just(urlRequest)) { urlRequestPublisher, requestInterceptor in
////            urlRequestPublisher.flatMap { requestInterceptor.intercept(urlRequest: $0, request: request) }.eraseToAnyPublisher()
////        }
////    }
//    
//    private func resumeDataTask(urlRequest: URLRequest) -> RequestAndResponsePublisher {
//        return Future() { promise in
//            self.urlSession.dataTask(with: urlRequest) { data, urlResponse, error in
//                promise(.success((urlRequest, data, urlResponse, error)))
//            }.resume()
//        }.eraseToAnyPublisher()
//    }
//    
//    private func applyResponseInterceptors(
//        urlRequest: URLRequest,
//        request: Request,
//        data: Data?,
//        urlResponse: URLResponse?,
//        error: Error?
//    ) -> ResponsePublisher {
//        let publisher: AnyPublisher<(URLRequest, Data?, URLResponse?, Error?), NetworkProviderError> = .just((urlRequest, data, urlResponse, error))
//        
//        return responseInterceptors.reduce(publisher) { publisher, responseInterceptor in
//            publisher.flatMap {
//                responseInterceptor.intercept(
//                    urlRequest: $0.0,
//                    request: request,
//                    data: $0.1,
//                    urlResponse: $0.2,
//                    error: $0.3
//                )
//            }
//            .eraseToAnyPublisher()
//        }
//        .map { return ($0.1, $0.2, $0.3) }
//        .eraseToAnyPublisher()
//    }
//    
//    private func decodeIfPossible<T: Decodable>(
//        data: Data?,
//        urlResponse: URLResponse?,
//        error: Error?
//    ) -> AnyPublisher<T, NetworkProviderError> {
//        if let error { return .error(.system(error: error)) }
//
//        guard let data = data else { return .error(.dataIsEmpty) }
//    
//        do {
//            return .just(try jsonDecoder.decode(T.self, from: data))
//        } catch {
//            return .error(.decoding(error: error))
//        }
//    }
//}
