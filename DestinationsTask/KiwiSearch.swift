import Foundation
import Combine
import UIKit

protocol NetworkDependency {
    func httpResponsePublisher(for url: URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
}

class KiwiSearch {
    let urlSession: NetworkDependency
    
    init(network: NetworkDependency) {
        self.urlSession = network
    }
    
    func flightsPublisher(from: String = "49.2-16.61-250km", limit: Int) -> AnyPublisher<FlightsResponse, Error> {
        var components = URLComponents(string: "https://api.skypicker.com/flights?v=3&sort=popularity&asc=0&locale=en&children=0&infants=0&to=anywhere&featureName=aggregateResults&dateFrom=26%2F06%2F2022&dateTo=18%2F07%2F2022&typeFlight=oneway&returnFrom&returnTo&one_per_date=0&oneforcity=1&wait_for_refresh=0&adults=1&partner=skypicker")!
        components.queryItems!.append(contentsOf: [
            URLQueryItem(name: "flyFrom", value: from),
            URLQueryItem(name: "limit", value: String(limit)),
        ])
        return urlSession.httpResponsePublisher(for: components.url!)
            .tryMap { $0.data }
            .decode(type: FlightsResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func imagePublisher(url: URL) -> AnyPublisher<UIImage, Error> {
        return urlSession.httpResponsePublisher(for: url)
            .tryMap { (data, response) in
                guard let image = UIImage(data: data) else { throw NetworkExchangeErrors.imageError }
                return image
            }
            .eraseToAnyPublisher()
    }
    
}

enum NetworkExchangeErrors: Error {
    case imageError
}

extension URLSession: NetworkDependency {
    func httpResponsePublisher(for url: URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        return dataTaskPublisher(for: url)
            .eraseToAnyPublisher()
    }
}
