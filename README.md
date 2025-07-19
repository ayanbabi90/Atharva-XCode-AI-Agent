# Atharva AI - AI-Powered Xcode Extension

An intelligent code completion and refactoring extension for Xcode, similar to GitHub Copilot, that provides AI-powered suggestions using OpenAI, Claude, or custom APIs.

## Features

- **AI Code Completion**: Get intelligent code suggestions based on context
- **Code Refactoring**: Improve code quality with AI-powered refactoring
- **Multi-Language Support**: Works with Swift, Objective-C, C++, JavaScript, Python, and more
- **Multiple AI Providers**: Choose from OpenAI, Claude, or implement custom APIs
- **Context-Aware**: Analyzes surrounding code for better suggestions
- **Configurable**: Customize API settings, temperature, max tokens, and more

## Installation

### Prerequisites

- Xcode 15.0 or later
- macOS 13.0 or later
- An API key from your chosen AI provider (OpenAI, Anthropic, etc.)

### Setup Steps

1. **Clone the Repository**
   ```bash
   git clone <your-repo-url>
   cd Atharva-AI
   ```

2. **Open in Xcode**
   ```bash
   open "Atharva AI.xcodeproj"
   ```

3. **Configure Team and Bundle ID**
   - Select the project in Xcode
   - Update the Team and Bundle Identifier for both targets:
     - `Atharva AI` (main app)
     - `Atharva Extension` (source editor extension)

4. **Build and Run**
   - Build the project (`Cmd+B`)
   - Run the main app (`Cmd+R`)
   - This will install the extension in Xcode

5. **Enable the Extension**
   - Open Xcode preferences (`Cmd+,`)
   - Go to Extensions tab
   - Enable "Atharva Extension"

6. **Configure API Key**
   - Launch the Atharva AI app
   - Open Settings
   - Enter your API key and configure preferences
   - Test the connection

## Configuration

### API Providers

#### OpenAI
- **API Key**: Get from [OpenAI Platform](https://platform.openai.com/api-keys)
- **Model**: `gpt-4`, `gpt-3.5-turbo`, or newer models
- **Base URL**: `https://api.openai.com/v1`

#### Claude (Anthropic)
- **API Key**: Get from [Anthropic Console](https://console.anthropic.com/)
- **Model**: `claude-3-sonnet-20240229`, `claude-3-haiku-20240307`
- **Base URL**: `https://api.anthropic.com`

#### Custom API
- **Base URL**: Your custom API endpoint
- **Model**: Your custom model name
- **Headers**: Configured in `AIHelper.swift`

### Settings

- **Temperature**: Controls randomness (0.0 = deterministic, 1.0 = creative)
- **Max Tokens**: Maximum completion length
- **Context Window**: Lines of code to include for context

## Usage

### Code Completion

1. Place your cursor where you want suggestions
2. Go to **Editor → Atharva AI → AI Code Completion**
3. Wait for the AI to generate and insert suggestions
4. Or assign a keyboard shortcut in Xcode preferences

### Code Refactoring

1. Select the code you want to refactor
2. Go to **Editor → Atharva AI → AI Refactor Code**
3. The AI will analyze and improve your code

### Keyboard Shortcuts

You can assign custom keyboard shortcuts:
1. Xcode → Preferences → Key Bindings
2. Search for "Atharva AI"
3. Assign shortcuts (e.g., `Cmd+Shift+A` for completion)

## Architecture

```
Atharva AI.xcodeproj/
├── Atharva AI/                    # Main macOS app
│   ├── Atharva_AIApp.swift       # App entry point
│   ├── ContentView.swift         # Main UI
│   └── SettingsView.swift        # Configuration UI
└── Atharva Extension/            # Xcode Source Editor Extension
    ├── SourceEditorExtension.swift    # Extension registration
    ├── AICompletionCommand.swift      # Code completion logic
    ├── AIRefactorCommand.swift        # Code refactoring logic
    ├── AIHelper.swift                 # API communication
    ├── Models.swift                   # Data models
    └── Constants.swift                # Configuration constants
```

## Technical Details

### How Xcode Extensions Work

- **Source Editor Extensions** can read and modify source code
- **Triggered manually** via menu or keyboard shortcuts
- **Cannot provide real-time suggestions** like VS Code extensions
- **Sandboxed environment** with limited system access

### Context Extraction

The extension extracts context around the cursor:
- 50 lines before and after the cursor (configurable)
- Marks cursor position with `<|cursor|>` token
- Includes file type and language information

### API Integration

- Supports multiple AI providers through unified interface
- Handles rate limiting and retries
- Parses responses and extracts code suggestions
- Error handling for network issues and API errors

### Code Insertion

- Handles both single-line and multi-line completions
- Preserves existing code and cursor position
- Updates Xcode selection after insertion

## Limitations

### Xcode Extension Constraints

- **No real-time typing detection**: Must be triggered manually
- **No inline UI**: Cannot show suggestions in popover/dropdown
- **No background processing**: Runs only when triggered
- **Sandboxed**: Limited file system and network access

### Workarounds

- Use keyboard shortcuts for quick access
- Configure context window size for better suggestions
- Implement caching for frequently used completions

## Customization

### Adding New AI Providers

1. Add new case to `AIProvider` enum in `Models.swift`
2. Implement request/response models
3. Add handling in `AIHelper.swift`
4. Update UI in `SettingsView.swift`

### Extending Language Support

1. Add UTI mapping in `Constants.supportedLanguages`
2. Update file extension mapping in command classes
3. Customize prompts for specific languages

### Custom Prompts

Modify prompts in `Constants.Prompts`:
- `systemPrompt`: Overall AI behavior
- `completionPrompt`: Context for completions

## Troubleshooting

### Extension Not Showing
- Ensure both targets are built successfully
- Check Xcode Extensions preferences
- Restart Xcode after enabling

### API Errors
- Verify API key is correct and has credits
- Check network connectivity
- Review error messages in console

### Poor Suggestions
- Increase context window size
- Adjust temperature setting
- Try different AI models
- Ensure sufficient code context

### Performance Issues
- Reduce max tokens for faster responses
- Implement request caching
- Use lighter AI models

## Development

### Building from Source

```bash
# Clone the repository
git clone <repo-url>
cd Atharva-AI

# Open in Xcode
open "Atharva AI.xcodeproj"

# Build and run
# Cmd+B to build
# Cmd+R to run and install extension
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

[Your License Here]

## Support

For issues and feature requests, please use the GitHub issue tracker.

## Security

- API keys are stored in UserDefaults (consider Keychain for production)
- Network requests use HTTPS
- No code is stored on external servers beyond API calls
