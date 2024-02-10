//  Created by Евгений Капанов on 25.01.2024.

public enum NetworkProviderError: Error {
    case hasBeenReleased
    case failedToCreateURLRequest
    case dataIsEmpty
    case network(error: NetworkError)
    case decoding(error: Error)
    case system(error: Error)
    case unknown(error: Error)
}
