//
//  GeminiService.swift
//  DevAscent
//
//  Gemini 1.5 Pro Integration for AI Interviewer
//  Created by Rishiraj on 13/12/24.
//

import Foundation
import Combine

/// Error types for Gemini API
enum GeminiError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(String)
    case decodingError
    case noContent
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid API URL"
        case .invalidResponse: return "Invalid response from server"
        case .apiError(let message): return message
        case .decodingError: return "Failed to decode response"
        case .noContent: return "No content in response"
        }
    }
}

/// Gemini API response structures
struct GeminiResponse: Codable {
    let candidates: [Candidate]?
    let error: GeminiAPIError?
    
    struct Candidate: Codable {
        let content: Content?
    }
    
    struct Content: Codable {
        let parts: [Part]?
        let role: String?
    }
    
    struct Part: Codable {
        let text: String?
    }
    
    struct GeminiAPIError: Codable {
        let message: String?
        let status: String?
    }
}

/// Gemini request structure
struct GeminiRequest: Codable {
    let contents: [Content]
    let generationConfig: GenerationConfig?
    let systemInstruction: SystemInstruction?
    
    struct Content: Codable {
        let role: String
        let parts: [Part]
    }
    
    struct Part: Codable {
        let text: String
    }
    
    struct GenerationConfig: Codable {
        let temperature: Double
        let maxOutputTokens: Int
        let topP: Double
    }
    
    struct SystemInstruction: Codable {
        let parts: [Part]
    }
}

/// Service for interacting with Gemini 1.5 Pro API
class GeminiService: ObservableObject {
    static let shared = GeminiService()
    
    // ⚠️ API key is now loaded from Secrets.swift (not committed to git)
    private let apiKey = Secrets.geminiAPIKey
    private let baseURL = Secrets.geminiBaseURL
    
    @Published var isLoading = false
    
    private init() {}
    
    /// Generate the system prompt for LLD interview simulation
    func getInterviewerPrompt(for problem: LLDProblem) -> String {
        return """
        You are a Principal Engineer at Goldman Sachs conducting a Low-Level Design interview. 
        
        The candidate is designing: \(problem.title)
        
        Requirements they should address:
        \(problem.requirements)
        
        Expected patterns and approach:
        \(problem.solutionStrategy)
        
        GS Specific Twist: \(problem.gsSpecificTwist)
        
        Your role:
        1. Act as a critical but fair interviewer
        2. Ask probing questions about their design choices
        3. Focus on concurrency, scalability, and edge cases
        4. Be brief and ruthless - max 2-3 sentences per response
        5. If they make a good point, acknowledge it briefly then challenge further
        6. Push them on: thread safety, failure modes, and system bottlenecks
        
        Start by asking about their high-level approach, then drill into specifics.
        """
    }
    
    /// Send a message and get a response from Gemini
    func sendMessage(
        userMessage: String,
        conversationHistory: [ChatMessage],
        systemPrompt: String
    ) async throws -> String {
        // Build the URL
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            throw GeminiError.invalidURL
        }
        
        // Build conversation contents
        var contents: [GeminiRequest.Content] = []
        
        // Add conversation history
        for message in conversationHistory {
            contents.append(GeminiRequest.Content(
                role: message.role == .user ? "user" : "model",
                parts: [GeminiRequest.Part(text: message.content)]
            ))
        }
        
        // Add current user message
        contents.append(GeminiRequest.Content(
            role: "user",
            parts: [GeminiRequest.Part(text: userMessage)]
        ))
        
        // Build request
        let request = GeminiRequest(
            contents: contents,
            generationConfig: GeminiRequest.GenerationConfig(
                temperature: 0.7,
                maxOutputTokens: 500,
                topP: 0.9
            ),
            systemInstruction: GeminiRequest.SystemInstruction(
                parts: [GeminiRequest.Part(text: systemPrompt)]
            )
        )
        
        // Create URL request
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        // Make the request
        await MainActor.run { isLoading = true }
        defer { Task { @MainActor in isLoading = false } }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        // Check HTTP status
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.invalidResponse
        }
        
        // Decode response
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        
        // Check for API error
        if let error = geminiResponse.error {
            throw GeminiError.apiError(error.message ?? "Unknown API error")
        }
        
        // Extract text from response
        guard let text = geminiResponse.candidates?.first?.content?.parts?.first?.text else {
            if httpResponse.statusCode != 200 {
                throw GeminiError.apiError("HTTP \(httpResponse.statusCode)")
            }
            throw GeminiError.noContent
        }
        
        return text
    }
    
    /// Simple generation without conversation history
    func generate(prompt: String, systemPrompt: String = "") async throws -> String {
        return try await sendMessage(
            userMessage: prompt,
            conversationHistory: [],
            systemPrompt: systemPrompt
        )
    }
}
