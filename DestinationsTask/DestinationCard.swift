import SwiftUI

struct DestinationCard: View {
    let destination: FlightStruct
    let currency: String
    let image: UIImage
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .ignoresSafeArea()
            HStack {
                Text(destination.cityTo)
                    .bold()
                    .font(.title)
                Spacer()
                Text(destination.decimalPrice.formattedMoney(currencyCode: currency))
                    .bold()
                    .font(.title)
            }
            .padding()
            HStack {
                Text(destination.routeDetails)
                Spacer()
            }
            .padding()
            Spacer()
        }
    }
    
}

extension NSDecimalNumber {
    func formattedMoney(currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: self) ?? (currencyCode + " " + self.stringValue)
    }
}

extension FlightStruct {
    var routeDetails: String {
        var result = ""
        if let details = stopoversDetails {
            result.append(details)
        }
        return result
    }
    private var stopoversDetails: String? {
        guard let first = route.first, first.cityTo != "deprecated" else { return nil }
        let stopoversCount = route.count - 1
        if route.count == 0 {
            return NSLocalizedString("Direct", comment: "Direct route, no stopovers")
        }
        let listFormatter = ListFormatter()
        listFormatter.locale = .current
        let cities = route.dropLast().map(\.cityTo)
        let citiesString = listFormatter.string(from: cities) ?? cities.joined(separator: ", ")
        return String.localizedStringWithFormat("%d stopovers (%@)", stopoversCount, citiesString)
    }
}


struct DestinationCard_Previews: PreviewProvider {
    static var previews: some View {
        let flight = FlightStruct(id: "abc",
                                  cityTo: "Dublin",
                                  fly_duration: "2h 30m",
                                  price: 3016.44,
                                  route: [RouteStruct(cityTo: "London"), RouteStruct(cityTo: "Paris"), RouteStruct(cityTo: "Paris"), RouteStruct(cityTo: "Dublin")],
                                  mapIdfrom: "amsterdam_nl",
                                  mapIdto: "dublin_ie")
        DestinationCard(destination: flight, currency: "GBP", image: UIImage(named: "demo_picture")!)
    }
}
