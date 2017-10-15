require("diff")
require("diff_timing")
require("diff_gamesettings")
require("diff_accels")
require("diff_powernodes")
require("diff_debug")

EventHandler.instance:on(Events.INIT, function(ev)
        Diff.instance = Diff()
    end)

require("diff_customsettings")
