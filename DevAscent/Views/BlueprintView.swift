//
//  BlueprintView.swift
//  DevAscent
//
//  LLD Visualizer - Problem List with Detail View
//  Created by Rishiraj on 13/12/24.
//

import SwiftUI
import SwiftData
import WebKit

// MARK: - Blueprint View (Problem List)

struct BlueprintView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LLDProblem.title) private var problems: [LLDProblem]
    
    @State private var selectedProblem: LLDProblem?
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Problem List
                if problems.isEmpty {
                    emptyState
                } else {
                    problemList
                }
            }
        }
        .sheet(item: $selectedProblem) { problem in
            LLDDetailView(problem: problem)
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("[ BLUEPRINT ]")
                    .font(.operatorLabel(12))
                    .foregroundColor(.primaryAccent)
                    .tracking(1.2)
                
                Text("LLD Question Bank")
                    .font(.operatorHeader(28))
                    .foregroundColor(.neonText)
            }
            
            Spacer()
            
            // Problem count
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(problems.count)")
                    .font(.operatorHeader(24))
                    .foregroundColor(.neonText)
                
                Text("PROBLEMS")
                    .font(.operatorLabel(10))
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 16)
    }
    
    // MARK: - Problem List
    
    private var problemList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(problems) { problem in
                    ProblemCard(problem: problem) {
                        selectedProblem = problem
                    }
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
            
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.textSecondary)
            
            Text("No Problems Loaded")
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

// MARK: - Problem Card

struct ProblemCard: View {
    let problem: LLDProblem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: "cube.transparent")
                    .font(.system(size: 28))
                    .foregroundColor(.neonText)
                    .frame(width: 50)
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(problem.title)
                        .font(.operatorHeader(18))
                        .foregroundColor(.white)
                    
                    if !problem.gsSpecificTwist.isEmpty {
                        Text(problem.gsSpecificTwist)
                            .font(.system(size: 13))
                            .foregroundColor(.textSecondary)
                            .lineLimit(2)
                    }
                    
                    // Feature badges
                    HStack(spacing: 8) {
                        if !problem.mermaidGraph.isEmpty {
                            FeatureBadge(icon: "rectangle.3.group", text: "UML")
                        }
                        if !problem.codeSnippet.isEmpty {
                            FeatureBadge(icon: "chevron.left.forwardslash.chevron.right", text: "Code")
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
            }
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

struct FeatureBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(.operatorLabel(9))
        }
        .foregroundColor(.primaryAccent)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.primaryAccent.opacity(0.15))
        .cornerRadius(4)
    }
}

// MARK: - LLD Detail View

enum LLDTab: String, CaseIterable {
    case diagram = "Diagram"
    case logic = "Logic"
    case code = "Code"
    case sim = "Sim"
    
    var icon: String {
        switch self {
        case .diagram: return "rectangle.3.group"
        case .logic: return "lightbulb"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .sim: return "brain.head.profile"
        }
    }
}

struct LLDDetailView: View {
    let problem: LLDProblem
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: LLDTab = .diagram
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Segmented Control
                    tabPicker
                    
                    // Tab Content
                    TabView(selection: $selectedTab) {
                        DiagramTabView(mermaidCode: problem.mermaidGraph)
                            .tag(LLDTab.diagram)
                        
                        LogicTabView(problem: problem)
                            .tag(LLDTab.logic)
                        
                        CodeTabView(code: problem.codeSnippet)
                            .tag(LLDTab.code)
                        
                        SimTabView(problem: problem)
                            .tag(LLDTab.sim)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle(problem.title)
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
    }
    
    private var tabPicker: some View {
        HStack(spacing: 0) {
            ForEach(LLDTab.allCases, id: \.self) { tab in
                Button(action: { selectedTab = tab }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 16))
                        Text(tab.rawValue)
                            .font(.operatorLabel(10))
                    }
                    .foregroundColor(selectedTab == tab ? .primaryAccent : .textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selectedTab == tab ? Color.primaryAccent.opacity(0.15) : Color.clear)
                }
            }
        }
        .background(Color.cardBackground)
        .overlay(
            Rectangle()
                .fill(Color.border)
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

// MARK: - Diagram Tab (Mermaid)

struct DiagramTabView: View {
    let mermaidCode: String
    
    var body: some View {
        Group {
            if mermaidCode.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "rectangle.3.group")
                        .font(.system(size: 50))
                        .foregroundColor(.textSecondary)
                    Text("No diagram available")
                        .foregroundColor(.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                MermaidWebView(mermaidCode: mermaidCode)
            }
        }
        .background(Color.background)
    }
}

// MARK: - Mermaid WebView

struct MermaidWebView: UIViewRepresentable {
    let mermaidCode: String
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = UIColor(Color.background)
        webView.scrollView.backgroundColor = UIColor(Color.background)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let html = MermaidHelper.generateHTML(for: mermaidCode)
        webView.loadHTMLString(html, baseURL: nil)
    }
}

// MARK: - Logic Tab

struct LogicTabView: View {
    let problem: LLDProblem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Requirements
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "checklist")
                            .foregroundColor(.neonText)
                        Text("REQUIREMENTS")
                            .font(.operatorLabel(12))
                            .foregroundColor(.neonText)
                    }
                    
                    Text(parseLLDMarkdown(problem.requirements))
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                        .lineSpacing(4)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.cardBackground)
                .cornerRadius(12)
                
                // Solution Strategy
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.primaryAccent)
                        Text("KEY PATTERNS")
                            .font(.operatorLabel(12))
                            .foregroundColor(.primaryAccent)
                    }
                    
                    Text(parseLLDMarkdown(problem.solutionStrategy))
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                        .lineSpacing(4)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.primaryAccent.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primaryAccent.opacity(0.3), lineWidth: 1)
                )
                
                // GS Twist
                if !problem.gsSpecificTwist.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.statusOA)
                            Text("GS SPECIFIC TWIST")
                                .font(.operatorLabel(12))
                                .foregroundColor(.statusOA)
                        }
                        
                        Text(problem.gsSpecificTwist)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.statusOA.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.statusOA.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            .padding(20)
        }
        .background(Color.background)
    }
}

// MARK: - Code Tab

struct CodeTabView: View {
    let code: String
    
    var body: some View {
        ScrollView {
            if code.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                        .font(.system(size: 50))
                        .foregroundColor(.textSecondary)
                    Text("No code snippet available")
                        .foregroundColor(.textSecondary)
                    Spacer()
                }
            } else {
                ScrollView(.horizontal, showsIndicators: true) {
                    Text(code)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(20)
                }
                .background(Color(hex: "#161B22"))
                .cornerRadius(12)
                .padding(20)
            }
        }
        .background(Color.background)
    }
}

// MARK: - Sim Tab (Gemini Chat)

struct SimTabView: View {
    let problem: LLDProblem
    @StateObject private var gemini = GeminiService.shared
    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    @State private var isInitialized = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        // System intro card
                        SystemMessageCard(text: "GS Interview Simulator for \(problem.title). The AI will grill you on your design choices.")
                        
                        ForEach(messages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                        }
                        
                        if gemini.isLoading {
                            HStack {
                                ProgressView()
                                    .tint(.primaryAccent)
                                Text("Thinking...")
                                    .font(.system(size: 14))
                                    .foregroundColor(.textSecondary)
                            }
                            .padding()
                        }
                    }
                    .padding(20)
                }
                .onChange(of: messages.count) { _, _ in
                    if let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input Bar
            inputBar
        }
        .background(Color.background)
        .onAppear {
            if !isInitialized {
                startInterview()
                isInitialized = true
            }
        }
    }
    
    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Defend your design...", text: $inputText)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.cardBackground)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.border, lineWidth: 1)
                )
            
            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(inputText.isEmpty ? .textSecondary : .primaryAccent)
            }
            .disabled(inputText.isEmpty || gemini.isLoading)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.cardBackground)
    }
    
    private func startInterview() {
        Task {
            let systemPrompt = gemini.getInterviewerPrompt(for: problem)
            do {
                let response = try await gemini.sendMessage(
                    userMessage: "I'm ready to discuss my design for \(problem.title). Ask me anything.",
                    conversationHistory: [],
                    systemPrompt: systemPrompt
                )
                
                await MainActor.run {
                    messages.append(ChatMessage(role: .user, content: "I'm ready to discuss my design for \(problem.title)."))
                    messages.append(ChatMessage(role: .assistant, content: response))
                }
            } catch {
                await MainActor.run {
                    messages.append(ChatMessage(role: .assistant, content: "Error: \(error.localizedDescription)"))
                }
            }
        }
    }
    
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        let userMessage = ChatMessage(role: .user, content: text)
        messages.append(userMessage)
        inputText = ""
        
        Task {
            let systemPrompt = gemini.getInterviewerPrompt(for: problem)
            do {
                let response = try await gemini.sendMessage(
                    userMessage: text,
                    conversationHistory: Array(messages.dropLast()), // Exclude the message we just added
                    systemPrompt: systemPrompt
                )
                
                await MainActor.run {
                    messages.append(ChatMessage(role: .assistant, content: response))
                }
            } catch {
                await MainActor.run {
                    messages.append(ChatMessage(role: .assistant, content: "Error: \(error.localizedDescription)"))
                }
            }
        }
    }
}

// MARK: - Chat Components

struct SystemMessageCard: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.neonText)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.textSecondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.border, lineWidth: 1)
        )
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var isUser: Bool { message.role == .user }
    
    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 60) }
            
            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.system(size: 15))
                    .foregroundColor(isUser ? .background : .white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(isUser ? Color.primaryAccent : Color.cardBackground)
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(isUser ? Color.clear : Color.border, lineWidth: 1)
                    )
            }
            
            if !isUser { Spacer(minLength: 60) }
        }
    }
}

// MARK: - Markdown Helper

/// Parse markdown text to AttributedString for proper rendering
private func parseLLDMarkdown(_ text: String) -> AttributedString {
    if let attributed = try? AttributedString(markdown: text, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
        return attributed
    }
    return AttributedString(text)
}

#Preview {
    BlueprintView()
        .modelContainer(for: [LLDProblem.self], inMemory: true)
}
