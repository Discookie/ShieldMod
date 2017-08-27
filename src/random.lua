require("logger")
require("track/track_export")

function SetSeed(seed)
    Logger.Global:log("Setting random seed " .. tostring(seed))
    math.randomseed(seed)
end

local defaultSeed = 133742069
SetSeed(defaultSeed)

EventHandler.instance:on(Events.PRE_TRAFFIC, function(ev)
        SetSeed(math.floor(Track.instance._time[Track.instance.size]*1000000000))
    end
)
