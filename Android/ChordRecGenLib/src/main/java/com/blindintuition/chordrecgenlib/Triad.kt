package com.blindintuition.chordrecgenlib

import blindintuition.midi3d.midi.MIDIConstants
import java.lang.Math.abs
import java.util.*
import kotlin.collections.HashMap

class Triad {

    enum class Required
    {
        Third, Fifth
    }

    var root : NoteRootOffset = 0
    var third : NoteRootOffset
    var fifth : NoteRootOffset
    var quality : Quality
    var requiredNote : NoteRootOffset

    constructor()
    {
        third = 3
        fifth = 5
        quality = Quality.Maj
        requiredNote = 3
    }

    constructor(third : NoteRootOffset, fifth : NoteRootOffset, required : NoteRootOffset,quality : Quality)
    {
        this.third = third
        this.fifth = fifth
        this.quality = quality
        this.requiredNote = required
    }

    fun addNotes(chordNotes : ArrayList<NoteRootOffset>, inversion : Inversion)
    {
        val notes = arrayOf(root,third,fifth)
        invert(notes, inversion)
        chordNotes.addAll(notes)
    }

    fun isSuspended() : Boolean
    {
        return quality == Quality.sus2 || quality == Quality.sus4
    }

    fun matchesNote(note : ChordNote) : Boolean
    {
        return third == note || fifth == note
    }

    fun matches(notes : Array<ChordNote>, triadNotes: Map<NoteRootOffset,Int>) : TriadMatch
    {
        val result = TriadMatch()
        result.triadType = quality
        result.triad = this
        result.rootIdx = triadNotes[0]!!
        result.notes = notes

        val rootNote = notes[triadNotes[0]!!]

        if (triadNotes[requiredNote] != null)
        {
            triadNotes[fifth]?.also { fifthNoteIdx ->
                val fifthNote = notes[fifthNoteIdx]
                addNoteToTriadMatch(rootNote, fifthNote, fifth, result)
            } ?:
            run {
                triadNotes[ChordDefs.sharpFifth]?.also { sharpFifthIdx ->
                    val fifthNote = notes[sharpFifthIdx]
                    result.alteredFifth = fifthNote
                    result.alteredFifthSign = Sign.sharp
                    addNoteToTriadMatch( rootNote, fifthNote, ChordDefs.sharpFifth, result)
                } ?:
                triadNotes[ChordDefs.flatFifth]?.also { flatFifthIdx ->
                    val fifthNote = notes[flatFifthIdx]
                    result.alteredFifth = fifthNote
                    result.alteredFifthSign = Sign.flat
                    addNoteToTriadMatch(rootNote,fifthNote, ChordDefs.flatFifth, result)
                } ?:
                run {
                    result.omission = Degree.five
                }
            }

            triadNotes[third]?.also { thirdNoteIdx ->
                val thirdNote = notes[thirdNoteIdx]
                addNoteToTriadMatch(rootNote, thirdNote,third,result)
            } ?:
            run {
                result.omission = Degree.three
            }
        }

        for (note in notes)
        {
            if (!result.triadNotes.contains(note) && abs(note - rootNote) % 12 != 0)
            {
                result.nonTriadNotes.add(note)
            }
        }

        return result
    }


    fun addNoteToTriadMatch(rootNote: ChordNote, note: ChordNote, offset : NoteRootOffset,result : TriadMatch)
    {
        result.triadNotes.add(note)

        if (note < rootNote)
        {
            result.invertedNotes.add(note)
            result.inversion = if(offset == third) Inversion.first else Inversion.second
        }
    }

    companion object Triad {

        fun extractTriadNotes(rootIdx: Int, notes : Array<ChordNote>) : HashMap<NoteRootOffset,Int>
        {
            val triadNotes = hashMapOf<NoteRootOffset,Int>()
            val baseNote = notes[rootIdx]
            for (i in 0 until notes.size)
            {
                val noteOffset = ChordDefs.offsetInChord(baseNote,notes[i])

                if ((noteOffset == 0.toByte()) && (triadNotes[0] == null))
                {
                    triadNotes[0] = i
                    continue
                }

                if (noteOffset >= 2 && noteOffset <= 8)
                {
                    triadNotes[noteOffset] = i
                }
            }

            return triadNotes
        }

        private fun isAlternateFifth(offset: NoteRootOffset): Boolean {
            return offset == ChordDefs.flatFifth || offset == ChordDefs.sharpFifth
        }

        fun invert(notes: Array<NoteRootOffset>, inversion: Inversion) {
            when(inversion)
            {
                Inversion.first -> {
                    notes[0] = (notes[0] + 12).toNoteRootOffset()
                }
                Inversion.second -> {
                    notes[0] = (notes[0] + 12).toNoteRootOffset()
                    notes[1] = (notes[1] + 12).toNoteRootOffset()
                }
                Inversion.third -> {
                    notes[0] = (notes[0] + 12).toNoteRootOffset()
                    notes[1] = (notes[1] + 12).toNoteRootOffset()
                    notes[2] = (notes[2] + 12).toNoteRootOffset()
                }
                else -> {

                }
            }
        }
    }

    class TriadMatch
    {
        var nonTriadNotes = arrayListOf<ChordNote>()
        var invertedNotes = arrayListOf<ChordNote>()
        lateinit var notes : Array<ChordNote>
        var omission : Degree? = null
        var triadNotes = arrayListOf<ChordNote>()
        lateinit var triad : com.blindintuition.chordrecgenlib.Triad
        var rootIdx : Int = 0
        var triadType = Quality.Maj
        var alteredFifth : ChordNote? = null
        var alteredFifthSign : Sign = Sign.natural
        var inversion = Inversion.none
        var isHalfDiminished = false

        fun getName() : String
        {
            val rootNote = notes[rootIdx]
            val rootName = MIDIConstants.stringForNote(rootNote)
            val alteration = if(alteredFifth == null) "" else String.format("%s%s",Degree.five.text,alteredFifthSign.text)
            return String.format("%s%s %s",rootName,triadType.text,alteration)
        }

        fun getScore() : Int
        {
            if(triadNotes.size == 0)
            {
                return 0
            }
            else
            {
                val score = triadNotes.size - rootIdx
                    + (if(omission == null) 4 else 0)
                    + (if(alteredFifth == null) 4 else 0)

                return score
            }
        }
    }
}

