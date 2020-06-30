//
//  ChordGenerator.swift
//  ChordRecognizeGenerate
//
//  Created by Derrick Ward on 12/20/19.
//  Copyright © 2019 Derrick Ward. All rights reserved.
//

import Foundation

@objc public class ChordGenerator : NSObject
{
    
    public override init() {}
    
    @objc public func chordToMIDINotes(chord: Chord) -> [ChordNote]
    {
        var chordNotes = [NoteRootOffset]()
        
        switch chord.quality
        {
            case Quality.Maj:
                ChordDefs.majTriad.addNotes(chordNotes: &chordNotes,inversion: chord.inversion)
                chord.addNotesFromOffsets(offsets: chordNotes)
                chord.triad = ChordDefs.majTriad
            case Quality.min:
                ChordDefs.minTriad.addNotes(chordNotes: &chordNotes,inversion: chord.inversion)
                chord.addNotesFromOffsets(offsets: chordNotes)
                chord.triad = ChordDefs.minTriad
            case Quality.aug:
                ChordDefs.augTriad.addNotes(chordNotes: &chordNotes,inversion: chord.inversion)
                chord.addNotesFromOffsets(offsets: chordNotes)
                chord.triad = ChordDefs.augTriad
            case Quality.dim:
                 ChordDefs.dimTriad.addNotes(chordNotes: &chordNotes,inversion: chord.inversion)
                 chord.addNotesFromOffsets(offsets:chordNotes)
                 chord.triad = ChordDefs.dimTriad
            case Quality.sus2:
                ChordDefs.sus2Triad.addNotes(chordNotes: &chordNotes,inversion: chord.inversion)
                chord.addNotesFromOffsets(offsets: chordNotes)
                chord.triad = ChordDefs.sus2Triad
            case Quality.sus4:
                ChordDefs.sus4Triad.addNotes(chordNotes: &chordNotes,inversion: chord.inversion)
                chord.addNotesFromOffsets(offsets: chordNotes)
                chord.triad = ChordDefs.sus4Triad
            default:
                ChordDefs.majTriad.addNotes(chordNotes: &chordNotes,inversion: chord.inversion)
                chord.addNotesFromOffsets(offsets: chordNotes)
                chord.triad = ChordDefs.majTriad
        }
        
        parseFactors(chord: chord)
               parseAlterations(chord: chord)
        parseAdditions(chord: chord)
        
        if chord.ommission != nil
        {
            let ommissionOffset = chord.ommission! == Degree.five ? chord.triad.fifth : chord.triad.third
            let note : ChordNote = chord.rootNote! + ChordNote(ommissionOffset)
            chord.notes.removeAll(where: { $0 == note })
        }
        
        let adjustedRoot = chord.inversion != .none ? chord.rootNote! + 12 : chord.rootNote!
        
        chord.notes.forEach({
            if $0 < adjustedRoot
            {
                chord.invertedNotes.append($0)
            }
        })
        
        return chord.notes
    }
    
    private func parseAdditions(chord: Chord)
    {
        chord.additions.forEach({ chord.notes.append($0.toNote(root: chord.rootNote!)) })
    }
    
    private func parseFactors(chord : Chord)
    {
        let tones = chord.factors
        let seventhOffsetVal = seventhOffset(chordQuality: chord.quality, factorQuality: chord.factorQuality)
        
        for tone in tones
        {
            var offsets = [NoteRootOffset]()
            //special case for "sixth" chords
            if tone.degree == Degree.six || tone.degree == Degree.sixNine
            {
                let extOffsets = ChordDefs.sixthChordDesignatorToOffset(designator: tone.degree)
                offsets.append(contentsOf: extOffsets)
                chord.addNotesFromOffsets(offsets: offsets)
                continue
            }
            
            let sigOffset = ChordDefs.signatureOffset(designators: tone.signs)
            guard let extensionOffset = ChordDefs.degreeToOffset[tone.degree] else { return }
            
            let degreeInScale = ChordDefs.offsetToMajDegree[Int(extensionOffset)].degree
            let numberDegreeInScale = degreeInScale.toNumber()
            if numberDegreeInScale >= 7 && numberDegreeInScale % 2 == 1
            {
                offsets.append(ChordDefs.majScaleToOffset[7] + seventhOffsetVal)
                
                for note in stride(from: 9, through: numberDegreeInScale, by: 2)
                {
                    offsets.append(ChordDefs.majScaleToOffset[Int(note)] + (note == numberDegreeInScale ? sigOffset : 0))
                }
            }
            
            chord.addNotesFromOffsets(offsets: offsets)
        }
    }
    
    private func parseAlterations(chord : Chord)
    {
        if chord.alteredNotes.count > 0
        {
            var idx = 0
            var alteredTone = chord.alteredNotes[0]
            for j in 0..<chord.notes.count
            {
                var note = chord.notes[j]
                let offset = ChordDefs.offsetInExtendedChord(rootNote: chord.rootNote!,note: note)
                let degree = ChordDefs.offsetToMajDegree[Int(offset)].degree
                if degree == alteredTone.degree
                {
                    note = ChordNote(Int8(note) + ChordDefs.signatureOffset(designators: alteredTone.signs))
                    chord.notes[j] = note
                    idx += 1
                    if idx < chord.alteredNotes.count
                    {
                        alteredTone = chord.alteredNotes[idx]
                    }
                }
            }
        }
    }
    
    private func seventhOffset(chordQuality: Quality, factorQuality : Quality) -> Int8
    {
        var offset : Int8 = -1
        
        if chordQuality == Quality.dim
        {
            offset = -2
        }
        
        switch factorQuality {
            case Quality.Maj:
                offset = 0
            //case Designator.dom:
            case Quality.halfDim:
                offset = -1
           // case Designator.min:
            //case Designator.aug:
            default:
                print("none")
        }
        
        return offset
    }

}
