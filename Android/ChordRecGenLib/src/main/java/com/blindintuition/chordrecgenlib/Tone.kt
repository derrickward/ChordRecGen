package com.blindintuition.chordrecgenlib

class Tone {

    val signs : ArrayList<Sign> = arrayListOf<Sign>()
    var degree : Degree

    constructor()
    {
        degree = Degree.none
    }

    constructor(signs : Array<Sign>, degree : Degree)
    {
        this.signs.addAll(signs)
        this.degree = degree
    }

    constructor(sign : Sign, degree : Degree)
    {
        this.signs.add(sign)
        this.degree = degree
    }

    constructor(degree : Degree)
    {
        this.degree = degree
    }

/*    public static func ==(lhs: Tone, rhs: Tone) -> Bool {
        return lhs.degree == rhs.degree && lhs.signs == rhs.signs
    }
*/
    fun toOffset() : NoteRootOffset
    {
        val sigOffset = ChordDefs.signatureOffset(signs.toTypedArray())
        return (ChordDefs.degreeToOffset[degree]!! + sigOffset).toNoteRootOffset()
    }

    fun toNote(root : ChordNote) : ChordNote
    {
        return (root + toOffset()).toChordNote()
    }

    fun has(degree: Degree) : Boolean
    {
        return this.degree == degree
    }

    fun has(sign: Sign, degree: Degree) : Boolean
    {
        return !this.signs.isEmpty() && this.signs.first() == sign && this.degree == degree
    }
}