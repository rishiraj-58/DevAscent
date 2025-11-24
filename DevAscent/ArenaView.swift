//
//  ArenaView.swift
//  DevAscent
//
//  Created by Rishiraj on 24/11/25.
//

import SwiftUI

struct ArenaView: View {
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "terminal.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.primaryAccent)
                
                Text("DSA Practice & Randomizer")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.neonText)
                
                Text("AI-powered problem generation and flashcard system coming soon")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }
}

#Preview {
    ArenaView()
}
