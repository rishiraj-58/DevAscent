//
//  CommandView.swift
//  DevAscent
//
//  The Cockpit - Morning Briefing & Situational Awareness
//  Created by Rishiraj on 13/12/24.
//

import SwiftUI
import SwiftData

struct CommandView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyTask.createdAt) private var allTasks: [DailyTask]
    @Query(sort: \JobApplication.appliedDate) private var allApplications: [JobApplication]
    
    // GitHub state
    @State private var lastGitHubCommit: Date?
    @State private var gitHubStatus: String = "Offline"
    @State private var isLoadingGitHub = false
    @State private var showGitHubSheet = false
    @State private var recentEvents: [GitHubEvent] = []
    
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
        
        while true {
            let hasCompletedTask = allTasks.contains { task in
                task.isCompleted && calendar.isDate(task.createdAt, inSameDayAs: checkDate)
            }
            
            if hasCompletedTask {
                streak += 1
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
    
    /// Count of active job applications (not rejected/offer)
    private var activeMissions: Int {
        allApplications.filter { app in
            let status = app.statusEnum
            return status != .rejected && status != .offer
        }.count
    }
    
    /// Next upcoming interview
    private var nextInterview: JobApplication? {
        allApplications
            .filter { $0.nextInterviewDate != nil && $0.nextInterviewDate! > Date() }
            .sorted { ($0.nextInterviewDate ?? .distantFuture) < ($1.nextInterviewDate ?? .distantFuture) }
            .first
    }
    
    /// Greeting based on time of day
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<5:
            return "Systems Online. Night Shift, Operator."
        case 5..<12:
            return "Systems Online. Good Morning, Operator."
        case 12..<17:
            return "Systems Online. Good Afternoon, Operator."
        default:
            return "Systems Online. Good Evening, Operator."
        }
    }
    
    /// GitHub commit status
    private var committedToday: Bool {
        guard let lastCommit = lastGitHubCommit else { return false }
        return Calendar.current.isDateInToday(lastCommit)
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
                    
                    // GitHub Module
                    githubModule
                    
                    // Next Critical Event
                    if let interview = nextInterview {
                        nextEventWidget(interview)
                    }
                    
                    // Activity Log - Heatmap
                    activityLogSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
        .task {
            await fetchGitHubActivity()
        }
        .sheet(isPresented: $showGitHubSheet) {
            GitHubLogView(events: recentEvents)
                .presentationDetents([.medium, .large])
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("[ COMMAND CENTER ]")
                .font(.operatorLabel(12))
                .foregroundColor(.primaryAccent)
                .tracking(1.2)
            
            Text(greetingText)
                .font(.operatorHeader(24))
                .foregroundColor(.neonText)
        }
    }
    
    // MARK: - HUD Section (3 metrics)
    
    private var hudSection: some View {
        HStack(spacing: 12) {
            HUDStatCard(
                title: "STREAK",
                value: "\(currentStreak)",
                icon: "flame.fill",
                accentColor: .primaryAccent
            )
            
            HUDStatCard(
                title: "FOCUS",
                value: "\(focusScore)",
                icon: "bolt.fill",
                accentColor: .neonText
            )
            
            HUDStatCard(
                title: "MISSIONS",
                value: "\(activeMissions)",
                icon: "target",
                accentColor: .statusInterview
            )
        }
    }
    
    // MARK: - GitHub Module
    
    private var githubModule: some View {
        Button(action: {
            if !recentEvents.isEmpty {
                showGitHubSheet = true
            } else {
                Task { await fetchGitHubActivity() }
            }
        }) {
            HStack(spacing: 16) {
                // Status indicator
                Circle()
                    .fill(committedToday ? Color.primaryAccent : Color.alertRed)
                    .frame(width: 12, height: 12)
                    .shadow(color: (committedToday ? Color.primaryAccent : Color.alertRed).opacity(0.5), radius: 4)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("GITHUB STATUS")
                        .font(.operatorLabel(11))
                        .foregroundColor(.textSecondary)
                        .tracking(1.0)
                    
                    Text(committedToday ? "Committed Today ✓" : "Missing in Action")
                        .font(.operatorHeader(16))
                        .foregroundColor(committedToday ? .primaryAccent : .alertRed)
                }
                
                Spacer()
                
                if isLoadingGitHub {
                    ProgressView()
                        .tint(.neonText)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(16)
            .operatorCard()
        }
    }
    
    // MARK: - Next Critical Event Widget
    
    private func nextEventWidget(_ application: JobApplication) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("NEXT CRITICAL EVENT")
                .font(.operatorLabel(11))
                .foregroundColor(.textSecondary)
                .tracking(1.0)
            
            HStack(spacing: 16) {
                // Countdown
                VStack(alignment: .leading, spacing: 4) {
                    if let interviewDate = application.nextInterviewDate {
                        let countdown = countdownString(to: interviewDate)
                        Text(countdown)
                            .font(.operatorHeader(20))
                            .foregroundColor(.statusInterview)
                    }
                    
                    Text("\(application.company) - \(application.role)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Pulsing indicator
                Circle()
                    .fill(Color.statusInterview)
                    .frame(width: 16, height: 16)
                    .modifier(PulsingAnimation())
            }
            .padding(16)
            .operatorCard()
            .glowBorder(color: .statusInterview)
        }
    }
    
    private func countdownString(to date: Date) -> String {
        let now = Date()
        let interval = date.timeIntervalSince(now)
        
        if interval <= 0 {
            return "NOW"
        }
        
        let hours = Int(interval / 3600)
        if hours >= 24 {
            let days = hours / 24
            return "T-\(days) Day\(days == 1 ? "" : "s")"
        } else {
            return "T-\(hours) Hour\(hours == 1 ? "" : "s")"
        }
    }
    
    // MARK: - Activity Log Section
    
    private var activityLogSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ACTIVITY LOG")
                .font(.operatorLabel(12))
                .foregroundColor(.textSecondary)
                .tracking(1.2)
            
            ContributionGrid(tasks: allTasks)
        }
    }
    
    // MARK: - GitHub Fetch
    
    private func fetchGitHubActivity() async {
        isLoadingGitHub = true
        defer { isLoadingGitHub = false }
        
        do {
            let events = try await GitHubService.shared.fetchRecentActivity(username: "rishiraj-58")
            recentEvents = events
            
            if let mostRecentPush = GitHubService.shared.findMostRecentPush(from: events) {
                lastGitHubCommit = mostRecentPush
                gitHubStatus = Calendar.current.isDateInToday(mostRecentPush) ? "Active" : "Inactive"
            } else {
                gitHubStatus = "No Activity"
            }
        } catch {
            gitHubStatus = "Offline"
            lastGitHubCommit = nil
        }
    }
}

// MARK: - HUD Stat Card Component

struct HUDStatCard: View {
    let title: String
    let value: String
    let icon: String
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(accentColor)
            
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            
            Text(title)
                .font(.operatorLabel(10))
                .foregroundColor(.textSecondary)
                .tracking(1.0)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .operatorCard()
    }
}

// MARK: - Contribution Grid (Heatmap)

struct ContributionGrid: View {
    let tasks: [DailyTask]
    
    private var last28Days: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let days = (0..<28).map { daysAgo in
            calendar.date(byAdding: .day, value: -daysAgo, to: today)!
        }.reversed()
        
        return Array(days)
    }
    
    private func completedTaskCount(for date: Date) -> Int {
        let calendar = Calendar.current
        return tasks.filter { task in
            task.isCompleted && calendar.isDate(task.createdAt, inSameDayAs: date)
        }.count
    }
    
    private func color(for count: Int) -> Color {
        switch count {
        case 0:
            return Color.background.opacity(0.5)
        case 1...2:
            return Color.primaryAccent.opacity(0.4)
        default:
            return Color.primaryAccent
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
                                    .frame(height: 36)
                                    .cornerRadius(4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.border, lineWidth: 1)
                                    )
                                    .overlay(
                                        count > 0 ?
                                        Text("\(count)")
                                            .font(.system(size: 10, weight: .semibold))
                                            .foregroundColor(.background)
                                        : nil
                                    )
                            } else {
                                Color.clear.frame(height: 36)
                            }
                        }
                    }
                }
            }
            
            // Legend
            HStack(spacing: 16) {
                Spacer()
                legendItem(color: .cardBackground, label: "0")
                legendItem(color: .primaryAccent.opacity(0.4), label: "1-2")
                legendItem(color: .primaryAccent, label: "3+")
            }
            .padding(.top, 8)
        }
        .padding(16)
        .operatorCard()
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

// MARK: - Pulsing Animation Modifier

struct PulsingAnimation: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.2 : 1.0)
            .opacity(isPulsing ? 0.7 : 1.0)
            .animation(
                .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
    }
}

#Preview {
    CommandView()
        .modelContainer(for: [
            DailyTask.self,
            JobApplication.self,
            Flashcard.self,
            DesignPattern.self,
            StarStory.self
        ], inMemory: true)
}
