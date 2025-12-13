//
//  GitHubLogView.swift
//  DevAscent
//
//  Created by Rishiraj on 24/11/25.
//

import SwiftUI

struct GitHubLogView: View {
    let events: [GitHubEvent]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Event List
                if events.isEmpty {
                    emptyState
                } else {
                    eventList
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("TRANSMISSION LOG")
                    .font(.system(size: 16, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(.neonText)
                    .tracking(1.5)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 12)
            
            Divider()
                .background(Color.textSecondary.opacity(0.3))
        }
        .background(Color.background)
    }
    
    // MARK: - Event List
    
    private var eventList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(events) { event in
                    GitHubEventRow(event: event)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.textSecondary)
            
            Text("No Recent Activity")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.neonText)
            
            Text("GitHub events will appear here")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
            
            Spacer()
        }
    }
}

// MARK: - Event Row Component

struct GitHubEventRow: View {
    let event: GitHubEvent
    
    private var eventIcon: (name: String, color: Color) {
        switch event.type {
        case "PushEvent":
            return ("arrow.up.circle.fill", .primaryAccent)
        case "PullRequestEvent":
            return ("arrow.triangle.merge", .purple)
        case "CreateEvent":
            return ("plus.circle.fill", .blue)
        case "IssuesEvent":
            return ("exclamationmark.circle.fill", .orange)
        case "WatchEvent":
            return ("star.fill", .yellow)
        default:
            return ("doc.text", .textSecondary)
        }
    }
    
    private var timeAgo: String {
        guard let date = event.date else {
            return "Unknown time"
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: eventIcon.name)
                .font(.system(size: 24))
                .foregroundColor(eventIcon.color)
                .frame(width: 40)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(event.repo.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.neonText)
                
                HStack(spacing: 6) {
                    Text(event.type.replacingOccurrences(of: "Event", with: ""))
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.textSecondary)
                    
                    Text("•")
                        .foregroundColor(.textSecondary)
                    
                    Text(timeAgo)
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.cardBackground)
        .cornerRadius(8)
    }
}

#Preview {
    GitHubLogView(events: [])
}
