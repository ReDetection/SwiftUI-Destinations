import SwiftUI
import Combine

class ViewModel: ObservableObject {
    @Published var flights: [FlightStruct] = []
    @Published var currency = "EUR"
    @Published var destinationImages: [String: UIImage] = [:]
}

struct DestinationsScreen: View {
    @ObservedObject var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        UIPageControl.appearance().currentPageIndicatorTintColor = .gray
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
    }
    
    var body: some View {
        if viewModel.flights.isEmpty {
            Text("Loading...")
        } else {
            TabView {
                ForEach(viewModel.flights) { flight in
                    DestinationCard(destination: flight, currency: viewModel.currency, image: viewModel.destinationImages[flight.mapIdto] ?? UIImage(named: "default")!)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .ignoresSafeArea()
        }
    }
}

struct DestinationsScreen_Previews: PreviewProvider {
    static var previews: some View {
        DestinationsScreen(viewModel: demoModel)
        DestinationsScreen(viewModel: ViewModel())
    }
    
    static var demoModel: ViewModel {
        let result = ViewModel()
        result.currency = "JPY"
        result.flights = [
            FlightStruct(id: "abc",
                         cityTo: "Dublin",
                         dTimeUTC: Date(timeIntervalSinceNow: 12300).timeIntervalSince1970,
                         fly_duration: "2h 30m",
                         price: 3016.44,
                         route: [RouteStruct(cityTo: "London"), RouteStruct(cityTo: "Paris"), RouteStruct(cityTo: "Paris"), RouteStruct(cityTo: "Dublin")],
                         mapIdfrom: "amsterdam_nl",
                         mapIdto: "dublin_ie"),
            FlightStruct(id: "qwe",
                         cityTo: "Berlin",
                         dTimeUTC: Date(timeIntervalSinceNow: 50300).timeIntervalSince1970,
                         fly_duration: "2h 10m",
                         price: 50,
                         route: [RouteStruct(cityTo: "Berlin")],
                         mapIdfrom: "amsterdam_nl",
                         mapIdto: "berlin_de"),
        ]
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            result.destinationImages["dublin_ie"] = UIImage(named: "demo_picture")
        }
        return result
    }
}

extension FlightStruct: Identifiable {
    typealias ID = String
}
