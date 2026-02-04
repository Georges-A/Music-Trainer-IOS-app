//
//  ContentView.swift
//  Music Trainer
//
//  Created by Georges Ataya on 2/4/26.
//

import SwiftUI

struct ContentView: View {
    @State private var isClicked = false
    
    var body: some View {
        if (isClicked){
            TrainingView()
        } else{
            ZStack{
                Color(.systemCyan).ignoresSafeArea()
                VStack{
                    Text("   Ear\nTrainer")
                        .font(.custom("Futura-Bold", size: 34, relativeTo: .largeTitle))
                        .padding(70)
                    
                    Spacer()
                    Button(
                        action: {isClicked=true}
                    ) {
                        Text("Start")
                            .font(.title)
                            .bold()
                            .foregroundColor(.black)
                            .padding(20)
                            .background(Rectangle().fill(Color(.systemOrange)).cornerRadius(10.0))
                        
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
