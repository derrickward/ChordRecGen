//
//  MIDIConstants.swift
//  MIDI Space
//
//  Created by Derrick Ward on 9/23/19.
//  Copyright © 2019 Derrick Ward. All rights reserved.
//

import Foundation

public class MIDIConstants
{
    public static let TIME_STEP : UInt64 = 10
    public static let STATUS_BIT : UInt8 = 0x80
    public static let STATUS_NIBBLE : UInt8 = 0xF0
    public static let CHANNEL_NIBBLE : UInt8 = 0x0F
    public static let NOTE_ON : UInt8  = 0x90
    public static let NOTE_OFF : UInt8  = 0x80
    public static let PATCH_CHANGE : UInt8  = 0xC0
    public static let SYSEX : UInt8  = 0xF0
    public static let SYSEX_END : UInt8  = 0xF7
    public static let SYSEX_GENERIC : UInt8  = 0x7F

    public static let MIDI_PB_MESSAGE : UInt8  = 0xE0
    public static let MIDI_CC_MESSAGE : UInt8  = 0xB0
    public static let MOD_WHEEL_CC : UInt8 = 0x01
    
    public static let PITCH_BEND_ZERO : UInt16 = 0x2000
    
    private static var expressionNames : [String]!
    private static var instrumentNames : [String]!

    public static func stringForNoteWithOctave(note: UInt8) -> String
   {
        let octave : Int = Int(note / 12)
        return String.init(format: "%@%d", stringForNote(note: note),octave-1)
   }

    public static func stringForNote(note: UInt8) -> String
       {
           switch note % 12 {
               case 0:
                   return "C";

               case 1:
                   return "C\u{266f}";

               case 2:
                   return "D";

               case 3:
                   return "D\u{266f}";

               case 4:
                   return "E";

               case 5:
                   return "F";

               case 6:
                   return "F\u{266f}";

               case 7:
                   return "G";

               case 8:
                   return "G\u{266f}";

               case 9:
                   return "A";

               case 10:
                   return "A\u{266f}";

               case 11:
                   return "B";

               default:
                   return "";
           }
       }
    
    static func getInstrumentNames()  -> [String]
    {
        if instrumentNames == nil
        {
            instrumentNames = ["1 Acoustic Grand Piano",
            "2 Bright Acoustic Piano",
            "3 Electric Grand Piano",
            "4 Honky-tonk Piano",
            "5 Electric Piano 1",
            "6 Electric Piano 2",
            "7 Harpsichord",
            "8 Clavi",
            "9 Celesta",
            "10 Glockenspiel",
            "11 Music Box",
            "12 Vibraphone",
            "13 Marimba",
            "14 Xylophone",
            "15 Tubular Bells",
            "16 Dulcimer",
            "17 Drawbar Organ",
            "18 Percussive Organ",
            "19 Rock Organ",
            "20 Church Organ",
            "21 Reed Organ",
            "22 Accordion",
            "23 Harmonica",
            "24 Tango Accordion",
            "25 Acoustic Guitar (nylon)",
            "26 Acoustic Guitar (steel)",
            "27 Electric Guitar (jazz)",
            "28 Electric Guitar (clean)",
            "29 Electric Guitar (muted)",
            "30 Overdriven Guitar",
            "31 Distortion Guitar",
            "32 Guitar harmonics",
            "33 Acoustic Bass",
            "34 Electric Bass (finger)",
            "35 Electric Bass (pick)",
            "36 Fretless Bass",
            "37 Slap Bass 1",
            "38 Slap Bass 2",
            "39 Synth Bass 1",
            "40 Synth Bass 2",
            "41 Violin",
            "42 Viola",
            "43 Cello",
            "44 Contrabass",
            "45 Tremolo Strings",
            "46 Pizzicato Strings",
            "47 Orchestral Harp",
            "48 Timpani",
            "49 String Ensemble 1",
            "50 String Ensemble 2",
            "51 SynthStrings 1",
            "52 SynthStrings 2",
            "53 Choir Aahs",
            "54 Voice Oohs",
            "55 Synth Voice",
            "56 Orchestra Hit",
            "57 Trumpet",
            "58 Trombone",
            "59 Tuba",
            "60 Muted Trumpet",
            "61 French Horn",
            "62 Brass Section",
            "63 SynthBrass 1",
            "64 SynthBrass 2",
            "65 Soprano Sax",
            "66 Alto Sax",
            "67 Tenor Sax",
            "68 Baritone Sax",
            "69 Oboe",
            "70 English Horn",
            "71 Bassoon",
            "72 Clarinet",
            "73 Piccolo",
            "74 Flute",
            "75 Recorder",
            "76 Pan Flute",
            "77 Blown Bottle",
            "78 Shakuhachi",
            "79 Whistle",
            "80 Ocarina",
            "81 Lead 1 (square)",
            "82 Lead 2 (sawtooth)",
            "83 Lead 3 (calliope)",
            "84 Lead 4 (chiff)",
            "85 Lead 5 (charang)",
            "86 Lead 6 (voice)",
            "87 Lead 7 (fifths)",
            "88 Lead 8 (bass + lead)",
            "89 Pad 1 (new age)",
            "90 Pad 2 (warm)",
            "91 Pad 3 (polysynth)",
            "92 Pad 4 (choir)",
            "93 Pad 5 (bowed)",
            "94 Pad 6 (metallic)",
            "95 Pad 7 (halo)",
            "96 Pad 8 (sweep)",
            "97 FX 1 (rain)",
            "98 FX 2 (soundtrack)",
            "99 FX 3 (crystal)",
            "100 FX 4 (atmosphere)",
            "101 FX 5 (brightness)",
            "102 FX 6 (goblins)",
            "103 FX 7 (echoes)",
            "104 FX 8 (sci-fi)",
            "105 Sitar",
            "106 Banjo",
            "107 Shamisen",
            "108 Koto",
            "109 Kalimba",
            "110 Bag pipe",
            "111 Fiddle",
            "112 Shanai",
            "113 Tinkle Bell",
            "114 Agogo",
            "115 Steel Drums",
            "116 Woodblock",
            "117 Taiko Drum",
            "118 Melodic Tom",
            "119 Synth Drum",
            "120 Reverse Cymbal",
            "121 Guitar Fret Noise",
            "122 Breath Noise",
            "123 Seashore",
            "124 Bird Tweet",
            "125 Telephone Ring",
            "126 Helicopter",
            "127 Applause",
            "128 Gunshot"]
        }
        
        return instrumentNames
    }

    static func getExpressionNames() -> Array<String>
    {
        if expressionNames == nil
        {
            expressionNames = ["None",
               "0 Bank Select ",
               "1 Modulation Wheel",
               "2 Breath controller",
               "4 Foot Pedal ",
               "5 Portamento Time ",
               "6 Data Entry ",
               "7 Volume ",
               "8 Balance",
               "10 Pan position ",
               "11 Expression ",

               "12 Effect Control 1",
               "13 Effect Control 2",
               "14 Undefined",
               "15 Undefined",
               "16 Ribbon Controller",
               "17 Knob 1",
               "18 General Purpose Slider 3",
               "19 Knob 2 General Purpose Slider 4",
               "20 Knob 3",
               "21 Knob 4",
               "22 Undefined",
               "23 Undefined",
               "24 Undefined",
               "25 Undefined",
               "26 Undefined",
               "27 Undefined",
               "28 Undefined",
               "29 Undefined",
               "30 Undefined",
               "31 Undefined",
               "32 Bank Select  (see cc0)",
               "33 Modulation Wheel ",
               "34 Breath controller ",
               "36 Foot Pedal ",
               "37 Portamento Time ",
               "38 Data Entry ",
               "39 Volume ",
               "40 Balance ",
               "42 Pan position ",
               "43 Expression ",
               "44 Effect Control 1",
               "45 Effect Control 2 ",
               "46 Undefined",
               "47 Undefined",
               "48 Undefined",
               "49 Undefined",
               "50 Undefined",
               "51 Undefined",
               "52 Undefined",
               "53 Undefined",
               "54 Undefined",
               "55 Undefined",
               "56 Undefined",
               "57 Undefined",
               "58 Undefined",
               "59 Undefined",
               "60 Undefined",
               "61 Undefined",
               "62 Undefined",
               "63 Undefined",
               "64 Hold Pedal (on/off)",

               "65 Portamento (on/off)",
               "66 Sustenuto Pedal (on/off)",
               "67 Soft Pedal (on/off)",
               "68 Legato Pedal (on/off)",
               "69 Hold 2 Pedal (on/off)",
               "70 Sound Variation",
               "71 Resonance (aka Timbre)",
               "72 Sound Release Time",
               "73 Sound Attack Time",
               "74 Frequency Cutoff",
               "75 Sound Control 6",
               "76 Sound Control 7",
               "77 Sound Control 8",
               "78 Sound Control 9",
               "79 Sound Control 10",
               "80 Decay",
               "81 Hi Pass Filter Frequency",
               "82 General Purpose Button 3",
               "83 General Purpose Button 4",
               "91 Reverb Level",
               "92 Tremolo Level",
               "93 Chorus Level",
               "94 Celeste Level or Detune",
               "95 Phaser Level",

               "96 Data Button increment",
               "97 Data Button decrement",
               "98 Non-registered Parameter",
               "99 Non-registered Parameter",
               "100 Registered Parameter",
               "101 Registered Parameter",
               "102 Undefined",
               "103 Undefined",
               "104 Undefined",
               "105 Undefined",
               "106 Undefined",
               "107 Undefined",
               "108 Undefined",
               "109 Undefined",
               "110 Undefined",
               "111 Undefined",
               "112 Undefined",
               "113 Undefined",
               "114 Undefined",
               "115 Undefined",
               "116 Undefined",
               "117 Undefined",
               "118 Undefined",
               "119 Undefined",
               "120 All Sound Off",
               "121 All Controllers Off",
               "122 Local Keyboard",
               "123 All Notes Off",
               "124 Omni Mode Off",
               "125 Omni Mode On",
               "126 Mono Operation",
               "127 Poly Operation"]
        }
        
        return expressionNames
    }

}
