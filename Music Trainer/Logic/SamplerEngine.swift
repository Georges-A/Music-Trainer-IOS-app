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
    
    @Published var firstNote:UInt8 = 60;
    @Published var secondNote:UInt8 = 60;

    init() {
        setupAudioSession()
        setupEngine()
        loadPianoSound()
    }

    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default)
        try? session.setActive(true)
    }

    private func setupEngine() {
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
        try? engine.start()
    }
    
    private func loadPianoSound() {
        if let bankURL = Bundle.main.url(forResource: "gs_instruments", withExtension: "dls") {
            try? sampler.loadSoundBankInstrument(
                at: bankURL,
                program: 1,
                bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                bankLSB: UInt8(kAUSampler_DefaultBankLSB)
            )
        }
    }
    
    func play(note: UInt8, duration: Double = 1.0) {
        sampler.startNote(note, withVelocity: 50, onChannel: 0)

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.sampler.stopNote(note, onChannel: 0)
        }
    }

    func playTwoSequential(_ a: UInt8, _ b: UInt8) {
        play(note: a)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.play(note: b)
        }
    }
    
    // Range of first note 50-70
    func pickTwoRandomNotes() {
        firstNote = UInt8.random(in: 50...70)
        secondNote = firstNote + UInt8.random(in: 1...12)
    }

}

