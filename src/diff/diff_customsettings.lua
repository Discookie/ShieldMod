require("diff")

EventHandler.instance:on(Events.INIT, function(ev)
        Diff.instance:loadValues(require("../../settings/game"))
    end)
