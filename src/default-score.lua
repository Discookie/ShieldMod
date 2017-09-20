require("logger")
require("events")
require("diff/diff_export")

EventHandler.on(Events.SCORE, function(ev)
    if Diff.instance.scoreMode == "SHIELD" then
        AssignBuiltInAudioshieldScoring()
    end
end)
