//  Created by Евгений Капанов on 25.01.2024.

import Combine

extension AnyPublisher where Failure == NetworkProviderError {
    static func error(_ failure: Failure) -> AnyPublisher<Output, Failure> {
        return Fail(error: failure).eraseToAnyPublisher()
    }
}
