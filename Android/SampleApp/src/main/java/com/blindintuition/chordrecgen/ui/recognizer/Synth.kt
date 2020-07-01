package com.blindintuition.chordrecgen.ui.recognizer

import android.util.Log
import blindintuition.midi3d.midi.MIDIConstants
import com.blindintuition.chordrecgenlib.Chord
import com.blindintuition.chordrecgenlib.ChordNote
import org.billthefarmer.mididriver.MidiConstants
import org.billthefarmer.mididriver.MidiDriver

object Synth : MidiDriver.OnMidiStartListener {

    private var midi: MidiDriver = MidiDriver()

    fun stopSynth()
    {
        midi.stop()
    }

    fun startSynth()
    {
        midi.setOnMidiStartListener(this)
        midi.start()
    }

    fun sendMidi(m: Byte, n: Byte) {
        val msg = ByteArray(2)

        msg[0] = m
        msg[1] = n

        midi.write(msg)
    }

    // Send a midi message, 3 bytes
    fun sendMidi(m: Byte, n: Byte, v: Byte) {

        //Log.d(TAG,String.format("play midi:  %x %x %x",m,n,v))
        val msg = ByteArray(3)

        msg[0] = m
        msg[1] = n
        msg[2] = v

        midi.write(msg)
    }

    fun playNotes(notes : Array<ChordNote>)
    {
        for (note in notes)
        {
            sendMidi(MIDIConstants.NOTE_ON,note,0x7F)
        }
    }

    fun stopNotes(notes : Array<ChordNote>)
    {
        for (note in notes)
        {
            sendMidi(MIDIConstants.NOTE_OFF,note,0)
        }
    }

    fun selectInstrument(instrument: Byte)
    {
        sendMidi( (MidiConstants.PROGRAM_CHANGE + 0).toByte(),instrument)
    }

    override fun onMidiStart()
    {
        val config = midi.config()!!
        val info = String.format(
            "%d %d %d %d", config[0],
            config[1], config[2], config[3])

      //  selectInstrument(0.toByte())

       // Log.d(TAG,info)
        // midi.setVolume(100)
    }
}