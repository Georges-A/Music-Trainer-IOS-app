//
//  TrainingView.swift
//  Music Trainer
//
//  Created by Georges Ataya on 2/4/26.
//

import SwiftUI

struct TrainingView: View {
    
    @StateObject var noteEngine = SamplerEngine();
    @State var noteOne: UInt8 = 60;
    @State var noteTwo: UInt8 = 60;
    
    @State var correctSegment = false;
    @State var displayCorrectness = false;
    
    @State var progressBar = 0.0;
    
    var body: some View {
        ZStack{
            Color(.systemCyan).ignoresSafeArea()
            VStack{
                
                if (displayCorrectness == true){
                    if (correctSegment == false) {
                        Image(systemName: "xmark")
                        Text("Sorry :((\nIt was \(noteTwo - noteOne) semitones...")
                    } else {
                        Image(systemName: "eyes")
                        Text("Congrats!\nIt was \(noteTwo - noteOne) semitones!")
                    }
                }
                
                
                Spacer()
                //circleIconButton(systemName: "music.note"){}
                HStack(){
                    rectIconButton(text: "First Half \n 1-6 Semitones"){
                        displayCorrectness = true;
                        if (noteTwo - noteOne <= 6){
                            correctSegment = true;
                            progressBar += 0.1;
                        } else {
                            correctSegment = false;
                            progressBar = 0.0;
                        }
                    }
                    rectIconButton(text: "Second Half \n 7-12 Semitones"){
                        displayCorrectness = true;
                        if (noteTwo - noteOne >= 7){
                            correctSegment = true;
                            progressBar += 0.1;
                        } else {
                            correctSegment = false;
                            progressBar = 0.0;
                        }
                    }
                }.padding(5)
                
                HStack(spacing: 40) {
                    circleIconButton(systemName: "arrow.trianglehead.2.counterclockwise.rotate.90") {
                        replayNotes()
                    }
                    
                    circleIconButton(systemName: "play.fill") {
                        playNotes()
                    }
                }
                Spacer()
                ProgressView(value: progressBar).progressViewStyle(.automatic)
                
            }.padding(20)
        }
        
    }
}

extension TrainingView {
    
    private func circleIconButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title2)
                .foregroundColor(.blue)
                .padding(15)
                .background(Circle().fill(Color(.systemOrange)))
        }
        .buttonStyle(.plain)
    }
    
    private func rectIconButton(text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .font(.title2)
                .foregroundColor(.black)
                .padding(5)
                .background(Rectangle().fill(Color(.systemOrange)).cornerRadius(10.0))
            
        }
        .buttonStyle(.plain)
    }
}

extension TrainingView {
    func playNotes() {
        displayCorrectness = false;
        noteEngine.pickTwoRandomNotes()
        noteOne = noteEngine.firstNote;
        noteTwo = noteEngine.secondNote;
        noteEngine.playTwoSequential(noteOne, noteTwo)
    }
    
    func replayNotes() {
        noteEngine.playTwoSequential(noteOne, noteTwo)
    }
}

#Preview {
    TrainingView()
}
