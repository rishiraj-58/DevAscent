//
//  AppModels.swift
//  DevAscent
//
//  DevAscent 3.0 - Elite Interview Prep Data Models
//  Created by Rishiraj on 13/12/24.
//

import Foundation
import SwiftData

// MARK: - Enums

/// Task category for daily tasks
enum TaskCategory: String, Codable, CaseIterable {
    case deepWork = "Deep Work"
    case admin = "Admin"
    case intel = "Intel"
    
    var icon: String {
        switch self {
        case .deepWork: return "brain.head.profile"
        case .admin: return "tray.full.fill"
        case .intel: return "book.fill"
        }
    }
    
    var displayName: String {
        rawValue
    }
}

/// Job application status
enum ApplicationStatus: String, Codable, CaseIterable {
    case wishlist = "Wishlist"
    case applied = "Applied"
    case oa = "OA"
    case interview = "Interview"
    case offer = "Offer"
    case rejected = "Rejected"
    
    var sortPriority: Int {
        switch self {
        case .interview: return 0
        case .offer: return 1
        case .oa: return 2
        case .applied: return 3
        case .wishlist: return 4
        case .rejected: return 5
        }
    }
    
    var displayName: String {
        rawValue
    }
}

/// CS Concept category for Kernel view
enum CSCategory: String, Codable, CaseIterable {
    case os = "OS"
    case dbms = "DBMS"
    case cn = "CN"
    case oops = "OOPS"
    case sql = "SQL"
    case java = "Java"
    case springBoot = "Spring"
    
    var icon: String {
        switch self {
        case .os: return "cpu"
        case .dbms: return "cylinder"
        case .cn: return "network"
        case .oops: return "cube"
        case .sql: return "tablecells"
        case .java: return "cup.and.saucer.fill"
        case .springBoot: return "leaf.fill"
        }
    }
    
    var displayName: String { rawValue }
}

/// Design pattern type
enum PatternType: String, Codable, CaseIterable {
    case creational = "Creational"
    case structural = "Structural"
    case behavioral = "Behavioral"
    
    var displayName: String {
        rawValue
    }
}

/// Chat message role
enum ChatRole: String, Codable {
    case user = "user"
    case assistant = "model"
}

// MARK: - DailyTask Model

@Model
final class DailyTask {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var category: String
    var createdAt: Date
    
    init(title: String, category: TaskCategory = .deepWork) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.category = category.rawValue
        self.createdAt = Date()
    }
    
    var categoryEnum: TaskCategory {
        TaskCategory(rawValue: category) ?? .deepWork
    }
}

// MARK: - JobApplication Model

@Model
final class JobApplication {
    var id: UUID
    var company: String
    var role: String
    var status: String
    var appliedDate: Date
    var nextInterviewDate: Date?
    var notes: String
    var platform: String
    
    init(company: String, role: String, status: ApplicationStatus = .applied, platform: String = "LinkedIn", notes: String = "") {
        self.id = UUID()
        self.company = company
        self.role = role
        self.status = status.rawValue
        self.appliedDate = Date()
        self.nextInterviewDate = nil
        self.notes = notes
        self.platform = platform
    }
    
    var statusEnum: ApplicationStatus {
        ApplicationStatus(rawValue: status) ?? .applied
    }
}

// MARK: - CSConcept Model (Kernel - CS Fundamentals)

@Model
final class CSConcept {
    var id: UUID
    var category: String
    var question: String
    var answer: String
    var tags: [String]
    var isMastered: Bool
    
    init(category: CSCategory, question: String, answer: String, tags: [String] = []) {
        self.id = UUID()
        self.category = category.rawValue
        self.question = question
        self.answer = answer
        self.tags = tags
        self.isMastered = false
    }
    
    var categoryEnum: CSCategory {
        CSCategory(rawValue: category) ?? .java
    }
}

// MARK: - LLDProblem Model (Blueprint - LLD Visualizer)

@Model
final class LLDProblem {
    var id: UUID
    var title: String
    var requirements: String
    var solutionStrategy: String
    var mermaidGraph: String
    var codeSnippet: String
    var gsSpecificTwist: String
    
    init(
        title: String,
        requirements: String,
        solutionStrategy: String,
        mermaidGraph: String = "",
        codeSnippet: String = "",
        gsSpecificTwist: String = ""
    ) {
        self.id = UUID()
        self.title = title
        self.requirements = requirements
        self.solutionStrategy = solutionStrategy
        self.mermaidGraph = mermaidGraph
        self.codeSnippet = codeSnippet
        self.gsSpecificTwist = gsSpecificTwist
    }
}

// MARK: - ChatMessage (For Gemini)

struct ChatMessage: Codable, Identifiable {
    var id: UUID
    var role: ChatRole
    var content: String
    var timestamp: Date
    
    init(role: ChatRole, content: String) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = Date()
    }
}

// MARK: - ChatSession Model (Gemini Interaction)

@Model
final class ChatSession {
    var id: UUID
    var associatedProblemID: UUID?
    var historyData: Data  // Stored as JSON
    var createdAt: Date
    
    init(associatedProblemID: UUID? = nil) {
        self.id = UUID()
        self.associatedProblemID = associatedProblemID
        self.historyData = Data()
        self.createdAt = Date()
    }
    
    var history: [ChatMessage] {
        get {
            (try? JSONDecoder().decode([ChatMessage].self, from: historyData)) ?? []
        }
        set {
            historyData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
    
    func addMessage(_ message: ChatMessage) {
        var messages = history
        messages.append(message)
        history = messages
    }
}

// MARK: - DesignPattern Model (Legacy - kept for compatibility)

@Model
final class DesignPattern {
    var id: UUID
    var name: String
    var type: String
    var summary: String
    var whenToUse: String
    var javaCode: String
    var isFavorite: Bool
    
    init(name: String, type: PatternType, summary: String, whenToUse: String, javaCode: String = "") {
        self.id = UUID()
        self.name = name
        self.type = type.rawValue
        self.summary = summary
        self.whenToUse = whenToUse
        self.javaCode = javaCode
        self.isFavorite = false
    }
    
    var typeEnum: PatternType {
        PatternType(rawValue: type) ?? .behavioral
    }
}

// MARK: - StarStory Model (Behavioral STAR Stories)

@Model
final class StarStory {
    var id: UUID
    var title: String
    var situation: String
    var task: String
    var action: String
    var result: String
    var tags: [String]
    
    init(title: String, situation: String = "", task: String = "", action: String = "", result: String = "", tags: [String] = []) {
        self.id = UUID()
        self.title = title
        self.situation = situation
        self.task = task
        self.action = action
        self.result = result
        self.tags = tags
    }
}

// MARK: - Flashcard Model (Legacy)

@Model
final class Flashcard {
    var id: UUID
    var question: String
    var answer: String
    var topic: String
    var masteryLevel: Int
    var nextReviewDate: Date
    
    init(question: String, answer: String, topic: FlashcardTopic = .java) {
        self.id = UUID()
        self.question = question
        self.answer = answer
        self.topic = topic.rawValue
        self.masteryLevel = 0
        self.nextReviewDate = Date()
    }
    
    var topicEnum: FlashcardTopic {
        FlashcardTopic(rawValue: topic) ?? .java
    }
    
    var isDue: Bool { nextReviewDate <= Date() }
    
    func markReset() {
        masteryLevel = max(masteryLevel - 1, 0)
        nextReviewDate = Calendar.current.date(byAdding: .minute, value: 10, to: Date()) ?? Date()
    }
    
    func markHard() {
        nextReviewDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    }
    
    func markEasy() {
        masteryLevel = min(masteryLevel + 1, 5)
        nextReviewDate = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
    }
}

enum FlashcardTopic: String, Codable, CaseIterable {
    case java = "Java"
    case lld = "LLD"
    case systemDesign = "System Design"
    
    var icon: String {
        switch self {
        case .java: return "cup.and.saucer.fill"
        case .lld: return "puzzlepiece.fill"
        case .systemDesign: return "server.rack"
        }
    }
    
    var displayName: String { rawValue }
}
