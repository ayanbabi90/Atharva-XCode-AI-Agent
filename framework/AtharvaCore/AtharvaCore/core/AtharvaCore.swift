//
//  AtharvaCore.swift
//  AtharvaCore
//
//  Created by ayan Chakraborty on 19/07/25.
//

import Foundation

// Re-export all public types from the framework
@_exported import Foundation

// MARK: - Framework Entry Point
public struct AtharvaFramework {
    public static let version = "1.0.0"
    
    public static func initialize() {
        // Framework initialization if needed
        print("[DEBUG] AtharvaCore framework initialized - version \(version)")
        print("[DEBUG] AIProvider cases available: \(AIProvider.allCases.map { $0.rawValue })")
    }
}

// MARK: - Convenience Extensions
public extension AIHelper {
    /// Create a quick completion request with default settings
    static func quickCompletion(
        for code: String,
        language: String = "swift",
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let config = AIHelper.createDefaultConfig()
        let aiHelper = AIHelper(config: config)
        
        let context = CompletionContext(
            language: language,
            filename: "temp.\(language)",
            contextBefore: code,
            contextAfter: "",
            cursorPosition: CursorPosition(line: 0, column: code.count),
            entireFile: code
        )
        
        aiHelper.fetchCompletion(for: context, completion: completion)
    }
}

public extension AIProviderConfig {
    /// Create config with OpenAI defaults
    static func openAI(apiKey: String) -> AIProviderConfig {
        return AIProviderConfig(
            provider: .openai,
            apiKey: apiKey,
            baseURL: AIProvider.openai.defaultBaseURL,
            model: AIProvider.openai.defaultModel,
            maxTokens: Constants.maxCompletionTokens,
            temperature: Constants.defaultTemperature
        )
    }
    
    /// Create config with Claude defaults
    static func claude(apiKey: String) -> AIProviderConfig {
        return AIProviderConfig(
            provider: .claude,
            apiKey: apiKey,
            baseURL: AIProvider.claude.defaultBaseURL,
            model: AIProvider.claude.defaultModel,
            maxTokens: Constants.maxCompletionTokens,
            temperature: Constants.defaultTemperature
        )
    }
    
    /// Create config with custom API
    static func custom(apiKey: String, baseURL: String, model: String) -> AIProviderConfig {
        return AIProviderConfig(
            provider: .custom,
            apiKey: apiKey,
            baseURL: baseURL,
            model: model,
            maxTokens: Constants.maxCompletionTokens,
            temperature: Constants.defaultTemperature
        )
    }
}
