//
//  ChordRepository.swift
//  ChordRecognizeGenerate
//
//  Created by Derrick Ward on 4/27/20.
//  Copyright © 2020 Derrick Ward. All rights reserved.
//

import Foundation
import ChordRecognizeGenerate

class ChordRepository
{
    
    private static let USER_PREFS_GENERATED_CHORD_KEY = "GeneratedChord"
    private static let USER_PREFS_RECOGNIZED_CHORD_KEY = "RecognizedChord"
    
    static func getRecognizedChordGroup() -> ChordGroup?
    {
        return getObject(key : USER_PREFS_RECOGNIZED_CHORD_KEY) as? ChordGroup
    }
        
    static func saveRecognizedChordGroup(chordGroup: ChordGroup)
    {
        saveObject(object: chordGroup, key: USER_PREFS_RECOGNIZED_CHORD_KEY)
    }
    
    static func getGeneratedChord() -> Chord?
    {
        return getObject(key : USER_PREFS_GENERATED_CHORD_KEY) as? Chord
    }
        
    static func saveGeneratedChord(chord: Chord)
    {
        saveObject(object: chord, key: USER_PREFS_GENERATED_CHORD_KEY)
    }

    private static func getObject(key : String) -> NSObject?
    {
        let userDefaults = UserDefaults.standard
        let decoded = userDefaults.data(forKey: key)
        var object : NSObject? = nil
            
        if(decoded != nil)
        {
            do
            {
                object = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded!) as? NSObject
            }
            catch
            {
                print("failed to decode data: \(error).")
            }
        }

        return object
    }

    private static func saveObject(object: NSObject,key : String)
    {
        let userDefaults = UserDefaults.standard
        
        do {
            let encodedData: Data = try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: false)
            userDefaults.set(encodedData, forKey: key)
            userDefaults.synchronize()
        }
        catch
        {
            print("failed to encode data: \(error).")
        }
    }

}
  
