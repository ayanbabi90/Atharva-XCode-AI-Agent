    //
    //  SettingsView.swift
    //  Atharva AI
    //
    //  Created by ayan Chakraborty on 19/07/25.
    //

import SwiftUI
import AtharvaCore

// For sheet dismissal
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var apiKey: String = ""
    @State private var selectedProvider: AIProvider = .openai
    @State private var customBaseURL: String = ""
    @State private var customModel: String = ""
    @State private var maxTokens: String = "500"
    @State private var temperature: String = "0.2"
    @State private var showingAlert = false
    @State private var alertMessage = ""

    private var isFrameworkLoaded: Bool {
        let cases = AIProvider.allCases
        return !cases.isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isFrameworkLoaded {
                    settingsForm
                } else {
                    errorView
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    dismiss()
                }
            }
        }
        .onAppear {
            print("[DEBUG] SettingsView: onAppear called" + "\(AtharvaFramework.version)")
            print("[DEBUG] SettingsView: body appeared")
            print("[DEBUG] isFrameworkLoaded = \(isFrameworkLoaded)")
            print("[DEBUG] NavigationStack body rendered")
        }
    }

    private var settingsForm: some View {
        Form {
            Section(header: Text("API Configuration")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("AI Provider")
                        .font(.headline)

                    Picker("AI Provider", selection: $selectedProvider) {
                        ForEach(AIProvider.allCases, id: \.self) { provider in
                            Text(provider.rawValue.capitalized).tag(provider)
                        }
                    }
                    .pickerStyle(.menu) // Changed from SegmentedPickerStyle
                    .onAppear {
                        print("[DEBUG] Picker rendered with \(AIProvider.allCases.count) providers")
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("API Key")
                        .font(.headline)
                    SecureField("Enter your API key", text: $apiKey)
                }

                if selectedProvider == .custom {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Custom Base URL")
                            .font(.headline)
                        TextField("https://api.example.com", text: $customBaseURL)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Custom Model")
                            .font(.headline)
                        TextField("model-name", text: $customModel)
                    }
                }
            }

            Section(header: Text("Completion Settings")) {
                HStack {
                    Text("Max Tokens")
                    Spacer()
                    TextField("500", text: $maxTokens)
                        .frame(width: 80)
                }

                HStack {
                    Text("Temperature")
                    Spacer()
                    TextField("0.2", text: $temperature)
                        .frame(width: 80)
                }
            }

            Section(header: Text("Information")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("How to use:")
                        .font(.headline)

                    Text("1. Set your API key above")
                    Text("2. In Xcode, go to Editor → Atharva AI → AI Code Completion")
                    Text("3. Place your cursor where you want suggestions")
                    Text("4. Use the menu command or assign a keyboard shortcut")

                    Text("Supported Languages:")
                        .font(.headline)
                        .padding(.top)

                    Text("Swift, Objective-C, C++, JavaScript, Python, and more")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Section {
                VStack(spacing: 8) {
                    Button("Save Settings") {
                        saveSettings()
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)

                    Button("Test Connection") {
                        testConnection()
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.bordered)
                }
            }
        }
        .navigationTitle("Settings")
        .formStyle(.grouped) // Add this for better form appearance
        .onAppear {
            print("[DEBUG] settingsForm: onAppear called")
            print("[DEBUG] settingsForm: Form is being rendered")
            loadSettings()
        }
        .alert("Settings", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }


    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.yellow)

            Text("⚠️ SETTINGS ERROR DETECTED")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.red)

            VStack(alignment: .leading, spacing: 8) {
                Text("DEBUG INFORMATION:")
                    .font(.headline)
                    .foregroundColor(.blue)

                Text("• Framework Import: \(AtharvaFramework.version)")
                Text("• AIProvider Cases: \(AIProvider.allCases.count)")
                Text("• Cases: \(AIProvider.allCases.map { $0.rawValue }.joined(separator: ", "))")

                if AIProvider.allCases.isEmpty {
                    Text("• ERROR: AIProvider.allCases is EMPTY!")
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                } else {
                    Text("• Status: Framework appears to be loaded correctly")
                        .foregroundColor(.green)
                }
            }
            .font(.caption)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)

            Text("POSSIBLE CAUSES:")
                .font(.headline)
                .foregroundColor(.orange)

            VStack(alignment: .leading, spacing: 4) {
                Text("1. Framework linking issue")
                Text("2. Module not properly loaded")
                Text("3. Build configuration problem")
                Text("4. Runtime loading failure")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .navigationTitle("Settings Error")
    }

    private func loadSettings() {
        print("[DEBUG] SettingsView: loadSettings() called")
        let defaults = UserDefaults.standard

        apiKey = defaults.string(forKey: Constants.UserDefaultsKeys.apiKey) ?? ""
        print("[DEBUG] Loaded API key length: \(apiKey.count)")

        if let providerString = defaults.string(forKey: Constants.UserDefaultsKeys.selectedProvider),
           let provider = AIProvider(rawValue: providerString) {
            selectedProvider = provider
            print("[DEBUG] Loaded provider: \(provider.rawValue)")
        }

        customBaseURL = defaults.string(forKey: Constants.UserDefaultsKeys.customBaseURL) ?? ""
        customModel = defaults.string(forKey: Constants.UserDefaultsKeys.customModel) ?? ""

        let maxTokensInt = defaults.integer(forKey: Constants.UserDefaultsKeys.maxTokens)
        maxTokens = maxTokensInt > 0 ? String(maxTokensInt) : "500"

        let temperatureDouble = defaults.double(forKey: Constants.UserDefaultsKeys.temperature)
        temperature = temperatureDouble > 0 ? String(temperatureDouble) : "0.2"
    }

    private func saveSettings() {
        let defaults = UserDefaults.standard

        defaults.set(apiKey, forKey: Constants.UserDefaultsKeys.apiKey)
        defaults.set(selectedProvider.rawValue, forKey: Constants.UserDefaultsKeys.selectedProvider)
        defaults.set(customBaseURL, forKey: Constants.UserDefaultsKeys.customBaseURL)
        defaults.set(customModel, forKey: Constants.UserDefaultsKeys.customModel)

        if let maxTokensInt = Int(maxTokens) {
            defaults.set(maxTokensInt, forKey: Constants.UserDefaultsKeys.maxTokens)
        }

        if let temperatureDouble = Double(temperature) {
            defaults.set(temperatureDouble, forKey: Constants.UserDefaultsKeys.temperature)
        }

        alertMessage = "Settings saved successfully!"
        showingAlert = true
    }

    private func testConnection() {
        guard !apiKey.isEmpty else {
            alertMessage = "Please enter an API key first."
            showingAlert = true
            return
        }

        let config = AIProviderConfig(
            provider: selectedProvider,
            apiKey: apiKey,
            baseURL: selectedProvider == .custom ? customBaseURL : selectedProvider.defaultBaseURL,
            model: selectedProvider == .custom ? customModel : selectedProvider.defaultModel,
            maxTokens: Int(maxTokens) ?? 500,
            temperature: Double(temperature) ?? 0.2
        )

        let aiHelper = AIHelper(config: config)
        let testContext = CompletionContext(
            language: "swift",
            filename: "test.swift",
            contextBefore: "// Test connection",
            contextAfter: "",
            cursorPosition: CursorPosition(line: 0, column: 0),
            entireFile: "// Test connection"
        )

        aiHelper.fetchCompletion(for: testContext) { result in
            DispatchQueue.main.async {
                switch result {
                    case .success:
                        alertMessage = "Connection successful! API is working."
                    case .failure(let error):
                        alertMessage = "Connection failed: \(error.localizedDescription)"
                }
                showingAlert = true
            }
        }
    }
}

#Preview {
    SettingsView()
}
