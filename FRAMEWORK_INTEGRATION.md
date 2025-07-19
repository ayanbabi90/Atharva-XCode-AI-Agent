# Atharva AI Framework Integration Guide

This comprehensive guide explains how to integrate the Atharva AI framework into your own macOS applications, Xcode extensions, or third-party development tools.

## Table of Contents

1. [Overview](#overview)
2. [Integration Methods](#integration-methods)
3. [Core Components](#core-components)
4. [API Reference](#api-reference)
5. [Advanced Usage](#advanced-usage)
6. [Best Practices](#best-practices)
7. [Examples](#examples)
8. [Troubleshooting](#troubleshooting)

## Overview

The Atharva AI framework provides a modular, reusable architecture for integrating AI-powered code assistance into any macOS development tool. The framework is designed with the following principles:

- **Modularity**: Core components can be used independently
- **Extensibility**: Easy to add new AI providers and languages
- **Performance**: Optimized for real-time code assistance
- **Security**: Built-in secure handling of API keys and user data

### Framework Architecture

```
AtharvaAI.framework/
├── Core/                    # Core AI functionality
│   ├── AIHelper            # Main AI communication
│   ├── ContextExtractor    # Code context analysis
│   ├── ResponseProcessor   # AI response handling
│   └── CacheManager        # Intelligent caching
├── Providers/              # AI provider implementations
│   ├── OpenAIProvider     # OpenAI GPT integration
│   ├── ClaudeProvider     # Anthropic Claude integration
│   └── CustomProvider     # Custom endpoint support
├── Models/                 # Data structures
│   ├── CompletionModels   # Request/response models
│   ├── ConfigurationModels # Settings and configuration
│   └── LanguageModels     # Language-specific structures
└── Utilities/             # Helper utilities
    ├── KeychainManager    # Secure credential storage
    ├── NetworkManager     # HTTP client with retry logic
    └── LanguageDetector   # Programming language detection
```

## Integration Methods

### Method 1: Swift Package Manager (Recommended)

Add Atharva AI to your project using Swift Package Manager:

1. **Add Package Dependency**
   ```swift
   // Package.swift
   dependencies: [
       .package(url: "https://github.com/your-org/atharva-ai.git", from: "1.0.0")
   ]
   ```

2. **Import Framework**
   ```swift
   import AtharvaAI
   ```

### Method 2: CocoaPods

```ruby
# Podfile
platform :macos, '12.0'
use_frameworks!

target 'YourApp' do
  pod 'AtharvaAI', '~> 1.0'
end
```

### Method 3: Manual Integration

1. **Download Framework**
   - Download the latest `AtharvaAI.framework` from releases
   - Add it to your project's "Frameworks and Libraries"

2. **Configure Build Settings**
   ```
   Framework Search Paths: $(PROJECT_DIR)/Frameworks
   Runpath Search Paths: @executable_path/../Frameworks
   ```

## Core Components

### AIHelper - Main Interface

The `AIHelper` class is the primary interface for AI functionality:

```swift
import AtharvaAI

// Initialize with configuration
let config = AIProviderConfig(
    provider: .openai,
    apiKey: "your-api-key",
    baseURL: "https://api.openai.com/v1",
    model: "gpt-4",
    maxTokens: 512,
    temperature: 0.2
)

let aiHelper = AIHelper(config: config)

// Basic completion request
let context = CompletionContext(
    code: sourceCode,
    language: .swift,
    cursorPosition: CursorPosition(line: 10, column: 5)
)

Task {
    do {
        let completion = try await aiHelper.fetchCompletion(for: context)
        print("AI Suggestion: \(completion)")
    } catch {
        print("Error: \(error)")
    }
}
```

### ContextExtractor - Code Analysis

Intelligently extract relevant context from source code:

```swift
let extractor = ContextExtractor()

// Extract context from source buffer
let context = extractor.extractContext(
    from: sourceLines,
    around: cursorPosition,
    language: .swift,
    maxLines: 100
)

// Advanced context extraction with semantic analysis
let advancedContext = extractor.extractSemanticContext(
    from: sourceCode,
    focusArea: .function, // .class, .method, .variable
    includeImports: true,
    includeDependencies: false
)
```

### CacheManager - Performance Optimization

Implement intelligent caching for improved performance:

```swift
let cacheManager = CacheManager(
    maxSize: 1000,
    expirationTime: 300 // 5 minutes
)

// Check cache before making API call
let contextHash = context.hashValue
if let cachedResponse = cacheManager.getCachedResponse(for: contextHash) {
    return cachedResponse
}

// Cache new response
cacheManager.cacheResponse(response, for: contextHash)
```

## API Reference

### AIHelper Class

#### Initialization

```swift
class AIHelper {
    init(config: AIProviderConfig)
    init(provider: AIProvider, apiKey: String)
}
```

#### Core Methods

```swift
// Code completion
func fetchCompletion(for context: CompletionContext) async throws -> String

// Code refactoring
func fetchRefactoring(for code: String, type: RefactoringType) async throws -> String

// Code explanation
func explainCode(_ code: String, language: ProgrammingLanguage) async throws -> String

// Generate tests
func generateTests(for code: String, framework: TestFramework) async throws -> String
```

### CompletionContext Structure

```swift
struct CompletionContext {
    let code: String                    // Source code context
    let language: ProgrammingLanguage   // Programming language
    let cursorPosition: CursorPosition  // Cursor location
    let fileType: String?               // File extension
    let imports: [String]               // Import statements
    let projectContext: ProjectContext? // Project-level context
}
```

### AIProviderConfig

```swift
struct AIProviderConfig {
    let provider: AIProvider            // .openai, .claude, .custom
    let apiKey: String                 // API authentication key
    let baseURL: String                // API endpoint URL
    let model: String                  // Model identifier
    let maxTokens: Int                 // Maximum response tokens
    let temperature: Double            // Randomness (0.0-1.0)
    let timeout: TimeInterval          // Request timeout
    let retryAttempts: Int            // Number of retry attempts
}
```

## Advanced Usage

### Custom AI Provider

Create your own AI provider by implementing the `AIProvider` protocol:

```swift
class CustomAIProvider: AIProvider {
    let config: AIProviderConfig
    
    init(config: AIProviderConfig) {
        self.config = config
    }
    
    func fetchCompletion(for context: CompletionContext) async throws -> String {
        // Implement your custom API logic
        let request = createCustomRequest(from: context)
        let response = try await performRequest(request)
        return processCustomResponse(response)
    }
    
    func fetchRefactoring(for code: String, type: RefactoringType) async throws -> String {
        // Implement refactoring logic
    }
}

// Register custom provider
AIHelper.registerProvider("custom", CustomAIProvider.self)
```

### Context Preprocessing

Implement custom context preprocessing for specific use cases:

```swift
class SwiftContextProcessor: ContextProcessor {
    func preprocess(_ context: CompletionContext) -> CompletionContext {
        var processedContext = context
        
        // Add Swift-specific context
        processedContext.imports = extractSwiftImports(from: context.code)
        processedContext.frameworks = detectFrameworks(from: context.imports)
        
        // Remove sensitive information
        processedContext.code = sanitizeCode(context.code)
        
        return processedContext
    }
}

// Use custom processor
let processor = SwiftContextProcessor()
let aiHelper = AIHelper(config: config, contextProcessor: processor)
```

### Response Post-processing

Customize AI response handling:

```swift
class CodeResponseProcessor: ResponseProcessor {
    func postprocess(_ response: String, for context: CompletionContext) -> String {
        var processedResponse = response
        
        // Format code according to style guide
        processedResponse = formatSwiftCode(processedResponse)
        
        // Add import statements if needed
        processedResponse = addMissingImports(processedResponse, context: context)
        
        // Validate syntax
        if !isValidSwiftCode(processedResponse) {
            throw AIError.invalidResponse
        }
        
        return processedResponse
    }
}
```

### Streaming Responses

For real-time streaming of AI responses:

```swift
let aiHelper = AIHelper(config: config)

// Stream completion with progress updates
aiHelper.streamCompletion(for: context) { progress in
    switch progress {
    case .started:
        showLoadingIndicator()
    case .progress(let partial):
        updateUI(with: partial)
    case .completed(let full):
        hideLoadingIndicator()
        insertCompletion(full)
    case .error(let error):
        handleError(error)
    }
}
```

## Best Practices

### Security Considerations

1. **API Key Management**
   ```swift
   // Store API keys securely in Keychain
   let keychain = KeychainManager()
   try keychain.store(apiKey, for: "ai-provider-key")
   
   // Retrieve when needed
   let apiKey = try keychain.retrieve("ai-provider-key")
   ```

2. **Input Sanitization**
   ```swift
   func sanitizeCode(_ code: String) -> String {
       // Remove sensitive information
       var sanitized = code
       sanitized = removeAPIKeys(sanitized)
       sanitized = removePersonalInfo(sanitized)
       return sanitized
   }
   ```

3. **Network Security**
   ```swift
   // Use certificate pinning for production
   let config = URLSessionConfiguration.default
   config.urlCache = nil
   config.requestCachePolicy = .reloadIgnoringLocalCacheData
   ```

### Performance Optimization

1. **Context Size Management**
   ```swift
   func optimizeContext(_ context: CompletionContext) -> CompletionContext {
       let maxTokens = 4000 // Model-specific limit
       
       if estimateTokenCount(context.code) > maxTokens {
           return truncateContext(context, maxTokens: maxTokens)
       }
       
       return context
   }
   ```

2. **Intelligent Caching**
   ```swift
   // Cache based on context similarity
   func getCacheKey(for context: CompletionContext) -> String {
       let semanticHash = semanticAnalyzer.hash(context.code)
       return "\(context.language)-\(semanticHash)"
   }
   ```

3. **Background Processing**
   ```swift
   // Perform AI requests on background queue
   func fetchCompletionAsync(for context: CompletionContext) {
       Task.detached(priority: .userInitiated) {
           let completion = try await aiHelper.fetchCompletion(for: context)
           
           await MainActor.run {
               self.updateUI(with: completion)
           }
       }
   }
   ```

### Error Handling

```swift
enum AIIntegrationError: LocalizedError {
    case configurationError(String)
    case networkError(Error)
    case apiError(Int, String)
    case contextTooLarge(Int)
    case invalidResponse(String)
    
    var errorDescription: String? {
        switch self {
        case .configurationError(let message):
            return "Configuration error: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .apiError(let code, let message):
            return "API error \(code): \(message)"
        case .contextTooLarge(let size):
            return "Context too large: \(size) tokens. Please reduce context size."
        case .invalidResponse(let response):
            return "Invalid AI response: \(response)"
        }
    }
}
```

## Examples

### Example 1: Simple Xcode Extension Integration

```swift
import XcodeKit
import AtharvaAI

class CodeCompletionCommand: NSObject, XCSourceEditorCommand {
    private let aiHelper: AIHelper
    
    override init() {
        let config = AIProviderConfig(
            provider: .openai,
            apiKey: KeychainManager.shared.getAPIKey(),
            model: "gpt-4"
        )
        self.aiHelper = AIHelper(config: config)
        super.init()
    }
    
    func perform(with invocation: XCSourceEditorCommandInvocation,
                 completionHandler: @escaping (Error?) -> Void) {
        
        Task {
            do {
                let context = extractContext(from: invocation.buffer)
                let completion = try await aiHelper.fetchCompletion(for: context)
                
                await MainActor.run {
                    insertCompletion(completion, into: invocation.buffer)
                    completionHandler(nil)
                }
            } catch {
                await MainActor.run {
                    completionHandler(error)
                }
            }
        }
    }
    
    private func extractContext(from buffer: XCSourceTextBuffer) -> CompletionContext {
        let extractor = ContextExtractor()
        let selection = buffer.selections.firstObject as! XCSourceTextRange
        
        return extractor.extractContext(
            from: buffer.lines as! [String],
            around: CursorPosition(line: selection.start.line, column: selection.start.column),
            language: detectLanguage(from: buffer.contentUTI)
        )
    }
}
```

### Example 2: Custom macOS App Integration

```swift
import SwiftUI
import AtharvaAI

class CodeAssistantViewModel: ObservableObject {
    @Published var code: String = ""
    @Published var suggestion: String = ""
    @Published var isLoading: Bool = false
    
    private let aiHelper: AIHelper
    
    init() {
        let config = UserDefaults.standard.aiProviderConfig
        self.aiHelper = AIHelper(config: config)
    }
    
    func requestCompletion() {
        guard !code.isEmpty else { return }
        
        isLoading = true
        
        Task {
            do {
                let context = CompletionContext(
                    code: code,
                    language: .swift,
                    cursorPosition: CursorPosition(line: code.lines.count, column: 0)
                )
                
                let completion = try await aiHelper.fetchCompletion(for: context)
                
                await MainActor.run {
                    self.suggestion = completion
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    // Handle error
                }
            }
        }
    }
}

struct CodeAssistantView: View {
    @StateObject private var viewModel = CodeAssistantViewModel()
    
    var body: some View {
        VStack {
            TextEditor(text: $viewModel.code)
                .font(.system(.body, design: .monospaced))
            
            if viewModel.isLoading {
                ProgressView("Generating suggestion...")
            } else if !viewModel.suggestion.isEmpty {
                Text(viewModel.suggestion)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            
            Button("Get AI Suggestion") {
                viewModel.requestCompletion()
            }
            .disabled(viewModel.isLoading)
        }
        .padding()
    }
}
```

### Example 3: Command Line Tool Integration

```swift
import Foundation
import AtharvaAI

@main
struct CodeAssistantCLI {
    static func main() async {
        let config = AIProviderConfig(
            provider: .openai,
            apiKey: ProcessInfo.processInfo.environment["OPENAI_API_KEY"]!,
            model: "gpt-4"
        )
        
        let aiHelper = AIHelper(config: config)
        
        print("Enter your code (press Ctrl+D when done):")
        let input = readInput()
        
        let context = CompletionContext(
            code: input,
            language: detectLanguage(from: input),
            cursorPosition: CursorPosition(line: input.lines.count, column: 0)
        )
        
        do {
            let completion = try await aiHelper.fetchCompletion(for: context)
            print("\nAI Suggestion:")
            print(completion)
        } catch {
            print("Error: \(error)")
        }
    }
    
    static func readInput() -> String {
        var lines: [String] = []
        while let line = readLine() {
            lines.append(line)
        }
        return lines.joined(separator: "\n")
    }
}
```

## Troubleshooting

### Common Integration Issues

1. **Framework Not Found**
   ```
   Error: dyld: Library not loaded: @rpath/AtharvaAI.framework
   
   Solution: Ensure framework is properly embedded and code signed
   ```

2. **API Key Issues**
   ```swift
   // Debug API key configuration
   func validateAPIKey() -> Bool {
       guard !config.apiKey.isEmpty else {
           print("API key is empty")
           return false
       }
       
       // Test with simple API call
       // Implementation specific to provider
   }
   ```

3. **Memory Issues**
   ```swift
   // Monitor memory usage
   func monitorMemoryUsage() {
       let memoryInfo = mach_task_basic_info()
       // Log memory usage and optimize context size
   }
   ```

### Debug Mode

Enable debug logging for troubleshooting:

```swift
// Enable debug mode
AtharvaAI.enableDebugMode()

// Custom debug handler
AtharvaAI.setDebugHandler { level, message in
    print("[\(level)] \(message)")
}
```

### Performance Monitoring

```swift
// Monitor API response times
let startTime = CFAbsoluteTimeGetCurrent()
let completion = try await aiHelper.fetchCompletion(for: context)
let responseTime = CFAbsoluteTimeGetCurrent() - startTime

print("API response time: \(responseTime)s")
```

## Support and Resources

- **Documentation**: Full API documentation available at [docs.atharva-ai.com](https://docs.atharva-ai.com)
- **GitHub Issues**: [Report integration issues](https://github.com/your-org/atharva-ai/issues)
- **Discord Community**: [Join our Discord](https://discord.gg/atharva-ai)
- **Email Support**: integration@atharva-ai.com

## License

The Atharva AI framework is released under the MIT License. See [LICENSE](./LICENSE) for details.
