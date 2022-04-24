import SwiftUI
import Combine

class ViewModel: ObservableObject {
    @Published var flights: [FlightStruct] = []
    @Published var currency = "EUR"
}

struct DestinationsScreen: View {
    @ObservedObject var viewModel: ViewModel
    var body: some View {
        TabView {
            ForEach(viewModel.flights) { flight in
                DestinationCard(destination: flight, currency: viewModel.currency, image: UIImage(named: "default")!)
                
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .ignoresSafeArea()
    }
}

struct DestinationsScreen_Previews: PreviewProvider {
    static var previews: some View {
        DestinationsScreen(viewModel: demoModel)
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
        return result
    }
}

extension FlightStruct: Identifiable {
    typealias ID = String
}
