//
//  MusicSequence.swift
//  MidiPlayer
//
//  Created by Dariusz Zabrzeński on 06/08/2023.
//

import AVFoundation


class Song {
    var musicSequence: MusicSequence?
    var tracks: [Int: MusicTrack] = [:]
    
    init() {
        guard NewMusicSequence(&musicSequence) == OSStatus(noErr) else {
            fatalError("Cannot create MusicSequence")
        }
    }
    
    func addTrack(instrumentId: UInt8) -> Int {
        var track: MusicTrack?
        
        guard MusicSequenceNewTrack(musicSequence!, &track) == OSStatus(noErr) else {
            fatalError("Cannot add track")
        }
        
        let trackId = tracks.count
        tracks[trackId] = track
        
        var inMessage = MIDIChannelMessage(status: 0xC0, data1: instrumentId, data2: 0, reserved: 0)
        MusicTrackNewMIDIChannelEvent(track!, 0, &inMessage)
        
        return trackId
    }
    
    func setTempo(tempo: Float64) {
        let timeStamp = MusicTimeStamp(0)
        var tempoTrack: MusicTrack?
        MusicSequenceGetTempoTrack(musicSequence! ,&tempoTrack);
        
        removeTempoEvents(tempoTrack: tempoTrack!)
        
        MusicTrackNewExtendedTempoEvent(tempoTrack!, timeStamp, tempo)
    }
    
    func addNote(trackId: Int, note: UInt8, duration: Float, position: Float) {
        let time = MusicTimeStamp(position)
        
        var musicNote = MIDINoteMessage(channel: 0,
                                        note: note,
                                        velocity: 64,
                                        releaseVelocity: 0,
                                        duration: duration)
        guard MusicTrackNewMIDINoteEvent(tracks[trackId]!, time, &musicNote) == OSStatus(noErr) else {
            fatalError("Cannot add Note")
        }
        
    }
    
    private func removeTempoEvents(tempoTrack: MusicTrack){
        var tempIter: MusicEventIterator?
        NewMusicEventIterator(tempoTrack, &tempIter);
        var hasEvent: DarwinBoolean = false
        MusicEventIteratorHasCurrentEvent(tempIter!, &hasEvent)
        while (hasEvent == true) {
            var stamp = MusicTimeStamp(0)
            var type:MusicEventType = 0
            var data: UnsafeRawPointer? = nil
            var sizeData: UInt32 = 0
            
            MusicEventIteratorGetEventInfo(tempIter!, &stamp, &type, &data, &sizeData);
            if (type == kMusicEventType_ExtendedTempo){
                MusicEventIteratorDeleteEvent(tempIter!);
                MusicEventIteratorHasCurrentEvent(tempIter!, &hasEvent)
            }
            else{
                MusicEventIteratorNextEvent(tempIter!)
                MusicEventIteratorHasCurrentEvent(tempIter!, &hasEvent)
            }
        }
        DisposeMusicEventIterator(tempIter!)
    }
}
