//
//  Constants.swift
//  AtharvaCore
//
//  Created by ayan Chakraborty on 19/07/25.
//

import Foundation

public struct Constants {
    // MARK: - API Configuration
    public static let defaultAPIKey = "your-api-key-here" // Replace with your actual API key
    public static let defaultProvider: AIProvider = .openai
    
    // MARK: - Completion Settings
    public static let maxContextTokens = 4000
    public static let maxCompletionTokens = 500
    public static let defaultTemperature = 0.2
    public static let contextWindowLines = 50
    
    // MARK: - Timeouts and Limits
    public static let apiTimeoutSeconds: TimeInterval = 30
    public static let maxRetries = 3
    public static let retryDelay: TimeInterval = 1.0
    
    // MARK: - User Defaults Keys
    public struct UserDefaultsKeys {
        public static let apiKey = "atharva.ai.apiKey"
        public static let selectedProvider = "atharva.ai.selectedProvider"
        public static let customBaseURL = "atharva.ai.customBaseURL"
        public static let customModel = "atharva.ai.customModel"
        public static let maxTokens = "atharva.ai.maxTokens"
        public static let temperature = "atharva.ai.temperature"
        public static let enabledLanguages = "atharva.ai.enabledLanguages"
    }
    
    // MARK: - Prompts
    public struct Prompts {
        public static let systemPrompt = """
        You are an AI code assistant integrated into Xcode. Your task is to provide helpful code completions and suggestions based on the current context.
        
        Guidelines:
        1. Analyze the code context around the cursor position (marked with <|cursor|>)
        2. Provide relevant, syntactically correct code completions
        3. Consider the programming language and existing code patterns
        4. Keep completions concise but meaningful
        5. Don't repeat existing code unless necessary for completion
        6. Focus on the most likely next code the developer would write
        
        Languages you support: Swift, Objective-C, C++, and others.
        
        Return only the code completion without explanations or markdown formatting.
        """
        
        public static func completionPrompt(for context: CompletionContext) -> String {
            return """
            File: \(context.filename)
            Language: \(context.language)
            
            Code context:
            \(context.contextBefore)<|cursor|>\(context.contextAfter)
            
            Provide a code completion for the cursor position. Return only the code that should be inserted, without any explanations.
            """
        }
    }
    
    // MARK: - Supported Languages
    public static let supportedLanguages: [String: String] = [
        "public.swift-source": "swift",
        "public.objective-c-source": "objective-c",
        "public.objective-c-plus-plus-source": "objective-c++",
        "public.c-plus-plus-source": "cpp",
        "public.c-source": "c",
        "public.c-header": "c",
        "public.objective-c-header": "objective-c",
        "public.javascript-source": "javascript",
        "public.python-script": "python",
        "public.shell-script": "bash",
        "public.json": "json",
        "public.xml": "xml"
    ]
    
    // MARK: - Stop Sequences
    public static let stopSequences: [String] = [
        "\n\n\n",
        "```",
        "*/",
        "#endif",
        "class ",
        "struct ",
        "func ",
        "var ",
        "let "
    ]
}
