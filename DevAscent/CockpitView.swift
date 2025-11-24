//
//  CockpitView.swift
//  DevAscent
//
//  Created by Rishiraj on 24/11/25.
//

import SwiftUI
import SwiftData

struct CockpitView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PlanTask.createdAt) private var allTasks: [PlanTask]
    
    // GitHub state
    @State private var lastGitHubCommit: Date?
    @State private var gitHubStatus: String = "Offline"
    @State private var isLoadingGitHub = false
    
    // MARK: - Computed Stats
    
    /// Count of tasks completed today
    private var tasksCompletedToday: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return allTasks.filter { task in
            task.isCompleted && calendar.isDate(task.createdAt, inSameDayAs: today)
        }.count
    }
    
    /// Current streak of consecutive days with at least 1 completed task
    private var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        
        // Keep going backwards until we find a day with no completed tasks
        while true {
            let hasCompletedTask = allTasks.contains { task in
                task.isCompleted && calendar.isDate(task.createdAt, inSameDayAs: checkDate)
            }
            
            if hasCompletedTask {
                streak += 1
                // Move to previous day
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                    break
                }
                checkDate = previousDay
            } else {
                break
            }
        }
        
        return streak
    }
    
    /// Focus score based on today's completed tasks (capped at 100)
    private var focusScore: Int {
        min(tasksCompletedToday * 10, 100)
    }
    
    /// Greeting based on time of day
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good Morning, Dev."
        case 12..<17:
            return "Good Afternoon, Dev."
        default:
            return "Good Evening, Dev."
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    headerSection
                    
                    // HUD - Stat Cards
                    hudSection
                    
                    // Activity Log - Heatmap
                    activityLogSection
                    
                    // GitHub Sync Button
                    githubSyncButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
        .task {
            await fetchGitHubActivity()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SYSTEM STATUS: ONLINE")
                .font(.system(size: 12, design: .monospaced))
                .fontWeight(.medium)
                .foregroundColor(.primaryAccent)
                .tracking(1.2)
            
            Text(greetingText)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.neonText)
        }
    }
    
    // MARK: - HUD Section
    
    private var hudSection: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Streak",
                value: "\(currentStreak)",
                icon: "flame.fill"
            )
            
            StatCard(
                title: "Focus Score",
                value: "\(focusScore)",
                icon: "bolt.fill"
            )
        }
    }
    
    // MARK: - Activity Log Section
    
    private var activityLogSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ACTIVITY LOG")
                .font(.system(size: 12, design: .monospaced))
                .fontWeight(.medium)
                .foregroundColor(.textSecondary)
                .tracking(1.2)
            
            ContributionGrid(tasks: allTasks)
        }
    }
    
    // MARK: - GitHub Sync Button
    
    private var githubSyncButton: some View {
        Button(action: {
            Task {
                await fetchGitHubActivity()
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: isLoadingGitHub ? "arrow.triangle.2.circlepath" : "network")
                    .font(.system(size: 18))
                    .rotationEffect(.degrees(isLoadingGitHub ? 360 : 0))
                    .animation(isLoadingGitHub ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isLoadingGitHub)
                
                Text(gitHubButtonText)
                    .font(.system(size: 16, design: .monospaced))
                    .fontWeight(.medium)
            }
            .foregroundColor(gitHubButtonForeground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(gitHubButtonBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(gitHubButtonForeground.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    // MARK: - GitHub Helpers
    
    private var gitHubButtonText: String {
        if isLoadingGitHub {
            return "> Syncing..."
        }
        
        if let lastCommit = lastGitHubCommit {
            let calendar = Calendar.current
            if calendar.isDateInToday(lastCommit) {
                return "GitHub: Active Today"
            } else {
                let formatter = RelativeDateTimeFormatter()
                formatter.unitsStyle = .abbreviated
                let timeAgo = formatter.localizedString(for: lastCommit, relativeTo: Date())
                return "GitHub: Last push \(timeAgo)"
            }
        }
        
        return "GitHub: No Commits Yet"
    }
    
    private var gitHubButtonBackground: Color {
        guard let lastCommit = lastGitHubCommit else {
            return .cardBackground
        }
        
        return Calendar.current.isDateInToday(lastCommit) ? .primaryAccent : .cardBackground
    }
    
    private var gitHubButtonForeground: Color {
        guard let lastCommit = lastGitHubCommit else {
            return .textSecondary
        }
        
        return Calendar.current.isDateInToday(lastCommit) ? .background : .neonText
    }
    
    private func fetchGitHubActivity() async {
        print("🔵 [GitHub] Starting fetch for username: rishiraj-58")
        isLoadingGitHub = true
        defer { isLoadingGitHub = false }
        
        do {
            print("🔵 [GitHub] Calling API...")
            let events = try await GitHubService.shared.fetchRecentActivity(username: "rishiraj-58")
            print("🟢 [GitHub] Success! Received \(events.count) events")
            
            if let mostRecentPush = GitHubService.shared.findMostRecentPush(from: events) {
                lastGitHubCommit = mostRecentPush
                print("🟢 [GitHub] Found most recent push: \(mostRecentPush)")
                
                let calendar = Calendar.current
                if calendar.isDateInToday(mostRecentPush) {
                    gitHubStatus = "Active"
                    print("🟢 [GitHub] Push was TODAY!")
                } else {
                    gitHubStatus = "Inactive"
                    print("🟡 [GitHub] Push was NOT today")
                }
            } else {
                gitHubStatus = "No Activity"
                print("🟡 [GitHub] No push events found")
            }
        } catch {
            print("🔴 [GitHub] API Error: \(error.localizedDescription)")
            print("🔴 [GitHub] Full error: \(error)")
            gitHubStatus = "Offline"
            lastGitHubCommit = nil
        }
    }
}

// MARK: - Stat Card Component

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.primaryAccent)
                
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.neonText)
            
            Text(title.uppercased())
                .font(.system(size: 11, design: .monospaced))
                .fontWeight(.medium)
                .foregroundColor(.textSecondary)
                .tracking(1.0)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.neonText.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Contribution Grid (Heatmap)

struct ContributionGrid: View {
    let tasks: [PlanTask]
    
    // Grid columns (7 days per week)
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    
    /// Get last 28 days including today
    private var last28Days: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let days = (0..<28).map { daysAgo in
            calendar.date(byAdding: .day, value: -daysAgo, to: today)!
        }.reversed()
        
        print("🔵 [Heatmap] Generated \(days.count) days")
        return Array(days)
    }
    
    /// Count completed tasks for a specific date
    private func completedTaskCount(for date: Date) -> Int {
        let calendar = Calendar.current
        return tasks.filter { task in
            task.isCompleted && calendar.isDate(task.createdAt, inSameDayAs: date)
        }.count
    }
    
    /// Get color for task count
    private func color(for count: Int) -> Color {
        switch count {
        case 0:
            return Color.background.opacity(0.5) // Darker than container
        case 1...2:
            return Color.primaryAccent.opacity(0.4)
        default:
            return Color.primaryAccent
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Manual grid layout (4 rows × 7 columns)
            VStack(spacing: 4) {
                ForEach(0..<4, id: \.self) { row in
                    HStack(spacing: 4) {
                        ForEach(0..<7, id: \.self) { col in
                            let index = row * 7 + col
                            if index < last28Days.count {
                                let date = last28Days[index]
                                let count = completedTaskCount(for: date)
                                
                                Rectangle()
                                    .fill(color(for: count))
                                    .frame(height: 40)
                                    .cornerRadius(4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.textSecondary.opacity(0.2), lineWidth: 1)
                                    )
                                    .overlay(
                                        VStack {
                                            if count > 0 {
                                                Text("\(count)")
                                                    .font(.system(size: 10, weight: .semibold))
                                                    .foregroundColor(.background)
                                            }
                                        }
                                    )
                                    .onAppear {
                                        if row == 0 && col == 0 {
                                            print("🔵 [Heatmap] Rendering grid with \(last28Days.count) squares")
                                        }
                                    }
                            } else {
                                Color.clear
                                    .frame(height: 40)
                            }
                        }
                    }
                }
            }
            
            // Legend
            HStack(spacing: 16) {
                Spacer()
                
                legendItem(color: .cardBackground, label: "None")
                legendItem(color: .primaryAccent.opacity(0.4), label: "1-2")
                legendItem(color: .primaryAccent, label: "3+")
            }
            .padding(.top, 8)
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
    
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Rectangle()
                .fill(color)
                .frame(width: 12, height: 12)
                .cornerRadius(2)
            
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.textSecondary)
        }
    }
}

#Preview {
    CockpitView()
        .modelContainer(for: PlanTask.self, inMemory: true)
}
