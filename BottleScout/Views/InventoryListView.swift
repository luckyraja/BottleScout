import SwiftUI
import SwiftData

enum InventoryFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case owned = "Owned"
    case notOwned = "Not Owned"

    var id: String { rawValue }
}

struct InventoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BottleEntry.dateAdded, order: .reverse) private var bottles: [BottleEntry]
    @State private var showingAddBottle = false
    @State private var filter: InventoryFilter = .all

    private var filteredBottles: [BottleEntry] {
        switch filter {
        case .all:
            return bottles
        case .owned:
            return bottles.filter(\.inCollection)
        case .notOwned:
            return bottles.filter { !$0.inCollection }
        }
    }

    var body: some View {
        Group {
            if filteredBottles.isEmpty {
                emptyStateView
            } else {
                bottleList
            }
        }
        .navigationTitle("Inventory")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddBottle = true
                } label: {
                    Text("Add Bottle")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: 140, maxHeight: 44)
                        .background(LinearGradient.primaryButtonGradient)
                        .cornerRadius(28)
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showingAddBottle) {
            NavigationStack {
                AddBottleView()
            }
        }
        .background(Color.surface.ignoresSafeArea())
    }

    private var emptyStateView: some View {
        VStack(spacing: 32) {
            filterPickerView
                .padding(.horizontal)

            Image(systemName: "wineglass")
                .font(.system(size: 70))
                .foregroundStyle(.secondary)

            Text("No Bottles")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            Text("Add bottles from the camera screen or tap +")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            Button {
                showingAddBottle = true
            } label: {
                Label("Add Bottle", systemImage: "camera")
                    .font(.headline.bold())
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.surfaceContainerHigh)
                    .foregroundColor(.primaryColor)
                    .cornerRadius(28)
                    .padding(.horizontal)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 40)
    }

    private var bottleList: some View {
        List {
            Section {
                filterPickerView
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 10)
            }
            .listRowInsets(EdgeInsets())
            .background(Color.surface)
            .padding(.top, 24)

            ForEach(filteredBottles) { bottle in
                NavigationLink(destination: BottleDetailView(bottle: bottle)) {
                    BottleRowView(bottle: bottle)
                        .listRowBackground(Color.clear)
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                }
            }
            .onDelete(perform: deleteBottles)
        }
        .listStyle(.plain)
        .background(Color.surface)
    }

    private var filterPickerView: some View {
        Picker("Filter", selection: $filter) {
            ForEach(InventoryFilter.allCases) { value in
                Text(value.rawValue).tag(value)
            }
        }
        .pickerStyle(.segmented)
        .padding(8)
        .background(Color.surfaceContainerHigh)
        .cornerRadius(24)
        .shadow(color: Color.primaryColor.opacity(0.12), radius: 8, x: 0, y: 2)
        .padding(.horizontal)
    }

    private func deleteBottles(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredBottles[index])
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
