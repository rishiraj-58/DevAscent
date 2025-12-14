//
//  CSConceptsContent.swift
//  DevAscent
//
//  Aggregates all CS concepts from category files
//

import Foundation

/// Provides all CS concepts for seeding
/// Each category provides its concepts via a static all() method
struct CSConceptsContent {
    
    /// Returns all CS concepts from all category files
    static func all() -> [CSConcept] {
        var concepts: [CSConcept] = []
        
        // Aggregate from all category files
        concepts.append(contentsOf: OSConcepts.all())
        concepts.append(contentsOf: JavaConcepts.all())
        concepts.append(contentsOf: DBMSConcepts.all())
        concepts.append(contentsOf: NetworkingConcepts.all())
        concepts.append(contentsOf: SpringBootConcepts.all())
        concepts.append(contentsOf: SQLConcepts.all())
        concepts.append(contentsOf: OOPSConcepts.all())
        
        return concepts
    }
}
