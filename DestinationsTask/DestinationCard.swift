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
        var result: [String] = []
        if let date = readableDepartureDate, let time = readableDepartureTime {
            let format = NSLocalizedString("%@ %@", comment: "flight relative date and absolute time")
            result.append(String(format: format, date.capitalizingFirstLetter, time))
        }
        if let details = stopoversDetails {
            result.append(details)
        }
        result.append(String(format: NSLocalizedString("%@ flight time", comment: "flight duration"), fly_duration))
        return result.joined(separator: NSLocalizedString(", ", comment: "flight details separataor"))
    }
    var departureDate: Date {
        return Date(timeIntervalSince1970: self.dTimeUTC).toLocalTimeZone()
    }
    private var readableDepartureTime: String? {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        return formatter.string(from: departureDate)
    }
    private var readableDepartureDate: String? {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.locale = Locale.current
        return formatter.string(for: departureDate)
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

extension String {
    var capitalizingFirstLetter: String {
        return prefix(1).capitalized + dropFirst()
    }
}

struct DestinationCard_Previews: PreviewProvider {
    static var previews: some View {
        let flight = FlightStruct(id: "abc",
                                  cityTo: "Dublin",
                                  dTimeUTC: Date(timeIntervalSinceNow: 12300).timeIntervalSince1970,
                                  fly_duration: "2h 30m",
                                  price: 3016.44,
                                  route: [RouteStruct(cityTo: "London"), RouteStruct(cityTo: "Paris"), RouteStruct(cityTo: "Paris"), RouteStruct(cityTo: "Dublin")],
                                  mapIdfrom: "amsterdam_nl",
                                  mapIdto: "dublin_ie")
        DestinationCard(destination: flight, currency: "GBP", image: UIImage(named: "demo_picture")!)
    }
}
