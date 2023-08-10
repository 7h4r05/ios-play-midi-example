//
//  ContentView.swift
//  MidiPlayer
//
//  Created by Dariusz Zabrzeński on 06/08/2023.
//

import SwiftUI
import AVFoundation


struct ContentView: View {
    let player = MidiPlayer()
    var body: some View {
        VStack {
            Button("Play audio", action: {
                let composer = SongComposer()
                let song = composer.compose()
                
                let player = MidiPlayer()
                player.prepareSong(song: song)
                
                Task {
                    await player.playSong()
                }
            })
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
