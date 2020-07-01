package com.blindintuition.chordrecgen.ui.recognizer

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import blindintuition.midi3d.midi.MIDIConstants
import com.blindintuition.chordrecgenlib.ChordGroup
import com.blindintuition.chordrecgenlib.ChordNote
import com.blindintuition.chordrecgenlib.ChordRecognizer

class RecognizerViewModel : ViewModel() {

    val recognizer = ChordRecognizer()
    var chords : Array<ChordGroup>? = null

    private val _text = MutableLiveData<String>().apply {
        value = "This is home Fragment"
    }
    val text: LiveData<String> = _text

    private val _chordName = MutableLiveData<String>().apply {
        value = ""
    }

    val chordName : LiveData<String> = _chordName

    private val _chordNotes = MutableLiveData<String>().apply {
        value = ""
    }

    val chordNotes : LiveData<String> = _chordNotes
    val notes = MutableLiveData<ArrayList<ChordNote>>(arrayListOf())

    fun addChordNote(note : ChordNote)
    {
        notes.value?.add(note)
        _chordNotes.value = String.format("%s %s",chordNotes.value, MIDIConstants.stringForNoteWithOctave(note))
    }

    fun onRecognize() {
        _chordName.value = ""
        if(!notes.value.isNullOrEmpty()) {
            val chordGroups = recognizer.notesToChord(notes.value!!.toTypedArray())
            chords = chordGroups
            _chordName.value = if(chordGroups.isEmpty()) "" else chordGroups.first().getFullName()
        }
    }

    fun clear()
    {
        notes.value?.clear()
        _chordNotes.value = ""
        _chordName.value = ""

    }
}