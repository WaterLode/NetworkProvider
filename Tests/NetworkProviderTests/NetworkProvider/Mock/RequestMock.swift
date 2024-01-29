//  Created by Евгений Капанов on 25.01.2024.

@testable import NetworkProvider

final class RequestMock: Request {
    let host: String
    let path: String
    let httpMethod: HTTPMethod
    let queryItems: [String: String]?
    let headers: [String: String]?
    let httpBody: [String: Any]?
    
    init(
        host: String,
        path: String,
        httpMethod: HTTPMethod = .get,
        queryItems: [String : String]? = nil,
        headers: [String : String]? = nil,
        httpBody: [String : Any]? = nil
    ) {
        self.host = host
        self.path = path
        self.httpMethod = httpMethod
        self.queryItems = queryItems
        self.headers = headers
        self.httpBody = httpBody
    }
}
