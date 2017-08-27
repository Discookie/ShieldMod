require("../../diff/diff_export")
require("../../vr/vr_export")
require("../../vr/vr_note_assign")
require("../helpers/auto_y")

function sgn_DefaultDoubleEnd_Gen(id, assigner, container)
    local rand = math.random
    local currentNote = container._notes[id]

    currentNote:setHand(Note.HandTypes.LEFT + Note.HandTypes.RIGHT)

    currentNote.pos.x = Diff.instance.spanX_offset
    currentNote.span.x = rand() * (Diff.instance.maxCrosshandSpan + Diff.instance.maxDoubleSpan - 2 * Diff.instance.minDoubleSpan) - Diff.instance.maxCrosshandSpan

    if currentNote.span.x > 0-Diff.instance.minDoubleSpan then
        currentNote.span.x = currentNote.span.x + 2 * Diff.instance.minDoubleSpan
    end

    AutoGenY(currentNote)

    currentNote.assigned = true
end

function sgn_DefaultDoubleEnd_Appl(id, assigner, container)
    local currentNote = container._notes[id]
    local nextTime = container:getNext(id, NoteContainer.FilterFlags.ENABLED_ONLY)

    if nextTime == true or nextTime.startTime - currentNote.endTime > 4 or (nextTime.startTime - currentNote.endTime > 2 and Track.instance:getNode(currentNote.startNode).intensity > 0.5) then
        return NoteAssigner.ApplicableTypes.FORCE
    else
        return NoteAssigner.ApplicableTypes.DISABLE
    end
end

EventHandler.instance:on(Events.INIT, function(ev)
        NoteAssigner.instance:add("sgn_default_double_end", sgn_DefaultDoubleEnd_gen, sgn_DefaultDoubleEnd_appl, 0, 5) -- make sure this is top priority and not randomly assigned
    end
)
