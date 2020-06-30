package blindintuition.midi3d.midi

/**
 * Created by derrickward on 12/19/16.
 */
object MIDIConstants {
    const val TIME_STEP = 10L
    const val STATUS_BIT = 0x80.toByte()
    const val STATUS_NIBBLE = 0xF0.toByte()
    const val CHANNEL_NIBBLE = 0x0F.toByte()
    const val NOTE_ON = 0x90.toByte()
    const val NOTE_OFF = 0x80.toByte()
    const val PATCH_CHANGE = 0xC0.toByte()
    const val SYSEX = 0xF0.toByte()
    const val SYSEX_END = 0xF7.toByte()
    const val SYSEX_GENERIC = 0x7F.toByte()
    const val MIDI_PB_MESSAGE = 0xE0.toByte()
    const val MIDI_CC_MESSAGE = 0xB0.toByte()
    const val MOD_WHEEL_CC = 0x01.toByte()

    fun stringForNoteWithOctave(note: Byte): String {
        val octave = note / 12
        return String.format("%s%d", stringForNote(note), octave - 1)
    }

    fun stringForNote(note: Byte): String {
        return when (note % 12) {
            0 -> "C"
            1 -> "C\u266f"
            2 -> "D"
            3 -> "D\u266f"
            4 -> "E"
            5 -> "F"
            6 -> "F\u266f"
            7 -> "G"
            8 -> "G\u266f"
            9 -> "A"
            10 -> "A\u266f"
            11 -> "B"
            else -> ""
        }
    }
}