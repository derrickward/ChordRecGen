//
//  ChordDefs.swift
//  ChordRecognizeGenerate
//
//  Created by Derrick Ward on 12/21/19.
//  Copyright © 2019 Derrick Ward. All rights reserved.
//

import Foundation

class ChordDefs
{
    public typealias DegreeInScale = (degree: Degree, sign: Sign)
    
    static let majScaleToOffset : [NoteRootOffset] = [0,0,2,4,5,7,9,11,12,14,16,17,19,21]
    static let minScaleToOffset : [NoteRootOffset] = [0,0,2,3,5,7,8,10,12,14,16,17,19,21]
    
    static let sharpFifth = ChordDefs.sharpNote(noteOffset: ChordDefs.majScaleToOffset[5])
    static let flatFifth = ChordDefs.flatNote(noteOffset: ChordDefs.majScaleToOffset[5])
    
    static let sixthNote = Tone(degree: Degree.six)
    static let minSixthNote = Tone(signs: [Sign.sharp],degree: Degree.five)
    static let ninthNote = Tone(degree: Degree.nine)
    
    static let offsetToMajDegree : [DegreeInScale] = [(Degree.root,Sign.natural),(Degree.two,Sign.flat),(Degree.two,Sign.natural),(Degree.three,Sign.flat),(Degree.three,Sign.natural),(Degree.four,Sign.natural),(Degree.five,Sign.flat),(Degree.five,Sign.natural),(Degree.five,Sign.sharp),(Degree.six,Sign.natural),(Degree.seven,Sign.flat),(Degree.seven,Sign.natural),(Degree.eight,Sign.natural),(Degree.nine,Sign.flat),(Degree.nine,Sign.natural),(Degree.nine,Sign.sharp),(Degree.eleven,Sign.flat),(Degree.eleven,Sign.natural),(Degree.eleven,Sign.sharp),(Degree.twelve,Sign.natural),(Degree.thirteen,Sign.flat),(Degree.thirteen,Sign.natural),(Degree.thirteen,Sign.sharp)]
    
    static let offsetToDimSeventh : [NoteRootOffset : DegreeInScale] = [
        9 : (Degree.seven,Sign.flat),
        10 : (Degree.seven,Sign.natural),
        11 : (Degree.seven,Sign.sharp)
    ]
    
    static let majTriad = Triad(third: ChordDefs.majScaleToOffset[3], fifth: ChordDefs.majScaleToOffset[5], required: ChordDefs.majScaleToOffset[0],quality: Quality.Maj)
    static let minTriad = Triad(third: ChordDefs.minScaleToOffset[3], fifth: ChordDefs.minScaleToOffset[5], required: ChordDefs.minScaleToOffset[3],quality: Quality.min)
    static let dimTriad = Triad(third: ChordDefs.minScaleToOffset[3], fifth: ChordDefs.flatNote(noteOffset: ChordDefs.minScaleToOffset[5]), required: ChordDefs.flatNote(noteOffset: ChordDefs.minScaleToOffset[5]),quality: Quality.dim)
    static let augTriad = Triad(third: ChordDefs.majScaleToOffset[3], fifth: ChordDefs.sharpNote(noteOffset: ChordDefs.majScaleToOffset[5]),required: ChordDefs.sharpNote(noteOffset: ChordDefs.majScaleToOffset[5]), quality: Quality.aug)
    static let sus2Triad = Triad(third: ChordDefs.majScaleToOffset[2], fifth: ChordDefs.majScaleToOffset[5], required: ChordDefs.majScaleToOffset[2],quality: Quality.sus2)
    static let sus4Triad = Triad(third: ChordDefs.majScaleToOffset[4], fifth: ChordDefs.majScaleToOffset[5], required: ChordDefs.majScaleToOffset[4],quality: Quality.sus4)
    
    static let triads = [majTriad,minTriad,dimTriad,augTriad,sus2Triad,sus4Triad]
    
    static func sixthChordDesignatorToOffset(designator : Designator) -> [NoteRootOffset]
    {
        if Degree.six.isEqual(designator: designator) { return [ChordDefs.majScaleToOffset[6]] }
        if Quality.min.isEqual(designator: designator) { return [ChordDefs.minScaleToOffset[6]] }
        if Quality.Maj.isEqual(designator: designator) { return [ChordDefs.majScaleToOffset[6],ChordDefs.majScaleToOffset[7]] }
        if Degree.sixNine.isEqual(designator: designator) { return [ChordDefs.majScaleToOffset[6],ChordDefs.majScaleToOffset[9]] }
        
        return []
    }
    
    static func seventhNoteToDesignator(quality: Quality,sign : Sign) -> Quality
    {
        if quality == Quality.dim
        {
            return dimSeventhNoteSignToDesignators[sign]!
        }
        
        return seventhNoteSignToDesignators[sign]!
    }
    
    static let dimSeventhNoteSignToDesignators : [Sign : Quality] = [
        Sign.flat : Quality.dom,
        Sign.natural : Quality.halfDim,
        Sign.sharp : Quality.Maj
    ]
    
    static let seventhNoteSignToDesignators : [Sign : Quality] = [
        Sign.flat : Quality.dom,
        Sign.natural : Quality.Maj
    ]
    
    static func offsetToMajDegree(quality : Quality,offset : NoteRootOffset) -> DegreeInScale
    {
        var degree : DegreeInScale? = nil
        if quality == Quality.dim
        {
            degree = offsetToDimSeventh[offset]
        }
        
        if degree == nil
        {
            degree = offsetToMajDegree[Int(offset)]
        }
        
        return degree!
    }
    
    static func signatureOffset(designators : [Sign]) -> Int8
    {
        var offsetTotal : Int8 = 0
        var offset : Int8 = 0
        for designator in designators
        {
            offset = 0
            if designator == Sign.flat
            {
                offset = -1
            }
            else if designator == Sign.sharp
            {
                offset = 1
            }
            else if designator == Sign.natural
            {
            }
            
            offsetTotal += offset
        }
        
        return offsetTotal
    }
    
    static let degreeToOffset : [Degree: NoteRootOffset] = [
        Degree.two : ChordDefs.majScaleToOffset[2],
        Degree.three : ChordDefs.majScaleToOffset[3],
        Degree.four : ChordDefs.majScaleToOffset[4],
        Degree.five : ChordDefs.majScaleToOffset[5],
        Degree.six : ChordDefs.majScaleToOffset[6],
        Degree.seven : ChordDefs.minScaleToOffset[7],
        Degree.nine : ChordDefs.majScaleToOffset[9],
        Degree.eleven : ChordDefs.minScaleToOffset[11],
        Degree.thirteen : ChordDefs.minScaleToOffset[13]
    ]
    
    static func flatNote(noteOffset : NoteRootOffset) -> NoteRootOffset
    {
        return noteOffset - 1
    }
    
    static func sharpNote(noteOffset : NoteRootOffset) -> NoteRootOffset
    {
        return noteOffset + 1
    }
    
    static func offsetInExtendedChord(rootNote: ChordNote, note: ChordNote) -> NoteRootOffset
    {
        if note < rootNote || note - rootNote > ChordDefs.majScaleToOffset[13]
        {
            return ((12 + NoteRootOffset(note) % 12) - (NoteRootOffset(rootNote) % 12)) % 12
        }
        else
        {
            return NoteRootOffset(note) - NoteRootOffset(rootNote)
        }
    }
    
    static func offsetInChord(rootNote: ChordNote, note: ChordNote) -> NoteRootOffset
    {
        return  (NoteRootOffset(note % 12) - NoteRootOffset(rootNote % 12) + 12) % 12
    }
}
