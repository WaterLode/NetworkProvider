//  Created by Евгений Капанов on 25.01.2024.

import Foundation

@testable import NetworkProvider

final class JSONDecoderMock: JSONDecoderProtocol {
    var decodeReturnValue: Decodable!
    private(set) var decodeCalled = false
    private(set) var decodeCallCount = 0
    
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        decodeCalled = true
        decodeCallCount += 1
        return decodeReturnValue as! T
    }
}
