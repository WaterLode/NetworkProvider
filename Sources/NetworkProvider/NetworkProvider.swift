//  Created by Евгений Капанов on 23.01.2024.

public protocol NetworkProvider {
    func send<T: Decodable>(request: Request, completionHandler: @escaping (Result<T, NetworkProviderError>) -> Void)
}
