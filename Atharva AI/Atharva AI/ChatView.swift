    //
    //  ChatView.swift
    //  Atharva AI
    //
    //  Created by ayan Chakraborty on 19/07/25.
    //

import SwiftUI
import AtharvaCore
import UniformTypeIdentifiers

struct AttachedFile: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let content: String
    let url: URL
}

struct AttachmentInfo {
    let fileName: String
    let fileType: String
}

struct AttachedFileView: View {
    let file: AttachedFile
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: iconForFileType(file.type))
                .foregroundColor(.blue)
                .font(.caption)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(file.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(file.type)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white)
        .cornerRadius(6)
        .shadow(radius: 1)
    }
    
    private func iconForFileType(_ type: String) -> String {
        switch type.lowercased() {
        case "swift": return "swift"
        case "objective-c": return "doc.text"
        case "c++": return "doc.text"
        case "python": return "doc.text"
        case "javascript", "typescript": return "doc.text"
        case "json": return "doc.text"
        case "image": return "photo"
        default: return "doc"
        }
    }
}

struct ChatView: View {
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isLoading: Bool = false
    @State private var selectedProvider: AIProvider = .openai
    @State private var selectedModel: String = ""
    @State private var showingModelPicker = false
    @State private var showingFilePicker = false
    @State private var attachedFiles: [AttachedFile] = []
    @State private var showingFileSearch = false
    @State private var isThinking = false
    @State private var thinkingStage = ""
    @State private var showingTextInput = true
    @State private var currentFileName = "ChatView.swift"
    @State private var currentFileType = "Swift"
    @State private var agentMode = "Agent"
    @State private var workspaceFiles: [String] = []

    private let availableModels: [AIProvider: [String]] = [
        .openai: ["gpt-4", "gpt-4-turbo", "gpt-3.5-turbo"],
        .claude: ["claude-3-opus", "claude-3-sonnet", "claude-3-haiku"],
        .custom: ["custom-model"]
    ]

    var body: some View {
        VStack(spacing: 0) {
                        // Header with GitHub Copilot style
            VStack(spacing: 0) {
                // Top bar with Copilot branding
                HStack {
                    // Copilot Icon and Title
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.blue)
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("GitHub Copilot")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    

                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                Divider()
                
                // Files changed section (like in the screenshot)
                VStack(spacing: 0) {
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "doc.text")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            Text("\(attachedFiles.count) files changed")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: { showingFileSearch = true }) {
                            Image(systemName: "plus.square")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    
                    // File list (if any files attached)
                    if !attachedFiles.isEmpty {
                        VStack(spacing: 4) {
                            ForEach(attachedFiles) { file in
                                HStack(spacing: 8) {
                                    Image(systemName: "swift")
                                        .foregroundColor(.orange)
                                        .font(.caption)
                                    
                                    Text(file.name)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Text(file.type)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Button(action: {
                                        if let index = attachedFiles.firstIndex(where: { $0.id == file.id }) {
                                            attachedFiles.remove(at: index)
                                        }
                                    }) {
                                        Image(systemName: "xmark")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                
                Divider()
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))

            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(messages) { message in
                            ChatMessageView(message: message)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _ in
                    if let lastMessage = messages.last {
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Input Area (GitHub Copilot style)
            VStack(spacing: 0) {
                Divider()
                
                // "Add Context..." and current file section
                HStack(spacing: 12) {
                    Button(action: { showingFileSearch = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "paperclip")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Add Context...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(6)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: iconForFileType(currentFileType))
                            .foregroundColor(colorForFileType(currentFileType))
                            .font(.subheadline)
                        
                        Menu {
                            ForEach(workspaceFiles, id: \.self) { fileName in
                                Button(fileName) {
                                    updateCurrentFile(fileName: fileName)
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(currentFileName)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Text("Current file")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            // Add current file to context
                            addCurrentFileToContext()
                        }) {
                            Image(systemName: "eye")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(6)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 12)

                // "Edit files in your workspace in agent mode" text
               
                
                // Bottom control bar

                
                // Hidden text input (for testing - in real GitHub Copilot this would be a modal or separate input)

                    VStack(spacing: 8) {
                        VStack {
                            TextEditor(text: $inputText)
                                .frame(minHeight: 60)
                                .padding(8)
                                .background(Color(NSColor.textBackgroundColor))
                                .cornerRadius(8)
                                .overlay(
                                    
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.blue, lineWidth: 1)
                                )

                            HStack(spacing: 12) {
                                    // Agent dropdown
                                Menu {
                                    Button("Agent Mode") { 
                                        agentMode = "Agent"
                                    }
                                    Button("Chat Mode") { 
                                        agentMode = "Chat"
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Text(agentMode)
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                        Image(systemName: "chevron.down")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(NSColor.controlBackgroundColor))
                                    .cornerRadius(4)
                                }

                                    // Model selector
                                Menu {
                                    ForEach(availableModels[selectedProvider] ?? [], id: \.self) { model in
                                        Button(model) { 
                                            selectedModel = model
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Text(selectedModel.isEmpty ? selectedProvider.defaultModel : selectedModel)
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                        Image(systemName: "chevron.down")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(NSColor.controlBackgroundColor))
                                    .cornerRadius(4)
                                }

                                Spacer(minLength: 0)

                                Button(action: {

                                    sendMessage()
                                }) {
                                    Image(systemName: "paperplane.fill")
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                }
                            }
//                            .padding(.horizontal, 16)
//                            .padding(.vertical, 12)


                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    }

            }
            .background(Color(NSColor.windowBackgroundColor))
        }
        .onAppear {
            loadSettings()
            addWelcomeMessage()
            loadWorkspaceFiles()
        }
        .sheet(isPresented: $showingModelPicker) {
            ModelPickerView(
                selectedProvider: $selectedProvider,
                selectedModel: $selectedModel,
                availableModels: availableModels
            )
        }
        .sheet(isPresented: $showingFileSearch) {
            FileSearchView(attachedFiles: $attachedFiles)
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.text, .sourceCode, .image, .data],
            allowsMultipleSelection: true
        ) { result in
            handleFileSelection(result)
        }
    }

    private func loadSettings() {
        let defaults = UserDefaults.standard

        if let providerString = defaults.string(forKey: Constants.UserDefaultsKeys.selectedProvider),
           let provider = AIProvider(rawValue: providerString) {
            selectedProvider = provider
        }

        selectedModel = selectedProvider.defaultModel
    }

    private func addWelcomeMessage() {
        if messages.isEmpty {
            let welcomeMessage = ChatMessage(
                content: "Hello! I'm Atharva AI, your coding assistant. I can help you with:\n\n• Code explanations and documentation\n• Bug fixes and debugging\n• Code optimization and refactoring\n• Generating tests\n• Architecture suggestions\n\nWhat would you like to work on today?",
                isUser: false,
                timestamp: Date()
            )
            messages.append(welcomeMessage)
        }
    }

    private func sendMessage() {
        let messageText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        let attachments = attachedFiles
        
        guard !messageText.isEmpty || !attachments.isEmpty else { return }

        // Add user message with attachments
        let userMessage = ChatMessage(
            content: messageText.isEmpty ? "Shared \(attachments.count) file(s)" : messageText,
            isUser: true,
            timestamp: Date(),
            attachments: attachments.map { AttachmentInfo(fileName: $0.name, fileType: $0.type) }
        )
        messages.append(userMessage)

        // Prepare full context including attachments
        var fullContext = messageText
        if !attachments.isEmpty {
            fullContext += "\n\n--- Attached Files ---\n"
            for file in attachments {
                fullContext += "\nFile: \(file.name) (\(file.type))\n"
                fullContext += "Content:\n\(file.content)\n"
                fullContext += "---\n"
            }
        }

        // Clear input and attachments
        let messageToSend = fullContext
        inputText = ""
        attachedFiles.removeAll()
        
        // Start thinking animation
        isThinking = true
        isLoading = true

        // Get AI response
        getAIResponse(for: messageToSend)
    }
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            for url in urls {
                if url.startAccessingSecurityScopedResource() {
                    defer { url.stopAccessingSecurityScopedResource() }
                    
                    do {
                        let fileName = url.lastPathComponent
                        let fileType = determineFileType(from: url)
                        let content = try String(contentsOf: url)
                        
                        let attachedFile = AttachedFile(
                            name: fileName,
                            type: fileType,
                            content: content,
                            url: url
                        )
                        
                        attachedFiles.append(attachedFile)
                    } catch {
                        // Handle error by showing a message
                        let errorMessage = ChatMessage(
                            content: "Error reading file \(url.lastPathComponent): \(error.localizedDescription)",
                            isUser: false,
                            isError: true
                        )
                        messages.append(errorMessage)
                    }
                }
            }
        case .failure(let error):
            let errorMessage = ChatMessage(
                content: "File selection error: \(error.localizedDescription)",
                isUser: false,
                isError: true
            )
            messages.append(errorMessage)
        }
    }
    
    private func determineFileType(from url: URL) -> String {
        let pathExtension = url.pathExtension.lowercased()
        switch pathExtension {
        case "swift": return "Swift"
        case "objc", "h", "m": return "Objective-C"
        case "cpp", "cc", "cxx": return "C++"
        case "py": return "Python"
        case "js": return "JavaScript"
        case "ts": return "TypeScript"
        case "json": return "JSON"
        case "xml": return "XML"
        case "txt": return "Text"
        case "md": return "Markdown"
        case "png", "jpg", "jpeg": return "Image"
        default: return "File"
        }
    }

    private func getAIResponse(for message: String) {
        let defaults = UserDefaults.standard

        guard let apiKey = defaults.string(forKey: Constants.UserDefaultsKeys.apiKey),
              !apiKey.isEmpty else {
            isThinking = false
            isLoading = false
            addErrorMessage("Please configure your API key in Settings first.")
            return
        }

        let config = AIProviderConfig(
            provider: selectedProvider,
            apiKey: apiKey,
            baseURL: selectedProvider == .custom ?
            defaults.string(forKey: Constants.UserDefaultsKeys.customBaseURL) ?? selectedProvider.defaultBaseURL :
                selectedProvider.defaultBaseURL,
            model: selectedModel.isEmpty ? selectedProvider.defaultModel : selectedModel,
            maxTokens: defaults.integer(forKey: Constants.UserDefaultsKeys.maxTokens) > 0 ?
            defaults.integer(forKey: Constants.UserDefaultsKeys.maxTokens) : 1000,
            temperature: defaults.double(forKey: Constants.UserDefaultsKeys.temperature) > 0 ?
            defaults.double(forKey: Constants.UserDefaultsKeys.temperature) : 0.7
        )

        let aiHelper = AIHelper(config: config)

        // Create a chat context instead of completion context
        let chatContext = CompletionContext(
            language: "markdown", // For chat responses
            filename: "chat.md",
            contextBefore: buildChatHistory(),
            contextAfter: "",
            cursorPosition: CursorPosition(line: 0, column: 0),
            entireFile: buildChatHistory() + "\n\nUser: " + message + "\n\nAssistant:"
        )

        aiHelper.fetchCompletion(for: chatContext) { [self] result in
            DispatchQueue.main.async {
                isLoading = false
                isThinking = false

                switch result {
                    case .success(let response):
                        let aiMessage = ChatMessage(
                            content: response,
                            isUser: false,
                            timestamp: Date()
                        )
                        messages.append(aiMessage)

                    case .failure(let error):
                        addErrorMessage("Error: \(error.localizedDescription)")
                }
            }
        }
    }

    private func buildChatHistory() -> String {
        return messages.map { message in
            "\(message.isUser ? "User" : "Assistant"): \(message.content)"
        }.joined(separator: "\n\n")
    }

    private func addErrorMessage(_ error: String) {
        let errorMessage = ChatMessage(
            content: error,
            isUser: false,
            timestamp: Date(),
            isError: true
        )
        messages.append(errorMessage)
    }

    private func iconForFileType(_ type: String) -> String {
        switch type.lowercased() {
        case "swift": return "swift"
        case "objective-c": return "doc.text"
        case "c++": return "doc.text"
        case "python": return "doc.text"
        case "javascript", "typescript": return "doc.text"
        case "json": return "doc.text"
        case "xml": return "doc.text"
        case "markdown": return "doc.richtext"
        case "text": return "doc.plaintext"
        case "image": return "photo"
        default: return "doc"
        }
    }
    
    private func colorForFileType(_ type: String) -> Color {
        switch type.lowercased() {
        case "swift": return .orange
        case "objective-c": return .blue
        case "c++": return .purple
        case "python": return .green
        case "javascript", "typescript": return .yellow
        case "json": return .cyan
        case "xml": return .red
        case "markdown": return .gray
        case "text": return .secondary
        case "image": return .pink
        default: return .secondary
        }
    }
    
    private func addCurrentFileToContext() {
        // Create a mock current file attachment
        let currentFile = AttachedFile(
            name: currentFileName,
            type: currentFileType,
            content: "// Current file content would be loaded here\n// This is a placeholder for the actual file content",
            url: URL(fileURLWithPath: "/path/to/\(currentFileName)")
        )
        
        // Check if file is already attached
        if !attachedFiles.contains(where: { $0.name == currentFileName }) {
            attachedFiles.append(currentFile)
        }
    }
    
    private func loadWorkspaceFiles() {
        // Mock workspace files - in a real implementation, this would scan the actual workspace
        workspaceFiles = [
            "ChatView.swift",
            "ContentView.swift", 
            "SettingsView.swift",
            "AIHelper.swift",
            "AtharvaCore.swift",
            "Models.swift",
            "Constants.swift"
        ]
    }
    
    private func updateCurrentFile(fileName: String) {
        currentFileName = fileName
        currentFileType = determineFileType(from: URL(fileURLWithPath: fileName))
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    let isError: Bool
    let attachments: [AttachmentInfo]

    init(content: String, isUser: Bool, timestamp: Date = Date(), isError: Bool = false, attachments: [AttachmentInfo] = []) {
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
        self.isError = isError
        self.attachments = attachments
    }
}

struct ChatMessageView: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 50)
            }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                HStack {
                    if !message.isUser {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.blue)
                            .font(.caption)
                    }

                    Text(message.isUser ? "You" : "Atharva AI")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(message.isUser ? .blue : .green)

                    if message.isUser {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                    }
                }

                Text(message.content)
                    .padding(12)
                    .background(
                        message.isError ? Color.red.opacity(0.1) :
                            message.isUser ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1)
                    )
                    .foregroundColor(
                        message.isError ? .red :
                            message.isUser ? .primary : .primary
                    )
                    .cornerRadius(16)
                    .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
                    
                // Show attachments if any
                if !message.attachments.isEmpty {
                    VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                        ForEach(message.attachments.indices, id: \.self) { index in
                            let attachment = message.attachments[index]
                            HStack(spacing: 6) {
                                Image(systemName: "paperclip")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                                Text("\(attachment.fileName) (\(attachment.fileType))")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.05))
                            .cornerRadius(8)
                        }
                    }
                }

                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if !message.isUser {
                Spacer(minLength: 50)
            }
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(16)
        }
    }
}

struct ModelPickerView: View {
    @Binding var selectedProvider: AIProvider
    @Binding var selectedModel: String
    let availableModels: [AIProvider: [String]]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("AI Provider") {
                    Picker("Provider", selection: $selectedProvider) {
                        ForEach(AIProvider.allCases, id: \.self) { provider in
                            Text(provider.rawValue.capitalized).tag(provider)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section("Model") {
                    ForEach(availableModels[selectedProvider] ?? [], id: \.self) { model in
                        Button(action: {
                            selectedModel = model
                            dismiss()
                        }) {
                            HStack {
                                Text(model)
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedModel == model {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Model")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }

        }
        .onAppear {
            if selectedModel.isEmpty {
                selectedModel = selectedProvider.defaultModel
            }
        }
    }
}

struct FileSearchView: View {
    @Binding var attachedFiles: [AttachedFile]
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var showingFilePicker = false
    @State private var workspaceFiles: [String] = [
        "ChatView.swift",
        "ContentView.swift",
        "SettingsView.swift", 
        "AIHelper.swift",
        "AtharvaCore.swift",
        "Models.swift",
        "Constants.swift"
    ]
    
    var filteredFiles: [String] {
        if searchText.isEmpty {
            return workspaceFiles
        } else {
            return workspaceFiles.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search files or type @ to search workspace", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                // Quick actions
                VStack(spacing: 12) {
                    Button(action: { showingFilePicker = true }) {
                        HStack {
                            Image(systemName: "doc.badge.plus")
                                .foregroundColor(.blue)
                            Text("Attach files")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(8)
                    }
                    
                    Button(action: {
                        // Add all workspace files to context
                        addAllWorkspaceFiles()
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "folder")
                                .foregroundColor(.blue)
                            Text("Use workspace (\(workspaceFiles.count) files)")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(8)
                    }
                }
                
                // Workspace files list
                if !filteredFiles.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Workspace Files")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView {
                            LazyVStack(spacing: 4) {
                                ForEach(filteredFiles, id: \.self) { fileName in
                                    Button(action: {
                                        addWorkspaceFile(fileName)
                                    }) {
                                        HStack {
                                            Image(systemName: iconForFileName(fileName))
                                                .foregroundColor(colorForFileName(fileName))
                                                .font(.subheadline)
                                            
                                            Text(fileName)
                                                .foregroundColor(.primary)
                                                .font(.subheadline)
                                            
                                            Spacer()
                                            
                                            if attachedFiles.contains(where: { $0.name == fileName }) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                                    .font(.caption)
                                            } else {
                                                Image(systemName: "plus.circle")
                                                    .foregroundColor(.blue)
                                                    .font(.caption)
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.gray.opacity(0.02))
                                        .cornerRadius(4)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                } else if searchText.isEmpty {
                    Spacer()
                    
                    Text("No recent files found")
                        .foregroundColor(.gray)
                        .font(.caption)
                    
                    Spacer()
                } else {
                    Spacer()
                    
                    Text("No files match '\(searchText)'")
                        .foregroundColor(.gray)
                        .font(.caption)
                    
                    Spacer()
                }
            }
            .padding()
            .navigationTitle("Add Context")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.text, .sourceCode, .image, .data],
            allowsMultipleSelection: true
        ) { result in
            handleFileSelection(result)
            dismiss()
        }
    }
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            for url in urls {
                if url.startAccessingSecurityScopedResource() {
                    defer { url.stopAccessingSecurityScopedResource() }
                    
                    do {
                        let fileName = url.lastPathComponent
                        let fileType = determineFileType(from: url)
                        let content = try String(contentsOf: url)
                        
                        let attachedFile = AttachedFile(
                            name: fileName,
                            type: fileType,
                            content: content,
                            url: url
                        )
                        
                        attachedFiles.append(attachedFile)
                    } catch {
                        // Handle error silently or show alert
                        print("Error reading file: \(error)")
                    }
                }
            }
        case .failure(let error):
            print("File selection error: \(error)")
        }
    }
    
    private func addWorkspaceFile(_ fileName: String) {
        // Check if file is already attached
        if !attachedFiles.contains(where: { $0.name == fileName }) {
            let fileType = determineFileType(from: URL(fileURLWithPath: fileName))
            let mockFile = AttachedFile(
                name: fileName,
                type: fileType,
                content: "// Mock content for \(fileName)\n// In a real implementation, this would load the actual file content",
                url: URL(fileURLWithPath: "/workspace/\(fileName)")
            )
            attachedFiles.append(mockFile)
        }
    }
    
    private func addAllWorkspaceFiles() {
        for fileName in workspaceFiles {
            addWorkspaceFile(fileName)
        }
    }
    
    private func iconForFileName(_ fileName: String) -> String {
        let fileType = determineFileType(from: URL(fileURLWithPath: fileName))
        return iconForFileType(fileType)
    }
    
    private func colorForFileName(_ fileName: String) -> Color {
        let fileType = determineFileType(from: URL(fileURLWithPath: fileName))
        return colorForFileType(fileType)
    }
    
    private func iconForFileType(_ type: String) -> String {
        switch type.lowercased() {
        case "swift": return "swift"
        case "objective-c": return "doc.text"
        case "c++": return "doc.text"
        case "python": return "doc.text"
        case "javascript", "typescript": return "doc.text"
        case "json": return "doc.text"
        case "xml": return "doc.text"
        case "markdown": return "doc.richtext"
        case "text": return "doc.plaintext"
        case "image": return "photo"
        default: return "doc"
        }
    }
    
    private func colorForFileType(_ type: String) -> Color {
        switch type.lowercased() {
        case "swift": return .orange
        case "objective-c": return .blue
        case "c++": return .purple
        case "python": return .green
        case "javascript", "typescript": return .yellow
        case "json": return .cyan
        case "xml": return .red
        case "markdown": return .gray
        case "text": return .secondary
        case "image": return .pink
        default: return .secondary
        }
    }
    
    private func determineFileType(from url: URL) -> String {
        let pathExtension = url.pathExtension.lowercased()
        switch pathExtension {
        case "swift": return "Swift"
        case "objc", "h", "m": return "Objective-C"
        case "cpp", "cc", "cxx": return "C++"
        case "py": return "Python"
        case "js": return "JavaScript"
        case "ts": return "TypeScript"
        case "json": return "JSON"
        case "xml": return "XML"
        case "txt": return "Text"
        case "md": return "Markdown"
        case "png", "jpg", "jpeg": return "Image"
        default: return "File"
        }
    }
}

#Preview {
    ChatView()
}
