//  Created by Евгений Капанов on 25.01.2024.

import Combine

extension AnyPublisher {
    static func just(_ output: Output) -> AnyPublisher<Output, Failure> {
        return Just(output).setFailureType(to: Failure.self).eraseToAnyPublisher()
    }
}
