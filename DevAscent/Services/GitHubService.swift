//
//  GitHubService.swift
//  DevAscent
//
//  Created by Rishiraj on 24/11/25.
//

import Foundation

/// Service for fetching GitHub user activity
class GitHubService {
    static let shared = GitHubService()
    
    private let apiToken = "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"
    
    private init() {}
    
    /// Fetch recent GitHub events for a user
    /// - Parameter username: GitHub username
    /// - Returns: Array of GitHub events
    func fetchRecentActivity(username: String) async throws -> [GitHubEvent] {
        // Construct URL
        guard let url = URL(string: "https://api.github.com/users/\(username)/events") else {
            throw GitHubError.invalidURL
        }
        
        // Create request with headers
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("token \(apiToken)", forHTTPHeaderField: "Authorization")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        
        // Fetch data
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check response status
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw GitHubError.httpError(statusCode: httpResponse.statusCode)
        }
        
        // Decode JSON
        let decoder = JSONDecoder()
        let events = try decoder.decode([GitHubEvent].self, from: data)
        
        return events
    }
    
    /// Find the most recent push event
    /// - Parameter events: Array of GitHub events
    /// - Returns: Date of the most recent push, or nil
    func findMostRecentPush(from events: [GitHubEvent]) -> Date? {
        return events
            .filter { $0.isPushEvent }
            .compactMap { $0.date }
            .max()
    }
}

// MARK: - Errors

enum GitHubError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid GitHub API URL"
        case .invalidResponse:
            return "Invalid response from GitHub"
        case .httpError(let code):
            return "GitHub API error: HTTP \(code)"
        }
    }
}
