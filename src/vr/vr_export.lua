require("vr_note")
require("vr_note_container")

EventHandler.instance:on(Events.INIT, function(ev)
        NoteContainer.instance = NoteContainer()
    end)
