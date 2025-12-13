//
//  OpsView.swift
//  DevAscent
//
//  The Planner - Tactical Execution
//  Created by Rishiraj on 13/12/24.
//

import SwiftUI
import SwiftData

struct OpsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyTask.createdAt, order: .reverse) private var tasks: [DailyTask]
    
    @State private var showingAddTask = false
    @State private var newTaskTitle = ""
    @State private var newTaskCategory: TaskCategory = .deepWork
    @State private var focusModeTask: DailyTask?
    
    // Group tasks by category
    private var deepWorkTasks: [DailyTask] {
        tasks.filter { $0.categoryEnum == .deepWork }
    }
    
    private var adminTasks: [DailyTask] {
        tasks.filter { $0.categoryEnum == .admin }
    }
    
    private var intelTasks: [DailyTask] {
        tasks.filter { $0.categoryEnum == .intel }
    }
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Task Lists by Category
                if tasks.isEmpty {
                    emptyStateView
                } else {
                    taskListView
                }
            }
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    addTaskButton
                        .padding(.trailing, 24)
                        .padding(.bottom, 24)
                }
            }
        }
        .sheet(isPresented: $showingAddTask) {
            addTaskSheet
        }
        .fullScreenCover(item: $focusModeTask) { task in
            FocusModeView(task: task)
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("[ OPS CENTER ]")
                        .font(.operatorLabel(12))
                        .foregroundColor(.primaryAccent)
                        .tracking(1.2)
                    
                    Text("Daily Protocol")
                        .font(.operatorHeader(28))
                        .foregroundColor(.neonText)
                }
                
                Spacer()
                
                // Generate Daily Orders Button
                Button(action: generateDailyOrders) {
                    HStack(spacing: 6) {
                        Image(systemName: "cpu")
                            .font(.system(size: 16))
                        Text("ORDERS")
                            .font(.operatorLabel(11))
                            .tracking(0.8)
                    }
                    .foregroundColor(.background)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.primaryAccent)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
        }
        .background(Color.background)
    }
    
    // MARK: - Task List
    
    private var taskListView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Deep Work
                if !deepWorkTasks.isEmpty {
                    categorySection(
                        title: "DEEP WORK",
                        icon: "brain.head.profile",
                        tasks: deepWorkTasks,
                        color: .neonText
                    )
                }
                
                // Intel (Study)
                if !intelTasks.isEmpty {
                    categorySection(
                        title: "INTEL",
                        icon: "book.fill",
                        tasks: intelTasks,
                        color: .statusInterview
                    )
                }
                
                // Admin
                if !adminTasks.isEmpty {
                    categorySection(
                        title: "ADMIN",
                        icon: "tray.full.fill",
                        tasks: adminTasks,
                        color: .textSecondary
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    private func categorySection(title: String, icon: String, tasks: [DailyTask], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.operatorLabel(12))
                    .foregroundColor(color)
                    .tracking(1.2)
                
                Spacer()
                
                Text("\(tasks.filter { $0.isCompleted }.count)/\(tasks.count)")
                    .font(.operatorLabel(11))
                    .foregroundColor(.textSecondary)
            }
            
            // Task Cards
            ForEach(tasks) { task in
                TaskToggleRow(
                    task: task,
                    onToggle: { toggleTaskCompletion(task) },
                    onFocus: { focusModeTask = task },
                    onDelete: { deleteTask(task) }
                )
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "scope")
                .font(.system(size: 60))
                .foregroundColor(.textSecondary)
            
            Text("No Active Protocols")
                .font(.operatorHeader(20))
                .foregroundColor(.neonText)
            
            Text("Tap 'ORDERS' to generate your daily mission\nor add tasks manually")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    // MARK: - FAB
    
    private var addTaskButton: some View {
        Button(action: { showingAddTask = true }) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.background)
                .frame(width: 60, height: 60)
                .background(Color.primaryAccent)
                .clipShape(Circle())
                .shadow(color: Color.primaryAccent.opacity(0.4), radius: 12, x: 0, y: 6)
        }
    }
    
    // MARK: - Add Task Sheet
    
    private var addTaskSheet: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Title Input
                    TextField("Task objective", text: $newTaskTitle)
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.border, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                    
                    // Category Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("CATEGORY")
                            .font(.operatorLabel(11))
                            .foregroundColor(.textSecondary)
                            .tracking(1.0)
                            .padding(.horizontal, 20)
                        
                        HStack(spacing: 12) {
                            ForEach(TaskCategory.allCases, id: \.self) { category in
                                CategoryPickerButton(
                                    category: category,
                                    isSelected: newTaskCategory == category
                                ) {
                                    newTaskCategory = category
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingAddTask = false
                        newTaskTitle = ""
                    }
                    .foregroundColor(.textSecondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addTask()
                    }
                    .foregroundColor(.primaryAccent)
                    .fontWeight(.semibold)
                    .disabled(newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .toolbarBackground(Color.cardBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .presentationDetents([.height(280)])
    }
    
    // MARK: - Actions
    
    private func addTask() {
        let task = DailyTask(
            title: newTaskTitle.trimmingCharacters(in: .whitespaces),
            category: newTaskCategory
        )
        modelContext.insert(task)
        
        showingAddTask = false
        newTaskTitle = ""
        newTaskCategory = .deepWork
    }
    
    private func toggleTaskCompletion(_ task: DailyTask) {
        task.isCompleted.toggle()
    }
    
    private func deleteTask(_ task: DailyTask) {
        modelContext.delete(task)
    }
    
    private func generateDailyOrders() {
        let aiTasks = [
            DailyTask(title: "Solve 1 LeetCode Medium", category: .deepWork),
            DailyTask(title: "Review LLD Pattern: Strategy", category: .intel),
            DailyTask(title: "Apply to 2 roles", category: .admin)
        ]
        
        for task in aiTasks {
            modelContext.insert(task)
        }
    }
}

// MARK: - Task Toggle Row

struct TaskToggleRow: View {
    let task: DailyTask
    let onToggle: () -> Void
    let onFocus: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Toggle Switch
            Button(action: onToggle) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(task.isCompleted ? Color.primaryAccent : Color.cardBackground)
                        .frame(width: 24, height: 24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(task.isCompleted ? Color.primaryAccent : Color.border, lineWidth: 2)
                        )
                    
                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.background)
                    }
                }
            }
            
            // Task Content
            Text(task.title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(task.isCompleted ? .textSecondary : .white)
                .strikethrough(task.isCompleted)
            
            Spacer()
            
            // Focus Button
            if !task.isCompleted {
                Button(action: onFocus) {
                    Image(systemName: "scope")
                        .font(.system(size: 18))
                        .foregroundColor(.neonText)
                }
            }
        }
        .padding(16)
        .operatorCard()
        .opacity(task.isCompleted ? 0.6 : 1.0)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Category Picker Button

struct CategoryPickerButton: View {
    let category: TaskCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 20))
                
                Text(category.displayName)
                    .font(.operatorLabel(10))
                    .tracking(0.5)
            }
            .foregroundColor(isSelected ? .background : .textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.primaryAccent : Color.cardBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.primaryAccent : Color.border, lineWidth: 1)
            )
        }
    }
}

// MARK: - Focus Mode View

struct FocusModeView: View {
    let task: DailyTask
    @Environment(\.dismiss) private var dismiss
    
    @State private var timeRemaining: TimeInterval = 25 * 60
    @State private var isRunning = false
    @State private var timer: Timer?
    @State private var selectedDuration: Int = 25
    @State private var pulseScale: CGFloat = 1.0
    
    private let durations = [25, 50]
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            // Radar animation
            radarAnimation
            
            VStack(spacing: 40) {
                // Header
                VStack(spacing: 8) {
                    Text("FOCUS MODE")
                        .font(.operatorLabel(12))
                        .foregroundColor(.primaryAccent)
                        .tracking(1.2)
                    
                    Text(task.title)
                        .font(.operatorHeader(20))
                        .foregroundColor(.neonText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Timer Display
                ZStack {
                    Circle()
                        .stroke(Color.border, lineWidth: 4)
                        .frame(width: 260, height: 260)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.neonText, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 260, height: 260)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.5), value: progress)
                    
                    VStack(spacing: 4) {
                        Text(timeString)
                            .font(.system(size: 56, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Text(isRunning ? "ACTIVE" : "STANDBY")
                            .font(.operatorLabel(12))
                            .foregroundColor(isRunning ? .primaryAccent : .textSecondary)
                            .tracking(1.0)
                    }
                }
                .scaleEffect(pulseScale)
                
                Spacer()
                
                // Duration Picker
                if !isRunning {
                    HStack(spacing: 16) {
                        ForEach(durations, id: \.self) { duration in
                            Button(action: {
                                selectedDuration = duration
                                timeRemaining = TimeInterval(duration * 60)
                            }) {
                                Text("\(duration) MIN")
                                    .font(.operatorLabel(14))
                                    .foregroundColor(selectedDuration == duration ? .background : .textSecondary)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(selectedDuration == duration ? Color.neonText : Color.cardBackground)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                // Controls
                HStack(spacing: 24) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.textSecondary)
                            .frame(width: 60, height: 60)
                            .background(Color.cardBackground)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.border, lineWidth: 1))
                    }
                    
                    Button(action: toggleTimer) {
                        Image(systemName: isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.background)
                            .frame(width: 80, height: 80)
                            .background(Color.primaryAccent)
                            .clipShape(Circle())
                            .shadow(color: Color.primaryAccent.opacity(0.4), radius: 12)
                    }
                    
                    Button(action: resetTimer) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.textSecondary)
                            .frame(width: 60, height: 60)
                            .background(Color.cardBackground)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.border, lineWidth: 1))
                    }
                }
                .padding(.bottom, 60)
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var radarAnimation: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(Color.neonText.opacity(0.1), lineWidth: 1)
                    .frame(width: CGFloat(300 + i * 100), height: CGFloat(300 + i * 100))
            }
        }
        .opacity(isRunning ? 0.5 : 0.2)
    }
    
    private var progress: CGFloat {
        let totalSeconds = TimeInterval(selectedDuration * 60)
        return (totalSeconds - timeRemaining) / totalSeconds
    }
    
    private var timeString: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func toggleTimer() {
        if isRunning {
            timer?.invalidate()
            timer = nil
            isRunning = false
        } else {
            isRunning = true
            startPulseAnimation()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    timer?.invalidate()
                    isRunning = false
                }
            }
        }
    }
    
    private func resetTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        timeRemaining = TimeInterval(selectedDuration * 60)
    }
    
    private func startPulseAnimation() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            pulseScale = 1.02
        }
    }
}

#Preview {
    OpsView()
        .modelContainer(for: [
            DailyTask.self,
            JobApplication.self,
            Flashcard.self,
            DesignPattern.self,
            StarStory.self
        ], inMemory: true)
}
