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

-- Loading core tools
require("track/track_export")
require("traffic/traffic_export")
require("vr/vr_export")

-- Loading settings
require("diff/diff_export")
require("camera")
require("random")

-- Loading current mod
require("mods/active")

-- Bind game events to EventHandler
function OnTrackCreated(track)
    local ev = Event(Events.TRACK, track)
    EventHandler.instance:throw(ev)

    if TrackReturn ~= nil then
        local retValue = TrackReturn
        TrackReturn = nil
        return retValue
    end
end

function OnFreqTrafficCreated(freqTraffic)
    local ev = Event(Events.PRE_TRAFFIC, freqTraffic)
    EventHandler.instance:throw(ev)

    if PreTrafficReturn ~= nil then
        local retValue = PreTrafficReturn
        PreTrafficReturn = nil
        return retValue
    end
end

function OnTrafficCreated(traffic)
    local ev = Event(Events.TRAFFIC, traffic)
    EventHandler.instance:throw(ev)

    if TrafficReturn ~= nil then
        local retValue = TrafficReturn
        TrafficReturn = nil
        return retValue
    end
end

function OnRequestLoadObjects(track)
    local ev = Event(Events.PRE_SKIN, track)
    EventHandler.instance:throw(ev)

    if PreSkinReturn ~= nil then
        local retValue = PreSkinReturn
        PreSkinReturn = nil
        return retValue
    end
end

function OnSkinLoaded()
    local ev = Event(Events.POST_SKIN)
    EventHandler.instance:throw(ev)

    if PostSkinReturn ~= nil then
        local retValue = PostSkinReturn
        PostSkinReturn = nil
        return retValue
    end
end

function Update(dt, location, strafe, inputs, height)
    local ev = Event(Events.FRAME, {dt = dt, location = location, strafe = strafe, inputs = inputs, height = height})
    EventHandler.instance:throw(ev)

    if FrameReturn ~= nil then
        local retValue = FrameReturn
        FrameReturn = nil
        return retValue
    end
end

function OnRequestFinalScoring()
    local ev = Event(Events.SCORE)
    EventHandler.instance:throw(ev)

    if ScoreReturn ~= nil then
        local retValue = ScoreReturn
        ScoreReturn = nil
        return retValue
    end
end

-- Loading done.
Logger.Global:debug("Pre-init GMS time is " .. math.round(GetMillisecondsSinceStartup(), 0)/1000)
EventHandler.instance:throw(Event(Events.INIT))
