import Foundation
import Combine
import UIKit

class ConnectedViewModel: ViewModel {
    let api: KiwiSearch
    private var cancellables: Set<AnyCancellable> = []
    private var flightResponse: FlightsResponse? {
        didSet {
            guard let newValue = flightResponse else { return }
            self.objectWillChange.send()
            flights = newValue.data
            currency = newValue.currency
            print("Assigned \(flights.count) new flights")
        }
    }
    
    init(api: KiwiSearch) {
        self.api = api
        super.init()
        let flights = api.flightsPublisher(from: "49.2-16.61-250km", dateFrom: Date(), dateTo: Date(timeIntervalSinceNow: 3600*24*7), limit: 10)
            .catch { _ in return Empty<FlightsResponse, Never>() }
            .share()
        
        flights
            .map { (a: FlightsResponse) -> FlightsResponse? in return a }
            .receive(on: DispatchQueue.main)
            .assign(to: \.flightResponse, on: self)
            .store(in: &cancellables)
        
        flights
            .map { flights -> AnyPublisher<(String, UIImage), Error> in
                let mapIds = Array(Set(flights.data.map { $0.mapIdto }))
                return Publishers.MergeMany(mapIds.map {
                    Just($0)
                        .setFailureType(to: Error.self)
                        .zip(api.imagePublisher(mapId: $0))
                    
                })
                .eraseToAnyPublisher()
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { _ in
            } receiveValue: { (mapId, image) in
                self.destinationImages[mapId] = image
            }
            .store(in: &cancellables)
    }
    
}
