    // SourceEditorExtension.swift
import Foundation
import XcodeKit
import AtharvaCore

class SourceEditorExtension: NSObject, XCSourceEditorExtension {
    func extensionDidFinishLaunching() {
        // Extension initialization
        print("Atharva AI Code Assistant extension launched")
        
        // Load user preferences
        loadUserPreferences()
    }

    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey : Any]] {
        return [
            [
                XCSourceEditorCommandDefinitionKey.classNameKey: "AICompletionCommand",
                XCSourceEditorCommandDefinitionKey.nameKey: "AI Code Completion",
                XCSourceEditorCommandDefinitionKey.identifierKey: "com.atharva.ai.completion"
            ],
            [
                XCSourceEditorCommandDefinitionKey.classNameKey: "AIRefactorCommand",
                XCSourceEditorCommandDefinitionKey.nameKey: "AI Refactor Code", 
                XCSourceEditorCommandDefinitionKey.identifierKey: "com.atharva.ai.refactor"
            ]
        ]
    }
    
    private func loadUserPreferences() {
        // Initialize default values if not set
        let defaults = UserDefaults.standard
        
        if defaults.string(forKey: Constants.UserDefaultsKeys.apiKey) == nil {
            defaults.set(Constants.defaultAPIKey, forKey: Constants.UserDefaultsKeys.apiKey)
        }
        
        if defaults.string(forKey: Constants.UserDefaultsKeys.selectedProvider) == nil {
            defaults.set(Constants.defaultProvider.rawValue, forKey: Constants.UserDefaultsKeys.selectedProvider)
        }
        
        if defaults.integer(forKey: Constants.UserDefaultsKeys.maxTokens) == 0 {
            defaults.set(Constants.maxCompletionTokens, forKey: Constants.UserDefaultsKeys.maxTokens)
        }
        
        if defaults.double(forKey: Constants.UserDefaultsKeys.temperature) == 0 {
            defaults.set(Constants.defaultTemperature, forKey: Constants.UserDefaultsKeys.temperature)
        }
    }
}
