import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var apiKey = ""
    @State private var savedMessage: String?
    @State private var showingSavedMessage = false

    private var hasStoredKey: Bool {
        !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Gemini") {
                    SecureField("API key", text: $apiKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Text("BottleScout stores this key on-device in the keychain and uses it for bottle analysis.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Button("Save Key") {
                        if GeminiKeyStore.save(apiKey) {
                            apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
                            savedMessage = "Gemini API key saved."
                            showingSavedMessage = true
                        }
                    }
                    .disabled(!hasStoredKey)

                    Button("Clear Key", role: .destructive) {
                        if GeminiKeyStore.clear() {
                            apiKey = ""
                            savedMessage = "Gemini API key removed."
                            showingSavedMessage = true
                        }
                    }
                }

                Section("Status") {
                    Label(hasStoredKey ? "Gemini key is configured" : "No Gemini key saved", systemImage: hasStoredKey ? "checkmark.circle.fill" : "xmark.circle")
                        .foregroundStyle(hasStoredKey ? .green : .secondary)
                }

                #if DEBUG
                Section("Debug") {
                    Button("Seed Scanned Bottle") {
                        seedBottle(owned: false)
                    }
                    Button("Seed Owned Bottle") {
                        seedBottle(owned: true)
                    }
                    Button("Delete All Bottles", role: .destructive) {
                        deleteAllBottles()
                    }
                }
                #endif
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                apiKey = GeminiKeyStore.load() ?? ""
            }
            .alert(savedMessage ?? "", isPresented: $showingSavedMessage) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    #if DEBUG
    private func seedBottle(owned: Bool) {
        let suffix = owned ? "Owned" : "Scanned"
        let bottle = BottleEntry(
            name: "Debug Bottle (\(suffix))",
            alcoholType: owned ? "wine" : "spirits",
            tastingNotes: "Seed entry for UI testing. Dark fruit, vanilla, lingering finish.",
            pairingNotes: "Pairs with debugging sessions and late-night builds.",
            priceRange: "$25-$40",
            imageData: nil,
            inCollection: owned
        )
        modelContext.insert(bottle)
        do {
            try modelContext.save()
            savedMessage = "Seeded \(suffix.lowercased()) bottle."
            showingSavedMessage = true
        } catch {
            savedMessage = "Seed failed: \(error.localizedDescription)"
            showingSavedMessage = true
        }
    }

    private func deleteAllBottles() {
        do {
            try modelContext.delete(model: BottleEntry.self)
            try modelContext.save()
            savedMessage = "All bottles deleted."
            showingSavedMessage = true
        } catch {
            savedMessage = "Delete failed: \(error.localizedDescription)"
            showingSavedMessage = true
        }
    }
    #endif
}
