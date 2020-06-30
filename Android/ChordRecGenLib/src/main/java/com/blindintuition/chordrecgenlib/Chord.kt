package com.blindintuition.chordrecgenlib

import android.util.Log
import blindintuition.midi3d.midi.MIDIConstants
import java.lang.StringBuilder

//
//  ChordRecognizeGenerate
//
//  Created by Derrick Ward on 12/20/19.
//  Copyright © 2019 Derrick Ward. All rights reserved.
//

enum class Inversion { none,first,second,third }
enum class Form { short,long }

enum class ChordRoot(val offset : Int)
{
    C(0),
    Csharp(1),
    D(2),
    Dsharp(3),
    E(4),
    F(5),
    Fsharp(6),
    G(7),
    Gsharp(8),
    A(9),
    Asharp(10),
    B(11)
}

typealias ChordNote = Byte
typealias NoteRootOffset = Byte

class Chord
{
    var additions = arrayListOf<Tone>()
    var factors = arrayListOf<Tone>()
    var ommission : Degree? = null
    var quality : Quality = Quality.Maj
    var factorQuality : Quality = Quality.dom
    var notes : ArrayList<ChordNote>
    var invertedNotes : ArrayList<ChordNote> = arrayListOf()
    var alteredNotes = arrayListOf<Tone>()
    lateinit var triad : Triad
    var octave : Byte = 0
    var inversion : Inversion = Inversion.none
    private var triadScore : Int = 0

    var rootNote : ChordNote = 0
        get() = field
        set(value) {
            field = value
            octave = (value / 12).toByte()
        }

    constructor()
    {
        notes = arrayListOf<ChordNote>()
        invertedNotes = arrayListOf<ChordNote>()
    }

    constructor(notes: Array<ChordNote>)
    {
        this.notes = ArrayList<ChordNote>(notes.toList())
        invertedNotes = arrayListOf<ChordNote>()
    }

    constructor(root : ChordRoot,octave : Byte, quality : Quality,factor : Degree, factorQuality : Quality)
    {
        rootNote = (Degree.root.ordinal + 12 * octave).toChordNote()
        this.quality = quality
        this.octave = octave
        this.factorQuality = factorQuality
        setFactor(factor)
        this.invertedNotes = arrayListOf<ChordNote>()
        this.notes = arrayListOf<ChordNote>()
    }

    constructor(rootNote : ChordNote,quality : Quality,factor : Degree, factorQuality : Quality)
    {
        this.octave = (rootNote / 12).toChordNote()
        this.rootNote = rootNote
        this.quality = quality
        this.factorQuality = factorQuality
        setFactor(factor)
        this.invertedNotes = arrayListOf<ChordNote>()
        this.notes = arrayListOf<ChordNote>()
    }

    constructor(notes:Array<ChordNote>, triadResult: Triad.TriadMatch)
    {
        rootNote = notes[triadResult.rootIdx]
        quality = triadResult.triadType
        invertedNotes = triadResult.invertedNotes
        inversion = triadResult.inversion
        ommission = triadResult.omission
        triad = triadResult.triad
        triadScore = triadResult.getScore()
        if (triadResult.alteredFifth != null)
        {
            alteredNotes.add(Tone(arrayOf(triadResult.alteredFifthSign), Degree.five))
        }
        this.notes = ArrayList<ChordNote>(notes.toList())
    }

    fun isDyad() : Boolean
    {
        return notes.size == 2
    }

    fun isPowerChord() : Boolean
    {
        return isDyad() && ChordDefs.offsetInExtendedChord(notes.first(), notes.last()) == ChordDefs.majTriad.fifth
    }

    fun isSuspended() : Boolean
    {
        return quality == Quality.sus4 || quality == Quality.sus2
    }

    fun removeIntersect(chordNotes : Array<ChordNote>)
    {
      //  notes.removeAll(where: { chordNotes.contains($0) })
    }

    fun addAdditions(designators: Array<Tone>)
    {
        additions.addAll(designators)
    }

    fun addFactors(factors: Array<Tone>)
    {
        this.factors.addAll(factors)
    }

    fun setFactor(degree: Degree)
    {
        clearFactors()
        if (degree != Degree.none)
        {
            factors.add(Tone(degree))
        }
    }

    fun clearFactors()
    {
        factors.clear()
    }

    fun getFullName() : String
    {
        return getFullName(Form.long)
    }

    fun getFullName(formType : Form) : String
    {
        val builder = StringBuilder()

        builder.append(getDesignatorsName(formType))

        if(isSuspended())
        {
            builder.insert(0,MIDIConstants.stringForNote(rootNote))
            builder.append(" ")
            builder.append(Chord.designatorToString(quality, formType))
        }
        else
        {
            builder.insert(0,getRootName())
        }

        if(invertedNotes.isNotEmpty())
        {
            builder.append(Delimiter.slash.text)
            builder.append(MIDIConstants.stringForNote(invertedNotes.first()))
        }

        return builder.toString()
    }

    private fun isHalfDiminished() : Boolean
    {
        //var isHalfDim = self.factors.count >= 1 && factorQuality == Quality.halfDim

        //if !isHalfDim
        //{
        val isHalfDim = factors.size >= 2 && (factors[0].has( Degree.seven) && factors[1].has(Sign.flat,Degree.five))
        //}
        return isHalfDim
    }

    private fun isHalfDiminishedSeventh(offset: NoteRootOffset) : Boolean
    {
        return quality == Quality.dim && offset == ChordDefs.flatNote(ChordDefs.majScaleToOffset[7])
    }

    fun getRootName() : String
    {
        return getRootName(Form.long)
    }

    fun getRootName(formType: Form) : String
    {
        val builder = StringBuilder()

        if(isDyad())
        {
            if (isPowerChord())
            {
                builder.append(MIDIConstants.stringForNote(notes[0]))
                builder.append(Degree.five.text)
            }
            else
            {
                builder.append(MIDIConstants.stringForNote(notes[0]))
                builder.append(" ")
                builder.append(MIDIConstants.stringForNote(notes[1]))
            }
        }
        else
        {
            builder.append(MIDIConstants.stringForNote(rootNote))
            if (quality != Quality.Maj)
            {
                builder.append(Chord.designatorToString(quality,formType))
            }
        }
        return builder.toString()
    }

    fun addNotesFromOffsets(offsets : Array<NoteRootOffset>)
    {
        offsets.forEach({
            val note = (rootNote + it).toChordNote()
            if(!notes.contains(note))
            {
                notes.add(note)
            }
        })
    }

    fun getScore() : Int
    {
        return triadScore + (if (isHalfDiminished())  1 else 0) - additions.size
    }

    fun add(notesToAdd : Array<ChordNote>)
    {
        removeIntersect(notesToAdd)
        notes.addAll(notesToAdd)
    }

    fun getDesignatorsName(formType : Form) : String
    {
        val builder = StringBuilder()

        val extendedAlteredNotes = alteredNotes.filter({ it.degree.number > 7.toUByte() })

        if(extendedAlteredNotes.isEmpty()) {
            coalesceDesignators(alteredNotes.toTypedArray(),builder)

            if (factors.isNotEmpty()) {
                if (factorQuality != Quality.dom && factorQuality != Quality.dim) {
                    builder.append(" ")
                    builder.append(designatorToString(factorQuality, formType))
                }
            }

            coalesceDesignators(factors.toTypedArray(), builder)
            if (factors.isEmpty()) {
                builder.append(" ")
            }
        }
        else if (factors.isNotEmpty())
        {
            coalesceDesignators(alteredNotes.toTypedArray(),builder)
            builder.insert(0,Degree.seven.text)
        }

        coalesceDesignators(additions.toTypedArray(),Delimiter.add,builder)

        if(ommission != null)
        {
            builder.append(" ")
            builder.append(Delimiter.omit.text)
            builder.append(ommission?.text)
        }
        return builder.toString()
    }

    companion object {

        private fun designatorToString(designator: Designator, form: Form) : String
        {
            if ((Quality.dom == designator) || (Sign.natural == designator))
            {
                return ""
            }
            else {
                return if(form == Form.short) designator.shortText else designator.text
            }
        }

        fun coalesceNotesToString(notes: Array<ChordNote>, isShowingOctave: Boolean): String
        {
            val builder = StringBuilder()
            for (note in notes) {
                if (isShowingOctave) {
                    builder.append(MIDIConstants.stringForNoteWithOctave(note.toByte()))
                } else {
                    builder.append(MIDIConstants.stringForNote(note.toByte()))
                }
                builder.append(" ")
            }
            Log.d("Chord",builder.toString())
            return builder.toString()
        }

        fun coalesceDesignatorsToString(tone: Tone): String {
            val builder = StringBuilder()
            for (designator in tone.signs) {
                builder.append(designatorToString(designator, Form.long))
            }
            builder.append(tone.degree.text)

            return builder.toString()
        }

        private fun coalesceDesignators(tones: Array<Tone>, builder: StringBuilder) {
            coalesceDesignators(tones, Delimiter.empty, builder)
        }

        private fun coalesceDesignators(tones: Array<Tone>, delimiter: Designator, builder: StringBuilder)
        {
            for (tone in tones) {
                builder.append(delimiter.text)
                builder.append(coalesceDesignatorsToString(tone))
                builder.append(" ")
            }
        }
    }
}
