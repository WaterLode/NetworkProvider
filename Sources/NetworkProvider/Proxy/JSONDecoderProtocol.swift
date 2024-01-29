//  Created by Евгений Капанов on 25.01.2024.

import Foundation

public protocol JSONDecoderProtocol {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}
