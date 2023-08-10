//
//  MidiPlayer.swift
//  MidiPlayer
//
//  Created by Dariusz Zabrzeński on 06/08/2023.
//

import AVFoundation


class MidiPlayer {
    var midiPlayer: AVMIDIPlayer?
    var bankURL: URL
    
    init() {
        guard let bankURL = Bundle.main.url(forResource: "Nokia_Tongbao_Bank__Series_30__8-bit", withExtension: "sf2") else {
            fatalError("\"Nokia_Tongbao_Bank__Series_30__8-bit.sf2\" file not found.")
        }
        self.bankURL = bankURL
        
        var array: Unmanaged<CFArray>?;
        CopyInstrumentInfoFromSoundBank(self.bankURL as CFURL, &array)
    }
    
    func prepareSong(song: Song){
        var data: Unmanaged<CFData>?
        guard MusicSequenceFileCreateData(song.musicSequence!,
                                          MusicSequenceFileTypeID.midiType,
                                          MusicSequenceFileFlags.eraseFile,
                                          480, &data) == OSStatus(noErr) else {
            fatalError("Cannot create music midi data")
        }
        
        if let md = data {
            let midiData = md.takeUnretainedValue() as Data
            do {
                try self.midiPlayer = AVMIDIPlayer(data: midiData, soundBankURL: self.bankURL)
            } catch let error {
                fatalError(error.localizedDescription)
            }
        }
        self.midiPlayer!.prepareToPlay()
    }
    
    func playSong() async {
        if let md = self.midiPlayer {
            md.currentPosition = 0
            await md.play()
        }
    }
}
