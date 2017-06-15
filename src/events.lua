Events = {
    "ERR" = 0,
    "FRAME" = 1,
    "INIT" = 2,
    "TRACK" = 3,
    "PRE_TRAFFIC" = 4,
    "TRAFFIC" = 5,
    "PRE_SKIN" = 6,
    "START" = 7,
    "PAUSE" = 8,
    "RESUME" = 9,
    "END" = 10,
    "SCORE" = 11
}

Event = {}
Event.__index = EventHandler
setmetatable(Event, {
        __call = function(cls, ...)
            return cls.init(...)
        end,
})

function Event.init(args)
    local self = setmetatable({}, Event)
    self.type = "Event"
    self.logger = Logger(self.type)
    self.eventType = args.eventType
    self.frames = args.frames
    self.seconds = args.seconds
    self.state = args.state
    return self
end

EventHandler = {}
EventHandler.__index = EventHandler
setmetatable(EventHandler, {
        __call = function(cls, ...)
            return cls.init(...)
        end,
})

function EventHandler.init()
    local self = setmetatable({}, EventHandler)
    self.type = "EventHandler"
    self:reset()
    return self
end

function EventHandler:reset()
    self._intervals
end

function EventHandler:add(event, callback)

end

function EventHandler:disable(id)

end

function EventHandler:enable(id)

end

function EventHandler:delete(id)
    self:remove(id)
end

function EventHandler:remove(id)

end

function EventHandler:addInterval(seconds, callback)

end

function EventHandler:removeInterval(id)

end

function EventHandler:event(event)

end
