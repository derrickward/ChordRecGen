package com.blindintuition.chordrecgenlib

class ChordGenerator {

    fun chordToMIDINotes(chord: Chord) : Array<ChordNote>
    {
        val chordNotes = arrayListOf<NoteRootOffset>()

        when(chord.quality) {
            Quality.Maj -> {
                ChordDefs.majTriad.addNotes(chordNotes, chord.inversion)
                chord.addNotesFromOffsets(chordNotes.toTypedArray())
                chord.triad = ChordDefs.majTriad
            }
            Quality.min -> {
                ChordDefs.minTriad.addNotes(chordNotes, chord.inversion)
                chord.addNotesFromOffsets(chordNotes.toTypedArray())
                chord.triad = ChordDefs.minTriad
            }

            Quality.aug -> {
                ChordDefs.augTriad.addNotes(chordNotes, chord.inversion)
                chord.addNotesFromOffsets(chordNotes.toTypedArray())
                chord.triad = ChordDefs.augTriad
            }
            Quality.dim -> {
                ChordDefs.dimTriad.addNotes(chordNotes, chord.inversion)
                chord.addNotesFromOffsets(chordNotes.toTypedArray())
                chord.triad = ChordDefs.dimTriad
            }
            Quality.sus2 -> {
                ChordDefs.sus2Triad.addNotes(chordNotes,chord.inversion)
                chord.addNotesFromOffsets(chordNotes.toTypedArray())
                chord.triad = ChordDefs.sus2Triad
            }
            Quality.sus4 -> {
                ChordDefs.sus4Triad.addNotes(chordNotes, chord.inversion)
                chord.addNotesFromOffsets(chordNotes.toTypedArray())
                chord.triad = ChordDefs.sus4Triad
            }
            else -> {
                ChordDefs.majTriad.addNotes(chordNotes, chord.inversion)
                chord.addNotesFromOffsets(chordNotes.toTypedArray())
                chord.triad = ChordDefs.majTriad
            }
        }

        parseFactors(chord)
        parseAlterations(chord)
        parseAdditions(chord)

        if (chord.ommission != null)
        {
            val ommissionOffset = if(chord.ommission == Degree.five)  chord.triad.fifth else chord.triad.third
            val note : ChordNote = (chord.rootNote + ommissionOffset).toChordNote()
            chord.notes.removeAll({ it == note })
        }

        val adjustedRoot = if(chord.inversion != Inversion.none) chord.rootNote + 12 else chord.rootNote

        chord.notes.forEach {
            if(it < adjustedRoot as ChordNote) {
                chord.invertedNotes.add(it)
            }
        }

        return chord.notes.toTypedArray()
    }

    private fun parseAdditions(chord: Chord)
    {
        chord.additions.forEach({ chord.notes.add(it.toNote(chord.rootNote)) })
    }

    private fun parseFactors(chord : Chord)
    {
        val tones = chord.factors
        val seventhOffsetVal = seventhOffset(chord.quality, chord.factorQuality)

        for (tone in tones)
        {
            val offsets = arrayListOf<NoteRootOffset>()
            //special case for "sixth" chords
            if (tone.degree == Degree.six || tone.degree == Degree.sixNine)
            {
                val extOffsets = ChordDefs.sixthChordDesignatorToOffset(tone.degree)
                offsets.addAll(extOffsets)
                chord.addNotesFromOffsets(offsets.toTypedArray())
                continue
            }

            val sigOffset = ChordDefs.signatureOffset(tone.signs.toTypedArray())
            val extensionOffset = ChordDefs.degreeToOffset[tone.degree]

            if(extensionOffset == null)
            {
                return
            }

            val degreeInScale = ChordDefs.offsetToMajDegree[extensionOffset.toInt()].degree
            val numberDegreeInScale = degreeInScale.number
            if ((numberDegreeInScale >= 7.toUByte()) && (numberDegreeInScale.toInt() % 2 == 1))
            {
                offsets.add((ChordDefs.majScaleToOffset[7] + seventhOffsetVal).toNoteRootOffset())

                for (note in 9..numberDegreeInScale.toInt() step 2)
                {
                    offsets.add( (ChordDefs.majScaleToOffset[note] +
                            (if(note == numberDegreeInScale.toInt()) sigOffset else 0)).toNoteRootOffset())
                }
            }

            chord.addNotesFromOffsets(offsets.toTypedArray())
        }
    }

    private fun parseAlterations(chord : Chord)
    {
        if(chord.alteredNotes.size > 0)
        {
            var idx = 0
            var alteredTone = chord.alteredNotes[0]
            for (j in 0 until chord.notes.size)
                    {
                        var note = chord.notes[j]
                        val offset = ChordDefs.offsetInExtendedChord(chord.rootNote,note)
                        val degree = ChordDefs.offsetToMajDegree[offset.toInt()].degree
                        if (degree == alteredTone.degree)
                        {
                            note = (note + ChordDefs.signatureOffset(alteredTone.signs.toTypedArray())).toChordNote()
                            chord.notes[j] = note
                            idx += 1
                            if (idx < chord.alteredNotes.size)
                            {
                                alteredTone = chord.alteredNotes[idx]
                            }
                        }
                    }
        }
    }

    private fun seventhOffset(chordQuality: Quality, factorQuality : Quality) : Byte
    {
        var offset : Byte = -1

        if (chordQuality == Quality.dim)
        {
            offset = -2
        }

        when(factorQuality)
        {
            Quality.Maj -> { offset = 0 }

            //case Designator.dom:
            Quality.halfDim -> { offset = -1 }

            // case Designator.min:
            //case Designator.aug:
            else -> {}
        }

        return offset
    }

}