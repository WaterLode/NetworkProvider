//  Created by Евгений Капанов on 23.01.2024.

import Combine

public protocol CombinedNetworkProvider {
    func send<T: Decodable>(request: Request) -> AnyPublisher<T, NetworkProviderError>
}
