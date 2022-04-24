import Foundation
import Combine

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
        api.flightsPublisher(from: "49.2-16.61-250km", dateFrom: Date(), dateTo: Date(timeIntervalSinceNow: 3600*24*7), limit: 10)
            .catch { _ in return Empty() }
            .map { (a: FlightsResponse) -> FlightsResponse? in return a }
            .receive(on: DispatchQueue.main)
            .assign(to: \.flightResponse, on: self)
            .store(in: &cancellables)
    }
    
}
