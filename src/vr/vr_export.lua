require("vr_note")
require("vr_note_container")
require("vr_note_assign")

EventHandler.instance:on(Events.INIT, function(ev)
        NoteContainer.instance = NoteContainer()
        NoteAssigner.instance = NoteAssigner(NoteContainer.instance)
    end)
