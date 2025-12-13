//
//  IntelView.swift
//  DevAscent
//
//  The Pipeline - Career CRM
//  Created by Rishiraj on 13/12/24.
//

import SwiftUI
import SwiftData

struct IntelView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var applications: [JobApplication]
    
    @State private var showingAddApplication = false
    @State private var selectedApplication: JobApplication?
    
    // Sort applications by status priority
    private var sortedApplications: [JobApplication] {
        applications.sorted { $0.statusEnum.sortPriority < $1.statusEnum.sortPriority }
    }
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Application List
                if applications.isEmpty {
                    emptyStateView
                } else {
                    applicationListView
                }
            }
            
            // FAB
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    addApplicationButton
                        .padding(.trailing, 24)
                        .padding(.bottom, 24)
                }
            }
        }
        .sheet(isPresented: $showingAddApplication) {
            AddApplicationSheet()
        }
        .sheet(item: $selectedApplication) { application in
            MissionDossierView(application: application)
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("[ INTEL CENTER ]")
                        .font(.operatorLabel(12))
                        .foregroundColor(.primaryAccent)
                        .tracking(1.2)
                    
                    Text("Mission Pipeline")
                        .font(.operatorHeader(28))
                        .foregroundColor(.neonText)
                }
                
                Spacer()
                
                // Stats
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(applications.count)")
                        .font(.operatorHeader(24))
                        .foregroundColor(.textPrimary)
                    
                    Text("ACTIVE")
                        .font(.operatorLabel(10))
                        .foregroundColor(.textSecondary)
                        .tracking(1.0)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
        }
        .background(Color.background)
    }
    
    // MARK: - Application List
    
    private var applicationListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(sortedApplications) { application in
                    ApplicationRow(application: application)
                        .onTapGesture {
                            selectedApplication = application
                        }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(.textSecondary)
            
            Text("No Active Missions")
                .font(.operatorHeader(20))
                .foregroundColor(.neonText)
            
            Text("Track your job applications\nand never lose a lead")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
    }
    
    // MARK: - FAB
    
    private var addApplicationButton: some View {
        Button(action: { showingAddApplication = true }) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.background)
                .frame(width: 60, height: 60)
                .background(Color.neonText)
                .clipShape(Circle())
                .shadow(color: Color.neonText.opacity(0.4), radius: 12, x: 0, y: 6)
        }
    }
}

// MARK: - Application Row

struct ApplicationRow: View {
    @Bindable var application: JobApplication
    
    var body: some View {
        HStack(spacing: 16) {
            // Status indicator
            statusIndicator
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(application.company)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textPrimary)
                
                Text(application.role)
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
                
                // Platform and date
                HStack(spacing: 8) {
                    Text(application.platform)
                        .font(.operatorLabel(10))
                        .foregroundColor(.textSecondary)
                    
                    Text("•")
                        .foregroundColor(.textSecondary)
                    
                    Text(application.appliedDate, style: .date)
                        .font(.operatorLabel(10))
                        .foregroundColor(.textSecondary)
                }
            }
            
            Spacer()
            
            // Status pill
            StatusPill(status: application.statusEnum)
        }
        .padding(16)
        .operatorCard()
    }
    
    private var statusIndicator: some View {
        Circle()
            .fill(statusColor)
            .frame(width: 10, height: 10)
            .modifier(application.statusEnum == .interview ? PulsingAnimation() : PulsingAnimation())
            .opacity(application.statusEnum == .interview ? 1 : 0)
            .overlay(
                Circle()
                    .fill(statusColor)
                    .frame(width: 10, height: 10)
                    .opacity(application.statusEnum == .interview ? 0 : 1)
            )
    }
    
    private var statusColor: Color {
        switch application.statusEnum {
        case .wishlist: return .textSecondary
        case .applied: return .statusApplied
        case .oa: return .statusOA
        case .interview: return .statusInterview
        case .offer: return .statusOffer
        case .rejected: return .statusRejected
        }
    }
}

// MARK: - Status Pill

struct StatusPill: View {
    let status: ApplicationStatus
    
    var body: some View {
        Text(status.displayName.uppercased())
            .font(.operatorLabel(10))
            .tracking(0.5)
            .foregroundColor(pillForeground)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(pillBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(pillBorder, lineWidth: 1)
            )
    }
    
    private var pillBackground: Color {
        switch status {
        case .wishlist: return .cardBackground
        case .applied: return .statusApplied.opacity(0.2)
        case .oa: return .statusOA.opacity(0.2)
        case .interview: return .statusInterview.opacity(0.2)
        case .offer: return .statusOffer.opacity(0.2)
        case .rejected: return .statusRejected.opacity(0.2)
        }
    }
    
    private var pillForeground: Color {
        switch status {
        case .wishlist: return .textSecondary
        case .applied: return .statusApplied
        case .oa: return .statusOA
        case .interview: return .statusInterview
        case .offer: return .statusOffer
        case .rejected: return .statusRejected
        }
    }
    
    private var pillBorder: Color {
        pillForeground.opacity(0.3)
    }
}

// MARK: - Add Application Sheet

struct AddApplicationSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var company = ""
    @State private var role = ""
    @State private var status: ApplicationStatus = .applied
    @State private var platform = "LinkedIn"
    @State private var notes = ""
    
    private let platforms = ["LinkedIn", "Referral", "Company Site", "Indeed", "Glassdoor", "Other"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Company
                        InputField(title: "COMPANY", text: $company, placeholder: "Company name")
                        
                        // Role
                        InputField(title: "ROLE", text: $role, placeholder: "Job title")
                        
                        // Platform Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PLATFORM")
                                .font(.operatorLabel(11))
                                .foregroundColor(.textSecondary)
                                .tracking(1.0)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(platforms, id: \.self) { p in
                                        Button(action: { platform = p }) {
                                            Text(p)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(platform == p ? .background : .textSecondary)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(platform == p ? Color.neonText : Color.cardBackground)
                                                .cornerRadius(8)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(Color.border, lineWidth: platform == p ? 0 : 1)
                                                )
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Status Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("STATUS")
                                .font(.operatorLabel(11))
                                .foregroundColor(.textSecondary)
                                .tracking(1.0)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(ApplicationStatus.allCases, id: \.self) { s in
                                        Button(action: { status = s }) {
                                            StatusPill(status: s)
                                                .opacity(status == s ? 1 : 0.5)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("NOTES")
                                .font(.operatorLabel(11))
                                .foregroundColor(.textSecondary)
                                .tracking(1.0)
                            
                            TextEditor(text: $notes)
                                .font(.system(size: 16))
                                .foregroundColor(.textPrimary)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 100)
                                .padding(12)
                                .background(Color.cardBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.border, lineWidth: 1)
                                )
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("New Application")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.textSecondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveApplication() }
                        .foregroundColor(.primaryAccent)
                        .fontWeight(.semibold)
                        .disabled(company.isEmpty || role.isEmpty)
                }
            }
            .toolbarBackground(Color.cardBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    private func saveApplication() {
        let application = JobApplication(
            company: company,
            role: role,
            status: status,
            platform: platform,
            notes: notes
        )
        modelContext.insert(application)
        dismiss()
    }
}

// MARK: - Input Field

struct InputField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.operatorLabel(11))
                .foregroundColor(.textSecondary)
                .tracking(1.0)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .foregroundColor(.textPrimary)
                .padding(16)
                .background(Color.cardBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.border, lineWidth: 1)
                )
        }
    }
}

// MARK: - Mission Dossier View

struct MissionDossierView: View {
    @Bindable var application: JobApplication
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingDeleteAlert = false
    @State private var isEditingNotes = false
    @State private var editedNotes = ""
    @State private var showDatePicker = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header Card
                        headerCard
                        
                        // Status Selector
                        statusSelector
                        
                        // Interview Date
                        interviewDateSection
                        
                        // Timeline
                        timelineSection
                        
                        // Notes Section
                        notesSection
                        
                        // Delete Button
                        deleteButton
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Mission Dossier")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.neonText)
                }
            }
            .toolbarBackground(Color.cardBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .alert("Delete Application?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                modelContext.delete(application)
                dismiss()
            }
        }
    }
    
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(application.company)
                        .font(.operatorHeader(24))
                        .foregroundColor(.neonText)
                    
                    Text(application.role)
                        .font(.system(size: 16))
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                StatusPill(status: application.statusEnum)
            }
            
            Divider()
                .background(Color.border)
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("PLATFORM")
                        .font(.operatorLabel(10))
                        .foregroundColor(.textSecondary)
                    Text(application.platform)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textPrimary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("APPLIED")
                        .font(.operatorLabel(10))
                        .foregroundColor(.textSecondary)
                    Text(application.appliedDate, style: .date)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textPrimary)
                }
            }
        }
        .padding(20)
        .operatorCard()
    }
    
    private var statusSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("UPDATE STATUS")
                .font(.operatorLabel(11))
                .foregroundColor(.textSecondary)
                .tracking(1.0)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ApplicationStatus.allCases, id: \.self) { status in
                        Button(action: { application.status = status.rawValue }) {
                            StatusPill(status: status)
                                .opacity(application.statusEnum == status ? 1 : 0.5)
                        }
                    }
                }
            }
        }
    }
    
    private var interviewDateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("INTERVIEW DATE")
                .font(.operatorLabel(11))
                .foregroundColor(.textSecondary)
                .tracking(1.0)
            
            Button(action: { showDatePicker.toggle() }) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.neonText)
                    
                    if let date = application.nextInterviewDate {
                        Text(date, style: .date)
                            .foregroundColor(.textPrimary)
                        Text(date, style: .time)
                            .foregroundColor(.textSecondary)
                    } else {
                        Text("Set interview date")
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.textSecondary)
                }
                .padding(16)
                .operatorCard()
            }
            
            if showDatePicker {
                DatePicker(
                    "Interview Date",
                    selection: Binding(
                        get: { application.nextInterviewDate ?? Date() },
                        set: { application.nextInterviewDate = $0 }
                    ),
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .tint(.neonText)
                .padding()
                .operatorCard()
            }
        }
    }
    
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TIMELINE")
                .font(.operatorLabel(11))
                .foregroundColor(.textSecondary)
                .tracking(1.0)
            
            VStack(alignment: .leading, spacing: 0) {
                TimelineItem(
                    title: "Applied",
                    date: application.appliedDate,
                    isFirst: true,
                    isLast: application.nextInterviewDate == nil
                )
                
                if let interviewDate = application.nextInterviewDate {
                    TimelineItem(
                        title: "Interview",
                        date: interviewDate,
                        isFirst: false,
                        isLast: true,
                        isFuture: interviewDate > Date()
                    )
                }
            }
            .padding(16)
            .operatorCard()
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("NOTES")
                    .font(.operatorLabel(11))
                    .foregroundColor(.textSecondary)
                    .tracking(1.0)
                
                Spacer()
                
                Button(action: {
                    if isEditingNotes {
                        application.notes = editedNotes
                    } else {
                        editedNotes = application.notes
                    }
                    isEditingNotes.toggle()
                }) {
                    Text(isEditingNotes ? "Save" : "Edit")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.neonText)
                }
            }
            
            if isEditingNotes {
                TextEditor(text: $editedNotes)
                    .font(.system(size: 16))
                    .foregroundColor(.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 150)
                    .padding(12)
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.neonText, lineWidth: 1)
                    )
            } else {
                Text(application.notes.isEmpty ? "Add STAR method stories, prep notes..." : application.notes)
                    .font(.system(size: 16))
                    .foregroundColor(application.notes.isEmpty ? .textSecondary : .textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .operatorCard()
            }
        }
    }
    
    private var deleteButton: some View {
        Button(action: { showingDeleteAlert = true }) {
            HStack {
                Image(systemName: "trash")
                Text("Delete Application")
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.alertRed)
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color.alertRed.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.alertRed.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Timeline Item

struct TimelineItem: View {
    let title: String
    let date: Date
    let isFirst: Bool
    let isLast: Bool
    var isFuture: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline indicator
            VStack(spacing: 0) {
                Circle()
                    .fill(isFuture ? Color.statusInterview : Color.primaryAccent)
                    .frame(width: 12, height: 12)
                
                if !isLast {
                    Rectangle()
                        .fill(Color.border)
                        .frame(width: 2, height: 40)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isFuture ? .statusInterview : .textPrimary)
                
                Text(date, style: .date)
                    .font(.operatorLabel(12))
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    IntelView()
        .modelContainer(for: [
            DailyTask.self,
            JobApplication.self,
            Flashcard.self,
            DesignPattern.self,
            StarStory.self
        ], inMemory: true)
}
