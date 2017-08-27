require("copyright")

-- Necessary for local build testing
require("test-data")

-- Load helper utilities
require("utils/requtils")
require("utils/dump")

-- Loading base utilities
require("logger")
require("events")
require("intervals")

-- Loading settings
require("diff/diff_export")
require("camera")
require("random")

-- Loading core tools
require("track/track_export")
require("traffic/traffic_export")
require("vr/vr_export")

-- Loading current mod
require("mods/active")

-- Bind game events to EventHandler
function OnTrackCreated(track)
    local ev = Event(Events.TRACK, track)
    EventHandler.instance:throw(ev)
end

function OnFreqTrafficCreated(freqTraffic)
    local ev = Event(Events.PRE_TRAFFIC, freqTraffic)
    EventHandler.instance:throw(ev)
end

function OnTrafficCreated(traffic)
    local ev = Event(Events.TRAFFIC, traffic)
    EventHandler.instance:throw(ev)
end

function OnRequestLoadObjects(track)
    local ev = Event(Events.PRE_SKIN, track)
    EventHandler.instance:throw(ev)
end

function OnSkinLoaded()
    local ev = Event(Events.POST_SKIN)
    EventHandler.instance:throw(ev)
end

function Update(dt, location, strafe, inputs, height)
    local ev = Event(Events.FRAME, {dt = dt, location = location, strafe = strafe, inputs = inputs, height = height})
    EventHandler.instance:throw(ev)
end

function OnRequestFinalScoring()
    local ev = Event(Events.SCORE)
    EventHandler.instance:throw(ev)
end

-- Loading done.
Logger.Global:debug("Pre-init GMS time is " .. math.round(GetMillisecondsSinceStartup(), 0)/1000)
EventHandler.instance:throw(Event(Events.INIT))
