//
//  TrainingView.swift
//  Music Trainer
//

import SwiftUI

struct TrainingView: View {

    @Binding var route: ContentView.Route
    @StateObject var noteEngine = SamplerEngine()

    @State private var noteOne: UInt8 = 60
    @State private var noteTwo: UInt8 = 60

    enum ResultState { case none, correct, wrong }
    @State private var result: ResultState = .none

    @State private var streak: Int = 0
    private let streakGoal: Int = 10

    // NEW
    @State private var answeredThisRound = false
    @State private var showCongrats = false

    // NEW (for background motion like homepage)
    @State private var animateBG = false

    private var progress: Double {
        min(1.0, Double(streak) / Double(streakGoal))
    }

    private let intervals: [(semitones: Int, name: String, short: String)] = [
        (1,"Minor 2nd","m2"), (2,"Major 2nd","M2"),
        (3,"Minor 3rd","m3"), (4,"Major 3rd","M3"),
        (5,"Perfect 4th","P4"), (6,"Tritone","TT"),
        (7,"Perfect 5th","P5"), (8,"Minor 6th","m6"),
        (9,"Major 6th","M6"), (10,"Minor 7th","m7"),
        (11,"Major 7th","M7"), (12,"Octave","P8")
    ]

    var body: some View {
        ZStack {

            // MARK: - Background (matches homepage)
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

            // Soft blobs (animated like homepage)
            Circle()
                .fill(Color.white.opacity(0.18))
                .frame(width: 260, height: 260)
                .blur(radius: 1)
                .offset(x: animateBG ? -120 : -80, y: animateBG ? -230 : -190)

            Circle()
                .fill(Color.white.opacity(0.12))
                .frame(width: 320, height: 320)
                .blur(radius: 1)
                .offset(x: animateBG ? 140 : 110, y: animateBG ? 270 : 230)

            // Music notes decoration (subtle)
            VStack {
                HStack {
                    Text("♪")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .opacity(0.10)
                        .rotationEffect(.degrees(-10))
                        .offset(x: -10, y: 10)

                    Spacer()

                    Text("♩")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .opacity(0.08)
                        .rotationEffect(.degrees(10))
                        .offset(x: 10, y: 20)
                }
                .padding(.horizontal, 28)
                .padding(.top, 30)

                Spacer()
            }

            // MARK: - Content
            VStack(spacing: 16) {
                HStack {
                    Button {
                        route = .none
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    }

                    Spacer()
                }


                feedbackBanner

                Spacer()

                intervalCard

                transportButtons

                Spacer()

                progressCard
            }
            .padding(20)
        }
        .overlay {
            if showCongrats {
                CongratsOverlay()
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                animateBG = true
            }
        }
    }
}

// User Interface
extension TrainingView {

    private var currentInterval: Int {
        abs(Int(noteTwo) - Int(noteOne))
    }

    private func intervalName(for semitones: Int) -> String {
        intervals.first(where: { $0.semitones == semitones })?.name ?? "\(semitones) semitones"
    }

    private var feedbackBanner: some View {
        Group {
            switch result {
            case .none:
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.clear)
                    .frame(height: 72)

            case .correct:
                bannerView(
                    icon: "checkmark.circle.fill",
                    title: "Correct",
                    subtitle: "\(intervalName(for: currentInterval)).",
                    color: .green
                )

            case .wrong:
                bannerView(
                    icon: "xmark.circle.fill",
                    title: "Not quite",
                    subtitle: "It was \(intervalName(for: currentInterval)).",
                    color: .red
                )
            }
        }
        .animation(.easeInOut, value: result)
    }

    private func bannerView(icon: String, title: String, subtitle: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                Text(subtitle)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .opacity(0.9)
            }

            Spacer()
        }
        .padding()
        .foregroundColor(.white)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.90))
                .shadow(color: .black.opacity(0.18), radius: 10, x: 0, y: 6)
        )
    }

    private var intervalCard: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Spacer()
                Text("Identify the interval")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
            }

            let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(intervals, id: \.semitones) { item in
                    intervalButton(title: item.short, subtitle: item.name) {
                        evaluateGuess(guessedSemitones: item.semitones)
                    }
                    .disabled(answeredThisRound)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.20))
                .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
    }

    private var transportButtons: some View {
        HStack(spacing: 30) {

            circleIconButton(systemName: "arrow.clockwise") {
                replayNotes()
            }

            circleIconButton(systemName: "play.fill") {
                playNotes()
            }
        }
        .padding(.top, 8)
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Streak")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)

                Spacer()

                Text("\(streak) / \(streakGoal)")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
            }

            ProgressView(value: progress)
                .tint(.white)
                .scaleEffect(x: 1, y: 2)
                .animation(.easeInOut, value: streak)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.18))
                .shadow(color: .black.opacity(0.10), radius: 12, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.16), lineWidth: 1)
        )
    }
}

// b uttons
extension TrainingView {

    private func circleIconButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(Color(.systemOrange))
                        .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 6)
                )
        }
        .buttonStyle(.plain)
    }

    private func intervalButton(title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                Text(subtitle)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .opacity(0.85)
            }
            .frame(maxWidth: .infinity, minHeight: 54)
            .foregroundColor(.black)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemOrange))
                    .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Game Logic
extension TrainingView {

    private func evaluateGuess(guessedSemitones: Int) {

        guard !answeredThisRound else { return }
        answeredThisRound = true

        if currentInterval == guessedSemitones {
            result = .correct
            streak += 1

            if streak >= streakGoal {
                triggerCongrats()
            }
        } else {
            result = .wrong
            streak = 0
        }
    }

    private func triggerCongrats() {
        showCongrats = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            streak = 0
            showCongrats = false
        }
    }

    func playNotes() {
        result = .none
        answeredThisRound = false

        noteEngine.pickTwoRandomNotes()
        noteOne = noteEngine.firstNote
        noteTwo = noteEngine.secondNote
        noteEngine.playTwoSequential(noteOne, noteTwo)
    }

    func replayNotes() {
        noteEngine.playTwoSequential(noteOne, noteTwo)
    }
}

// Win streak message
struct CongratsOverlay: View {

    @State private var pop = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.25).ignoresSafeArea()

            ConfettiView()

            Text("Streak Complete! 🎉")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 8)
                )
                .scaleEffect(pop ? 1 : 0.6)
                .opacity(pop ? 1 : 0)
                .onAppear {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        pop = true
                    }
                }
        }
    }
}

struct ConfettiView: View {

    @State private var animate = false

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<20, id: \.self) { _ in
                Text(["🎉","✨","🎊","⭐️"].randomElement()!)
                    .font(.system(size: CGFloat.random(in: 18...28)))
                    .position(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: animate ? geo.size.height + 40 : -40
                    )
                    .animation(.easeIn(duration: Double.random(in: 1...1.6)), value: animate)
            }
        }
        .onAppear { animate = true }
        .ignoresSafeArea()
    }
}

#Preview {
    TrainingView(route: .constant(.classic))
}
