//
//  Triad.swift
//  ChordRecognizeGenerate
//
//  Created by Derrick Ward on 1/2/20.
//  Copyright © 2020 Derrick Ward. All rights reserved.
//

import Foundation

@objc public class Triad : NSObject, NSSecureCoding
{
    enum Required
    {
        case Third, Fifth
    }
    
    public static var supportsSecureCoding = true
    public var third : NoteRootOffset
    public var fifth : NoteRootOffset
    public var quality : Quality
    public var requiredNote : NoteRootOffset
    
    override init()
    {
        third = 3
        fifth = 5
        quality = Quality.Maj
        requiredNote = 3
        super.init()
    }
    
    init(third : NoteRootOffset, fifth : NoteRootOffset, required : NoteRootOffset,quality : Quality)
    {
        self.third = third
        self.fifth = fifth
        self.quality = quality
        self.requiredNote = required
    }
    
    public required init?(coder: NSCoder) {
       
        third = NoteRootOffset(coder.decodeInteger(forKey: "third"))
        fifth = NoteRootOffset(coder.decodeInteger(forKey: "fifth"))
        quality = Quality(rawValue: Int(coder.decodeInt32(forKey: "quality")))!
        requiredNote = NoteRootOffset(coder.decodeInteger(forKey: "requiredNote"))
        super.init()
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(Int(third), forKey: "third")
        coder.encode(Int(fifth), forKey: "fifth")
        coder.encode(quality.rawValue, forKey: "quality")
        coder.encode(Int(requiredNote), forKey: "requiredNote")
    }
    
    func addNotes(chordNotes : inout [NoteRootOffset], inversion : Inversion)
    {
        var notes = [third,fifth]
        Triad.invert(notes: &notes, inversion: inversion)
        chordNotes.append(contentsOf: notes)
    }
    
    func isSuspended() -> Bool
    {
        return quality == Quality.sus2 || quality == Quality.sus4
    }
    
    func matchesNote(note : ChordNote) -> Bool
    {
        return self.third == note || self.fifth == note
    }
    
    static func extractTriadNotes(rootIdx: Int, notes : [ChordNote]) -> [NoteRootOffset : Int]
    {
        var triadNotes = [NoteRootOffset : Int]()
        let baseNote = notes[rootIdx]
        for i in 0..<notes.count
        {
            let noteOffset = ChordDefs.offsetInChord(rootNote: baseNote, note: notes[i])
            
            if noteOffset == 0 && triadNotes[0] == nil
            {
                triadNotes[0] = i
                continue
            }
            
            if noteOffset >= 2 && noteOffset <= 8
            {
                triadNotes[noteOffset] = i
            }
        }
        
        return triadNotes
    }
    
    func matches(notes : [ChordNote], triadNotes: [NoteRootOffset : Int]) -> TriadMatch
    {
        let result = TriadMatch()
        result.triadType = self.quality
        result.triad = self
        result.rootIdx = triadNotes[0]!
        
        let rootNote = notes[triadNotes[0]!]
        
        if let _ = triadNotes[requiredNote]
        {
            if let fifthNoteIdx = triadNotes[fifth]
            {
                let fifthNote = notes[fifthNoteIdx]
                addNoteToTriadMatch(rootNote: rootNote, note: fifthNote, offset: fifth, result: result)
            }
            else
            {
                if let sharpFifthIdx = triadNotes[ChordDefs.sharpFifth]
                {
                    let fifthNote = notes[sharpFifthIdx]
                    result.alteredFifth = fifthNote
                    result.alteredFifthSign = Sign.sharp
                    
                    addNoteToTriadMatch(rootNote: rootNote, note: fifthNote, offset: ChordDefs.sharpFifth, result: result)
                }
                else if let flatFifthIdx = triadNotes[ChordDefs.flatFifth]
                {
                     let fifthNote = notes[flatFifthIdx]
                     result.alteredFifth = fifthNote
                     result.alteredFifthSign = Sign.flat
                      addNoteToTriadMatch(rootNote: rootNote, note: fifthNote, offset: ChordDefs.flatFifth, result: result)
                }
                else
                {
                    result.omission = Degree.five
                }
            }
            
            if let thirdNoteIdx = triadNotes[third]
            {
                let thirdNote = notes[thirdNoteIdx]
                addNoteToTriadMatch(rootNote: rootNote, note: thirdNote, offset: third, result: result)
            }
            else
            {
                result.omission = Degree.three
            }
            
        }
        
        for note in notes
        {
            if !result.triadNotes.contains(note) && abs(Int8(note) - Int8(rootNote)) % 12 != 0
            {
                result.nonTriadNotes.append(note)
            }
        }
        
        return result
    }
    
    func addNoteToTriadMatch(rootNote: ChordNote, note: ChordNote, offset : NoteRootOffset,result : TriadMatch)
    {
        result.triadNotes.append(note)
        
        if note < rootNote
        {
            result.invertedNotes.append(note)
            result.inversion = offset == third ? Inversion.first : Inversion.second
        }
    }
    
    private func isAlternateFifth(offset: NoteRootOffset) -> Bool
    {
        return offset == ChordDefs.flatFifth || offset == ChordDefs.sharpFifth
    }
    
    public static func invert(notes: inout [NoteRootOffset], inversion: Inversion)
    {
            switch inversion {
            case .first:
                notes[0] -= 12
            case .second:
                notes[1] -= 12
            default:
                print("default")
            }
    }
}

public class TriadMatch
{
    var nonTriadNotes = [ChordNote]()
    var invertedNotes = [ChordNote]()
    var omission : Degree?
    var triadNotes = [ChordNote]()
    weak var triad : Triad!
    var rootIdx : Int = 0
    var triadType = Quality.Maj
    var alteredFifth : ChordNote?
    var alteredFifthSign : Sign = Sign.natural
    var inversion = Inversion.none
    public var isHalfDiminished = false
    
    func getScore() -> Int
    {
        if triadNotes.count == 0
        {
            return 0
        }
        else
        {
            let score = triadNotes.count - rootIdx
                - (alteredFifth == nil ? 0 : 1)
        
            return score
        }
        
    }
}

