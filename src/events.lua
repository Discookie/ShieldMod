require("utils/bind")
require("logger")

Events = {
    ALL = -1,
    ERR = 0,
    FRAME = 1,
    INIT = 2,
    TRACK = 3,
    PRE_TRAFFIC = 4,
    TRAFFIC = 5,
    PRE_SKIN = 6,
    POST_SKIN = 7,
    START = 8,
    PAUSE = 9,
    RESUME = 10,
    END = 11,
    SCORE = 12
}

Event = {}
Event.__index = Event
setmetatable(Event, {
        __call = function(cls, ...)
            return cls.init(...)
        end,
})

function Event.init(eventID, data)
    local self = setmetatable({}, Event)
    self.type = "Event"
    self.logger = Logger(self.type)
    self.id = eventID
    self.data = data
    return self
end

EventHandler = {}
EventHandler.__index = EventHandler
setmetatable(EventHandler, {
        __call = function(cls, ...)
            return cls.init(...)
        end,
})

function EventHandler.init(isInstance)
    local self = setmetatable({}, EventHandler)
    self.isInstance = isInstance or false
    self.type = "EventHandler"
    self.logger = Logger(self.type)
    self:reset()
    return self
end

function EventHandler:reset()
    if not self.isInstance then
        if (self._id ~= nil) then
            EventHandler.instance:delete(self._id)
        end
        self._id = EventHandler.instance:add("ALL", self.event, self)
    end
    self.events = {}
    self.eventLinks = {}
    for k, v in ipairs(Events) do
        if v ~= Events.ERR then
            self.eventLinks[v] = {}
        end
    end
    return false
end

function EventHandler:on(eventID, callback, object)
    return self:add(eventID, callback, object)
end
function EventHandler:add(eventID, callback, object)
    if object ~= nil then
        self.events[#self.events+1] = {true, bindFunc(object, callback), eventID, 0}
    else
        self.events[#self.events+1] = {true, callback, eventID, 0}
    end
    self.eventLinks[eventID][#self.eventLinks[eventID] + 1] = #self.events
    self.events[#self.events][4] = #self.eventLinks[eventID]
    return #self.events
end

function EventHandler:disable(id)
    if self.events[id] ~= nil then
        self.events[id][1] = false
        return false
    else
        return true
    end
end

function EventHandler:enable(id)
    if self.events[id] ~= nil then
        self.events[id][1] = true
        return false
    else
        return true
    end
end

function EventHandler:delete(id)
    self:remove(id)
end

function EventHandler:remove(id)
    if self.events ~= nil then
        self.eventLinks[self.events[id][3]][self.events[id][4]] = nil
        self.events[id] = nil
        return false
    else
        return true
    end
end

function EventHandler:event(event)
    for k, v in ipairs(self.eventLinks[event.type]) do
        if self.events[v] ~= nil and self.events[v][0] then
            self.events[v][1](event)
        end
    end
end

EventHandler.instance = EventHandler(true)
