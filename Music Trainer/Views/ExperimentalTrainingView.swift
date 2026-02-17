//
//  ExperimentalTrainingView.swift
//  Music Trainer
//

import SwiftUI

struct ExperimentalTrainingView: View {

    @StateObject var noteEngine = SamplerEngine()

    @State private var noteOne: UInt8 = 60
    @State private var noteTwo: UInt8 = 60

    enum ResultState { case none, correct, wrong }
    @State private var result: ResultState = .none

    @State private var streak: Int = 0
    private let streakGoal: Int = 10

    @State private var showCongrats = false

    // Background motion (to match homepage)
    @State private var animateBG = false

    // Progression stages
    enum Stage { case half, third, exact }
    @State private var stage: Stage = .half

    // We lock input briefly after a tap to avoid double firing during animations
    @State private var inputLocked: Bool = false

    // Which group we are currently inside (used to render next stage)
    @State private var chosenHalf: ClosedRange<Int>? = nil       // 1...6 or 7...12
    @State private var chosenThird: ClosedRange<Int>? = nil      // 1...3, 4...6, 7...9, 10...12

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
    
    private var canStartNewRound: Bool {
        stage == .half && !inputLocked && !showCongrats
    }

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

                feedbackBanner

                Spacer()

                stageCard

                transportButtons

                Spacer()

                progressCard
            }
            .padding(20)
        }
        .overlay {
            if showCongrats {
                ExperimentalCongratsOverlay()
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                animateBG = true
            }
        }
    }
}

// MARK: - UI
extension ExperimentalTrainingView {

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

    // The main card that morphs through stages
    private var stageCard: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Spacer()
                Text("Identify the interval")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
            }

            Group {
                switch stage {
                case .half:
                    halfStageView
                        .transition(.opacity.combined(with: .scale))

                case .third:
                    thirdStageView
                        .transition(.opacity.combined(with: .scale))

                case .exact:
                    exactStageView
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: stage)
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

    // Stage 1: 1–6 vs 7–12
    private var halfStageView: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)

        return LazyVGrid(columns: columns, spacing: 12) {
            bigRangeButton(title: "1–6", subtitle: "Lower half") {
                handleHalfPick(range: 1...6)
            }
            .disabled(inputLocked)

            bigRangeButton(title: "7–12", subtitle: "Upper half") {
                handleHalfPick(range: 7...12)
            }
            .disabled(inputLocked)
        }
        .padding(.top, 4)
    }

    // Stage 2: 3/3 split inside the correct half
    private var thirdStageView: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)

        let a: ClosedRange<Int>
        let b: ClosedRange<Int>

        if chosenHalf == (1...6) {
            a = 1...3
            b = 4...6
        } else {
            a = 7...9
            b = 10...12
        }

        return LazyVGrid(columns: columns, spacing: 12) {
            bigRangeButton(title: "\(a.lowerBound)–\(a.upperBound)", subtitle: "Group A") {
                handleThirdPick(range: a)
            }
            .disabled(inputLocked)

            bigRangeButton(title: "\(b.lowerBound)–\(b.upperBound)", subtitle: "Group B") {
                handleThirdPick(range: b)
            }
            .disabled(inputLocked)
        }
        .padding(.top, 4)
    }

    // Stage 3: Exact interval (3 options)
    private var exactStageView: some View {
        let options = intervalsForChosenThird()

        let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(options, id: \.semitones) { item in
                intervalButton(title: item.short, subtitle: item.name) {
                    handleExactPick(semitones: item.semitones)
                }
                .disabled(inputLocked)
            }
        }
        .padding(.top, 4)
    }

    private var transportButtons: some View {
        HStack(spacing: 30) {

            circleIconButton(systemName: "arrow.clockwise") {
                replayNotes()
            }

            circleIconButton(systemName: "play.fill") {
                playNotes()
            }
            .disabled(!canStartNewRound)
            .opacity(canStartNewRound ? 1.0 : 0.45)
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

// MARK: - Buttons
extension ExperimentalTrainingView {

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

    // Big blocks for Stage 1 and 2
    private func bigRangeButton(title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                Text(subtitle)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .opacity(0.9)
            }
            .frame(maxWidth: .infinity, minHeight: 110)
            .foregroundColor(.black)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemOrange))
                    .shadow(color: .black.opacity(0.16), radius: 8, x: 0, y: 6)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Game Logic (3-stage)
extension ExperimentalTrainingView {

    private func lockInputBriefly() {
        inputLocked = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            inputLocked = false
        }
    }

    // Stage 1
    private func handleHalfPick(range: ClosedRange<Int>) {
        guard !inputLocked else { return }
        lockInputBriefly()

        if range.contains(currentInterval) {
            chosenHalf = range
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                result = .correct
                stage = .third
            }
        } else {
            wrongReset()
        }
    }

    // Stage 2
    private func handleThirdPick(range: ClosedRange<Int>) {
        guard !inputLocked else { return }
        lockInputBriefly()

        if range.contains(currentInterval) {
            chosenThird = range
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                result = .correct
                stage = .exact
            }
        } else {
            wrongReset()
        }
    }

    // Stage 3 (only here do we increment streak)
    private func handleExactPick(semitones: Int) {
        guard !inputLocked else { return }
        lockInputBriefly()

        if currentInterval == semitones {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                result = .correct
                streak += 1
            }

            if streak >= streakGoal {
                triggerCongrats()
            }

            // Start a new round after a short pause
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                startNewRound()
            }
        } else {
            wrongReset()
        }
    }

    private func wrongReset() {
        withAnimation(.easeInOut(duration: 0.2)) {
            result = .wrong
        }

        // Reset streak & return to stage 1
        streak = 0

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                stage = .half
                chosenHalf = nil
                chosenThird = nil
                result = .none
            }
        }
    }

    private func startNewRound() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            stage = .half
            chosenHalf = nil
            chosenThird = nil
            result = .none
        }
        playNotes()
    }

    private func intervalsForChosenThird() -> [(semitones: Int, name: String, short: String)] {
        guard let r = chosenThird else { return [] }
        return intervals.filter { r.contains($0.semitones) }
    }

    private func triggerCongrats() {
        showCongrats = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            streak = 0
            showCongrats = false
            startNewRound()
        }
    }

    // Audio
    func playNotes() {
        result = .none

        noteEngine.pickTwoRandomNotes()
        noteOne = noteEngine.firstNote
        noteTwo = noteEngine.secondNote
        noteEngine.playTwoSequential(noteOne, noteTwo)
    }

    func replayNotes() {
        noteEngine.playTwoSequential(noteOne, noteTwo)
    }
}

// MARK: - Congrats Overlay (unique names to avoid collisions)
struct ExperimentalCongratsOverlay: View {

    @State private var pop = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.25).ignoresSafeArea()

            ExperimentalConfettiView()

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

struct ExperimentalConfettiView: View {

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
    ExperimentalTrainingView()
}
