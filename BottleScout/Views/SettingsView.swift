import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

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
}
