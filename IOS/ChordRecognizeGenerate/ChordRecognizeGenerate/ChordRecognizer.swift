//
//  ChordRecognizer.swift
//  ChordRecognizeGenerate
//
//  Created by Derrick Ward on 12/20/19.
//  Copyright © 2019 Derrick Ward. All rights reserved.
//

import Foundation

@objc public class ChordRecognizer : NSObject
{
    private var matches = [TriadMatch]()
    
    public override init() {}
    
    @objc public func notesToChord(midiNoteValues : [ChordNote]) -> [ChordGroup]
    {
        if midiNoteValues.count < 2
        {
            return []
        }
        
        var chordGroups = [ChordGroup]()
        let notes = midiNoteValues.sorted(by: { $0 < $1 })
        
        if notes.count == 2
        {
            let chordGroup = ChordGroup()
            let chord = Chord(notes: notes)
            chord.rootNote = notes[0]
            chordGroup.add(newChord: chord)
            chordGroups.append(chordGroup)
            return chordGroups
        }
        
        var bestMatches = [TriadMatch]()
        
        matches.removeAll()
    
        findTriad(notes: notes)
        
        for match in matches
        {
            if match.getScore() > 0
            {
                //print("chord: \(match.getName()) score: \(match.getScore())")
                bestMatches.append(match)
            }
        }
        
        for triad in bestMatches
        {
            let chords = ChordGroup()
            let chord = Chord(notes: notes, triadResult: triad)
            
            // inversions and slash chords
            for note in triad.nonTriadNotes
            {
                if note < chord.rootNote!
                {
                    chord.invertedNotes.append(note)
                }
            }
            
            //print("match ",chord.getRootName(),triad.getScore())
            
            findFactors(chord: chord, triad: triad)
            chords.chords.append(chord)
            
            let polyChords = notesToChord(midiNoteValues: triad.nonTriadNotes)
            if polyChords.count > 0
            {
                let polyChordGroup = polyChords.first!
                let polyChord = polyChordGroup.chords.first!
                
                if !polyChord.isDyad()
                {
                    chords.add(newChord: polyChord)
                    triad.nonTriadNotes.removeAll(where: { polyChord.notes.contains($0) })
                }
            }
            
            triad.nonTriadNotes.removeAll(where: { chord.invertedNotes.contains($0) })
            
            findAddedNotes(chord: chord, notes: triad.nonTriadNotes)
            //print("inversion: \(chord.inversion.rawValue)")
            chordGroups.append(chords)
        }
        
        var bestGroups = [ChordGroup]()
        for group in chordGroups
        {
            //print(group.getFullName() + " value: ",group.getScore())
            let firstMatch = bestGroups.first
            if bestGroups.count == 0 || group.getScore() == firstMatch!.getScore()
            {
                bestGroups.append(group)
            }
            else if group.getScore() > firstMatch!.getScore()
            {
                //print("new best ",group.getFullName(),group.getScore())
                bestGroups.removeAll()
                bestGroups.append(group)
            }
        }
        
        return bestGroups
    }
    
    private func findFactors(chord: Chord, triad: TriadMatch)
    {
        // stack of thirds
        var numberDegreeInScale : UInt8 = 7
        var lastDegreeInChord = Degree.none
        var notesMatched = [ChordNote]()
        var i = 0
        var seventhChordType = Quality.dom
        var alteredDesignators = [Tone]()
        var seventhChordDesignator : Tone?
        
        while i < triad.nonTriadNotes.count && numberDegreeInScale <= 13
        {
            let note = triad.nonTriadNotes[i]
            let noteOffset = ChordDefs.offsetInExtendedChord(rootNote: chord.rootNote!, note: note)
            let noteInScaleInfo = ChordDefs.offsetToMajDegree(quality: chord.quality, offset: noteOffset)
            let degreeInScale = Degree.numberToDegree(number: numberDegreeInScale)
            
            i += 1
            
            if noteInScaleInfo.degree == degreeInScale
            {
                if noteInScaleInfo.degree == Degree.seven
                {
                    seventhChordType = ChordDefs.seventhNoteToDesignator(quality: chord.quality ,sign: noteInScaleInfo.sign)
                    seventhChordDesignator = Tone(degree: degreeInScale)
                    chord.inversion = note < chord.rootNote!
                        && chord.inversion == Inversion.none ? Inversion.third : chord.inversion
                }
                else if noteInScaleInfo.sign != Sign.natural
                {
                    alteredDesignators.append(Tone(signs: [noteInScaleInfo.sign],degree: degreeInScale))
                }
                else
                {
                    lastDegreeInChord = degreeInScale
                }
                
                notesMatched.append(note)
                numberDegreeInScale += 2
            }
        }
        
        if lastDegreeInChord != Degree.none
        {
            chord.factorQuality = seventhChordType
            chord.addFactors(factors: [Tone(degree: lastDegreeInChord)])
            
            if !alteredDesignators.isEmpty
            {
                chord.addFactors(factors: alteredDesignators)
            }
        }
        else if seventhChordDesignator != nil
        {
            chord.factorQuality = seventhChordType
            chord.factors.insert(seventhChordDesignator!, at: 0)
            if !alteredDesignators.isEmpty
            {
                chord.addFactors(factors: alteredDesignators)
            }
        }
        
        triad.nonTriadNotes.removeAll(where: { notesMatched.contains($0) })
    }
    
    private func findAddedNotes(chord: Chord, notes: [ChordNote])
    {
        for note in notes
        {
            let offsetExtended : Int = Int(ChordDefs.offsetInExtendedChord(rootNote: chord.rootNote!, note: note))
            let offset = Int(ChordDefs.offsetInChord(rootNote: chord.rootNote!, note: note))
            let degree = ChordDefs.offsetToMajDegree[offsetExtended]
            
            if chord.triad.matchesNote(note: ChordNote(offset))
            {
                continue
            }
            
            if degree.sign == Sign.natural
            {
                chord.addAdditions(designators: [Tone(degree: degree.degree)])
            }
            else
            {
                chord.addAdditions(designators: [Tone(signs: [degree.sign], degree: degree.degree)])
            }
        }
        
        addedSixthNotes(chord: chord)
    }
    
    private func addedSixthNotes(chord : Chord)
    {
        // do a final pass to find the special case of added sixth and six/nine notes and reformat them as factors
        let factor = chord.factors.first
        if factor == nil || (factor != nil && factor!.degree != Degree.seven)
        {
            if chord.additions.contains(ChordDefs.sixthNote)
            {
                if chord.additions.contains(ChordDefs.ninthNote)
                {
                    chord.factors.insert(Tone(degree: Degree.sixNine), at: 0)
                    chord.additions.removeAll(where: { $0 == ChordDefs.sixthNote || $0 == ChordDefs.ninthNote })
                }
                else
                {
                    if chord.quality != Quality.Maj
                    {
                        chord.factorQuality = Quality.Maj
                    }
                    chord.factors.insert(ChordDefs.sixthNote, at: 0)
                    chord.additions.removeAll(where: { $0 == ChordDefs.sixthNote })
                }
            }
            else if chord.additions.contains(ChordDefs.minSixthNote)
            {
                if chord.quality != Quality.min
                {
                    chord.factorQuality = Quality.min
                }
                chord.factors.insert(ChordDefs.sixthNote, at: 0)
                chord.additions.removeAll(where: { $0 == ChordDefs.minSixthNote })
            }
        }
    }
    
    private func removeNotes(root: ChordNote, notes: inout [ChordNote],notesToRemove: [NoteRootOffset])
    {
        notes.removeAll(where: { notesToRemove.contains(ChordDefs.offsetInExtendedChord(rootNote: root, note: $0)) })
    }
    
    private func findTriad(notes: [ChordNote])
    {
        for i in 0..<notes.count
        {
            let triadNotes = Triad.extractTriadNotes(rootIdx: i, notes: notes)
            for triad in ChordDefs.triads
            {
                matches.append(triad.matches(notes: notes, triadNotes: triadNotes))
            }
        }
    }
}
