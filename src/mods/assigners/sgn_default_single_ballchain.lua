require("../../diff/diff_export")
require("../../vr/vr_note_assign")
require("../helpers/auto_y")
require("../helpers/offsets")

function sgn_DefaultSingleBallchain_gen(id, assigner, container)
    local rand = math.random
    local currentNote = container._notes[id]

    if rand() < 0.5 then
        currentNote:setHand(Note.HandTypes.LEFT)
    else
        currentNote:setHand(Note.HandTypes.RIGHT)
    end

    currentNote.pos.x = (rand()-0.5) * Diff.instance.spanX + Diff.instance.spanX_offset

    if currentNote.lengthNode > 44 then
        currentNote.offsetFunc = offs_Sine
    else
        currentNote.offsetFunc = offs_Triangle
    end
    currentNote.objects.tail = Note.Objects.DEFAULT

    AutoGenY(currentNote)

    currentNote.assigned = true
end

function sgn_DefaultSingleBallchain_appl(id, assigner, container)
    local currentNote = container._notes[id]
    local currentNode = Track.instance:getNode(container._notes[id].startNode)

    if (currentNote.lengthNode>11) and (currentNode.intensity<.6) then
        return NoteAssigner.ApplicableTypes.WEIGHT
    elseif (currentNote.lengthNode>22) and (currentNode.intensity<.9) then
        return NoteAssigner.ApplicableTypes.WEIGHT
    else
        return NoteAssigner.ApplicableTypes.DISABLE
    end
end

EventHandler.instance:on(Events.INIT, function(ev)
        NoteAssigner.instance:add("sgn_default_single_ballchain", sgn_DefaultSingleBallchain_gen, sgn_DefaultSingleBallchain_appl, 1-Diff.instance.doubleFactor, 14)
    end
)
