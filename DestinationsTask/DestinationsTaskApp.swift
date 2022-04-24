import SwiftUI

@main
struct DestinationsTaskApp: App {
    var body: some Scene {
        WindowGroup {
//            let network = MockedNetwork(responseData: try! Data(contentsOf: Bundle(for: KiwiSearch.self).url(forResource: "flights", withExtension: "json")!))
            let network = URLSession(configuration: .default)
            DestinationsScreen(viewModel: ConnectedViewModel(api: KiwiSearch(network: network)))
        }
    }
}
