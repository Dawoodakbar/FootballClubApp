//
//  LoadingView.swift
//  FootballClub
//
//  Created by Dawood Akbar on 29/06/2025.
//

import SwiftUI

struct LoadingView: View {
    @State private var isLoading = true
    @State private var rotationAngle: Double = 0
    @State private var scaleEffect: CGFloat = 0.8
    @State private var opacity: Double = 0
    @State private var progressValue: Double = 0
    
    let onLoadingComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [Color(hex: "#22C55E"), Color(hex: "#3B82F6"), Color(hex: "#8B5CF6")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Animated Logo
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(rotationAngle))
                    }
                    .scaleEffect(scaleEffect)
                    .opacity(opacity)
                    
                    VStack(spacing: 8) {
                        Text("Football Club Manager")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .opacity(opacity)
                        
                        Text("Professional Club Management")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .opacity(opacity)
                    }
                }
                
                // Feature Icons
                HStack(spacing: 30) {
                    ForEach(0..<4) { index in
                        let icons = ["person.3.fill", "calendar", "trophy.fill", "target"]
                        
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: icons[index])
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        .opacity(opacity)
                        .animation(.easeInOut(duration: 0.6).delay(Double(index) * 0.2), value: opacity)
                    }
                }
                
                // Progress Bar
                VStack(spacing: 16) {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white)
                            .frame(width: CGFloat(progressValue) * 250, height: 4)
                    }
                    .frame(width: 250)
                    
                    Text("Loading your club...")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .opacity(opacity)
            }
        }
        .onAppear {
            startLoadingAnimation()
        }
    }
    
    private func startLoadingAnimation() {
        // Initial fade in and scale
        withAnimation(.easeOut(duration: 1.0)) {
            opacity = 1.0
            scaleEffect = 1.0
        }
        
        // Continuous rotation
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Progress bar animation
        withAnimation(.easeInOut(duration: 3.0)) {
            progressValue = 1.0
        }
        
        // Complete loading after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            onLoadingComplete()
        }
    }
}

// Color extension for hex support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

//struct LoadingView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoadingView()
//        print("Loading completed")
//    }
//}
