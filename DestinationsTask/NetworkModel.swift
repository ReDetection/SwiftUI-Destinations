import Foundation

struct FlightsResponse: Decodable {
    let data: [FlightStruct]
    let currency: String
}

struct FlightStruct: Decodable {
    let id: String
    let cityTo: String
    let fly_duration: String
    var decimalPrice: NSDecimalNumber {
        return NSDecimalNumber(decimal: price)
    }
    let price: Decimal
    let route: [RouteStruct]
    let mapIdfrom: String
    let mapIdto: String
}

struct RouteStruct: Decodable {
    let cityTo: String
}
