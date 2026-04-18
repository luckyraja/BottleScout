import SwiftUI
import SwiftData

struct BottleDetailView: View {
    @Bindable var bottle: BottleEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Image container
                Group {
                    if let imageData = bottle.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    } else {
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .fill(Color.surfaceContainerLow) // Assuming Color.surfaceContainerLow exists
                            .frame(height: 300)
                            .overlay {
                                Image(systemName: "wineglass")
                                    .font(.system(size: 80))
                                    .foregroundStyle(.secondary)
                            }
                    }
                }
                .padding(24)
                .background(Color.surfaceContainerLow) // Assuming Color.surfaceContainerLow exists
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))

                // Bottle name headline
                Text(bottle.name)
                    .font(.largeTitle).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.bottom, 8)

                // Detail sections container
                VStack(alignment: .leading, spacing: 32) {
                    DetailSection(title: "Type", icon: "tag.fill") {
                        Text(bottle.alcoholType.capitalized)
                    }

                    DetailSection(title: "Price Range", icon: "dollarsign.circle.fill") {
                        Text(bottle.priceRange)
                    }

                    DetailSection(title: "Tasting Notes", icon: "note.text") {
                        Text(bottle.tastingNotes)
                    }

                    DetailSection(title: "Pairing Notes", icon: "fork.knife") {
                        Text(bottle.pairingNotes)
                    }

                    DetailSection(title: "Scanned", icon: "calendar") {
                        Text(bottle.dateAdded, style: .date)
                    }
                }
                .padding(24)
                .background(Color.surfaceContainerHigh) // Assuming Color.surfaceContainerHigh exists
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .padding(.horizontal)
                
                // Toggle Owned Button container
                HStack {
                    Spacer()
                    Button {
                        bottle.inCollection.toggle()
                    } label: {
                        Image(systemName: bottle.inCollection ? "checkmark.circle.fill" : "circle")
                            .font(.title)
                            .foregroundColor(Color.primaryColor) // Assuming Color.primaryColor exists
                    }
                    .padding(16)
                    .background(Color.surfaceContainerHigh) // Assuming Color.surfaceContainerHigh exists
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    Spacer()
                }
                .padding(.top, 16)
            }
            .padding(.vertical, 32)
        }
        .background(Color.surface.ignoresSafeArea()) // Assuming Color.surface exists
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                // Empty to remove default button (we use bottom button instead)
                EmptyView()
            }
        }
    }
}

struct DetailSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label {
                Text(title)
                    .font(.headline).bold()
                    .foregroundStyle(Color.primaryColor) // Assuming Color.primaryColor exists
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 4)
            } icon: {
                Image(systemName: icon)
                    .foregroundColor(Color.primaryColor) // Assuming Color.primaryColor exists
                    .font(.headline)
            }

            content
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding(24)
        .background(Color.surfaceContainerLow) // Assuming Color.surfaceContainerLow exists
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        BottleDetailView(bottle: BottleEntry(
            name: "Chateau Margaux 2015",
            alcoholType: "wine",
            tastingNotes: "Rich fruit with cedar and tobacco.",
            pairingNotes: "Pair with lamb, duck, or aged hard cheeses.",
            priceRange: "$800-$1000"
        ))
    }
    .modelContainer(for: BottleEntry.self, inMemory: true)
}
