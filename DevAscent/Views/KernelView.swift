//
//  KernelView.swift
//  DevAscent
//
//  CS Fundamentals - Accordion Q&A with Category Pills
//  Created by Rishiraj on 13/12/24.
//

import SwiftUI
import SwiftData

struct KernelView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CSConcept.question) private var allConcepts: [CSConcept]
    
    @State private var selectedCategory: CSCategory? = nil
    @State private var expandedConceptID: UUID? = nil
    
    // Filter concepts by category
    private var filteredConcepts: [CSConcept] {
        let concepts = selectedCategory == nil 
            ? allConcepts 
            : allConcepts.filter { $0.categoryEnum == selectedCategory }
        
        // Unmastered first, then mastered at bottom
        return concepts.sorted { !$0.isMastered && $1.isMastered }
    }
    
    private var masteredCount: Int {
        filteredConcepts.filter { $0.isMastered }.count
    }
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Category Pills
                categoryPills
                
                // Content
                if allConcepts.isEmpty {
                    emptyState
                } else {
                    conceptList
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("[ KERNEL ]")
                    .font(.operatorLabel(12))
                    .foregroundColor(.primaryAccent)
                    .tracking(1.2)
                
                Text("CS Fundamentals")
                    .font(.operatorHeader(28))
                    .foregroundColor(.neonText)
            }
            
            Spacer()
            
            // Progress indicator
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(masteredCount)/\(filteredConcepts.count)")
                    .font(.operatorHeader(24))
                    .foregroundColor(.primaryAccent)
                
                Text("MASTERED")
                    .font(.operatorLabel(10))
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
    
    // MARK: - Category Pills
    
    private var categoryPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // All pill
                CategoryPill(
                    title: "ALL",
                    icon: "square.grid.2x2",
                    isSelected: selectedCategory == nil,
                    count: allConcepts.count
                ) {
                    selectedCategory = nil
                }
                
                ForEach(CSCategory.allCases, id: \.self) { category in
                    let count = allConcepts.filter { $0.categoryEnum == category }.count
                    
                    CategoryPill(
                        title: category.displayName,
                        icon: category.icon,
                        isSelected: selectedCategory == category,
                        count: count
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 16)
    }
    
    // MARK: - Concept List
    
    private var conceptList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredConcepts) { concept in
                    ConceptAccordion(
                        concept: concept,
                        isExpanded: expandedConceptID == concept.id,
                        onToggle: {
                            withAnimation(.spring(response: 0.3)) {
                                expandedConceptID = expandedConceptID == concept.id ? nil : concept.id
                            }
                        },
                        onMarkMastered: {
                            withAnimation {
                                concept.isMastered.toggle()
                                if concept.isMastered {
                                    expandedConceptID = nil
                                }
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "brain")
                .font(.system(size: 60))
                .foregroundColor(.textSecondary)
            
            Text("No Concepts Loaded")
                .font(.operatorHeader(20))
                .foregroundColor(.neonText)
            
            Text("Data will be seeded on first launch.\nRestart the app if needed.")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
    }
}

// MARK: - Category Pill

struct CategoryPill: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                
                Text(title)
                    .font(.operatorLabel(11))
                    .tracking(0.5)
                
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(isSelected ? .background : .textSecondary)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(isSelected ? Color.background.opacity(0.3) : Color.border)
                        .cornerRadius(4)
                }
            }
            .foregroundColor(isSelected ? .background : .textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? Color.primaryAccent : Color.cardBackground)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.primaryAccent : Color.border, lineWidth: 1)
            )
        }
    }
}

// MARK: - Concept Accordion

struct ConceptAccordion: View {
    @Bindable var concept: CSConcept
    let isExpanded: Bool
    let onToggle: () -> Void
    let onMarkMastered: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header (always visible)
            Button(action: onToggle) {
                HStack(spacing: 12) {
                    // Category icon
                    Image(systemName: concept.categoryEnum.icon)
                        .font(.system(size: 16))
                        .foregroundColor(concept.isMastered ? .primaryAccent : .neonText)
                        .frame(width: 24)
                    
                    // Question
                    Text(concept.question)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(concept.isMastered ? .textSecondary : .white)
                        .multilineTextAlignment(.leading)
                        .strikethrough(concept.isMastered)
                    
                    Spacer()
                    
                    // Expand indicator
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(.textSecondary)
                }
                .padding(16)
            }
            
            // Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    Divider()
                        .background(Color.border)
                    
                    // Answer
                    Text(concept.answer)
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.textSecondary)
                        .lineSpacing(4)
                    
                    // Tags
                    if !concept.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(concept.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.operatorLabel(10))
                                        .foregroundColor(.neonText)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.neonText.opacity(0.15))
                                        .cornerRadius(4)
                                }
                            }
                        }
                    }
                    
                    // Mark Mastered button
                    Button(action: onMarkMastered) {
                        HStack(spacing: 8) {
                            Image(systemName: concept.isMastered ? "arrow.uturn.backward" : "checkmark.circle")
                            Text(concept.isMastered ? "UNMARK" : "MARK MASTERED")
                                .font(.operatorLabel(11))
                        }
                        .foregroundColor(concept.isMastered ? .textSecondary : .primaryAccent)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(concept.isMastered ? Color.cardBackground : Color.primaryAccent.opacity(0.15))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(concept.isMastered ? Color.border : Color.primaryAccent.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .background(Color.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(concept.isMastered ? Color.primaryAccent.opacity(0.3) : Color.border, lineWidth: 1)
        )
        .opacity(concept.isMastered ? 0.7 : 1.0)
    }
}

#Preview {
    KernelView()
        .modelContainer(for: [CSConcept.self], inMemory: true)
}
