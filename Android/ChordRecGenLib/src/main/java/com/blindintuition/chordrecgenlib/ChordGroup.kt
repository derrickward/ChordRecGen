package com.blindintuition.chordrecgenlib

import java.lang.StringBuilder

class ChordGroup {

    var chords = arrayListOf<Chord>()

    fun getNotes() : Array<ChordNote>
    {
        val allNotes = arrayListOf<Byte>()
        for (chord in chords)
        {
            allNotes.addAll(chord.notes)
        }
        return allNotes.toTypedArray()
    }

    fun getFullName() : String
    {
        val builder = StringBuilder()
        for (i in 0 until chords.size)
        {
            if (i > 0)
            {
                builder.append(" - ")
            }
            builder.append(chords[i].getFullName())
        }

        if (chords.size > 1)
        {
            builder.append(" (poly)")
        }

        return builder.toString()
    }

    fun add(newChord : Chord)
    {
        chords.forEach({ it.removeIntersect(newChord.notes.toTypedArray()) })
        chords.add(newChord)
    }

    fun isPolyChord() : Boolean
    {
        return chords.size > 1
    }

    fun getScore() : Int
    {
        var score = 0
        chords.forEach({ score += it.getScore() })
        return score / chords.size
    }
}