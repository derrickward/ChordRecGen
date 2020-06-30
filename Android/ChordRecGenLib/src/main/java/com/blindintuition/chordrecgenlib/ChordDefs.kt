package com.blindintuition.chordrecgenlib

import java.util.*
import kotlin.collections.HashMap

object ChordDefs {

    data class DegreeInScale(val degree: Degree, val sign: Sign)

    val majScaleToOffset = arrayOf<NoteRootOffset>(0,0,2,4,5,7,9,11,12,14,16,17,19,21)
    val minScaleToOffset = arrayOf<NoteRootOffset>(0,0,2,3,5,7,8,10,12,14,16,17,19,21)

    val sharpFifth = sharpNote(majScaleToOffset[5])
    val flatFifth = flatNote(majScaleToOffset[5])

    val sixthNote = Tone(Degree.six)
    val minSixthNote = Tone(arrayOf(Sign.sharp),Degree.five)
    val ninthNote = Tone(Degree.nine)

    val majTriad = Triad(majScaleToOffset[3], majScaleToOffset[5], majScaleToOffset[0],Quality.Maj)
    val minTriad = Triad(minScaleToOffset[3], minScaleToOffset[5], minScaleToOffset[3],Quality.min)
    val dimTriad = Triad(minScaleToOffset[3], flatNote(minScaleToOffset[5]),flatNote(minScaleToOffset[5]),Quality.dim)
    val augTriad = Triad(majScaleToOffset[3], sharpNote(majScaleToOffset[5]),sharpNote(majScaleToOffset[5]), Quality.aug)
    val sus2Triad = Triad(majScaleToOffset[2],majScaleToOffset[5], majScaleToOffset[2],Quality.sus2)
    val sus4Triad = Triad(majScaleToOffset[4],majScaleToOffset[5], majScaleToOffset[4],Quality.sus4)

    val triads = arrayOf(majTriad,minTriad,dimTriad,augTriad,sus2Triad,sus4Triad)

    val degreeToOffset : HashMap<Degree,NoteRootOffset> = hashMapOf(
        Degree.two to majScaleToOffset[2],
        Degree.three to majScaleToOffset[3],
        Degree.four to majScaleToOffset[4],
        Degree.five to majScaleToOffset[5],
        Degree.six to majScaleToOffset[6],
        Degree.seven to minScaleToOffset[7],
        Degree.nine to majScaleToOffset[9],
        Degree.eleven to minScaleToOffset[11],
        Degree.thirteen to minScaleToOffset[13])

    val offsetToDimSeventh : HashMap<NoteRootOffset, DegreeInScale> = hashMapOf(
        9.toNoteRootOffset() to DegreeInScale(Degree.seven,Sign.flat),
        10.toNoteRootOffset() to DegreeInScale(Degree.seven,Sign.natural),
        11.toNoteRootOffset() to DegreeInScale(Degree.seven,Sign.sharp)
    )

    fun seventhNoteToDesignator(quality: Quality,sign : Sign) : Quality
    {
        if (quality == Quality.dim)
        {
            return dimSeventhNoteSignToDesignators[sign]!!
        }

        return seventhNoteSignToDesignators[sign]!!
    }

    val dimSeventhNoteSignToDesignators : HashMap<Sign,Quality> = hashMapOf(
        Sign.flat to Quality.dom,
        Sign.natural to Quality.halfDim,
        Sign.sharp to Quality.Maj
    )

    val seventhNoteSignToDesignators : HashMap<Sign,Quality> = hashMapOf(
        Sign.flat to Quality.dom,
        Sign.natural to Quality.Maj
    )

    val offsetToMajDegree : Array<DegreeInScale> =
        arrayOf( DegreeInScale(Degree.root,Sign.natural),DegreeInScale(Degree.two,Sign.flat),DegreeInScale(Degree.two,Sign.natural),
            DegreeInScale(Degree.three,Sign.flat),DegreeInScale(Degree.three,Sign.natural),DegreeInScale(Degree.four,Sign.natural),DegreeInScale(Degree.five,Sign.flat),
            DegreeInScale(Degree.five,Sign.natural),DegreeInScale(Degree.five,Sign.sharp),DegreeInScale(Degree.six,Sign.natural),DegreeInScale(Degree.seven,Sign.flat),
            DegreeInScale(Degree.seven,Sign.natural),DegreeInScale(Degree.eight,Sign.natural),DegreeInScale(Degree.nine,Sign.flat),DegreeInScale(Degree.nine,Sign.natural),
            DegreeInScale(Degree.nine,Sign.sharp),DegreeInScale(Degree.eleven,Sign.flat),DegreeInScale(Degree.eleven,Sign.natural),DegreeInScale(Degree.eleven,Sign.sharp),
            DegreeInScale(Degree.twelve,Sign.natural),DegreeInScale(Degree.thirteen,Sign.flat),DegreeInScale(Degree.thirteen,Sign.natural),DegreeInScale(Degree.thirteen,Sign.sharp))

    fun sixthChordDesignatorToOffset(designator : Designator) : Array<NoteRootOffset>
    {
        if (Degree.six == designator) { return arrayOf(majScaleToOffset[6]) }
        if (Quality.min == designator) { return arrayOf(minScaleToOffset[6]) }
        if (Quality.Maj == designator) { return arrayOf(majScaleToOffset[6],majScaleToOffset[7]) }
        if (Degree.sixNine == designator) { return arrayOf(majScaleToOffset[6],majScaleToOffset[9]) }

        return arrayOf<NoteRootOffset>()
    }

    fun flatNote(noteOffset : NoteRootOffset) : NoteRootOffset
    {
        return (noteOffset - 1).toNoteRootOffset()
    }

    fun sharpNote(noteOffset : NoteRootOffset) : NoteRootOffset
    {
        return (noteOffset + 1).toNoteRootOffset()
    }

    fun signatureOffset(designators : Array<Sign>) : Byte
    {
        var offsetTotal : Byte = 0
        var offset : Byte = 0
        for (designator in designators)
        {
            offset = 0
            if (designator == Sign.flat)
            {
                offset = -1
            }
            else if (designator == Sign.sharp)
            {
                offset = 1
            }
            else if (designator == Sign.natural)
            {
            }

            offsetTotal = (offsetTotal + offset).toByte()
        }

        return offsetTotal
    }

    fun offsetInExtendedChord(rootNote: ChordNote, note: ChordNote) : NoteRootOffset
    {
        if (note < rootNote || note - rootNote > majScaleToOffset[13])
        {
            return ((12 + note % 12) - (rootNote % 12) % 12).toNoteRootOffset()
        }
        else
        {
            return (note - rootNote).toNoteRootOffset()
        }
    }

    fun offsetInChord(rootNote: ChordNote, note: ChordNote) : NoteRootOffset
    {
        return  (((note % 12)  - (rootNote % 12) + 12) % 12).toNoteRootOffset()
    }

    fun offsetToMajDegree(quality : Quality,offset : NoteRootOffset) : DegreeInScale
    {
        var degree : DegreeInScale? = null
        if (quality == Quality.dim)
        {
            degree = offsetToDimSeventh[offset]
        }

        if (degree == null)
        {
            degree = offsetToMajDegree[offset.toInt()]
        }

        return degree
    }
}

fun Int.toChordNote() : ChordNote
{
    return this.toByte()
}

fun Int.toNoteRootOffset() : NoteRootOffset
{
    return this.toByte()
}