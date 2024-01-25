//  Created by Евгений Капанов on 25.01.2024.

public enum NetworkProviderError: Error {
    case failedToCreateURLRequest
    case dataIsEmpty
    case decoding(error: Error)
    case system(error: Error)
    case hasBeenReleased
}
