//
//  AIHelper.swift
//  AtharvaCore
//
//  Created by ayan Chakraborty on 19/07/25.
//

import Foundation

public class AIHelper {
    private let config: AIProviderConfig
    private let session: URLSession
    
    public init(config: AIProviderConfig) {
        self.config = config
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Constants.apiTimeoutSeconds
        configuration.timeoutIntervalForResource = Constants.apiTimeoutSeconds * 2
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Public API
    public func fetchCompletion(for context: CompletionContext, completion: @escaping (Result<String, Error>) -> Void) {
        switch config.provider {
        case .openai:
            fetchOpenAICompletion(for: context, completion: completion)
        case .claude:
            fetchClaudeCompletion(for: context, completion: completion)
        case .custom:
            fetchCustomCompletion(for: context, completion: completion)
        }
    }
    
    // MARK: - OpenAI Implementation
    private func fetchOpenAICompletion(for context: CompletionContext, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(config.baseURL)/chat/completions") else {
            completion(.failure(AIError.invalidURL))
            return
        }
        
        let request = OpenAICompletionRequest(
            model: config.model,
            messages: [
                OpenAIMessage(role: "system", content: Constants.Prompts.systemPrompt),
                OpenAIMessage(role: "user", content: Constants.Prompts.completionPrompt(for: context))
            ],
            temperature: config.temperature,
            maxTokens: config.maxTokens,
            stop: Constants.stopSequences,
            stream: false
        )
        
        performRequest(url: url, requestBody: request, headers: openAIHeaders()) { (result: Result<OpenAICompletionResponse, Error>) in
            switch result {
            case .success(let response):
                if let choice = response.choices.first {
                    let completionText = choice.message.content.trimmingCharacters(in: .whitespacesAndNewlines)
                    completion(.success(completionText))
                } else {
                    completion(.failure(AIError.noCompletionReceived))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Claude Implementation
    private func fetchClaudeCompletion(for context: CompletionContext, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(config.baseURL)/v1/messages") else {
            completion(.failure(AIError.invalidURL))
            return
        }
        
        let request = ClaudeCompletionRequest(
            model: config.model,
            maxTokens: config.maxTokens,
            messages: [
                ClaudeMessage(role: "user", content: Constants.Prompts.systemPrompt + "\n\n" + Constants.Prompts.completionPrompt(for: context))
            ],
            temperature: config.temperature,
            stopSequences: Constants.stopSequences
        )
        
        performRequest(url: url, requestBody: request, headers: claudeHeaders()) { (result: Result<ClaudeCompletionResponse, Error>) in
            switch result {
            case .success(let response):
                if let content = response.content.first {
                    let completionText = content.text.trimmingCharacters(in: .whitespacesAndNewlines)
                    completion(.success(completionText))
                } else {
                    completion(.failure(AIError.noCompletionReceived))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Custom API Implementation
    private func fetchCustomCompletion(for context: CompletionContext, completion: @escaping (Result<String, Error>) -> Void) {
        // Implement your custom API logic here
        // This is a placeholder for custom API implementations
        completion(.failure(AIError.customAPINotImplemented))
    }
    
    // MARK: - HTTP Request Helper
    private func performRequest<T: Codable, R: Codable>(
        url: URL,
        requestBody: T,
        headers: [String: String],
        completion: @escaping (Result<R, Error>) -> Void
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Encode request body
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            request.httpBody = try encoder.encode(requestBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        // Perform request with retry logic
        performRequestWithRetry(request: request, retryCount: 0, completion: completion)
    }
    
    private func performRequestWithRetry<R: Codable>(
        request: URLRequest,
        retryCount: Int,
        completion: @escaping (Result<R, Error>) -> Void
    ) {
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                if retryCount < Constants.maxRetries {
                    DispatchQueue.global().asyncAfter(deadline: .now() + Constants.retryDelay) {
                        self.performRequestWithRetry(request: request, retryCount: retryCount + 1, completion: completion)
                    }
                } else {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                completion(.failure(AIError.noDataReceived))
                return
            }
            
            // Check HTTP status code
            if let httpResponse = response as? HTTPURLResponse {
                guard 200...299 ~= httpResponse.statusCode else {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    completion(.failure(AIError.httpError(httpResponse.statusCode, errorMessage)))
                    return
                }
            }
            
            // Decode response
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let responseObject = try decoder.decode(R.self, from: data)
                completion(.success(responseObject))
            } catch {
                completion(.failure(AIError.decodingError(error)))
            }
        }.resume()
    }
    
    // MARK: - Headers
    private func openAIHeaders() -> [String: String] {
        return [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(config.apiKey)"
        ]
    }
    
    private func claudeHeaders() -> [String: String] {
        return [
            "Content-Type": "application/json",
            "x-api-key": config.apiKey,
            "anthropic-version": "2023-06-01"
        ]
    }
}

// MARK: - Error Types
public enum AIError: LocalizedError {
    case invalidURL
    case noDataReceived
    case noCompletionReceived
    case httpError(Int, String)
    case decodingError(Error)
    case customAPINotImplemented
    case configurationError(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .noDataReceived:
            return "No data received from API"
        case .noCompletionReceived:
            return "No completion text received"
        case .httpError(let code, let message):
            return "HTTP Error \(code): \(message)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .customAPINotImplemented:
            return "Custom API implementation not available"
        case .configurationError(let message):
            return "Configuration error: \(message)"
        }
    }
}

// MARK: - Configuration Factory
public extension AIHelper {
    static func createDefaultConfig() -> AIProviderConfig {
        let apiKey = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.apiKey) ?? Constants.defaultAPIKey
        let providerString = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.selectedProvider) ?? Constants.defaultProvider.rawValue
        let provider = AIProvider(rawValue: providerString) ?? .openai
        
        return AIProviderConfig(
            provider: provider,
            apiKey: apiKey,
            baseURL: provider.defaultBaseURL,
            model: provider.defaultModel,
            maxTokens: UserDefaults.standard.integer(forKey: Constants.UserDefaultsKeys.maxTokens) > 0 
                ? UserDefaults.standard.integer(forKey: Constants.UserDefaultsKeys.maxTokens) 
                : Constants.maxCompletionTokens,
            temperature: UserDefaults.standard.double(forKey: Constants.UserDefaultsKeys.temperature) > 0 
                ? UserDefaults.standard.double(forKey: Constants.UserDefaultsKeys.temperature) 
                : Constants.defaultTemperature
        )
    }
}
