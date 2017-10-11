require("../../diff/diff_export")
require("../../vr/vr_note_assign")
require("../helpers/auto_y")
require("../helpers/accel_calc_v1")
require("../helpers/offsets")

function sgn_AccelV1SingleBallchain_gen(id, assigner, container)
    local rand = math.random
    local currentNote = container._notes[id]
    local prevNote = false
    local prevOtherNote = false
    local prevTable = {}
    local prevOtherTable = {}
    if rand() < 0.5 then
        currentNote:setHand(Note.HandTypes.LEFT)
        prevNote = container:getPrev(id, NoteContainer.FilterFlags.ASSIGNED + NoteContainer.FilterFlags.FILTER_HANDS + NoteContainer.FilterFlags.HAS_LEFT + NoteContainer.FilterFlags.ENABLED_ONLY)
        prevOtherNote = container:getPrev(id, NoteContainer.FilterFlags.ASSIGNED + NoteContainer.FilterFlags.FILTER_HANDS + NoteContainer.FilterFlags.HAS_RIGHT + NoteContainer.FilterFlags.ENABLED_ONLY)
        if prevNote == true then
            prevNote = Note()
        end
        if prevOtherNote == true then
            prevOtherNote = Note()
        end

        prevTable = {
            x = prevNote.endPos.x - prevNote.endSpan.x / 2,
            time = prevNote.endTime,
            max = Diff.instance.maxAccelLeft,
            fact = Diff.instance.factAccelLeft
        }
        prevOtherTable = {
            x = prevOtherNote.endPos.x + prevOtherNote.endSpan.x / 2,
            time = prevNote.endTime,
            max = Diff.instance.maxAccelRight,
            fact = Diff.instance.factAccelRight
        }
    else
        currentNote:setHand(Note.HandTypes.RIGHT)
        prevNote = container:getPrev(id, NoteContainer.FilterFlags.ASSIGNED + NoteContainer.FilterFlags.FILTER_HANDS + NoteContainer.FilterFlags.HAS_RIGHT + NoteContainer.FilterFlags.ENABLED_ONLY)
        prevOtherNote = container:getPrev(id, NoteContainer.FilterFlags.ASSIGNED + NoteContainer.FilterFlags.FILTER_HANDS + NoteContainer.FilterFlags.HAS_LEFT + NoteContainer.FilterFlags.ENABLED_ONLY)
        if prevNote == true then
            prevNote = Note()
        end
        if prevOtherNote == true then
            prevOtherNote = Note()
        end

        prevTable = {
            x = prevNote.endPos.x + prevNote.endSpan.x / 2,
            time = prevNote.endTime,
            max = Diff.instance.maxAccelRight,
            fact = Diff.instance.factAccelRight
        }
        prevOtherTable = {
            x = prevOtherNote.endPos.x - prevOtherNote.endSpan.x / 2,
            time = prevNote.endTime,
            max = Diff.instance.maxAccelLeft,
            fact = Diff.instance.factAccelLeft
        }
    end
    local spans = {
        total = Diff.instance.spanX,
        normal = Diff.instance.maxDoubleSpan,
        crosshand = Diff.instance.maxCrosshandSpan
    }

    local retPos = CalculateAccelPos(currentNote.startTime, prevTable, prevOtherTable, currentNote.handType, spans)

    if retPos == true then
        currentNote:disable()
        return false
    end

    if currentNote.lengthNode > 44 then
        currentNote.offsetFunc = offs_Sine
    else
        currentNote.offsetFunc = offs_Triangle
    end
    currentNote.objects.tail = Note.Objects.DEFAULT

    currentNote.pos.x = retPos
    currentNote.span.x = 0

    AutoGenY(currentNote)

    currentNote:finalize()

    return false
end

function sgn_AccelV1SingleBallchain_appl(id, assigner, container)
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
        NoteAssigner.instance:add("sgn_accelv1_single_ballchain", sgn_AccelV1SingleBallchain_gen, sgn_AccelV1SingleBallchain_appl, 1-Diff.instance.doubleFactor, 14)
    end
)
