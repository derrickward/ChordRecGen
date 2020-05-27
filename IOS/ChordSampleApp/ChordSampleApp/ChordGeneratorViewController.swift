//
//  ChordGeneratorViewController.swift
//  ChordSampleApp
//
//  Created by Derrick Ward on 1/1/20.
//  Copyright © 2020 Derrick Ward. All rights reserved.
//

import Foundation
import SwiftUI
import ChordRecognizeGenerate
import AudioKit

class ChordGeneratorViewController : UIViewController, ItemViewDelgate
{
    @IBOutlet weak var chordLabel: UILabel!
    @IBOutlet weak var rootNoteSegment: UISegmentedControl!
    @IBOutlet weak var addNoteSegment: UISegmentedControl!
    @IBOutlet weak var flatSharpSegment: UISegmentedControl!
    @IBOutlet weak var notesInChordLabel: UILabel!
    @IBOutlet weak var octaveSegment: UISegmentedControl!
    @IBOutlet weak var addNoteContainer: UIView!
    @IBOutlet weak var inversionSegment: UISegmentedControl!
    @IBOutlet weak var alteredSegment: UISegmentedControl!
    @IBOutlet weak var qualitySegment: UISegmentedControl!
    @IBOutlet weak var factorSegment: UISegmentedControl!
    @IBOutlet weak var factorQualitySegment: UISegmentedControl!
    
    let bank = AKOscillatorBank()
        
    let generator = ChordGenerator()
    var additions = [Tone]()
        
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        AudioKit.output = bank
        do
        {
            try AudioKit.start()
        }
        catch
        {
            print("failed to start audiokit")
        }
        
        updateUI()
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
    
    func updateUI()
    {
        if let savedChord = ChordRepository.getGeneratedChord()
        {
            switch savedChord.quality
            {
                case .Maj:
                    qualitySegment.selectedSegmentIndex = 0
                case .min:
                    qualitySegment.selectedSegmentIndex = 1
                case .aug:
                    qualitySegment.selectedSegmentIndex = 2
                case .dim:
                    qualitySegment.selectedSegmentIndex = 3
                case .sus2:
                    qualitySegment.selectedSegmentIndex = 4
                case .sus4:
                    qualitySegment.selectedSegmentIndex = 5
                default:
                    qualitySegment.selectedSegmentIndex = 0
            }
            
            onQualityChanged()
            
            octaveSegment.selectedSegmentIndex = Int(savedChord.octave)
            
            switch savedChord.inversion
            {
                case .none:
                    inversionSegment.selectedSegmentIndex = 0
                case .first:
                    inversionSegment.selectedSegmentIndex = 1
                case .second:
                    inversionSegment.selectedSegmentIndex = 2
                case .third:
                    inversionSegment.selectedSegmentIndex = 3
                default:
                    print("none")
            }
            
           switch savedChord.factorQuality
           {
               case .Maj:
                    factorQualitySegment.selectedSegmentIndex = 1
               case .halfDim:
                   factorQualitySegment.selectedSegmentIndex = 2
               default:
                   factorQualitySegment.selectedSegmentIndex = 0
           }
            
            rootNoteSegment.selectedSegmentIndex = Int(savedChord.rootNote % 12)
            
            if let extensionTone = savedChord.factors.first
            {
                switch extensionTone.degree
                {
                    case .six:
                        factorSegment.selectedSegmentIndex = 1
                    case .seven:
                        factorSegment.selectedSegmentIndex = 2
                    case .nine:
                        factorSegment.selectedSegmentIndex = 3
                    case .sixNine:
                        factorSegment.selectedSegmentIndex = 4
                    case .eleven:
                        factorSegment.selectedSegmentIndex = 5
                    case .thirteen:
                        factorSegment.selectedSegmentIndex = 6
                    default:
                        print("none")
                }
            }
            
            if let alteredTone = savedChord.alteredNotes.first
            {
                   if alteredTone == Tone(signs: [Sign.flat], degree: Degree.five)
                   {
                        alteredSegment.selectedSegmentIndex = 1
                   }
                   else if alteredTone == Tone(signs: [Sign.sharp], degree: Degree.five)
                   {
                        alteredSegment.selectedSegmentIndex = 2
                    }
                   else if alteredTone == Tone(signs: [Sign.flat], degree: Degree.nine)
                   {
                        alteredSegment.selectedSegmentIndex = 3
                   }
                   else if alteredTone == Tone(signs: [Sign.sharp], degree: Degree.nine)
                   {
                        alteredSegment.selectedSegmentIndex = 4
                   }
                   else if alteredTone == Tone(signs: [Sign.sharp], degree: Degree.eleven)
                   {
                        alteredSegment.selectedSegmentIndex = 5
                   }
            }
        
            for addedTone in savedChord.additions
            {
                addAddedNote(tone: addedTone)
            }
            
            chordLabel.text = savedChord.getFullName()
            notesInChordLabel.text = Chord.coalesceNotesToString(notes: savedChord.notes, isShowingOctave: true)
        }
    }
    
    func onQualityChanged()
    {
        factorQualitySegment.setEnabled(qualitySegment.selectedSegmentIndex == 3, forSegmentAt: 2)
    }
    
    @IBAction func onQualitySegment(_ sender: Any) {
         onQualityChanged()
    }
    
    @IBAction func onPlay(_ sender: Any) {
        
        let chord = Chord()
        var designators = [Tone]()
        
        chord.addAdditions(designators: additions)
        
        switch qualitySegment.selectedSegmentIndex
        {
            case 0:
                chord.quality = Quality.Maj
            case 1:
                chord.quality = Quality.min
            case 2:
                chord.quality = Quality.aug
            case 3:
                chord.quality = Quality.dim
            case 4:
                chord.quality = Quality.sus2
            case 5:
                chord.quality = Quality.sus4
            default:
                chord.quality = Quality.Maj
        }
        
        switch factorQualitySegment.selectedSegmentIndex
        {
            case 1:
                chord.factorQuality = Quality.Maj
            case 2:
                chord.factorQuality = Quality.halfDim
            default:
                print("default: dom")
        }
    
        switch factorSegment.selectedSegmentIndex
        {
            case 0:
                print("none")
            case 1:
                designators.append(Tone(degree: Degree.six))
            case 2:
                designators.append(Tone(degree:Degree.seven))
            case 3:
                designators.append(Tone(degree:Degree.nine))
            case 4:
                designators.append(Tone(degree:Degree.sixNine))
            case 5:
                designators.append(Tone(degree:Degree.eleven))
            case 6:
                designators.append(Tone(degree:Degree.thirteen))
            default:
                print("none")
        }
        
        chord.addFactors(factors: designators)
        
        switch inversionSegment.selectedSegmentIndex
        {
            case 0:
                chord.inversion = Inversion.none
            case 1:
                chord.inversion = Inversion.first
            case 2:
                chord.inversion = Inversion.second
            case 3:
                chord.inversion = Inversion.third
            default:
                print("none")
        }
        
        switch alteredSegment.selectedSegmentIndex
        {
            case 1:
                chord.alteredNotes.append(Tone(signs: [Sign.flat], degree: Degree.five))
            case 2:
                chord.alteredNotes.append(Tone(signs: [Sign.sharp], degree: Degree.five))
            case 3:
                chord.alteredNotes.append(Tone(signs: [Sign.flat], degree: Degree.nine))
            case 4:
                chord.alteredNotes.append(Tone(signs: [Sign.sharp], degree: Degree.nine))
            case 5:
                chord.alteredNotes.append(Tone(signs: [Sign.sharp], degree: Degree.eleven))
            default:
                print("none")
        }
        
        let octave = UInt8(octaveSegment.selectedSegmentIndex)
        chord.rootNote = UInt8(rootNoteSegment.selectedSegmentIndex) + (12 * octave)
        
        let notes = generator.chordToMIDINotes(chord: chord)
        notesInChordLabel.text = Chord.coalesceNotesToString(notes: notes, isShowingOctave: true)
        chordLabel.text = chord.getFullName()
        
        for note in notes
        {
            bank.play(noteNumber: note, velocity: 80)
        }
        
        save(chord: chord)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for note in notes
            {
                self.bank.stop(noteNumber: note)
            }
        }
    }
    
    @IBAction func onClear(_ sender: Any) {
        notesInChordLabel.text = ""
        chordLabel.text = ""
        additions.removeAll()
        addNoteContainer.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    @IBAction func onAddNote(_ sender: Any) {
        
        var sign = Sign.natural
        var noteInScale = Degree.two
        switch flatSharpSegment.selectedSegmentIndex
        {
            case 0:
                print("natural")
            case 1:
                sign = Sign.flat
            case 2:
                sign = Sign.sharp
            default:
                print("natural by default")
        }
        
        switch addNoteSegment.selectedSegmentIndex
        {
            case 0:
                noteInScale = Degree.two
            case 1:
                noteInScale = Degree.four
            case 2:
                noteInScale = Degree.six
            case 3:
                noteInScale = Degree.nine
            case 4:
                noteInScale = Degree.eleven
            case 5:
                noteInScale = Degree.thirteen
            default:
                print("default")
        }
        
        addAddedNote(tone : Tone(signs: [sign], degree: noteInScale))
    }
    
    func addAddedNote(tone: Tone)
    {
        additions.append(tone)
        let count = addNoteContainer.subviews.count
        let itemView = ItemView.create(vc: self, tag: count, text: Chord.coalesceDesignatorsToString(tone: tone))
        itemView.center = CGPoint(x: itemView.center.x + (10 + itemView.bounds.size.width) * CGFloat(count), y: itemView.center.y )
        addNoteContainer.addSubview(itemView)
    }
    
    func save(chord: Chord)
    {
        ChordRepository.saveGeneratedChord(chord: chord)
    }
    
    func onClose(itemView : ItemView)
    {
        additions.remove(at: itemView.tag)
        itemView.removeFromSuperview()
    }
}
