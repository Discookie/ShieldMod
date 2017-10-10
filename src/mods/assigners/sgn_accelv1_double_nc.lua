require("../../diff/diff_export")
require("../../vr/vr_note_assign")
require("../helpers/auto_y")
require("../helpers/accel_calc_v1")

function sgn_AccelV1DoubleNC_gen(id, assigner, container)
    local rand = math.random
    local currentNote = container._notes[id]
    local prevLeftNote = false
    local prevRightNote = false
    local prevTable = {}
    local prevOtherTable = {}

    prevLeftNote = container:getPrev(id, NoteContainer.FilterFlags.ASSIGNED + NoteContainer.FilterFlags.FILTER_HANDS + NoteContainer.FilterFlags.HAS_LEFT + NoteContainer.FilterFlags.ENABLED_ONLY)
    prevRightNote = container:getPrev(id, NoteContainer.FilterFlags.ASSIGNED + NoteContainer.FilterFlags.FILTER_HANDS + NoteContainer.FilterFlags.HAS_RIGHT + NoteContainer.FilterFlags.ENABLED_ONLY)
    if prevLeftNote == true then
        prevLeftNote = Note()
    end
    if prevRightNote == true then
        prevRightNote = Note()
    end

    prevLeftTable = {
        x = prevLeftNote.endPos.x - prevLeftNote.endSpan.x / 2,
        time = prevLeftNote.endTime,
        max = Diff.instance.maxAccelLeft,
        fact = Diff.instance.factAccelLeft
    }
    prevRightTable = {
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

    local retPos = CalculateAccelDoublePos(currentNote.startTime, prevLeftTable, prevRightTable, spans)
    if retPos.hand == Note.HandTypes.AUTO then
        currentNote:disable()
        return false
    end
    currentNote:setHand(retPos.hand)

    currentNote.pos.x = retPos.pos
    currentNote.span.x = retPos.span

    AutoGenY(currentNote)

    currentNote:finalize()

    return false
end

function sgn_AccelV1DoubleNC_appl(id, assigner, container)
    if Track.instance:getNode(container._notes[id].startNode).intensity > Diff.instance.doubleIntensity then
        return NoteAssigner.ApplicableTypes.WEIGHT
    else
        return NoteAssigner.ApplicableTypes.DISABLE
    end
end

EventHandler.instance:on(Events.INIT, function(ev)
        NoteAssigner.instance:add("sgn_accelv1_double_nc", sgn_AccelV1DoubleNC_gen, sgn_AccelV1DoubleNC_appl, Diff.instance.doubleFactor, 15)
    end
)
