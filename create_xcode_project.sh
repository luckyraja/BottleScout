#!/bin/bash

# Create the project structure
mkdir -p BottleScout/Models
mkdir -p BottleScout/Views
mkdir -p BottleScout/ViewModels
mkdir -p BottleScout/Services
mkdir -p BottleScout/Utilities
mkdir -p BottleScout/Resources

# Create basic Swift files
cat > BottleScout/BottleScoutApp.swift << 'SWIFT'
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
SWIFT

cat > BottleScout/Views/ContentView.swift << 'SWIFT'
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "wineglass")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("BottleScout")
                    .font(.largeTitle)
                    .padding()
                Text("Your wine collection awaits!")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("My Collection")
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
SWIFT

echo "Project structure created!"
