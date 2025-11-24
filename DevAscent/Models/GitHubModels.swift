//
//  GitHubModels.swift
//  DevAscent
//
//  Created by Rishiraj on 24/11/25.
//

import Foundation

/// GitHub event data model
struct GitHubEvent: Codable, Identifiable {
    let id: String
    let type: String
    let createdAt: String
    let repo: Repository
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case createdAt = "created_at"
        case repo
    }
    
    /// Nested repository struct
    struct Repository: Codable {
        let name: String
    }
    
    /// Parse the ISO8601 date string to Date
    var date: Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: createdAt)
    }
    
    /// Check if this event is a Push event  
    var isPushEvent: Bool {
        type == "PushEvent"
    }
}
