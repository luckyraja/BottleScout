import SwiftUI
import SwiftData
import OSLog

private let inventoryLog = Logger(subsystem: "com.bottlescout.app", category: "InventoryListView")

struct InventoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BottleEntry.dateAdded, order: .reverse) private var bottles: [BottleEntry]

    private var ownedBottles: [BottleEntry] {
        bottles.filter(\.inCollection)
    }

    private var scannedBottles: [BottleEntry] {
        bottles.filter { !$0.inCollection }
    }

    var body: some View {
        Group {
            if bottles.isEmpty {
                emptyStateView
            } else {
                bottleList
            }
        }
        .navigationTitle("Inventory")
        .onAppear {
            inventoryLog.info("InventoryListView appeared. total=\(bottles.count) owned=\(ownedBottles.count) scanned=\(scannedBottles.count)")
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Bottles Yet", systemImage: "wineglass")
        } description: {
            Text("Scan a bottle from the camera to add it to your history.")
        }
    }

    private var bottleList: some View {
        List {
            if !ownedBottles.isEmpty {
                Section("Collection") {
                    ForEach(ownedBottles) { bottle in
                        NavigationLink(destination: BottleDetailView(bottle: bottle)) {
                            BottleRowView(bottle: bottle)
                        }
                    }
                    .onDelete { offsets in
                        delete(from: ownedBottles, at: offsets)
                    }
                }
            }

            if !scannedBottles.isEmpty {
                Section("Scanned") {
                    ForEach(scannedBottles) { bottle in
                        NavigationLink(destination: BottleDetailView(bottle: bottle)) {
                            BottleRowView(bottle: bottle)
                        }
                    }
                    .onDelete { offsets in
                        delete(from: scannedBottles, at: offsets)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func delete(from source: [BottleEntry], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(source[index])
        }

        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to delete bottle: \(error.localizedDescription)")
        }
    }
}

struct BottleRowView: View {
    let bottle: BottleEntry

    var body: some View {
        HStack(spacing: 14) {
            thumbnail

            VStack(alignment: .leading, spacing: 4) {
                Text(bottle.name)
                    .font(.body.weight(.semibold))
                    .lineLimit(2)

                Text(bottle.alcoholType.capitalized)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if !bottle.priceRange.isEmpty {
                    Text(bottle.priceRange)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let imageData = bottle.imageData,
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        } else {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.surfaceContainerHigh)
                .frame(width: 56, height: 56)
                .overlay {
                    Image(systemName: "wineglass")
                        .foregroundStyle(.secondary)
                }
        }
    }
}

#Preview {
    NavigationStack {
        InventoryListView()
    }
    .modelContainer(for: BottleEntry.self, inMemory: true)
}
