//
//  ContentView.swift
//  Music Trainer
//

import SwiftUI

struct ContentView: View {
    enum Route {
        case none
        case classic
        case experimental
    }

    @State private var route: Route = .none
    @State private var animate = false

    var body: some View {
        switch route {
        case .classic:
            TrainingView()

        case .experimental:
            ExperimentalTrainingView()

        case .none:
            home
        }
    }

    private var home: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(.systemCyan),
                    Color(.systemTeal),
                    Color(.systemBlue).opacity(0.65)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Soft blobs for depth
            Circle()
                .fill(Color.white.opacity(0.18))
                .frame(width: 260, height: 260)
                .blur(radius: 1)
                .offset(x: animate ? -120 : -80, y: animate ? -210 : -180)

            Circle()
                .fill(Color.white.opacity(0.12))
                .frame(width: 320, height: 320)
                .blur(radius: 1)
                .offset(x: animate ? 140 : 110, y: animate ? 260 : 230)

            // Music notes decoration (subtle)
            VStack {
                HStack {
                    Text("♪")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .opacity(0.12)
                        .rotationEffect(.degrees(-12))
                        .offset(x: -10, y: 10)

                    Spacer()

                    Text("♩")
                        .font(.system(size: 54, weight: .bold, design: .rounded))
                        .opacity(0.10)
                        .rotationEffect(.degrees(10))
                        .offset(x: 10, y: 20)
                }
                .padding(.horizontal, 30)
                .padding(.top, 40)

                Spacer()
            }

            VStack(spacing: 18) {

                Spacer()

                // Title block
                VStack(spacing: 10) {
                    Text("Ear")
                        .font(.system(size: 52, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)

                    Text("Trainer")
                        .font(.system(size: 52, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white.opacity(0.95))
                        .shadow(color: .black.opacity(0.20), radius: 10, x: 0, y: 6)

                    Text("Train intervals • Build your streak • Level up your ear")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(.top, 6)
                }
                .padding(.horizontal, 24)

                Spacer()

                // Buttons
                VStack(spacing: 14) {

                    StartPillButton(
                        title: "Start Training",
                        subtitle: "Classic grid",
                        icon: "music.note.list"
                    ) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            route = .classic
                        }
                    }

                    StartPillButton(
                        title: "Experimental Training",
                        subtitle: "Higher / Lower → Narrow down",
                        icon: "slider.horizontal.3"
                    ) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            route = .experimental
                        }
                    }
                }
                .padding(.horizontal, 26)

                // Footer hint
                Text("Tip: Start with Experimental, then try Classic for speed ⚡️")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.75))
                    .padding(.top, 8)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - Reusable button style
struct StartPillButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {

                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.28))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.black)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundStyle(.black)

                    Text(subtitle)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.black.opacity(0.75))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black.opacity(0.8))
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemOrange))
                    .shadow(color: .black.opacity(0.22), radius: 12, x: 0, y: 8)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
