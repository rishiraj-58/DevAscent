//
//  LibraryView.swift
//  DevAscent
//
//  Created by Rishiraj on 24/11/25.
//

import SwiftUI

struct LibraryView: View {
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.neonText)
                
                Text("Roadmaps & Notes")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.neonText)
                
                Text("Pre-built learning tracks for Web Dev, System Design, and more")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }
}

#Preview {
    LibraryView()
}
