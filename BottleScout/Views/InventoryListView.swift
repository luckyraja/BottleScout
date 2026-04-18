import SwiftUI
import SwiftData

struct InventoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BottleEntry.dateAdded, order: .reverse) private var bottles: [BottleEntry]

    private var ownedBottles: [BottleEntry] {
        bottles.filter(\.inCollection)
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
        .background(Color.surface.ignoresSafeArea())
    }

    private var emptyStateView: some View {
        VStack(spacing: 32) {
            Image(systemName: "wineglass")
                .font(.system(size: 70))
                .foregroundStyle(.secondary)

            Text("No Bottles")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            Text("Scan bottles from the main camera screen and they will show up here in history.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
        }
        .padding(.vertical, 40)
    }

    private var bottleList: some View {
        List {
            if !ownedBottles.isEmpty {
                Section("Owned") {
                    ForEach(ownedBottles) { bottle in
                        NavigationLink(destination: BottleDetailView(bottle: bottle)) {
                            BottleRowView(bottle: bottle)
                                .listRowBackground(Color.clear)
                                .padding(.vertical, 8)
                                .padding(.horizontal)
                        }
                    }
                }
            }

            Section("History") {
                ForEach(bottles) { bottle in
                    NavigationLink(destination: BottleDetailView(bottle: bottle)) {
                        BottleRowView(bottle: bottle)
                            .listRowBackground(Color.clear)
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                    }
                }
                .onDelete(perform: deleteHistoryBottles)
            }
        }
        .listStyle(.plain)
        .background(Color.surface)
    }

    private func deleteHistoryBottles(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(bottles[index])
        }

        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to delete history bottle: \(error.localizedDescription)")
        }
    }
}

struct BottleRowView: View {
    let bottle: BottleEntry

    var body: some View {
        HStack(spacing: 16) {
            if let imageData = bottle.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            } else {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.surfaceContainerLow)
                    .frame(width: 72, height: 72)
                    .overlay {
                        Image(systemName: "wineglass")
                            .foregroundStyle(.secondary)
                            .font(.title2)
                    }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(bottle.name)
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(bottle.alcoholType.capitalized)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(bottle.priceRange)
                    .font(.caption)
                    .foregroundColor(.blue)
            }

            Spacer()

            Image(systemName: bottle.inCollection ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(bottle.inCollection ? .green : .secondary)
        }
        .padding(20)
        .background(Color.surfaceContainerLow)
        .cornerRadius(32)
    }
}

#Preview {
    NavigationStack {
        InventoryListView()
    }
    .modelContainer(for: BottleEntry.self, inMemory: true)
}
