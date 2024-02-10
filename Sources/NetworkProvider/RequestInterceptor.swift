//  Created by Евгений Капанов on 25.01.2024.

import Combine
import Foundation

public protocol RequestInterceptor {
    func intercept<R: Request>(request: R, urlRequest: inout URLRequest) throws
//    func intercept<R: Request>(urlRequest: URLRequest, request: R) -> AnyPublisher<URLRequest, NetworkProviderError>
}
