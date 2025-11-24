//
//  InterviewView.swift
//  DevAscent
//
//  Created by Rishiraj on 24/11/25.
//

import SwiftUI

struct InterviewView: View {
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "person.crop.rectangle.stack.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.primaryAccent)
                
                Text("AI Resume Interrogation")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.neonText)
                
                Text("Upload your resume and get grilled by an AI interviewer")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }
}

#Preview {
    InterviewView()
}
