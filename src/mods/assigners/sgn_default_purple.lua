require("../../diff/diff_export")
require("../../track/track_export")
require("../../vr/vr_note_assign")
require("../helpers/auto_y")

local sgn_DefaultPurple = {}
local sgn_DefaultPurple_sorted = {}
local sgn_DefaultPurple_current = 1

function sgn_DefaultPurple_gen(id, assigner, container)
    local rand = math.random
    local currentNote = container._notes[id]

    sgn_DefaultPurple_current = sgn_DefaultPurple_current + 1

    currentNote:setHand(Note.HandTypes.PURPLE)

    currentNote.pos.x = (rand()-0.5) * Diff.instance.spanX + Diff.instance.spanX_offset

    AutoGenY(currentNote)

    currentNote.assigned = true
end

function sgn_DefaultPurple_appl(id, assigner, container)
    if sgn_DefaultPurple_sorted[sgn_DefaultPurple_current] and sgn_DefaultPurple_sorted[sgn_DefaultPurple_current] < container._notes[id].startNode and container._notes[id].lengthNode > 5 then
        return NoteAssigner.ApplicableTypes.FORCE
    else
        return NoteAssigner.ApplicableTypes.DISABLE
    end
end

function sgn_DefaultPurple_loadPowerNodes(powerNodes)
    sgn_DefaultPurple_sorted = deepcopy(powerNodes)
    table.sort(sgn_DefaultPurple_sorted)
    sgn_DefaultPurple_current = 1
    return false
end

EventHandler.instance:on(Events.INIT, function(ev)
        NoteAssigner.instance:add("sgn_default_purple", sgn_DefaultPurple_gen, sgn_DefaultPurple_appl, 0, 5)
    end
)

EventHandler.instance:on(Events.PRE_TRAFFIC, function(ev)
        return sgn_DefaultPurple_loadPowerNodes(Track.instance:get("powerNodes"))
    end
)
