import Foundation
import Combine
import UIKit

private let lastFlightCitiesKey = "lastFlightCitiesKey"
private let lastViewDate = "lastViewDate"

class ConnectedViewModel: ViewModel {
    let api: KiwiSearch
    private var cancellables: Set<AnyCancellable> = []

    init(api: KiwiSearch) {
        self.api = api
        super.init()
        let flights = api.flightsPublisher(from: "49.2-16.61-250km", dateFrom: Date(), dateTo: Date(timeIntervalSinceNow: 3600*24*7), limit: 10)
            .catch { _ in return Empty<FlightsResponse, Never>() }
            .share()
        
        flights
            .map { response in
                let filteredCities = self.citiesToFilterOut()
                return response.data.filter { !filteredCities.contains($0.mapIdto) }.prefix(5).map { $0 }
            }
            .handleEvents(receiveOutput: { flights in
                self.saveHistory(cities: flights.map { $0.mapIdto })
            })
            .receive(on: DispatchQueue.main)
            .assign(to: \.flights, on: self)
            .store(in: &cancellables)
        
        flights
            .map { $0.currency }
            .receive(on: DispatchQueue.main)
            .assign(to: \.currency, on: self)
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
    
    func saveHistory(cities: [String]) {
        UserDefaults.standard.set(cities, forKey: lastFlightCitiesKey)
        UserDefaults.standard.set(Date(), forKey: lastViewDate)
    }
    
    func citiesToFilterOut() -> [String] {
        guard let savedDate = UserDefaults.standard.value(forKey: lastViewDate) as? Date,
              savedDate.isYesterday else { return [] }
        return UserDefaults.standard.value(forKey: lastFlightCitiesKey) as? [String] ?? []
    }
    
}
