require("../../diff/diff_export")
require("../../vr/vr_note_assign")

function sgn_NoteSpacing_gen(id, assigner, container)
    container._notes[id]:disable()
end

function sgn_NoteSpacing_appl(id, assigner, container)
    if container:getPrev(k, NoteContainer.FilterFlags.ENABLED_ONLY) ~= true and container._notes[id].startTime - container:getPrev(id, NoteContainer.FilterFlags.ENABLED_ONLY).endTime < Diff.instance.minSpacing then
        return NoteAssigner.ApplicableTypes.FORCE
    else
        return NoteAssigner.ApplicableTypes.DISABLE
    end
end

EventHandler.instance:on(Events.INIT, function(ev)
        NoteAssigner.instance:add("sgn_notespacing", sgn_NoteSpacing_gen, sgn_NoteSpacing_appl, 0, 10)
    end
)
