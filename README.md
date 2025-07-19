# Atharva AI: Xcode AI Assistant

Atharva AI is a powerful, open-source Xcode extension and macOS app that brings intelligent AI-powered code completion, refactoring, and code analysis directly to Xcode. Think of it as GitHub Copilot specifically designed for the Apple development ecosystem.

## 🚀 Features

### Core AI Capabilities
- **Intelligent Code Completion**: Context-aware suggestions with multi-line code generation
- **Smart Refactoring**: AI-powered code restructuring and optimization
- **Code Analysis**: Detect bugs, suggest improvements, and explain complex code
- **Documentation Generation**: Auto-generate comments and documentation
- **Test Generation**: Create unit tests based on your code

### Language Support
- **Swift**: Full support with iOS/macOS framework awareness
- **Objective-C**: Legacy code support and modernization suggestions
- **C/C++**: System-level programming assistance
- **Python**: Cross-platform scripting support
- **JavaScript/TypeScript**: Web development integration
- **More languages**: Extensible architecture for additional language support

### AI Provider Flexibility
- **OpenAI GPT Models**: GPT-3.5, GPT-4, and custom fine-tuned models
- **Anthropic Claude**: Claude-3 and Claude-2 support
- **Custom Endpoints**: Support for self-hosted or enterprise AI models
- **Multiple Providers**: Switch between providers based on task type

### Advanced Features
- **Context-Aware Processing**: Understands project structure and dependencies
- **Caching System**: Intelligent caching for improved performance
- **Offline Mode**: Basic functionality without internet connection
- **Privacy-First**: No data logging or telemetry
- **Customizable Prompts**: Tailor AI behavior to your coding style

## 📋 Requirements

### System Requirements
- **macOS**: 12.0 (Monterey) or later
- **Xcode**: 14.0 or later
- **Swift**: 5.7+ for development
- **Memory**: 8GB RAM minimum, 16GB recommended
- **Storage**: 500MB for installation
- **Network**: Internet connection for AI API calls

### Developer Requirements
- Apple Developer account (for code signing and distribution)
- Valid API key from supported AI provider
- Basic understanding of Xcode extension architecture

## 🛠 Installation

### Option 1: Pre-built Release (Recommended)

1. **Download the Latest Release**
   ```sh
   # Download from GitHub releases
   curl -L https://github.com/your-org/atharva-ai/releases/latest/download/Atharva-AI.dmg -o Atharva-AI.dmg
   ```

2. **Install the Application**
   - Mount the DMG file
   - Drag `Atharva AI.app` to Applications folder
   - Launch the app and grant necessary permissions

3. **Enable System Extension**
   - Go to **System Preferences → Extensions → Xcode Source Editor**
   - Check the box next to "Atharva AI"
   - Restart Xcode for changes to take effect

### Option 2: Build from Source

1. **Clone the Repository**
   ```sh
   git clone https://github.com/your-org/atharva-ai.git
   cd atharva-ai
   ```

2. **Open in Xcode**
   ```sh
   open Atharva-XCode-AI-Agent.xcodeproj
   ```

3. **Configure Signing**
   - Select your development team in project settings
   - Update bundle identifiers if needed
   - Ensure both app and extension targets are properly signed

4. **Build and Run**
   - Build the project (⌘+B)
   - Run the host application (⌘+R)
   - Follow system extension enablement steps above

## ⚙️ Configuration

### Initial Setup

1. **Launch Atharva AI**
   - Open the host application from Applications folder
   - The configuration window will appear automatically

2. **Configure AI Provider**
   ```
   Provider: OpenAI / Claude / Custom
   API Key: [Your API key]
   Model: gpt-4 / claude-3-sonnet / custom-model
   Base URL: [For custom providers]
   ```

3. **Adjust Settings**
   - **Max Tokens**: 256-2048 (controls response length)
   - **Temperature**: 0.1-1.0 (creativity vs consistency)
   - **Context Window**: Number of lines to include as context
   - **Auto-completion**: Enable/disable real-time suggestions

### Advanced Configuration

#### Custom Prompts
```json
{
  "completion_prompt": "Complete the following code:\n{context}\n\nProvide only the completion:",
  "refactor_prompt": "Refactor this code for better readability:\n{code}",
  "explain_prompt": "Explain what this code does:\n{code}"
}
```

#### Performance Tuning
- **Cache Duration**: How long to keep cached responses (default: 5 minutes)
- **Request Timeout**: Maximum wait time for API responses (default: 30 seconds)
- **Retry Attempts**: Number of retry attempts for failed requests (default: 3)

## 🎯 Usage

### Basic Code Completion

1. **Position Cursor**: Place cursor where you want AI assistance
2. **Trigger Command**: Use keyboard shortcut (⌘+Shift+A) or Editor menu
3. **Review Suggestion**: AI-generated code appears inline
4. **Accept/Reject**: Press Tab to accept or Esc to dismiss

### Code Refactoring

1. **Select Code Block**: Highlight the code you want to refactor
2. **Open Refactor Menu**: Editor → Atharva AI → Refactor Code
3. **Choose Refactoring Type**:
   - Optimize performance
   - Improve readability
   - Add error handling
   - Convert to modern syntax

### Advanced Features

#### Context-Aware Completion
```swift
class UserManager {
    private var users: [User] = []
    
    func addUser(_ user: User) {
        // Cursor here - AI understands the class context
        // Suggests: users.append(user)
    }
}
```

#### Multi-line Generation
```swift
// Type: "create a function to validate email"
// AI generates complete function with validation logic
func validateEmail(_ email: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
    return emailPredicate.evaluate(with: email)
}
```

## 🔧 Troubleshooting

### Common Issues

#### Extension Not Appearing
```sh
# Check if extension is enabled
defaults read com.apple.dt.Xcode XCSourceEditorCommand

# Reset Xcode preferences if needed
rm -rf ~/Library/Developer/Xcode/UserData
```

#### API Connection Issues
- Verify API key is correct and has sufficient credits
- Check internet connection and firewall settings
- Ensure the AI provider service is operational

#### Performance Problems
- Reduce context window size in settings
- Clear application cache: Atharva AI → Clear Cache
- Restart Xcode and the host application

### Debug Mode

Enable debug logging for detailed troubleshooting:
```sh
# Enable debug mode
defaults write com.atharva.ai.extension DebugMode -bool true

# View logs
tail -f ~/Library/Logs/Atharva-AI/extension.log
```

## 🏗 Architecture

### Project Structure
```
Atharva AI/
├── Host App/                    # Main macOS application
│   ├── Atharva_AIApp.swift    # App lifecycle management
│   ├── ContentView.swift      # Main UI components
│   ├── SettingsView.swift     # Configuration interface
│   └── KeychainManager.swift  # Secure credential storage
├── Extension/                   # Xcode Source Editor Extension
│   ├── SourceEditorExtension.swift    # Extension entry point
│   ├── Commands/                       # Command implementations
│   │   ├── AICompletionCommand.swift  # Code completion logic
│   │   ├── AIRefactorCommand.swift    # Refactoring operations
│   │   └── AIExplainCommand.swift     # Code explanation
│   ├── Core/                          # Core functionality
│   │   ├── AIHelper.swift             # AI API communication
│   │   ├── ContextExtractor.swift     # Code context analysis
│   │   ├── CodeInserter.swift         # Text manipulation
│   │   └── CacheManager.swift         # Response caching
│   └── Models/                        # Data structures
│       ├── CompletionRequest.swift    # API request models
│       ├── AIResponse.swift           # API response models
│       └── Configuration.swift       # Settings models
└── Shared/                      # Shared resources
    ├── Constants.swift         # App-wide constants
    ├── Extensions.swift        # Utility extensions
    └── Resources/              # Assets and localization
```

### Key Components

#### AI Helper
Central component managing AI provider communication:
```swift
class AIHelper {
    private let config: AIProviderConfig
    private let cache: CacheManager
    private let session: URLSession
    
    func fetchCompletion(for context: CompletionContext) async throws -> String
    func fetchRefactoring(for code: String, type: RefactoringType) async throws -> String
}
```

#### Context Extractor
Intelligent code context analysis:
```swift
class ContextExtractor {
    func extractContext(from buffer: XCSourceTextBuffer, 
                       around selection: XCSourceTextRange) -> CompletionContext
    func detectLanguage(from uti: String) -> ProgrammingLanguage
    func findRelevantImports(in lines: [String]) -> [String]
}
```

## 📚 Documentation

- **[Complete Tutorial](./TUTORIAL.md)**: Step-by-step development guide
- **[Framework Integration](./FRAMEWORK_INTEGRATION.md)**: Using Atharva AI in your projects
- **[API Reference](./docs/API.md)**: Detailed API documentation
- **[Contributing Guide](./CONTRIBUTING.md)**: How to contribute to the project

## 🔒 Security & Privacy

### Data Handling
- **No Data Collection**: We don't collect or store your code
- **Local Processing**: Context analysis happens locally
- **Secure Transmission**: All API calls use HTTPS with certificate pinning
- **API Key Security**: Keys stored in macOS Keychain with encryption

### Privacy Features
- **Opt-in Telemetry**: Anonymous usage statistics (disabled by default)
- **Code Filtering**: Ability to exclude sensitive files/directories
- **Offline Mode**: Basic functionality without network access
- **Audit Trail**: Log all AI interactions for security review

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](./CONTRIBUTING.md) for details.

### Development Setup
```sh
# Fork and clone the repository
git clone https://github.com/your-username/atharva-ai.git

# Create a development branch
git checkout -b feature/your-feature

# Make changes and test thoroughly
# Submit a pull request
```

### Areas for Contribution
- Additional AI provider integrations
- New programming language support
- Performance optimizations
- UI/UX improvements
- Documentation and tutorials

## 📄 License

MIT License - see [LICENSE](./LICENSE) file for details.

## 🙏 Acknowledgments

- OpenAI for GPT models and API
- Anthropic for Claude AI
- Apple for Xcode extension framework
- The open-source community for inspiration and feedback

## 📞 Support

- **GitHub Issues**: [Report bugs or request features](https://github.com/your-org/atharva-ai/issues)
- **Documentation**: [Comprehensive guides and tutorials](./docs/)
- **Community**: [Join our Discord server](https://discord.gg/atharva-ai)
- **Email**: support@atharva-ai.com

---

**Made with ❤️ for the Apple development community**
