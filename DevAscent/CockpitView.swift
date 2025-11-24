//
//  CockpitView.swift
//  DevAscent
//
//  Created by Rishiraj on 24/11/25.
//

import SwiftUI

struct CockpitView: View {
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "command.square.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.neonText)
                
                Text("Dashboard & Heatmap")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.neonText)
                
                Text("Your contribution grid and streak tracker will live here")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }
}

#Preview {
    CockpitView()
}
