//
//  PlannerView.swift
//  DevAscent
//
//  Created by Rishiraj on 24/11/25.
//

import SwiftUI
import SwiftData

struct PlannerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PlanTask.createdAt, order: .forward) private var tasks: [PlanTask]
    
    @State private var showingAddTask = false
    @State private var newTaskTitle = ""
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Task List
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
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Protocol")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.neonText)
                    
                    Text(currentDateString)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                // Generate Plan Button
                Button(action: generateAIPlan) {
                    HStack(spacing: 6) {
                        Image(systemName: "cpu")
                            .font(.system(size: 16))
                        Text("AI")
                            .font(.caption)
                            .fontWeight(.semibold)
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
            LazyVStack(spacing: 12) {
                ForEach(tasks) { task in
                    TaskRowView(task: task, onToggle: {
                        toggleTaskCompletion(task)
                    }, onDelete: {
                        deleteTask(task)
                    })
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
            
            Image(systemName: "checkmark.circle.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.textSecondary)
            
            Text("No tasks yet")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.neonText)
            
            Text("Tap the + button or use AI to generate your daily plan")
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
                .shadow(color: Color.primaryAccent.opacity(0.3), radius: 12, x: 0, y: 6)
        }
    }
    
    // MARK: - Add Task Sheet
    private var addTaskSheet: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    TextField("Task title", text: $newTaskTitle)
                        .font(.title3)
                        .foregroundColor(.neonText)
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                    
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
        .presentationDetents([.height(200)])
    }
    
    // MARK: - Helper Properties
    private var currentDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: Date())
    }
    
    // MARK: - Actions
    private func addTask() {
        let task = PlanTask(title: newTaskTitle.trimmingCharacters(in: .whitespaces))
        modelContext.insert(task)
        
        showingAddTask = false
        newTaskTitle = ""
    }
    
    private func toggleTaskCompletion(_ task: PlanTask) {
        task.isCompleted.toggle()
    }
    
    private func deleteTask(_ task: PlanTask) {
        modelContext.delete(task)
    }
    
    private func generateAIPlan() {
        // Inject 3 hardcoded AI-suggested tasks
        let aiTasks = [
            PlanTask(title: "Review System Design: Load Balancers", category: .learning, isAISuggested: true),
            PlanTask(title: "Solve 1 LeetCode Medium", category: .core, isAISuggested: true),
            PlanTask(title: "Commit to GitHub", category: .core, isAISuggested: true)
        ]
        
        for task in aiTasks {
            modelContext.insert(task)
        }
    }
}

// MARK: - Task Row Component
struct TaskRowView: View {
    let task: PlanTask
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(task.isCompleted ? .primaryAccent : .textSecondary)
            }
            
            // Task Text
            HStack(spacing: 6) {
                Text(task.title)
                    .font(.body)
                    .foregroundColor(task.isCompleted ? .textSecondary : .neonText)
                    .strikethrough(task.isCompleted)
                
                // AI Sparkle Icon
                if task.isAISuggested {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundColor(.primaryAccent)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .opacity(task.isCompleted ? 0.6 : 1.0)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    PlannerView()
        .modelContainer(for: PlanTask.self, inMemory: true)
}
