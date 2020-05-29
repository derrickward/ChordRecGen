//
//  MainViewController.swift
//  ChordSampleApp
//
//  Created by Derrick Ward on 12/27/19.
//  Copyright © 2019 Derrick Ward. All rights reserved.
//

import Foundation
import SwiftUI
import AudioKit
import AudioKitUI
import ChordRecognizeGenerate

class ChordRecognizerViewController : UIViewController, AKKeyboardDelegate
{

    @IBOutlet weak var chordLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var keyboardView: AKKeyboardView!
    
    var notes = [ChordNote]()
    let recognizer = ChordRecognizer()
    let bank = AKOscillatorBank()
    var chords : [ChordGroup]?
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        self.keyboardView.delegate = self
        chordLabel.text = ""
        notesLabel.text = ""
        
        AudioKit.output = bank
        do
        {
            try AudioKit.start()
        }
        catch
        {
            print("failed to start audiokit")
        }
        
        if let chordGroup = ChordRepository.getRecognizedChordGroup()
        {
            chords = [chordGroup]
            let allNotes = chordGroup.notes
            notes.append(contentsOf: allNotes)
    
            notesLabel.text = Chord.coalesceNotesToString(notes: allNotes, isShowingOctave: true)

            updateUI(chordGroups: [chordGroup])
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        do
        {
            try AudioKit.stop()
        }
        catch
        {
            print("failed to stop audiokit")
        }
    }
    
    func noteOn(note: MIDINoteNumber) {
        notes.append(ChordNote(note))
        notesLabel.text = String(format: "%@ %@",notesLabel.text!,MIDIConstants.stringForNoteWithOctave(note: note))
        
        bank.play(noteNumber: note, velocity: 80)
    }
    
    func noteOff(note: MIDINoteNumber) {
       bank.stop(noteNumber: note)
    }
    
    func updateUI(chordGroups: [ChordGroup])
    {
        let builder = NSMutableString()
        var i = 0
        for chord in chordGroups
        {
            if i >= 1
            {
                builder.append("  *or*  ")
            }
            builder.append(chord.getFullName())
            i += 1
            if i >= 3
            {
                break
            }
        }
        
        let text = builder as String
        chordLabel.text = text
        
        let builderFull = NSMutableString()
        for chord in chordGroups
        {
            builderFull.append(chord.getFullName() + "\n")
        }
        print(builderFull as String)
        print("\(chordGroups.count) results total")
    }
    
    @IBAction func onRecognize(_ sender: Any) {
        chordLabel.text = ""
        let chordGroups = recognizer.notesToChord(midiNoteValues: notes)

        chords = chordGroups
        if let firstChordGroup = chordGroups.first
        {
            ChordRepository.saveRecognizedChordGroup(chordGroup: firstChordGroup)
        }
        
        updateUI(chordGroups: chordGroups)
        
    }
    
    @IBAction func onClear(_ sender: Any) {
        
        notes.removeAll()
        chordLabel.text = ""
        notesLabel.text = ""
        chords = nil
    }
    
    @IBAction func onPlay(_ sender: Any) {
        
        if notes.isNotEmpty
        {
            chords = recognizer.notesToChord(midiNoteValues: notes)
        }
        
        if let chordGroup = chords?.first
        {
            for chord in chordGroup.chords
            {
                for note in chord.notes
                {
                    bank.play(noteNumber: note, velocity: 80)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    for note in chord.notes
                    {
                        self.bank.stop(noteNumber: note)
                    }
                }
            }
        }
    
    }
}
