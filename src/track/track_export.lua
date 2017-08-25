require("track")
require("powernodes")

EventHandler.instance:on(Events.INIT, function(ev)
        Track.instance = Track()
    end)
