package com.blindintuition.chordrecgen.ui.generator

import android.os.Bundle
import android.os.Handler
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.*
import androidx.core.view.children
import androidx.fragment.app.Fragment
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProviders
import com.blindintuition.chordrecgen.R
import com.blindintuition.chordrecgen.ui.recognizer.Synth
import kotlinx.android.synthetic.main.fragment_generator.*

class GeneratorFragment : Fragment() {

    private lateinit var generatorViewModel: GeneratorViewModel
    private val handler = Handler()
    lateinit var addNoteRadioGroup : RadioGroup
    lateinit var addNoteLayout : LinearLayout
    lateinit var addNoteSignRadioGroup : RadioGroup

    override fun onCreateView(
            inflater: LayoutInflater,
            container: ViewGroup?,
            savedInstanceState: Bundle?
    ): View? {
        generatorViewModel =
                ViewModelProviders.of(this).get(GeneratorViewModel::class.java)
        val root = inflater.inflate(R.layout.fragment_generator, container, false)
        val rootRadioGroup : RadioGroup = root.findViewById(R.id.rootRadioGroup)
        val qualityRadioGroup : RadioGroup = root.findViewById(R.id.qualityRadioGroup)
        val octaveRadioGroup : RadioGroup = root.findViewById(R.id.octaveRadioGroup)
        val factorRadioGroup : RadioGroup = root.findViewById(R.id.factorRadioGroup)
        val inversionRadioGroup : RadioGroup = root.findViewById(R.id.inversionRadioGroup)
        val factorQualityRadioGroup : RadioGroup = root.findViewById(R.id.factorQualityRadioGroup)
        val playButton : Button = root.findViewById(R.id.playButton)
        val clearButton : Button = root.findViewById(R.id.clearButton)
        val chordNameTextView : TextView = root.findViewById(R.id.chordNameTextView)
        val chordNotesTextView : TextView = root.findViewById(R.id.chordNotesTextView)
        val addButton : Button = root.findViewById(R.id.addButton)
        val alteredRadioGroup : RadioGroup = root.findViewById(R.id.alteredRadioGroup)

        addNoteRadioGroup = root.findViewById(R.id.addNoteRadioGroup)
        addNoteLayout = root.findViewById(R.id.addNoteLayout)
        addNoteSignRadioGroup = root.findViewById(R.id.addNoteSignRadioGroup)

        playButton.setOnClickListener { onPlay() }
        clearButton.setOnClickListener { generatorViewModel.onClear() }
        addButton.setOnClickListener { onAddNote() }
        rootRadioGroup.setOnCheckedChangeListener { radioGroup, i ->
            val rb: RadioButton = radioGroup.findViewById(i) as RadioButton
            generatorViewModel.root.value = (rb.tag as String).toInt()
        }
        qualityRadioGroup.setOnCheckedChangeListener { radioGroup, i ->
            val rb: RadioButton = radioGroup.findViewById(i) as RadioButton
            generatorViewModel.quality.value = (rb.tag as String).toInt()
        }
        octaveRadioGroup.setOnCheckedChangeListener { radioGroup, i ->
            val rb: RadioButton = radioGroup.findViewById(i) as RadioButton
            generatorViewModel.octave.value = (rb.tag as String).toInt()
        }

        factorRadioGroup.setOnCheckedChangeListener { radioGroup, i ->
            val rb: RadioButton = radioGroup.findViewById(i) as RadioButton
            generatorViewModel.factor.value = (rb.tag as String).toInt()
        }

        factorQualityRadioGroup.setOnCheckedChangeListener { radioGroup, i ->
            val rb: RadioButton = radioGroup.findViewById(i) as RadioButton
            generatorViewModel.factorQuality.value = (rb.tag as String).toInt()
        }

        inversionRadioGroup.setOnCheckedChangeListener { radioGroup, i ->
            val rb: RadioButton = radioGroup.findViewById(i) as RadioButton
            generatorViewModel.inversion.value = (rb.tag as String).toInt()
        }

        alteredRadioGroup.setOnCheckedChangeListener { radioGroup, i ->
            val rb: RadioButton = radioGroup.findViewById(i) as RadioButton
            generatorViewModel.alteration.value = (rb.tag as String).toInt()
        }

        generatorViewModel.chordName.observe(viewLifecycleOwner, Observer {
            chordNameTextView.text = it
        })

        generatorViewModel.chordNotes.observe(viewLifecycleOwner, Observer {
            chordNotesTextView.text = it
        })

        /*val textView: TextView = root.findViewById(R.id.text_dashboard)
        generatorViewModel.text.observe(viewLifecycleOwner, Observer {
            textView.text = it
        })*/
        return root
    }

    fun onPlay()
    {
        generatorViewModel.generate()
        Synth.playNotes(generatorViewModel.notes!!)

        handler.postDelayed({
            Synth.stopNotes(generatorViewModel.notes!!)
        },1000)
    }

    fun onAddNote()
    {
        val noteRb: RadioButton = addNoteRadioGroup.findViewById(addNoteRadioGroup.checkedRadioButtonId) as RadioButton
        val addedNoteTag = (noteRb.tag as String).toInt()

        val signRb: RadioButton = addNoteSignRadioGroup.findViewById(addNoteSignRadioGroup.checkedRadioButtonId) as RadioButton
        val addedNoteSignTag = (signRb.tag as String).toInt()

        generatorViewModel.addedNotes.value?.add(addedNoteTag)
        generatorViewModel.addedNoteSigns.value?.add(addedNoteSignTag)

        val view = LayoutInflater.from(context).inflate(R.layout.add_note_layout,addNoteLayout,false)
        (addNoteLayout as ViewGroup).addView(view)
        val textView = view.findViewById<TextView>(R.id.noteTextView)
        val closeButton = view.findViewById<Button>(R.id.xButton)
        closeButton.setOnClickListener { l ->
            val parentView = l.parent as View
            val vg = addNoteLayout as ViewGroup
            generatorViewModel.addedNotes.value?.removeAt(vg.indexOfChild(parentView))
            generatorViewModel.addedNoteSigns.value?.removeAt(vg.indexOfChild(parentView))
            vg.removeView(parentView)
        }
        textView.text = String.format("%s %s",noteRb.text,(if(addedNoteSignTag > 0) signRb.text else ""))
        view.tag = noteRb.tag
    }
}