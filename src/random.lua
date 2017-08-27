require("logger")
require("track/track_export")

function SetSeed(seed)
    math.randomseed(seed)
    Logger.Global:log("Setting random seed " .. seed)
end

local defaultSeed = 133742069
SetSeed(defaultSeed)

EventHandler.instance:on(Events.TRACK, function(ev)
        SetSeed(Track.instance._time[Track.instance.size])
    end
)
