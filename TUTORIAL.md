# Building an AI-Powered Xcode Extension: Complete Tutorial

This tutorial walks you through building a GitHub Copilot-like extension for Xcode that provides AI-powered code suggestions and refactoring.

## Table of Contents

1. [Understanding Xcode Extensions](#understanding-xcode-extensions)
2. [Project Architecture](#project-architecture)
3. [Implementation Guide](#implementation-guide)
4. [Advanced Features](#advanced-features)
5. [Deployment and Distribution](#deployment-and-distribution)

## Understanding Xcode Extensions

### What are Source Editor Extensions?

Xcode Source Editor Extensions allow you to:
- **Read source code** from the current file
- **Modify text** in the editor
- **Access cursor position** and selections
- **Get file metadata** (language, path)

### Key Limitations

Unlike VS Code extensions, Xcode extensions have significant constraints:

1. **Manual Trigger Only**: No real-time typing detection
2. **No Custom UI**: Cannot show popover suggestions
3. **Sandboxed**: Limited system and network access
4. **Menu-Based**: Accessed via Editor menu or shortcuts

### Extension Lifecycle

```swift
// 1. Extension loads when Xcode starts
func extensionDidFinishLaunching() {
    // Initialize extension
}

// 2. Commands are registered via Info.plist
var commandDefinitions: [[XCSourceEditorCommandDefinitionKey : Any]] {
    // Return command definitions
}

// 3. User triggers command
func perform(with invocation: XCSourceEditorCommandInvocation,
             completionHandler: @escaping (Error?) -> Void) {
    // Execute command logic
}
```

## Project Architecture

### Project Structure

```
Atharva AI/
├── Atharva AI/                     # Main macOS host app
│   ├── Atharva_AIApp.swift        # App entry point
│   ├── ContentView.swift          # Main interface
│   └── SettingsView.swift         # Configuration UI
└── Atharva Extension/              # Source Editor Extension
    ├── SourceEditorExtension.swift     # Extension registration
    ├── AICompletionCommand.swift       # Code completion
    ├── AIRefactorCommand.swift         # Code refactoring
    ├── AIHelper.swift                  # API communication
    ├── Models.swift                    # Data structures
    └── Constants.swift                 # Configuration
```

### Key Components

1. **Host App**: Provides configuration UI
2. **Extension Target**: Implements actual functionality
3. **Commands**: Individual actions (completion, refactoring)
4. **AI Helper**: Handles API communication
5. **Models**: Request/response structures

## Implementation Guide

### Step 1: Create the Extension Structure

#### Extension Registration

```swift
// SourceEditorExtension.swift
class SourceEditorExtension: NSObject, XCSourceEditorExtension {
    func extensionDidFinishLaunching() {
        print("AI Extension launched")
        loadUserPreferences()
    }

    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey : Any]] {
        return [
            [
                XCSourceEditorCommandDefinitionKey.classNameKey: "AICompletionCommand",
                XCSourceEditorCommandDefinitionKey.commandNameKey: "AI Code Completion",
                XCSourceEditorCommandDefinitionKey.commandIdentifierKey: "com.atharva.ai.completion"
            ]
        ]
    }
}
```

#### Info.plist Configuration

```xml
<key>XCSourceEditorCommandDefinitions</key>
<array>
    <dict>
        <key>XCSourceEditorCommandClassName</key>
        <string>$(PRODUCT_MODULE_NAME).AICompletionCommand</string>
        <key>XCSourceEditorCommandIdentifier</key>
        <string>com.atharva.ai.completion</string>
        <key>XCSourceEditorCommandName</key>
        <string>AI Code Completion</string>
    </dict>
</array>
```

### Step 2: Implement Context Extraction

#### Understanding the Buffer

```swift
func perform(with invocation: XCSourceEditorCommandInvocation,
             completionHandler: @escaping (Error?) -> Void) {
    
    let buffer = invocation.buffer  // Contains the source code
    let lines = buffer.lines        // NSMutableArray of strings
    let selections = buffer.selections  // Current selections
    let contentUTI = buffer.contentUTI  // File type identifier
    
    // Extract context and make API call
}
```

#### Context Extraction Strategy

```swift
private func extractContext(from lines: NSMutableArray,
                            around selection: XCSourceTextRange) -> String {
    let currentLine = selection.start.line
    let currentColumn = selection.start.column
    
    // Define context window (lines before/after cursor)
    let contextWindow = 50
    let startLine = max(0, currentLine - contextWindow)
    let endLine = min(lines.count - 1, currentLine + contextWindow)

    var contextLines: [String] = []

    for i in startLine...endLine {
        if let line = lines[i] as? String {
            if i == currentLine {
                // Mark cursor position with special token
                let beforeCursor = String(line.prefix(currentColumn))
                let afterCursor = String(line.dropFirst(currentColumn))
                contextLines.append(beforeCursor + "<|cursor|>" + afterCursor)
            } else {
                contextLines.append(line)
            }
        }
    }

    return contextLines.joined(separator: "\n")
}
```

### Step 3: Language Detection

```swift
private func detectLanguage(from uti: String) -> String {
    let supportedLanguages: [String: String] = [
        "public.swift-source": "swift",
        "public.objective-c-source": "objective-c",
        "public.objective-c-plus-plus-source": "objective-c++",
        "public.c-plus-plus-source": "cpp",
        "public.c-source": "c",
        "public.javascript-source": "javascript",
        "public.python-script": "python"
    ]
    
    return supportedLanguages[uti] ?? "unknown"
}
```

### Step 4: API Integration

#### AI Provider Configuration

```swift
struct AIProviderConfig {
    let provider: AIProvider
    let apiKey: String
    let baseURL: String
    let model: String
    let maxTokens: Int
    let temperature: Double
}

enum AIProvider: String, CaseIterable {
    case openai = "OpenAI"
    case claude = "Claude"
    case custom = "Custom"
}
```

#### API Request Implementation

```swift
class AIHelper {
    private let config: AIProviderConfig
    private let session: URLSession
    
    func fetchCompletion(for context: CompletionContext, 
                        completion: @escaping (Result<String, Error>) -> Void) {
        switch config.provider {
        case .openai:
            fetchOpenAICompletion(for: context, completion: completion)
        case .claude:
            fetchClaudeCompletion(for: context, completion: completion)
        case .custom:
            fetchCustomCompletion(for: context, completion: completion)
        }
    }
    
    private func fetchOpenAICompletion(for context: CompletionContext,
                                     completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(config.baseURL)/chat/completions") else {
            completion(.failure(AIError.invalidURL))
            return
        }
        
        let request = OpenAICompletionRequest(
            model: config.model,
            messages: [
                OpenAIMessage(role: "system", content: systemPrompt),
                OpenAIMessage(role: "user", content: createPrompt(for: context))
            ],
            temperature: config.temperature,
            maxTokens: config.maxTokens,
            stop: stopSequences,
            stream: false
        )
        
        performRequest(url: url, requestBody: request, headers: openAIHeaders(), completion: completion)
    }
}
```

### Step 5: Code Insertion

#### Single Line Insertion

```swift
private func insertCompletion(_ completion: String, 
                            into buffer: XCSourceTextBuffer, 
                            at selection: XCSourceTextRange) {
    let lines = buffer.lines
    let insertionLine = selection.start.line
    let insertionColumn = selection.start.column
    
    guard let currentLine = lines[insertionLine] as? String else { return }
    
    let completionLines = completion.components(separatedBy: .newlines)
    
    if completionLines.count == 1 {
        // Single line completion
        let beforeCursor = String(currentLine.prefix(insertionColumn))
        let afterCursor = String(currentLine.dropFirst(insertionColumn))
        let newLine = beforeCursor + completion + afterCursor
        
        lines.replaceObject(at: insertionLine, with: newLine)
        
        // Update cursor position
        let newPosition = XCSourceTextPosition(
            line: insertionLine, 
            column: insertionColumn + completion.count
        )
        updateSelection(in: buffer, to: newPosition)
    }
}
```

#### Multi-Line Insertion

```swift
// Multi-line completion
let beforeCursor = String(currentLine.prefix(insertionColumn))
let afterCursor = String(currentLine.dropFirst(insertionColumn))

// Replace current line with first completion line
let firstLine = beforeCursor + completionLines[0]
lines.replaceObject(at: insertionLine, with: firstLine)

// Insert middle lines
for i in 1..<(completionLines.count - 1) {
    lines.insert(completionLines[i], at: insertionLine + i)
}

// Insert last line with remaining text
if completionLines.count > 1 {
    let lastLine = completionLines.last! + afterCursor
    lines.insert(lastLine, at: insertionLine + completionLines.count - 1)
}
```

### Step 6: Error Handling and UX

#### Robust Error Handling

```swift
enum AIError: LocalizedError {
    case invalidURL
    case noDataReceived
    case httpError(Int, String)
    case decodingError(Error)
    case rateLimitExceeded
    case apiKeyInvalid
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL configuration"
        case .httpError(let code, let message):
            return "API Error \(code): \(message)"
        case .rateLimitExceeded:
            return "API rate limit exceeded. Please try again later."
        // ... more cases
        }
    }
}
```

#### Retry Logic

```swift
private func performRequestWithRetry<R: Codable>(
    request: URLRequest,
    retryCount: Int,
    completion: @escaping (Result<R, Error>) -> Void
) {
    session.dataTask(with: request) { data, response, error in
        if let error = error {
            if retryCount < maxRetries {
                DispatchQueue.global().asyncAfter(deadline: .now() + retryDelay) {
                    self.performRequestWithRetry(
                        request: request, 
                        retryCount: retryCount + 1, 
                        completion: completion
                    )
                }
            } else {
                completion(.failure(error))
            }
            return
        }
        
        // Process response...
    }.resume()
}
```

## Advanced Features

### Intelligent Context Management

#### Token Counting

```swift
func estimateTokenCount(for text: String) -> Int {
    // Rough estimation: 1 token ≈ 4 characters for English
    return text.count / 4
}

func truncateContext(_ context: String, maxTokens: Int) -> String {
    let estimatedTokens = estimateTokenCount(for: context)
    
    if estimatedTokens <= maxTokens {
        return context
    }
    
    // Truncate from the beginning, keeping recent context
    let targetLength = maxTokens * 4
    let startIndex = context.index(context.endIndex, offsetBy: -targetLength)
    return String(context[startIndex...])
}
```

#### Smart Context Selection

```swift
private func extractSmartContext(from lines: NSMutableArray, 
                               around selection: XCSourceTextRange,
                               language: String) -> String {
    // Include more context for certain constructs
    let currentLine = selection.start.line
    var startLine = currentLine - 25
    var endLine = currentLine + 25
    
    // Extend context for class/function definitions
    if language == "swift" {
        startLine = findClassOrFunctionStart(in: lines, from: currentLine) ?? startLine
        endLine = findBlockEnd(in: lines, from: currentLine) ?? endLine
    }
    
    return extractContext(from: lines, startLine: startLine, endLine: endLine, cursorLine: currentLine)
}
```

### Caching Strategy

```swift
class CompletionCache {
    private var cache: [String: CachedCompletion] = [:]
    private let maxCacheSize = 100
    
    struct CachedCompletion {
        let completion: String
        let timestamp: Date
        let contextHash: String
    }
    
    func getCachedCompletion(for contextHash: String) -> String? {
        guard let cached = cache[contextHash],
              Date().timeIntervalSince(cached.timestamp) < 300 else { // 5 minute expiry
            return nil
        }
        return cached.completion
    }
    
    func cacheCompletion(_ completion: String, for contextHash: String) {
        if cache.count >= maxCacheSize {
            // Remove oldest entries
            let sortedEntries = cache.sorted { $0.value.timestamp < $1.value.timestamp }
            for entry in sortedEntries.prefix(20) {
                cache.removeValue(forKey: entry.key)
            }
        }
        
        cache[contextHash] = CachedCompletion(
            completion: completion,
            timestamp: Date(),
            contextHash: contextHash
        )
    }
}
```

### Performance Optimization

#### Async Processing

```swift
func perform(with invocation: XCSourceEditorCommandInvocation,
             completionHandler: @escaping (Error?) -> Void) {
    
    // Show immediate feedback
    showProgressIndicator()
    
    // Extract context synchronously (fast)
    let context = extractContext(from: invocation.buffer)
    let language = detectLanguage(from: invocation.buffer.contentUTI)
    
    // Make async API call
    DispatchQueue.global(qos: .userInitiated).async {
        self.fetchAICompletion(context: context, language: language) { result in
            DispatchQueue.main.async {
                self.hideProgressIndicator()
                
                switch result {
                case .success(let completion):
                    self.insertCompletion(completion, into: invocation.buffer)
                    completionHandler(nil)
                case .failure(let error):
                    self.showError(error)
                    completionHandler(error)
                }
            }
        }
    }
}
```

#### Debouncing

```swift
class DebouncedCompletion {
    private var workItem: DispatchWorkItem?
    private let delay: TimeInterval = 0.5
    
    func requestCompletion(context: String, completion: @escaping (String) -> Void) {
        workItem?.cancel()
        
        workItem = DispatchWorkItem {
            self.fetchCompletion(context: context, completion: completion)
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + delay, execute: workItem!)
    }
}
```

## Deployment and Distribution

### Code Signing

1. **Developer Account**: Need Apple Developer membership
2. **Certificates**: Create development and distribution certificates
3. **Provisioning Profiles**: Create profiles for both app and extension
4. **Bundle IDs**: Register unique bundle identifiers

### App Store Distribution

```swift
// Info.plist configuration for App Store
<key>LSApplicationCategoryType</key>
<string>public.app-category.developer-tools</string>

<key>NSExtension</key>
<dict>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.dt.Xcode.extension.source-editor</string>
</dict>
```

### Alternative Distribution

1. **Direct Distribution**: Distribute .app file directly
2. **GitHub Releases**: Use GitHub releases for open source
3. **Custom Installer**: Create custom installation process

### Testing Strategy

```swift
// Unit tests for core functionality
class AIHelperTests: XCTestCase {
    func testContextExtraction() {
        let lines = NSMutableArray(array: ["line 1", "line 2", "line 3"])
        let selection = createSelection(line: 1, column: 5)
        
        let context = aiCommand.extractContext(from: lines, around: selection)
        
        XCTAssertTrue(context.contains("<|cursor|>"))
    }
    
    func testLanguageDetection() {
        let language = aiCommand.detectLanguage(from: "public.swift-source")
        XCTAssertEqual(language, "swift")
    }
}
```

## Best Practices

### Security

1. **API Key Storage**: Use Keychain for production
2. **Input Validation**: Sanitize all user inputs
3. **Network Security**: Use HTTPS only
4. **Error Messages**: Don't expose sensitive information

### User Experience

1. **Clear Feedback**: Show progress and error states
2. **Keyboard Shortcuts**: Make commands easily accessible
3. **Settings UI**: Provide comprehensive configuration
4. **Documentation**: Include clear setup instructions

### Performance

1. **Context Optimization**: Balance context size vs. relevance
2. **Caching**: Cache frequent completions
3. **Rate Limiting**: Respect API limits
4. **Background Processing**: Don't block the UI

## Conclusion

Building an AI-powered Xcode extension requires understanding:

1. **Xcode Extension Architecture**: Limitations and capabilities
2. **Context Management**: Extracting meaningful code context
3. **API Integration**: Robust communication with AI services
4. **Code Manipulation**: Safe insertion and modification
5. **User Experience**: Making the extension intuitive and reliable

While Xcode extensions have limitations compared to VS Code, they can still provide valuable AI-powered assistance for developers working in Apple's ecosystem.

The key is to work within the constraints while maximizing the value delivered to users through intelligent context extraction, robust error handling, and seamless integration with the Xcode development workflow.
