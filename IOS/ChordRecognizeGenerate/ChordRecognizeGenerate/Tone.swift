//
//  Tone.swift
//  ChordRecognizeGenerate
//
//  Created by Derrick Ward on 3/1/20.
//  Copyright © 2020 Derrick Ward. All rights reserved.
//

import Foundation

@objc
public class Tone : NSObject, NSSecureCoding
{
    public static var supportsSecureCoding = true
    public var signs : [Sign] = [Sign]()
    @objc public var degree : Degree
    
    override init()
    {
        degree = Degree.none
        super.init()
    }
    
    public init(signs : [Sign], degree : Degree)
    {
        self.signs.append(contentsOf: signs)
        self.degree = degree
    }
    
    public init(degree : Degree)
    {
        self.degree = degree
    }
    
    public required init?(coder: NSCoder) {
        
        let signInts = coder.decodeObject(forKey: "signs") as! [Int]
        for signInt in signInts
        {
            signs.append(Sign(rawValue: signInt) ?? Sign.natural)
        }
        degree = Degree(rawValue: Int(coder.decodeInt32(forKey: "degree")))!
        super.init()
    }
    
    public func encode(with coder: NSCoder) {
        var signIntegers = [Int]()
        for sign in signs
        {
            signIntegers.append(sign.rawValue)
        }
        coder.encode(signIntegers, forKey: "signs")
        coder.encode(degree.rawValue, forKey: "degree")
    }
    
    public static func ==(lhs: Tone, rhs: Tone) -> Bool {
        return lhs.degree == rhs.degree && lhs.signs == rhs.signs
    }
    
    func toOffset() -> NoteRootOffset
    {
        let sigOffset = ChordDefs.signatureOffset(designators: signs)
        return ChordDefs.degreeToOffset[degree]! + sigOffset
    }
    
    func toNote(root : ChordNote) -> ChordNote
    {
        return ChordNote(NoteRootOffset(root) + toOffset())
    }
    
    func has(degree: Degree) ->Bool
    {
        return self.degree == degree
    }
    
    func has(sign: Sign, degree: Degree) ->Bool
    {
        return !self.signs.isEmpty && self.signs.first! == sign && self.degree == degree
    }
}
