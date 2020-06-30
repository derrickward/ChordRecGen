package com.blindintuition.chordrecgenlib

enum class Quality (override val text: String,override val shortText : String) : Designator
{
    Maj("Maj","M"),
    min("min","m"),
    sus2("sus2","sus2"),
    sus4("sus4","sus4"),
    dim("dim","o"),
    aug("aug","+"),
    dom("dom","dom"),
    halfDim("ø","ø")
}


enum class Degree(val number: UByte, override val text : String) : Designator {
    none(0.toUByte(),"0"),
    root(1.toUByte(),"1"),
    two(2.toUByte(),"2"),
    three(3.toUByte(),"3"),
    four(4.toUByte(),"4"),
    five(5.toUByte(),"5"),
    six(6.toUByte(),"6"),
    seven(7.toUByte(),"7"),
    eight(8.toUByte(),"8"),
    nine(9.toUByte(),"9"),
    eleven(11.toUByte(),"11"),
    twelve(12.toUByte(),"12"),
    thirteen(13.toUByte(),"13"),
    sixNine(0.toUByte(),"6/9");

    override val shortText : String
        get() = text

    companion object {

        fun numberToDegree(number: UByte): Degree {
            for (v in values()) {
                if (v.number == number) {
                    return v
                }
            }
            return none
        }
    }
}

enum class Sign(override val text : String) : Designator
{
    flat("♭"),
    sharp("♯"),
    natural("♮");

    override val shortText : String
        get() = text

}

enum class Delimiter(override val text : String) : Designator
{
    omit("omit"),
    add("add"),
    slash(" / "),
    empty("");

    override val shortText : String
        get() = text
}

interface Designator
{
    val text: String
    val shortText : String
}