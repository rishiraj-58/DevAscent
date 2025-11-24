//
//  MainTabView.swift
//  DevAscent
//
//  Created by Rishiraj on 24/11/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CockpitView()
                .tabItem {
                    Label("Cockpit", systemImage: "command.square.fill")
                }
                .tag(0)
            
            ArenaView()
                .tabItem {
                    Label("Arena", systemImage: "terminal.fill")
                }
                .tag(1)
            
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical.fill")
                }
                .tag(2)
            
            InterviewView()
                .tabItem {
                    Label("Interview", systemImage: "person.crop.rectangle.stack.fill")
                }
                .tag(3)
            
            PlannerView()
                .tabItem {
                    Label("Planner", systemImage: "list.bullet.clipboard.fill")
                }
                .tag(4)
        }
        .onAppear {
            setupTabBarAppearance()
        }
    }
    
    /// Configures the Tab Bar with custom colors matching the Zen Coder theme
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        
        // Background styling
        appearance.backgroundColor = UIColor(Color.cardBackground)
        appearance.shadowColor = .clear
        
        // Unselected tab items (muted gray)
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.textSecondary)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.textSecondary)
        ]
        
        // Selected tab items (neon blue)
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.neonText)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.neonText)
        ]
        
        // Apply to both standard and scroll edge appearances
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    MainTabView()
}
