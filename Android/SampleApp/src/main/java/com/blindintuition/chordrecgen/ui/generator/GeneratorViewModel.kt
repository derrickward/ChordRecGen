package com.blindintuition.chordrecgen.ui.generator

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.blindintuition.chordrecgenlib.*

class GeneratorViewModel : ViewModel() {

    var notes : Array<ChordNote>? = null
    val generator = ChordGenerator()

    private val _chordName = MutableLiveData<String>().apply {
        value = ""
    }

    val chordName : LiveData<String> = _chordName

    private val _chordNotes = MutableLiveData<String>().apply {
        value = ""
    }

    val chordNotes : LiveData<String> = _chordNotes

    val alteration : MutableLiveData<Int> = MutableLiveData<Int>(0)
    val inversion : MutableLiveData<Int> = MutableLiveData<Int>(0)
    val root : MutableLiveData<Int> = MutableLiveData<Int>(0)
    val quality : MutableLiveData<Int> = MutableLiveData<Int>(0)
    val factor : MutableLiveData<Int> = MutableLiveData<Int>(0)
    val factorQuality : MutableLiveData<Int> = MutableLiveData<Int>(0)
    val octave : MutableLiveData<Int> = MutableLiveData<Int>(5)
    val addedNotes: MutableLiveData<ArrayList<Int>> = MutableLiveData(arrayListOf())
    val addedNoteSigns: MutableLiveData<ArrayList<Int>> = MutableLiveData(arrayListOf())

    fun generate()
    {
        val chord = Chord()
        val designators = ArrayList<Tone>()

        when(quality.value)
        {
            0 -> chord.quality = Quality.Maj
            1 -> chord.quality = Quality.min
            2 -> chord.quality = Quality.aug
            3 -> chord.quality = Quality.dim
            4 -> chord.quality = Quality.sus2
            5 -> chord.quality = Quality.sus4
            else -> chord.quality = Quality.Maj
        }

        when(factorQuality.value)
        {
            1 -> chord.factorQuality = Quality.Maj
            2 -> chord.factorQuality = Quality.halfDim
        }

        when(factor.value)
        {
            1 -> designators.add(Tone(Degree.six))
            2 -> designators.add(Tone(Degree.seven))
            3 -> designators.add(Tone(Degree.nine))
            4 -> designators.add(Tone(Degree.sixNine))
            5 -> designators.add(Tone(Degree.eleven))
            6 -> designators.add(Tone(Degree.thirteen))
        }

        chord.addFactors(designators.toTypedArray())

        for(i in 0 until addedNotes.value!!.size)
        {
            var sign = Sign.natural
            var noteInScale = Degree.two
            val addedNoteIdx = addedNotes.value!![i]
            val addedNoteSignIdx = addedNoteSigns.value!![i]

            when (addedNoteSignIdx)
            {
                1 -> sign = Sign.flat
                2 -> sign = Sign.sharp
            }

            when(addedNoteIdx)
            {
                0 -> noteInScale = Degree.two
                1 -> noteInScale = Degree.four
                2 -> noteInScale = Degree.six
                3 -> noteInScale = Degree.nine
                4 -> noteInScale = Degree.eleven
                5 -> noteInScale = Degree.thirteen
            }

            chord.addAdditions(arrayOf(Tone(sign,noteInScale)))
        }


        when(inversion.value)
        {
            0 -> chord.inversion = Inversion.none
            1 -> chord.inversion = Inversion.first
            2 -> chord.inversion = Inversion.second
            3 -> chord.inversion = Inversion.third
        }

        when(alteration.value)
        {
            1 -> chord.alteredNotes.add(Tone(Sign.flat, Degree.five))
            2 -> chord.alteredNotes.add(Tone(Sign.sharp,Degree.five))
            3 -> chord.alteredNotes.add(Tone(Sign.flat,Degree.nine))
            4 -> chord.alteredNotes.add(Tone(Sign.sharp,Degree.nine))
            5 -> chord.alteredNotes.add(Tone(Sign.sharp, Degree.eleven))
        }

        chord.rootNote = (root.value!! + (12 * octave.value!!)).toChordNote()

        notes = generator.chordToMIDINotes(chord)
        _chordNotes.value = Chord.coalesceNotesToString(notes!!, true)
        _chordName.value = chord.getFullName()
    }

    fun onClear()
    {
        _chordNotes.value = ""
        _chordName.value = ""
    }
}