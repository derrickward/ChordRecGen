package com.blindintuition.chordrecgenlib

import kotlin.collections.ArrayList

class ChordRecognizer {

    private var matches = arrayListOf<Triad.TriadMatch>()

    fun notesToChord(notes : Array<ChordNote>) : Array<ChordGroup>
    {
        if (notes.size < 2)
        {
            return emptyArray()
        }

        val chordGroups = arrayListOf<ChordGroup>()
        notes.sort()

        if (notes.size == 2)
        {
            val chordGroup = ChordGroup()
            val chord = Chord(notes)
            chord.rootNote = notes[0]
            chordGroup.add(chord)
            chordGroups.add(chordGroup)
            return chordGroups.toTypedArray()
        }

        val bestMatches = arrayListOf<Triad.TriadMatch>()

        matches.clear()

        findTriad(notes)

        for (match in matches)
        {
            if (match.getScore() > 0)
            {
                //print("chord: \(match.getName()) score: \(match.getScore())")
                bestMatches.add(match)
            }
        }

        for (triad in bestMatches)
        {
            val chords = ChordGroup()
            val chord = Chord(notes, triad)

            // inversions and slash chords
            for (note in triad.nonTriadNotes)
            {
                if (note < chord.rootNote)
                {
                    chord.invertedNotes.add(note)
                }
            }

            //print("match ",chord.getRootName(),triad.getScore())

            findFactors(chord, triad)
            chords.chords.add(chord)

            val polyChords = notesToChord(triad.nonTriadNotes.toTypedArray())
            if (polyChords.size > 0)
            {
                val polyChordGroup = polyChords.first()
                val polyChord = polyChordGroup.chords.first()

                if (!polyChord.isDyad())
                {
                    chords.add(polyChord)
                    triad.nonTriadNotes.removeAll({ polyChord.notes.contains(it) })
                }
            }

            triad.nonTriadNotes.removeAll({ chord.invertedNotes.contains(it) })

            findAddedNotes(chord, triad.nonTriadNotes.toTypedArray())
            //print("inversion: \(chord.inversion.rawValue)")
            chordGroups.add(chords)
        }

        val bestGroups = arrayListOf<ChordGroup>()
        for (group in chordGroups)
        {
            //print(group.getFullName() + " value: ",group.getScore())
            val firstMatch = if(bestGroups.isEmpty()) null else bestGroups.first()
            if (bestGroups.size == 0 || group.getScore() == firstMatch?.getScore())
            {
                bestGroups.add(group)
            }
            else if (group.getScore() > firstMatch!!.getScore())
            {
                //print("new best ",group.getFullName(),group.getScore())
                bestGroups.clear()
                bestGroups.add(group)
            }
        }

        return bestGroups.toTypedArray()
    }

    private fun findFactors(chord: Chord, triad: Triad.TriadMatch)
    {
        // stack of thirds
        var numberDegreeInScale : UByte = 7.toUByte()
        var lastDegreeInChord = Degree.none
        val notesMatched = arrayListOf<ChordNote>()
        var i = 0
        var seventhChordType = Quality.dom
        val alteredDesignators = arrayListOf<Tone>()
        var seventhChordDesignator : Tone? = null

        while (i < triad.nonTriadNotes.size && numberDegreeInScale <= 13.toUByte())
        {
            val note = triad.nonTriadNotes[i]
            val noteOffset = ChordDefs.offsetInExtendedChord(chord.rootNote, note)
            val noteInScaleInfo = ChordDefs.offsetToMajDegree(chord.quality, noteOffset)
            val degreeInScale = Degree.numberToDegree( numberDegreeInScale)

            i += 1

            if (noteInScaleInfo.degree == degreeInScale)
            {
                if (noteInScaleInfo.degree == Degree.seven)
                {
                    seventhChordType = ChordDefs.seventhNoteToDesignator(chord.quality ,noteInScaleInfo.sign)
                    seventhChordDesignator = Tone(degreeInScale)
                    chord.inversion = (if(note < chord.rootNote && chord.inversion == Inversion.none) Inversion.third else chord.inversion)
                }
                else if (noteInScaleInfo.sign != Sign.natural)
                {
                    alteredDesignators.add(Tone(arrayOf(noteInScaleInfo.sign), degreeInScale))
                }
                else
                {
                    lastDegreeInChord = degreeInScale
                }

                notesMatched.add(note)
                numberDegreeInScale = (numberDegreeInScale + 2.toUByte()).toUByte()
            }
        }

        if (lastDegreeInChord != Degree.none)
        {
            chord.factorQuality = seventhChordType
            chord.addFactors(arrayOf(Tone(lastDegreeInChord)))

            if (!alteredDesignators.isEmpty())
            {
                chord.addFactors(alteredDesignators.toTypedArray())
            }
        }
        else if (seventhChordDesignator != null)
        {
            chord.factorQuality = seventhChordType
            chord.factors.add(0,seventhChordDesignator)
            if (alteredDesignators.isNotEmpty())
            {
                chord.addFactors(alteredDesignators.toTypedArray())
            }
        }

        triad.nonTriadNotes.removeAll({ notesMatched.contains(it) })
    }

    private fun findAddedNotes(chord: Chord, notes: Array<ChordNote>)
    {
        for (note in notes)
        {
            val offsetExtended : Int = ChordDefs.offsetInExtendedChord(chord.rootNote,note).toInt()
            val offset = ChordDefs.offsetInChord( chord.rootNote, note).toInt()
            val degree = ChordDefs.offsetToMajDegree[offsetExtended]

            if (chord.triad.matchesNote(offset.toChordNote()))
            {
                continue
            }

            if (degree.sign == Sign.natural)
            {
                chord.addAdditions(arrayOf(Tone(degree.degree)))
            }
            else
            {
                chord.addAdditions(arrayOf(Tone(arrayOf(degree.sign),degree.degree)))
            }
        }

        addedSixthNotes(chord)
    }

    private fun addedSixthNotes(chord : Chord)
    {
        // do a final pass to find the special case of added sixth and six/nine notes and reformat them as factors
        val factor = if (chord.factors.isNotEmpty()) chord.factors.first() else null

        if (factor == null || (factor.degree != Degree.seven))
        {
            if (chord.additions.contains(ChordDefs.sixthNote))
            {
                if (chord.additions.contains(ChordDefs.ninthNote))
                {
                    chord.factors.add(0,Tone(Degree.sixNine))
                    chord.additions.removeAll( { it == ChordDefs.sixthNote || it == ChordDefs.ninthNote })
                }
                else
                {
                    if (chord.quality != Quality.Maj)
                    {
                        chord.factorQuality = Quality.Maj
                    }
                    chord.factors.add(0,ChordDefs.sixthNote)
                    chord.additions.removeAll({ it == ChordDefs.sixthNote })
                }
            }
            else if (chord.additions.contains(ChordDefs.minSixthNote))
            {
                if (chord.quality != Quality.min)
                {
                    chord.factorQuality = Quality.min
                }
                chord.factors.add(0,ChordDefs.sixthNote)
                chord.additions.removeAll({ it == ChordDefs.minSixthNote })
            }
        }
    }

    private fun removeNotes(root: ChordNote, notes:  ArrayList<ChordNote>,notesToRemove: Array<NoteRootOffset>)
    {
        notes.removeAll({ notesToRemove.contains(ChordDefs.offsetInExtendedChord(root, it)) })
    }

    private fun findTriad(notes: Array<ChordNote>)
    {
        for (i in 0 until notes.size)
        {
            val triadNotes = Triad.extractTriadNotes(i, notes)
            for (triad in ChordDefs.triads)
            {
                matches.add(triad.matches(notes, triadNotes))
            }
        }
    }
}