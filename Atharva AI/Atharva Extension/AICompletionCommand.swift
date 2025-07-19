//
//  AICompletionCommand.swift
//  Atharva Extension
//
//  Created by ayan Chakraborty on 19/07/25.
//

import Foundation
import XcodeKit
import AtharvaCore

class AICompletionCommand: NSObject, XCSourceEditorCommand {
    func perform(with invocation: XCSourceEditorCommandInvocation,
                 completionHandler: @escaping (Error?) -> Void) {

            // Get current file context
        let buffer = invocation.buffer
        let lines = buffer.lines
        let selections = buffer.selections

            // Extract context around cursor
        guard let selection = selections.firstObject as? XCSourceTextRange else {
            completionHandler(NSError(domain: "AICodeAssistant", code: 1,
                                      userInfo: [NSLocalizedDescriptionKey: "No selection found"]))
            return
        }

        let context = extractContext(from: lines, around: selection)
        let language = detectLanguage(from: invocation.buffer.contentUTI)

            // Make async API call
        fetchAICompletion(context: context, language: language) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let completion):
                        self?.insertCompletion(completion, into: buffer, at: selection)
                        completionHandler(nil)
                    case .failure(let error):
                        completionHandler(error)
                }
            }
        }
    }
}


extension AICompletionCommand {
    private func extractContext(from lines: NSMutableArray,
                                around selection: XCSourceTextRange) -> String {
        let currentLine = selection.start.line
        let currentColumn = selection.start.column

            // Define context window (e.g., 50 lines before and after)
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

    private func detectLanguage(from uti: String) -> String {
        return Constants.supportedLanguages[uti] ?? "unknown"
    }
    
    private func fetchAICompletion(context: String, language: String, completion: @escaping (Result<String, Error>) -> Void) {
        let config = AIHelper.createDefaultConfig()
        let aiHelper = AIHelper(config: config)
        
        // Create completion context
        let completionContext = CompletionContext(
            language: language,
            filename: "current_file.\(getFileExtension(for: language))",
            contextBefore: context.components(separatedBy: "<|cursor|>").first ?? "",
            contextAfter: context.components(separatedBy: "<|cursor|>").last ?? "",
            cursorPosition: CursorPosition(line: 0, column: 0),
            entireFile: context
        )
        
        aiHelper.fetchCompletion(for: completionContext, completion: completion)
    }
    
    private func insertCompletion(_ completion: String, into buffer: XCSourceTextBuffer, at selection: XCSourceTextRange) {
        let lines = buffer.lines
        let insertionLine = selection.start.line
        let insertionColumn = selection.start.column
        
        // Get the current line
        guard insertionLine < lines.count,
              let currentLine = lines[insertionLine] as? String else {
            return
        }
        
        // Split the completion into lines
        let completionLines = completion.components(separatedBy: .newlines)
        
        if completionLines.count == 1 {
            // Single line completion - insert at cursor position
            let beforeCursor = String(currentLine.prefix(insertionColumn))
            let afterCursor = String(currentLine.dropFirst(insertionColumn))
            let newLine = beforeCursor + completion + afterCursor
            
            lines.replaceObject(at: insertionLine, with: newLine)
        } else {
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
        }
        
        // Update selection to end of inserted text
        let newSelection = XCSourceTextRange()
        if completionLines.count == 1 {
            newSelection.start = XCSourceTextPosition(line: insertionLine, column: insertionColumn + completion.count)
            newSelection.end = newSelection.start
        } else {
            newSelection.start = XCSourceTextPosition(line: insertionLine + completionLines.count - 1, column: completionLines.last!.count)
            newSelection.end = newSelection.start
        }
        
        buffer.selections.removeAllObjects()
        buffer.selections.add(newSelection)
    }
    
    private func getFileExtension(for language: String) -> String {
        switch language.lowercased() {
        case "swift":
            return "swift"
        case "objective-c":
            return "m"
        case "objective-c++":
            return "mm"
        case "cpp", "c++":
            return "cpp"
        case "c":
            return "c"
        case "javascript":
            return "js"
        case "python":
            return "py"
        default:
            return "txt"
        }
    }
}
