package com.blindintuition.chordrecgen.ui.recognizer

import android.os.Bundle
import android.os.Handler
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProviders
import blindintuition.midi3d.midi.MIDIConstants
import com.blindintuition.chordrecgen.R
import com.blindintuition.chordrecgenlib.toChordNote
import com.blindintuition.pianoview.Piano

class RecognizerFragment : Fragment(), Piano.PianoKeyListener {

    private lateinit var recognizerViewModel: RecognizerViewModel
    val handler = Handler()

    override fun onCreateView(
            inflater: LayoutInflater,
            container: ViewGroup?,
            savedInstanceState: Bundle?
    ): View? {
        recognizerViewModel =
                ViewModelProviders.of(this).get(RecognizerViewModel::class.java)
        val root = inflater.inflate(R.layout.fragment_recognizer, container, false)
        val pianoView : Piano = root.findViewById(R.id.pianoView)
        val chordNameTextView : TextView = root.findViewById(R.id.chordNameTextView)
        val chordNotesTextView : TextView = root.findViewById(R.id.chordNotesTextView)
        val recognizeButton : Button = root.findViewById(R.id.recognizeButton)
        val clearButton : Button = root.findViewById(R.id.clearButton)
        val playButton : Button = root.findViewById(R.id.playButton)

        recognizerViewModel.chordName.observe(viewLifecycleOwner, Observer {
            chordNameTextView.text = it
        })

        recognizerViewModel.chordNotes.observe(viewLifecycleOwner, Observer {
            chordNotesTextView.text = it
        })

        recognizeButton.setOnClickListener { recognizerViewModel.onRecognize() }
        clearButton.setOnClickListener { onClear() }
        playButton.setOnClickListener { onPlay() }

        pianoView.setPianoKeyListener(this)
        return root
    }

    override fun keyPressed(id: Int, action: Int) {
        Log.d("recognizer",String.format("key pressed %d %d",id,action))

        val midiNote = (12 * 4 + id).toChordNote()
        if(action == 0)
        {
            recognizerViewModel.addChordNote(midiNote)
            Synth.sendMidi(MIDIConstants.NOTE_ON,midiNote,0x7f)
        }
        else if(action == 1)
        {
            Synth.sendMidi(MIDIConstants.NOTE_OFF,midiNote,0)
        }
    }

    fun onPlay()
    {
        if(!recognizerViewModel.notes.value.isNullOrEmpty()) {
            Synth.playNotes(recognizerViewModel.notes.value!!.toTypedArray())

            handler.postDelayed({
                Synth.stopNotes(recognizerViewModel.notes.value!!.toTypedArray())
            },1000)
        }
    }

    fun onClear()
    {
        recognizerViewModel.clear()
    }

}