require("events")
require("logger")

GameStates = {
    ERR = -1,
    PRE_TRACK = 0x00,
    PRE_TRAFFIC = 0x01,
    PRE_SKIN = 0x02,
    PRE_START = 0x03,
    PRE_SONG = 0x13,
    PLAYING = 0x14,
    PAUSED = 0x04,
    ENDED = 0x05,
}

GameStates.current = GameStates.PRE_TRACK

function GameStates.eventChange(event)
    if (event.id == Events.TRACK) then
        GameStates.current = GameStates.PRE_TRAFFIC
    elseif (event.id == Events.TRAFFIC) then
        GameStates.current = GameStates.PRE_SKIN
    elseif (event.id == Events.POST_SKIN) then
        GameStates.current = GameStates.PRE_START
    elseif (event.id == Events.FRAME) then
        if event.data.dt > 0 and seconds >= 0 then
            if seconds > -0.0056 and seconds < 0.0056 then
                local ev = Event(Events.START, event.data)
                EventHandler.instance:throw(ev)
            end
            GameStates.current = GameStates.PLAYING
        elseif events.data.dt == 0 then
            GameStates.current = GameStates.PAUSED
        else
            GameStates.current = GameStates.PRE_SONG
        end
    end
end

EventHandler.instance:on(Events.ALL, GameStates.eventChange)

Tick = {}
Tick.__index = Tick
setmetatable(Tick, {
        __call = function(cls, ...)
            return cls.init(...)
        end,
})

function Tick.init(args)
    local self = setmetatable({}, Tick)
    self.type = "Tick"
    self.logger = Logger(self.type)
    self:reset()
    return self
end

function Tick:reset()
    self.seconds = -5
    self.ticks = 0
    if self.id then EventHandler.instance:remove(self.id) end
    self.id = EventHandler.instance:add(Events.FRAME, self.onFrame, self)
end

function Tick.isPaused()
    return GameStates.current < 16
end

function Tick:getAbsoluteTime()
    return self.ticks/90
end

function Tick:getRelativeTime()
    return self.seconds
end

function Tick:frame(dt)
    self.ticks = self.ticks + 1
    self.seconds = self.seconds + dt
end

function Tick:onFrame(event)
    self:frame(event.data.dt)
end

Tick.instance = Tick()
