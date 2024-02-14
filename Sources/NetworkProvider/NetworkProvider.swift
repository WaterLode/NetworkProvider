//  Created by Евгений Капанов on 23.01.2024.

import Foundation

public protocol NetworkProvider {
    func send(urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
}
