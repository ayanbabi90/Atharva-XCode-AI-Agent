//
//  AIRefactorCommand.swift
//  Atharva Extension
//
//  Created by ayan Chakraborty on 19/07/25.
//

import Foundation
import XcodeKit
import AtharvaCore

class AIRefactorCommand: NSObject, XCSourceEditorCommand {
    func perform(with invocation: XCSourceEditorCommandInvocation,
                 completionHandler: @escaping (Error?) -> Void) {

        let buffer = invocation.buffer
        let lines = buffer.lines
        let selections = buffer.selections

            // Get selected text or entire file if no selection
        guard let selection = selections.firstObject as? XCSourceTextRange else {
            completionHandler(NSError(domain: "AICodeAssistant", code: 1,
                                      userInfo: [NSLocalizedDescriptionKey: "No selection found"]))
            return
        }

        let selectedText = extractSelectedText(from: lines, selection: selection)
        let language = detectLanguage(from: invocation.buffer.contentUTI)

            // Make async API call for refactoring
        fetchAIRefactoring(code: selectedText, language: language) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let refactoredCode):
                        self?.replaceSelection(refactoredCode, in: buffer, at: selection)
                        completionHandler(nil)
                    case .failure(let error):
                        completionHandler(error)
                }
            }
        }
    }
}

extension AIRefactorCommand {
    private func extractSelectedText(from lines: NSMutableArray, selection: XCSourceTextRange) -> String {
        let startLine = selection.start.line
        let endLine = selection.end.line
        let startColumn = selection.start.column
        let endColumn = selection.end.column

        var selectedLines: [String] = []

        if startLine == endLine {
                // Single line selection
            if let line = lines[startLine] as? String {
                let start = String.Index(utf16Offset: startColumn, in: line)
                let end = String.Index(utf16Offset: endColumn, in: line)
                selectedLines.append(String(line[start..<end]))
            }
        } else {
                // Multi-line selection
            for i in startLine...endLine {
                if let line = lines[i] as? String {
                    if i == startLine {
                        let start = String.Index(utf16Offset: startColumn, in: line)
                        selectedLines.append(String(line[start...]))
                    } else if i == endLine {
                        let end = String.Index(utf16Offset: endColumn, in: line)
                        selectedLines.append(String(line[..<end]))
                    } else {
                        selectedLines.append(line)
                    }
                }
            }
        }

        return selectedLines.joined(separator: "\n")
    }

    private func detectLanguage(from uti: String) -> String {
        return Constants.supportedLanguages[uti] ?? "unknown"
    }

    private func fetchAIRefactoring(code: String, language: String, completion: @escaping (Result<String, Error>) -> Void) {
        let config = AIHelper.createDefaultConfig()
        let aiHelper = AIHelper(config: config)

            // Create refactoring context
        let refactorPrompt = """
        Please refactor the following \(language) code to improve readability, performance, and maintainability:
        
        \(code)
        
        Return only the refactored code without explanations or markdown formatting.
        """

        let completionContext = CompletionContext(
            language: language,
            filename: "refactor.\(getFileExtension(for: language))",
            contextBefore: refactorPrompt,
            contextAfter: "",
            cursorPosition: CursorPosition(line: 0, column: 0),
            entireFile: code
        )

        aiHelper.fetchCompletion(for: completionContext, completion: completion)
    }

    private func replaceSelection(_ refactoredCode: String, in buffer: XCSourceTextBuffer, at selection: XCSourceTextRange) {
        let lines = buffer.lines
        let startLine = selection.start.line
        let endLine = selection.end.line
        let startColumn = selection.start.column
        let endColumn = selection.end.column

        let refactoredLines = refactoredCode.components(separatedBy: .newlines)

        if startLine == endLine {
                // Single line replacement
            if let currentLine = lines[startLine] as? String {
                let beforeSelection = String(currentLine.prefix(startColumn))
                let afterSelection = String(currentLine.dropFirst(endColumn))
                let newLine = beforeSelection + refactoredCode + afterSelection

                lines.replaceObject(at: startLine, with: newLine)
            }
        } else {
                // Multi-line replacement
                // Remove selected lines
            for _ in startLine...endLine {
                lines.removeObject(at: startLine)
            }

                // Insert refactored lines
            for (index, line) in refactoredLines.enumerated() {
                lines.insert(line, at: startLine + index)
            }
        }

            // Update selection to cover the new code
        let newSelection = XCSourceTextRange()
        newSelection.start = XCSourceTextPosition(line: startLine, column: startColumn)

        if refactoredLines.count == 1 {
            newSelection.end = XCSourceTextPosition(line: startLine, column: startColumn + refactoredCode.count)
        } else {
            newSelection.end = XCSourceTextPosition(line: startLine + refactoredLines.count - 1, column: refactoredLines.last?.count ?? 0)
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
