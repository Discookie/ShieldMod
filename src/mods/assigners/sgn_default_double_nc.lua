require("../../diff/diff_export")
require("../../track/track_export")
require("../../vr/vr_note_assign")
require("../helpers/auto_y")

function sgn_DefaultDoubleNC_gen(id, assigner, container)
    local rand = math.random
    local currentNote = container._notes[id]

    if rand() < 0.5 then
        currentNote:setHand(Note.HandTypes.LEFT + Note.HandTypes.RIGHT)
    end

    currentNote.pos.x = (rand()-0.5) * (Diff.instance.spanX - 2 * Diff.instance.minDoubleSpan) + Diff.instance.spanX_offset

    local distToBorder = (Diff.instance.spanX / 2) - math.abs(currentNote.pos.x)
    currentNote.span.x = rand() * (math.min(Diff.instance.maxCrosshandSpan, distToBorder) + math.min(Diff.instance.maxDoubleSpan, distToBorder) - 2 * Diff.instance.minDoubleSpan) - math.min(Diff.instance.maxCrosshandSpan, distToBorder)

    if currentNote.span.x > 0-Diff.instance.minDoubleSpan then
        currentNote.span.x = currentNote.span.x + 2 * Diff.instance.minDoubleSpan
    end

    AutoGenY(currentNote)

    currentNote.assigned = true
end

function sgn_DefaultDoubleNC_appl(id, assigner, container)
    if Track.instance:getNode(container._notes[id].startNode).intensity > Diff.instance.doubleIntensity then
        return NoteAssigner.ApplicableTypes.WEIGHT
    else
        return NoteAssigner.ApplicableTypes.DISABLE
    end
end

EventHandler.instance:on(Events.INIT, function(ev)
        NoteAssigner.instance:add("sgn_default_double_nc", sgn_DefaultDoubleNC_gen, sgn_DefaultDoubleNC_appl, Diff.instance.doubleFactor, 15)
    end
)
