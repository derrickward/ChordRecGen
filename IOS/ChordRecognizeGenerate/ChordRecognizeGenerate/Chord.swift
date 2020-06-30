//
//  Chord.swift
//  ChordRecognizeGenerate
//
//  Created by Derrick Ward on 12/20/19.
//  Copyright © 2019 Derrick Ward. All rights reserved.
//

import Foundation

@objc public enum Inversion : Int { case none,first,second,third }
@objc public enum Form : Int { case short,long }

@objc
public enum ChordRoot : UInt8
{
    case C = 0
    case Csharp = 1
    case D = 2
    case Dsharp = 3
    case E = 4
    case F = 5
    case Fsharp = 6
    case G = 7
    case Gsharp = 8
    case A = 9
    case Asharp = 10
    case B = 11
}

public typealias ChordNote = UInt8
public typealias NoteRootOffset = Int8

@objc public class Chord : NSObject, NSSecureCoding
{
    public static var supportsSecureCoding = true
    
    @objc public var additions = [Tone]()
    @objc public var factors = [Tone]()
    public var ommission : Degree?
    @objc public var quality : Quality = Quality.Maj
    @objc public var factorQuality : Quality = Quality.dom
    @objc public var notes : [ChordNote]!
    @objc public var invertedNotes : [ChordNote]!
    @objc public var alteredNotes = [Tone]()
    @objc public weak var triad : Triad!
    @objc public var octave : UInt8 = 0
    @objc public var inversion : Inversion = Inversion.none
    @objc private var triadScore : Int = 0
    
    public var rootNote: ChordNote! {
         willSet {
        }
        didSet {
            octave = rootNote / 12
        }
    }
    
    @objc public override init() {
        self.notes = [ChordNote]()
        self.invertedNotes = [ChordNote]()
    }
    
    @objc public init(notes:[ChordNote])
    {
        self.notes = notes
        self.invertedNotes = [ChordNote]()
    }
    
    @objc public init(root : ChordRoot,octave : UInt8, quality : Quality,factor : Degree, factorQuality : Quality)
    {
        super.init()
        self.rootNote = root.rawValue + 12 * octave
        self.quality = quality
        self.octave = octave
        self.factorQuality = factorQuality
        setFactor(degree: factor)
        self.invertedNotes = [ChordNote]()
        self.notes = [ChordNote]()
    }
    
    @objc public init(rootNote : ChordNote,quality : Quality,factor : Degree, factorQuality : Quality)
    {
        super.init()
        self.octave = rootNote / 12
        self.rootNote = rootNote
        self.quality = quality
        self.factorQuality = factorQuality
        setFactor(degree: factor)
        self.invertedNotes = [ChordNote]()
        self.notes = [ChordNote]()
    }
    
    public init(notes:[ChordNote], triadResult: TriadMatch)
    {
        rootNote = notes[triadResult.rootIdx]
        quality = triadResult.triadType
        invertedNotes = triadResult.invertedNotes
        inversion = triadResult.inversion
        ommission = triadResult.omission
        triad = triadResult.triad
        triadScore = triadResult.getScore()
        if triadResult.alteredFifth != nil
        {
            self.alteredNotes.append(Tone(signs:[triadResult.alteredFifthSign], degree: Degree.five))
        }
        self.notes = notes
    }
    
    public required init?(coder: NSCoder) {
        
        additions = coder.decodeObject(forKey: "additions") as! [Tone]
        factors = coder.decodeObject(forKey: "factors") as! [Tone]
        if coder.containsValue(forKey: "ommission")
        {
            ommission = Degree(rawValue: Int(coder.decodeInt32(forKey: "ommission")))
        }
       
        quality = Quality(rawValue: Int(coder.decodeInt32(forKey: "quality")))!
        factorQuality = Quality(rawValue: Int(coder.decodeInt32(forKey: "factorQuality")))!
        notes = coder.decodeObject(forKey: "notes") as? [ChordNote]
        invertedNotes = coder.decodeObject(forKey: "invertedNotes") as? [ChordNote]
        alteredNotes = coder.decodeObject(forKey: "alteredNotes") as! [Tone]
        triad = coder.decodeObject(forKey: "triad") as? Triad
        octave = UInt8(coder.decodeInt32(forKey: "octave"))
        inversion = Inversion(rawValue: Int(coder.decodeInt32(forKey: "inversion")))!
        rootNote = ChordNote(coder.decodeInt32(forKey: "rootNote"))
        super.init()
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(additions, forKey: "additions")
        coder.encode(factors, forKey: "factors")
        if let optionalOmmission = ommission
        {
            coder.encode(optionalOmmission.rawValue, forKey: "ommission")
        }
        coder.encode(quality.rawValue, forKey: "quality")
        coder.encode(factorQuality.rawValue, forKey: "factorQuality")
        coder.encode(notes, forKey: "notes")
        coder.encode(invertedNotes, forKey: "invertedNotes")
        coder.encode(alteredNotes, forKey: "alteredNotes")
        coder.encode(triad, forKey: "triad")
        coder.encode(Int(octave), forKey: "octave")
        coder.encode(inversion.rawValue, forKey: "inversion")
        coder.encode(Int(rootNote), forKey: "rootNote")
    }
    
    @objc func isDyad() -> Bool
    {
        return notes.count == 2
    }
    
    @objc func isPowerChord() -> Bool
    {
        return isDyad() && ChordDefs.offsetInExtendedChord(rootNote: notes.first!, note: notes.last!) == ChordDefs.majTriad.fifth
    }
    
    @objc func isSuspended() -> Bool
    {
        return quality == Quality.sus4 || quality == Quality.sus2
    }
    
    public func removeIntersect(chordNotes : [ChordNote])
    {
        notes.removeAll(where: { chordNotes.contains($0) })
    }
    
    @objc public func addAdditions(designators: [Tone])
    {
        additions.append(contentsOf: designators)
    }
    
    @objc public func addFactors(factors: [Tone])
    {
        self.factors.append(contentsOf: factors)
    }
    
    @objc public func setFactor(degree: Degree)
    {
        clearFactors()
        if degree != Degree.none
        {
            self.factors.append(Tone(degree: degree))
        }
    }
    
    @objc public func clearFactors()
    {
        factors.removeAll()
    }
    
    @objc public func getFullName() -> String
    {
        return getFullName(formType: Form.long)
    }
    
    @objc public func getFullName(formType : Form) -> String
    {
        let builder = NSMutableString()
        
        builder.append(getDesignatorsName(formType: formType))
        
        if isSuspended()
        {
            builder.insert(MIDIConstants.stringForNote(note: rootNote), at: 0)
            builder.append(" ")
            builder.append(Chord.designatorToString(designator: quality,form: formType))
        }
        else
        {
            builder.insert(getRootName(), at: 0)
        }
        
        if invertedNotes != nil && invertedNotes.count > 0
        {
            builder.append(Delimiter.slash.toString())
            builder.append(MIDIConstants.stringForNote(note: invertedNotes.first!))
        }
    
        return builder as String
    }
    
    private func isHalfDiminished() -> Bool
    {
        //var isHalfDim = self.factors.count >= 1 && factorQuality == Quality.halfDim
        
        //if !isHalfDim
        //{
          let isHalfDim = self.factors.count >= 2 && (factors[0].has(degree: Degree.seven) && factors[1].has(sign: Sign.flat,degree: Degree.five))
        //}
        return isHalfDim
    }
    
    private func isHalfDiminishedSeventh(offset: NoteRootOffset) -> Bool
    {
        return self.quality == Quality.dim && offset == ChordDefs.flatNote(noteOffset: ChordDefs.majScaleToOffset[7])
    }
    
    @objc public func getRootName() -> String
    {
        return getRootName(formType: Form.long)
    }
    
    public func getRootName(formType: Form) -> String
    {
        let builder = NSMutableString()
        
        if isDyad()
        {
            if isPowerChord()
            {
                builder.append(MIDIConstants.stringForNote(note: notes[0]))
                builder.append(Degree.five.toString())
            }
            else
            {
                builder.append(MIDIConstants.stringForNote(note: notes[0]))
                builder.append(" ")
                builder.append(MIDIConstants.stringForNote(note: notes[1]))
            }
        }
        else
        {
            builder.append(MIDIConstants.stringForNote(note: rootNote))
            if quality != Quality.Maj
            {
                builder.append(Chord.designatorToString(designator: quality,form: formType))
            }
        }
        return builder as String
    }
    
    @objc public func addNotesFromOffsets(offsets : [NoteRootOffset])
    {
        offsets.forEach({
            let note = ChordNote(Int8(rootNote!) + $0)
            if !notes.contains(note)
            {
                notes.append(note)
            }
        })
    }
    
    @objc public func getScore() -> Int
    {
        return triadScore
            + (isHalfDiminished() ? 1 : 0)
            - additions.count
    }
    
    @objc public func add(notesToAdd : [ChordNote])
    {
        removeIntersect(chordNotes: notesToAdd)
        notes.append(contentsOf: notesToAdd)
    }
    
    private static func designatorToString(designator : Designator, form: Form) -> String
    {
        if Quality.dom.isEqual(designator: designator) || Sign.natural.isEqual(designator: designator)
        {
            return ""
        }
        else
        {
            return form == Form.short ? designator.toShortString() : designator.toString()
        }
    }
    
    public func getDesignatorsName(formType : Form) -> String
    {
        let builder = NSMutableString()
        
        let extendedAlteredNotes = alteredNotes.filter({ $0.degree.rawValue > 7 })

        if extendedAlteredNotes.isEmpty
        {
            coalesceDesignators(tones: alteredNotes, builder: builder)
            if !factors.isEmpty
            {
                if factorQuality != Quality.dom && factorQuality != Quality.dim
                {
                    builder.append(" ")
                    builder.append(Chord.designatorToString(designator: factorQuality, form: formType))
                }
            }
            
            coalesceDesignators(tones: factors, builder: builder)
            if factors.isEmpty
            {
                builder.append(" ")
            }
        }
        else if !factors.isEmpty
        {
            coalesceDesignators(tones: alteredNotes, builder: builder)
            builder.insert(Degree.seven.toString(), at: 0)
        }
        coalesceDesignators(tones: additions, delimiter: Delimiter.add, builder: builder)
        
        if ommission != nil
        {
            builder.append(" ")
            builder.append(Delimiter.omit.toString())
            builder.append(ommission!.toString())
        }
        return builder as String
    }
    
    
    static public func coalesceNotesToString(notes : [ChordNote], isShowingOctave : Bool) -> String
    {
        let builder = NSMutableString()
        for note in notes
        {
            if isShowingOctave
            {
                builder.append(MIDIConstants.stringForNoteWithOctave(note: UInt8(note)))
            }
            else
            {
                builder.append(MIDIConstants.stringForNote(note: UInt8(note)))
            }
            builder.append(" ")
        }
        return builder as String
    }
    
    static public func coalesceDesignatorsToString(tone: Tone) -> String
    {
        let builder = NSMutableString()
        for designator in tone.signs
        {
            builder.append(Chord.designatorToString(designator: designator,form: Form.long))
        }
        builder.append(tone.degree.toString())
        
        return builder as String
    }
    
    private func coalesceDesignators(tones: [Tone], builder: NSMutableString)
    {
        coalesceDesignators(tones: tones, delimiter: Delimiter.empty, builder: builder)
    }
    
    private func coalesceDesignators(tones: [Tone], delimiter: Designator, builder: NSMutableString)
    {
        for tone in tones
        {
            builder.append(delimiter.toString())
            builder.append(Chord.coalesceDesignatorsToString(tone: tone))
            builder.append(" ")
        }
    }
}
