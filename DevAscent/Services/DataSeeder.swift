//
//  DataSeeder.swift
//  DevAscent
//
//  Seeds the database with GS Interview preparation data
//  Created by Rishiraj on 13/12/24.
//

import Foundation
import SwiftData

/// Seeds the database with Goldman Sachs interview preparation content
/// This is the main coordinator that imports content from modular files
struct DataSeeder {
    
    // Increment this when content changes to trigger re-seed
    private static let contentVersion = 10
    
    /// Check if data needs to be seeded (first launch or version change)
    static func needsSeeding(context: ModelContext) -> Bool {
        let lldCount = (try? context.fetchCount(FetchDescriptor<LLDProblem>())) ?? 0
        let csCount = (try? context.fetchCount(FetchDescriptor<CSConcept>())) ?? 0
        
        // Check if content version changed (stored in UserDefaults)
        let storedVersion = UserDefaults.standard.integer(forKey: "DataSeederVersion")
        if storedVersion < contentVersion {
            return true
        }
        
        return lldCount == 0 && csCount == 0
    }
    
    /// Seed all data
    static func seedIfNeeded(context: ModelContext) {
        guard needsSeeding(context: context) else { return }
        
        // Clear existing data first
        clearExistingData(context: context)
        
        // Seed fresh data from modular content files
        seedLLDProblems(context: context)
        seedCSConcepts(context: context)
        
        // Update version
        UserDefaults.standard.set(contentVersion, forKey: "DataSeederVersion")
    }
    
    /// Clear existing seeded data
    private static func clearExistingData(context: ModelContext) {
        try? context.delete(model: LLDProblem.self)
        try? context.delete(model: CSConcept.self)
    }
    
    // MARK: - LLD Problems (Goldman Sachs Question Bank)
    
    /// Seeds LLD problems from modular content files
    private static func seedLLDProblems(context: ModelContext) {
        let problems = LLDProblemsContent.all()
        for problem in problems {
            context.insert(problem)
        }
    }
    
    // MARK: - CS Concepts (Kernel)
    
    /// Seeds CS concepts from modular content files
    private static func seedCSConcepts(context: ModelContext) {
        let concepts = CSConceptsContent.all()
        for concept in concepts {
            context.insert(concept)
        }
    }
}
