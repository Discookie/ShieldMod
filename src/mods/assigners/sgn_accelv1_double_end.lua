require("../../diff/diff_export")
require("../../vr/vr_export")
require("../../vr/vr_note_assign")
require("../helpers/auto_y")

function sgn_AccelV1DoubleEnd_gen(id, assigner, container)
    local rand = math.random
    local currentNote = container._notes[id]
    local prevLeftNote = false
    local prevRightNote = false

    currentNote:setHand(Note.HandTypes.LEFT + Note.HandTypes.RIGHT)

    prevLeftNote = container:getPrev(id, NoteContainer.FilterFlags.ASSIGNED + NoteContainer.FilterFlags.FILTER_HANDS + NoteContainer.FilterFlags.HAS_LEFT + NoteContainer.FilterFlags.ENABLED_ONLY)
    prevRightNote = container:getPrev(id, NoteContainer.FilterFlags.ASSIGNED + NoteContainer.FilterFlags.FILTER_HANDS + NoteContainer.FilterFlags.HAS_RIGHT + NoteContainer.FilterFlags.ENABLED_ONLY)
    if prevLeftNote == true then
        prevLeftNote = Note()
    end
    if prevRightNote == true then
        prevRightNote = Note()
    end


    local prevLeftTable = {
        x = prevLeftNote.endPos.x - prevLeftNote.endSpan.x / 2,
        time = prevLeftNote.endTime,
        max = Diff.instance.maxAccelLeft,
        fact = Diff.instance.factAccelLeft
    }
    local prevRightTable = {
        x = prevRightNote.endPos.x + prevRightNote.endSpan.x / 2,
        time = prevRightNote.endTime,
        max = Diff.instance.maxAccelRight,
        fact = Diff.instance.factAccelRight
    }
    local spans = {
        total = Diff.instance.spanX,
        normal =Diff.instance.maxDoubleSpan,
        crosshand = Diff.instance.maxCrosshandSpan,
        min = Diff.instance.minDoubleSpan
    }

    local retPos = CalculateAccelCenteredPos(currentNote.startTime, prevLeftTable, prevRightTable, spans)

    currentNote.pos.x = retPos.pos
    currentNote.span.x = retPos.span

    AutoGenY(currentNote)

    currentNote:finalize()
end

function sgn_AccelV1DoubleEnd_appl(id, assigner, container)
    local currentNote = container._notes[id]
    local nextTime = container:getNext(id, NoteContainer.FilterFlags.ENABLED_ONLY)

    if nextTime == true or nextTime.startTime - currentNote.endTime > 4 or (nextTime.startTime - currentNote.endTime > 2 and Track.instance:getNode(currentNote.startNode).intensity > 0.5) then
        return NoteAssigner.ApplicableTypes.FORCE
    else
        return NoteAssigner.ApplicableTypes.DISABLE
    end
end

EventHandler.instance:on(Events.INIT, function(ev)
        NoteAssigner.instance:add("sgn_accelv1_double_end", sgn_AccelV1DoubleEnd_gen, sgn_AccelV1DoubleEnd_appl, 0, 5) -- make sure this is top priority and not randomly assigned
    end
)
