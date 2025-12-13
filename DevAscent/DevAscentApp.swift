//
//  DevAscentApp.swift
//  DevAscent
//
//  DevAscent 3.0 - Elite Interview Prep
//  Created by Rishiraj on 13/12/24.
//

import SwiftUI
import SwiftData

@main
struct DevAscentApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .task {
                    // Seed data on first launch
                    // This is handled in MainTabView now
                }
        }
        .modelContainer(for: [
            // Core models
            DailyTask.self,
            JobApplication.self,
            
            // CS Fundamentals
            CSConcept.self,
            
            // LLD Problems
            LLDProblem.self,
            
            // Gemini Chat
            ChatSession.self,
            
            // Legacy models (kept for compatibility)
            Flashcard.self,
            DesignPattern.self,
            StarStory.self
        ])
    }
}
