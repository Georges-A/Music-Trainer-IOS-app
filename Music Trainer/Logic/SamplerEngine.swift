//
//  SamplerEngine.swift
//  Music Trainer
//
//  Created by Georges Ataya on 2/5/26.
//

import Foundation
import AVFoundation
import Combine

final class SamplerEngine: ObservableObject {

    private let engine = AVAudioEngine()
    private let sampler = AVAudioUnitSampler()

    @Published var firstNote: UInt8 = 60
    @Published var secondNote: UInt8 = 60

    // Tweakable values :))
    private let defaultVelocity: UInt8 = 96
    private let defaultDuration: Double = 1.0

    init() {
        setupAudioSession()
        setupEngine()
        loadBestAvailablePiano()
    }

    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }

    private func setupEngine() {
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)

        engine.mainMixerNode.outputVolume = 1.0

        do {
            try engine.start()
        } catch {
            print("Engine start error: \(error)")
        }
    }

    // MARK: - Sound Loading

    private func loadBestAvailablePiano() {
        if loadSoundFontIfExists(resource: "Piano", ext: "sf2", program: 0) {
            print("✅ Loaded bundled Piano.sf2")
            return
        }

        if loadSoundFontIfExists(resource: "piano", ext: "sf2", program: 0) {
            print("✅ Loaded bundled piano.sf2")
            return
        }

        if loadDLSIfExists(resource: "gs_instruments", ext: "dls", program: 0) {
            print("✅ Loaded bundled gs_instruments.dls (program 0)")
            return
        }

        let possibleSystemPaths: [String] = [
            "/System/Library/Components/CoreAudio.component/Contents/Resources/gs_instruments.dls", // macOS
            "/System/Library/Audio/Components/CoreAudio.component/Contents/Resources/gs_instruments.dls" // some setups
        ]

        for path in possibleSystemPaths {
            let url = URL(fileURLWithPath: path)
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    try sampler.loadSoundBankInstrument(
                        at: url,
                        program: 0,
                        bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                        bankLSB: UInt8(kAUSampler_DefaultBankLSB)
                    )
                    print("Loaded system gs_instruments.dls from \(path)")
                    return
                } catch {
                    print("Failed loading system DLS at \(path): \(error)")
                }
            }
        }
    }

    private func loadSoundFontIfExists(resource: String, ext: String, program: UInt8) -> Bool {
        guard let url = Bundle.main.url(forResource: resource, withExtension: ext) else { return false }
        do {
            try sampler.loadSoundBankInstrument(
                at: url,
                program: program,
                bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                bankLSB: UInt8(kAUSampler_DefaultBankLSB)
            )
            return true
        } catch {
            print("Failed loading \(resource).\(ext): \(error)")
            return false
        }
    }

    private func loadDLSIfExists(resource: String, ext: String, program: UInt8) -> Bool {
        guard let url = Bundle.main.url(forResource: resource, withExtension: ext) else { return false }
        do {
            try sampler.loadSoundBankInstrument(
                at: url,
                program: program,
                bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                bankLSB: UInt8(kAUSampler_DefaultBankLSB)
            )
            return true
        } catch {
            print("Failed loading \(resource).\(ext): \(error)")
            return false
        }
    }

    // MARK: - Playback (same API)

    func play(note: UInt8, duration: Double = 1.0) {
        play(note: note, duration: duration, velocity: defaultVelocity)
    }

    private func play(note: UInt8, duration: Double, velocity: UInt8) {
        sampler.startNote(note, withVelocity: velocity, onChannel: 0)

        DispatchQueue.main.asyncAfter(deadline: .now() + max(0.01, duration)) { [weak self] in
            self?.sampler.stopNote(note, onChannel: 0)
        }
    }

    func playTwoSequential(_ a: UInt8, _ b: UInt8) {
        play(note: a, duration: defaultDuration)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.play(note: b, duration: self?.defaultDuration ?? 1.0)
        }
    }

    // Range of first note 50-70
    func pickTwoRandomNotes() {
        firstNote = UInt8.random(in: 50...70)
        secondNote = firstNote &+ UInt8.random(in: 1...12)
    }
}
