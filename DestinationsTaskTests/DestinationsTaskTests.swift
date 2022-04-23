import XCTest
import Combine
@testable import DestinationsTask

class DestinationsTaskTests: XCTestCase {
    var cancellables: Set<AnyCancellable> = []
    let fixture = try! Data(contentsOf: Bundle(for: DestinationsTaskTests.self).url(forResource: "flights", withExtension: "json")!)

    override func setUpWithError() throws {
        cancellables = []
    }

    func testFlightsParsing() throws {
        let api = KiwiSearch(network: MockedNetwork(responseData: fixture))
        let expectation = self.expectation(description: "Should finish")
        api.flightsPublisher(from: "somewhere", limit: 10).sink { result in
            if case .failure(let error) = result {
                XCTFail("\(error)")
            }
            expectation.fulfill()
        } receiveValue: { response in
            XCTAssertEqual(response.currency, "EUR")
            XCTAssertEqual(response.data.count, 10)
            XCTAssertEqual(response.data[0].id, "1f2f032d4aeb00006aa4bb45_0|032d01af4aeb0000e2b22422_0")
            XCTAssertEqual(response.data[0].mapIdfrom, "brno_cz")
        }
        .store(in: &cancellables)
        self.wait(for: [expectation], timeout: 1)
    }
    
    func testFlightsParsingE2E() throws {
        let api = KiwiSearch(network: URLSession(configuration: .default))
        let expectation = self.expectation(description: "Should finish")
        api.flightsPublisher(from: "prague_cz", limit: 3).sink { result in
            if case .failure(let error) = result {
                XCTFail("\(error)")
            }
            expectation.fulfill()
        } receiveValue: { response in
            XCTAssertEqual(response.data.count, 3)
            XCTAssertEqual(response.data[0].mapIdfrom, "prague_cz")
        }
        .store(in: &cancellables)
        self.wait(for: [expectation], timeout: 10)
    }

}

class MockedNetwork: NetworkDependency {
    let responseData: Data
    
    init(responseData: Data) {
        self.responseData = responseData
    }
    
    func httpResponsePublisher(for url: URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return Just((data: responseData, response: response))
            .delay(for: 0.1, scheduler: DispatchQueue.global(qos: .background))
            .setFailureType(to: URLError.self)
            .eraseToAnyPublisher()
    }
    
}
