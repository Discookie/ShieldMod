require("../../diff/diff_export")
require("../../vr/vr_note_assign")
require("../helpers/auto_y")

function sgn_DefaultSingle_Gen(id, assigner, container)
    local rand = math.random
    local currentNote = container._notes[id]

    if rand() < 0.5 then
        currentNote:setHand(Note.HandTypes.LEFT)
    else
        currentNote:setHand(Note.HandTypes.RIGHT)
    end

    currentNote.pos.x = (rand()-0.5) * Diff.instance.spanX + Diff.instance.spanX_offset

    AutoGenY(currentNote)

    currentNote.assigned = true
end

function sgn_DefaultSingle_Appl(id, assigner, container)
    return NoteAssigner.ApplicableTypes.WEIGHT
end

EventHandler.instance:on(Events.INIT, function(ev)
        NoteAssigner.instance:add("sgn_default_single", sgn_DefaultSingle_gen, sgn_DefaultSingle_appl, 1-Diff.instance.doubleFactor, 15)
    end
)
