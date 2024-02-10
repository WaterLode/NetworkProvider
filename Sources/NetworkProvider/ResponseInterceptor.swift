//  Created by Евгений Капанов on 25.01.2024.

import Foundation
import Combine

public protocol ResponseInterceptor {
    func intercept<R: Request>(request: R, data: Data?, urlResponse: URLResponse?, error: Error?) throws
}
