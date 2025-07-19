//
//  Models.swift
//  AtharvaCore
//
//  Created by ayan Chakraborty on 19/07/25.
//

import Foundation

// MARK: - OpenAI API Models
public struct OpenAICompletionRequest: Codable {
    public let model: String
    public let messages: [OpenAIMessage]
    public let temperature: Double
    public let maxTokens: Int
    public let stop: [String]?
    public let stream: Bool
    
    public init(model: String, messages: [OpenAIMessage], temperature: Double, maxTokens: Int, stop: [String]?, stream: Bool) {
        self.model = model
        self.messages = messages
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.stop = stop
        self.stream = stream
    }

    enum CodingKeys: String, CodingKey {
        case model, messages, temperature, stop, stream
        case maxTokens = "max_tokens"
    }
}

public struct OpenAIMessage: Codable {
    public let role: String
    public let content: String
    
    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }
}

public struct OpenAICompletionResponse: Codable {
    public let id: String
    public let object: String
    public let created: Int
    public let model: String
    public let choices: [OpenAIChoice]
    public let usage: OpenAIUsage?
}

public struct OpenAIChoice: Codable {
    public let index: Int
    public let message: OpenAIMessage
    public let finishReason: String?

    enum CodingKeys: String, CodingKey {
        case index, message
        case finishReason = "finish_reason"
    }
}

public struct OpenAIUsage: Codable {
    public let promptTokens: Int
    public let completionTokens: Int
    public let totalTokens: Int

    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

// MARK: - Claude API Models
public struct ClaudeCompletionRequest: Codable {
    public let model: String
    public let maxTokens: Int
    public let messages: [ClaudeMessage]
    public let temperature: Double?
    public let stopSequences: [String]?
    
    public init(model: String, maxTokens: Int, messages: [ClaudeMessage], temperature: Double?, stopSequences: [String]?) {
        self.model = model
        self.maxTokens = maxTokens
        self.messages = messages
        self.temperature = temperature
        self.stopSequences = stopSequences
    }

    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
        case stopSequences = "stop_sequences"
    }
}

public struct ClaudeMessage: Codable {
    public let role: String
    public let content: String
    
    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }
}

public struct ClaudeCompletionResponse: Codable {
    public let id: String
    public let type: String
    public let role: String
    public let content: [ClaudeContent]
    public let model: String
    public let stopReason: String?
    public let stopSequence: String?
    public let usage: ClaudeUsage

    enum CodingKeys: String, CodingKey {
        case id, type, role, content, model, usage
        case stopReason = "stop_reason"
        case stopSequence = "stop_sequence"
    }
}

public struct ClaudeContent: Codable {
    public let type: String
    public let text: String
}

public struct ClaudeUsage: Codable {
    public let inputTokens: Int
    public let outputTokens: Int

    enum CodingKeys: String, CodingKey {
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
    }
}

// MARK: - Completion Context
public struct CompletionContext {
    public let language: String
    public let filename: String
    public let contextBefore: String
    public let contextAfter: String
    public let cursorPosition: CursorPosition
    public let entireFile: String
    
    public init(language: String, filename: String, contextBefore: String, contextAfter: String, cursorPosition: CursorPosition, entireFile: String) {
        self.language = language
        self.filename = filename
        self.contextBefore = contextBefore
        self.contextAfter = contextAfter
        self.cursorPosition = cursorPosition
        self.entireFile = entireFile
    }
}

public struct CursorPosition {
    public let line: Int
    public let column: Int
    
    public init(line: Int, column: Int) {
        self.line = line
        self.column = column
    }
}

// MARK: - Configuration Models
public struct AIProviderConfig {
    public let provider: AIProvider
    public let apiKey: String
    public let baseURL: String
    public let model: String
    public let maxTokens: Int
    public let temperature: Double
    
    public init(provider: AIProvider, apiKey: String, baseURL: String, model: String, maxTokens: Int, temperature: Double) {
        self.provider = provider
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.model = model
        self.maxTokens = maxTokens
        self.temperature = temperature
    }
}

public enum AIProvider: String, CaseIterable {
    case openai = "OpenAI"
    case claude = "Claude"
    case custom = "Custom"
    
    public var defaultModel: String {
        switch self {
        case .openai:
            return "gpt-4"
        case .claude:
            return "claude-3-sonnet-20240229"
        case .custom:
            return "custom-model"
        }
    }
    
    public var defaultBaseURL: String {
        switch self {
        case .openai:
            return "https://api.openai.com/v1"
        case .claude:
            return "https://api.anthropic.com"
        case .custom:
            return "https://your-custom-api.com"
        }
    }
}
