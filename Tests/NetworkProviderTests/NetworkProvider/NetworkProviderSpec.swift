import Quick
import Combine
import Nimble

@testable import NetworkProvider

final class NetworkProviderTests: QuickSpec {
    override class func spec() {
        var urlSessionMock: URLSessionMock!
        var jsonDecoderMock: JSONDecoderMock!
        var sut: NetworkProvider!
        
        beforeEach {
            urlSessionMock = URLSessionMock()
            jsonDecoderMock = JSONDecoderMock()
            sut = NetworkProvider(
                urlSession: urlSessionMock,
                jsonDecoder: jsonDecoderMock,
                requestInterceptors: [],
                responseInterceptors: []
            )
        }
        
        describe("-send<T: Decodable>(request: Request) -> AnyPublisher<T, NetworkProviderError>") {
            context("request is valid") {
                var cancellable: AnyCancellable!
                
                beforeEach {
                    let publisher: AnyPublisher<String, NetworkProviderError> = sut.send(request: TestConstants.validRequest)
                    cancellable = publisher.sink(receiveCompletion: { _ in }, receiveValue: { _ in })
                }
                
                it("should call -dataTask(with:, completionHandler:) from urlSession") {
                    expect(urlSessionMock.dataTaskCalled).toEventually(equal(true))
                }
                
                afterEach {
                    cancellable.cancel()
                }
            }
        }
    }
}

// MARK: - TestData

extension NetworkProviderTests {
    enum TestConstants {
        static let validRequest: Request = RequestMock(host: "https://www.example.com", path: "/")
    }
}
