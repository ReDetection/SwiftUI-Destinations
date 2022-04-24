import SwiftUI

@main
struct DestinationsTaskApp: App {
    var body: some Scene {
        WindowGroup {
            DestinationsScreen(viewModel: ViewModel())
        }
    }
}
