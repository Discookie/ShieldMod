require("../../logger")
require("../../events")
require("../../diff/diff_export")

EventHandler.instance:on(Events.SCORE, function(ev)
    if Diff.instance.scoreMode == "SHIELD" then
        Logger("Scorer_Default"):log("Set default Audioshield scoring")
        AssignBuiltInAudioshieldScoring()
    end
end)
