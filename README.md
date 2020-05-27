
# ChordRecGen

Mobile app (Swift, IOS/Mac) library for musical chord recognition and generation. Interface is also compatible with objective-C.

## Getting Started

1. clone git repository
2. Add ChordRecognizeGenerate XCode library project to your workspace.
3. (optional) If you want to run sample app, from command line, run pod install to generate XCode workspace for app. Sample app uses AudioKit and AudioKitUI cocoapod libraries. 

### How Chord Recognition Works

1. On receiving an array of notes, the chord recognizer attempts to match a triad from a lookup table. Multiple roots are tried. The best match is chosen based on a score computed by a utility.
2. If a triad is found, the "stack of thirds" are traversed in the note array to determine the chord's factor. Other notes are classified as "altered", "added", or "inverted", etc.. along the way accordingly.
3. If there are notes left over that do not match, a recursive check for additional chords is made (polychords).

### Usage

**• Chord Recognition**

1. Declare an instance of the *ChordRecognizer* class
2. Pass an array of note bytes (MIDI standard) to the notesToChord method.
3. *notesToChord* returns an array of *ChordGroup* objects, which contain a characterization of the chord. Each object in the array represents an alternate descriptor/name for the chord. Each *ChordGroup* instance only contains more than one *Chord* object instance if the notes form a polychord.

See *ChordRecognizerViewController.swift* class code in the sample app for a complete example.

**• Chord Generation**

1. Declare an instance of the *ChordRecognizer* class
2. Declare an instance of the *Chord* class. Specify the key, factor, octave, and quality using the constructor. Initialize any additional descriptors using the properties (inversions, alterations, added notes, etc...).
3. Call the *chordToMIDINotes* method and pass in the chord.
4. The *notes* property of the chord class will now contain the MIDI note bytes for the chord.

See *ChordGeneratorViewController.swift* class code in the sample app for a complete example.

### Chord Classes

#### ***• Chord***

Object encapsulating a single chord's notes and descriptors.

*Properties*
```
additions - array of Tone objects representing added notes to chord

factors - array of Tone objects representing chord's factors (7, 9, etc..). 

ommision - optional property indicating degree of ommited note in Triad

quality - quality of chord (major, minor, etc...)

factorQuality - quality of chord factor (dominant, major, half-diminished, none)

rootNote - byte indicating the root note of the chord (MIDI note)

notes - array of MIDI note bytes for all chord notes

invertedNotes - array of MIDI note bytes for inverted chord notes

alteredNotes - array of Tones representing altered notes in chord

triad - Triad instance containing information about the chord's triad

octave - octave 0 - 8

inversion - indicates 1st, 2nd, 3rd, or no inversion
```
            
*Methods*
```

init(rootNote : ChordNote,quality : Quality,factor : Degree, factorQuality : Quality)

init(root : ChordRoot,octave : UInt8, quality : 
Quality,factor : Degree, factorQuality : Quality)

init(notes:[ChordNote])

init()

isDyad - returns true is chord is a dyad

isPowerchord - returns true if chord is a powerchord

isSuspended - returns true if chord has a quality of sus2 or sus4

addAdditions(designators: [Tone]) - add additional notes to chord (added notes)

setFactor(degree: Degree) - set the factor of the chord

addFactors(factors: [Tone]) - add more than one factor to chord

clearFactors

getFullName - returns a string containing the full name of the chord

getFullName(formType : Form) - overload that allows you to specify short or long form for the chord name (default is long)

getRootName - returns a string with the name of the root of the chord

```

#### ***• ChordGroup***
Object encapsulating an array of chords. More than one chord in array implies a polychord. 

*Properties*
```
chords - array of Chord objects

notes - returns an array of bytes representing the notes in all chords in the group (MIDI notes)

```

*Methods*
```
getFullName - returns a string containing the full name of the chord/polychord

isPolychord - returns true if group of chords is a polychord
```

#### ***• Tone***
Object that encapsulates a degree and an array of signs. Used to represent chord factors, alterations, and added notes.

### Sample App

The sample app UI contains a tab for chord recognition and a tab for chord generation. The chord recognition UI has an onscreen piano keyboard for entering notes. The recognize button characterizes the chord using the library, and the name is displayed on screen. The chord generation UI contains controls for setting the chord's key, octave, factor, qualities, inversions, added notes, etc... On clicking generate, the notes for the chord are generated and the chord is played back.

### Apps That Use Library

Mixxmaster
[https://apps.apple.com/us/app/mixxmaster/id1381233927](https://apps.apple.com/us/app/mixxmaster/id1381233927)

## Authors

* **Derrick Ward** - [derrickward](https://github.com/derrickward)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* I am not an expert in music theory and learned chord theory on the fly while building this project. I am seeking contributors and testers with more depth of knowledge than I have to improve this project!
