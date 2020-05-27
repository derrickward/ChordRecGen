//
//  Designator.swift
//  ChordRecognizeGenerate
//
//  Created by Derrick Ward on 3/3/20.
//  Copyright © 2020 Derrick Ward. All rights reserved.
//

import Foundation

protocol Designator
{
    func toString() -> String
    func toShortString() -> String
}

@objc public enum Quality : Int, Designator
{
    case Maj
    case min
    case sus2
    case sus4
    case dim
    case aug
    case dom
    case halfDim
    
    static let names : [Quality : String] = [
        Quality.Maj : "Maj",
        Quality.min : "min",
        Quality.aug : "aug",
        Quality.dim : "dim",
        Quality.sus2 : "sus2",
        Quality.sus4 : "sus4",
        Quality.dom : "dom",
        Quality.halfDim : "ø"
    ]
    
    static let shortNames : [Quality : String] = [
        Quality.Maj : "M",
        Quality.min : "m",
        Quality.aug : "+",
        Quality.dim : "o"
    ]
    
    func toString() -> String
    {
        if let name = Quality.names[self]
        {
            return name
        }
        return ""
    }
    
    func toShortString() -> String
    {
        if let shortName = Quality.shortNames[self]
        {
            return shortName
        }
        else if let name = Quality.names[self]
        {
            return name
        }
        return ""
    }
    
    func isEqual(designator : Designator) -> Bool
    {
        return type(of: designator) == type(of:self)
            && (designator as! Quality) == self
    }
}

@objc public enum Degree: Int, Designator
{
    case none
    case root
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    case nine
    case eleven
    case twelve
    case thirteen
    case sixNine
    
    static let names : [Degree : String] = [
        none : "",
        root : "root",
        two : "2",
        three : "3",
        four : "4",
        five : "5",
        six : "6",
        seven : "7",
        eight : "8",
        nine : "9",
        eleven : "11",
        twelve : "12",
        thirteen : "13",
        sixNine : "6/9"
    ]
    
    func toString() -> String
    {
        if let name = Degree.names[self]
        {
            return name
        }
        return ""
    }
    
    func toShortString() -> String
    {
        return toString()
    }
    
    func isEqual(designator : Designator) -> Bool
    {
        return type(of: designator) == type(of:self)
            && (designator as! Degree) == self
    }
    
    static func numberToDegree(number: UInt8) -> Degree
    {
        switch number
        {
            case 2:
                return Degree.two
            case 3:
                return Degree.three
            case 4:
                return Degree.four
            case 5:
                return Degree.five
            case 6:
                return Degree.six
            case 7:
                return Degree.seven
            case 8:
                return Degree.eight
            case 9:
                return Degree.nine
            case 11:
                return Degree.eleven
            case 12:
                return Degree.twelve
            case 13:
                return Degree.thirteen
            default:
                return Degree.none
        }
    }
    
    func toNumber() -> UInt8
    {
        switch self
        {
            case Degree.two:
                return 2
            case Degree.three:
                return 3
            case Degree.four:
                return 4
            case Degree.five:
                return 5
            case Degree.six:
                return 6
            case Degree.seven:
                return 7
            case Degree.eight:
                return 8
            case Degree.nine:
                return 9
            case Degree.eleven:
                return 11
            case Degree.twelve:
                return 12
            case Degree.thirteen:
                return 13
            default:
                return 0
        }
    }
}

@objc public enum Sign : Int, Designator
{
    case flat
    case sharp
    case natural
    
    static let names : [Sign : String] = [
        flat : "♭",
        sharp : "♯",
        natural : "♮"
    ]
    
    func toString() -> String
    {
        if let name = Sign.names[self]
        {
            return name
        }
        return ""
    }
    
    func toShortString() -> String
    {
        return toString()
    }
    
    func isEqual(designator : Designator) -> Bool
    {
        return type(of: designator) == type(of:self)
            && (designator as! Sign) == self
    }
}

@objc public enum Delimiter : Int, Designator
{
    case omit
    case add
    case slash
    case empty
    
    static let names : [Delimiter : String] = [
        omit : "omit",
        add : "add",
        slash : " / ",
        empty : ""
    ]
    
    func toString() -> String
    {
        if let name = Delimiter.names[self]
        {
            return name
        }
        return ""
    }
    
    func toShortString() -> String
    {
        return toString()
    }
}
