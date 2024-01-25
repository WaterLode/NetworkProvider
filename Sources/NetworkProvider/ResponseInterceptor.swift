//  Created by Евгений Капанов on 25.01.2024.

import Foundation
import Combine

public protocol ResponseInterceptor {
    func intercept<R: Request>(
        urlRequest: URLRequest,
        requestType: R.Type,
        data: Data?,
        urlResponse: URLResponse?,
        error: Error?
    ) -> AnyPublisher<Void, NetworkProviderError>
}
