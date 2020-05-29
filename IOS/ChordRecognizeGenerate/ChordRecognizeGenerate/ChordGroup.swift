//
//  ChordGroup.swift
//  ChordRecognizeGenerate
//
//  Created by Derrick Ward on 1/11/20.
//  Copyright © 2020 Derrick Ward. All rights reserved.
//

import Foundation

@objc public class ChordGroup : NSObject, NSSecureCoding
{
    public static var supportsSecureCoding = true
    
    @objc public var chords = [Chord]()
    
    public override init()
    {
        super.init()
    }
    
    public required init?(coder: NSCoder) {
        chords = coder.decodeObject(forKey: "chords") as! [Chord]
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(chords, forKey: "chords")
    }
    
    @objc public var notes: [ChordNote] {
        get
        {
            var allNotes = [ChordNote]()
            for chord in chords
            {
                allNotes.append(contentsOf: chord.notes)
            }
            return allNotes
        }
    }
    
    @objc public func getFullName() -> String
    {
        let builder = NSMutableString()
        for i in 0..<chords.count
        {
            if i > 0
            {
                builder.append(" - ")
            }
            builder.append(chords[i].getFullName())
        }
        
        if chords.count > 1
        {
            builder.append(" (poly)")
        }
        
        return builder as String
    }
    
    @objc public func add(newChord : Chord)
    {
        chords.forEach({ $0.removeIntersect(chordNotes: newChord.notes) })
        chords.append(newChord)
    }
    
    @objc public func isPolyChord() -> Bool
    {
        return chords.count > 1
    }
    
    func getScore() -> Int
    {
        var score = 0
        chords.forEach({ score += $0.getScore() })
        return score / chords.count
    }
}
