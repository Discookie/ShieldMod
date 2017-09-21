require("../../diff/diff_export")
require("../../vr/vr_note_assign")
require("../helpers/auto_y")
require("../helpers/accel_calc_v1")

local sgn_AccelV1Purple = {}
local sgn_AccelV1Purple_sorted = {}
local sgn_AccelV1Purple_current = 1


function sgn_AccelV1Purple_gen(id, assigner, container)
    local rand = math.random
    local currentNote = container._notes[id]
    local prevLeftNote = false
    local prevRightNote = false
    local prevTable = {}
    local prevOtherTable = {}
    currentNote:setHand(Note.HandTypes.PURPLE)

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
        min = 0
    }

    local leftPos = 0
    local rightPos = 0
    if math.random() < 0.5 then
        leftPos = CalculateAccelPos(currentNote.startTime, prevLeftTable, prevRightTable, Note.HandTypes.LEFT, spans)
        prevLeftTable = {
            x = leftPos,
            time = currentNote.startTime,
            max = Diff.instance.maxAccelLeft,
            fact = Diff.instance.factAccelLeft
        }
        rightPos = CalculateAccelPos(currentNote.startTime, prevRightTable, prevLeftTable, Note.HandTypes.RIGHT, spans)
    else
        rightPos = CalculateAccelPos(currentNote.startTime, prevRightTable, prevLeftTable, Note.HandTypes.RIGHT, spans)
        prevRightTable = {
            x = leftPos,
            time = currentNote.startTime,
            max = Diff.instance.maxAccelRight,
            fact = Diff.instance.factAccelRight
        }
        leftPos = CalculateAccelPos(currentNote.startTime, prevLeftTable, prevRightTable, Note.HandTypes.LEFT, spans)
    end
    currentNote.pos.x = (leftPos + rightPos)/2
    currentNote.span.x = rightPos - leftPos

    AutoGenY(currentNote)

    currentNote:finalize()

    return false
end

function sgn_AccelV1Purple_appl(id, assigner, container)
    if sgn_AccelV1Purple_sorted[sgn_AccelV1Purple_current] and sgn_AccelV1Purple_sorted[sgn_AccelV1Purple_current] < container._notes[id].endNode and container._notes[id].lengthNode > 5 then
        sgn_AccelV1Purple_current = sgn_AccelV1Purple_current + 1
        return NoteAssigner.ApplicableTypes.FORCE
    else
        return NoteAssigner.ApplicableTypes.DISABLE
    end
end

function sgn_AccelV1Purple_loadPowerNodes(powerNodes)
    sgn_AccelV1Purple_sorted = deepcopy(powerNodes)
    table.sort(sgn_AccelV1Purple_sorted)
    sgn_AccelV1Purple_current = 1
    return false
end

EventHandler.instance:on(Events.INIT, function(ev)
        NoteAssigner.instance:add("sgn_accelv1_purple", sgn_AccelV1Purple_gen, sgn_AccelV1Purple_appl, 0, 5)
    end
)

EventHandler.instance:on(Events.PRE_TRAFFIC, function(ev)
        return sgn_AccelV1Purple_loadPowerNodes(Track.instance:get("powerNodes"))
    end
)
