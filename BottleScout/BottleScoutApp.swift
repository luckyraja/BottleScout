import SwiftUI
import SwiftData

@main
struct BottleScoutApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: BottleEntry.self)
    }
}
