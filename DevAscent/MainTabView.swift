//
//  MainTabView.swift
//  DevAscent
//
//  DevAscent 3.0 - Elite Interview Prep Navigation
//  Created by Rishiraj on 13/12/24.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    @State private var hasSeeded = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Command - Dashboard
            NavigationStack {
                CommandView()
            }
            .tabItem {
                Label("Command", systemImage: "command")
            }
            .tag(0)
            
            // Kernel - CS Fundamentals
            NavigationStack {
                KernelView()
            }
            .tabItem {
                Label("Kernel", systemImage: "cpu")
            }
            .tag(1)
            
            // Blueprint - LLD Visualizer
            NavigationStack {
                BlueprintView()
            }
            .tabItem {
                Label("Blueprint", systemImage: "cube.transparent")
            }
            .tag(2)
            
            // Intel - Job Pipeline
            NavigationStack {
                IntelView()
            }
            .tabItem {
                Label("Intel", systemImage: "briefcase")
            }
            .tag(3)
            
            // Arsenal - Design Patterns & STAR Stories
            NavigationStack {
                ArsenalView()
            }
            .tabItem {
                Label("Arsenal", systemImage: "brain.head.profile")
            }
            .tag(4)
        }
        .tint(.primaryAccent)
        .onAppear {
            setupTabBarAppearance()
            seedDataIfNeeded()
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.cardBackground)
        
        // Normal state
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.textSecondary)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.textSecondary),
            .font: UIFont.monospacedSystemFont(ofSize: 10, weight: .medium)
        ]
        
        // Selected state
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.primaryAccent)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.primaryAccent),
            .font: UIFont.monospacedSystemFont(ofSize: 10, weight: .semibold)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    private func seedDataIfNeeded() {
        guard !hasSeeded else { return }
        hasSeeded = true
        DataSeeder.seedIfNeeded(context: modelContext)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [
            DailyTask.self,
            JobApplication.self,
            CSConcept.self,
            LLDProblem.self,
            ChatSession.self,
            Flashcard.self,
            DesignPattern.self,
            StarStory.self
        ], inMemory: true)
}
