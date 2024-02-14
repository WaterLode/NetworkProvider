//  Created by Евгений Капанов on 25.01.2024.

import Combine
import Foundation

public protocol RequestInterceptor {
    func intercept(urlRequest: inout URLRequest)
}
