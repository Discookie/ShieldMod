require("utils/bind")
require("utils/dump")
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
    FINISH = 11,
    SCORE = 12
}
Events.LastIndex = 12

Events.Register = function(name)
    return Events.AddEvent(name)
end
Events.RegisterEvent = function(name)
    return Events.AddEvent(name)
end
Events.Add = function(name)
    return Events.AddEvent(name)
end
Events.AddEvent = function(name)
    if Events[name] then
        return Events[name]
    else
        Events.LastIndex = Events.LastIndex + 1
        Events[name] = Events.LastIndex
        return Events.LastIndex
    end
end

Event = {}
Event.__index = Event
setmetatable(Event, {
        __call = function(cls, ...)
            return cls.init(...)
        end
})

function Event.init(eventID, data)
    local self = setmetatable({}, Event)
    self.type = "Event"
    self.logger = Logger(self.type)
    self.id = eventID
    self.data = data
    return self
end

function Event:dupe()
    return self:copy()
end
function Event:duplicate()
    return self:copy()
end
function Event:copy()
    return Event(self.id, self.data)
end

EventHandler = {}
EventHandler.__index = EventHandler
setmetatable(EventHandler, {
        __call = function(cls, ...)
            return cls.init(...)
        end
})

function EventHandler.init(isInstance)
    local self = setmetatable({}, EventHandler)
    self.isInstance = isInstance or false
    self.type = "EventHandler"
    self.logger = Logger(self.type)
    self.logger:log("Init")
    self:reset()
    return self
end

function EventHandler:reset()
    self.logger:trace("Reset", 3)
    if not self.isInstance then
        if (self._id ~= nil) then
            EventHandler.instance:delete(self._id)
        end
        self._id = EventHandler.instance:add(Events.ALL, self.event, self)
    end
    self.events = {}
    self.eventLinks = {}
    for k, v in pairs(Events) do
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
        self.events[#self.events+1] = {true, bindFunc(callback, object), eventID, 0}
    else
        self.events[#self.events+1] = {true, callback, eventID, 0}
    end
    self.eventLinks[eventID][#self.eventLinks[eventID] + 1] = #self.events
    self.events[#self.events][4] = #self.eventLinks[eventID]
    self.logger:trace("New event for " .. eventID .. ": ID " .. #self.events)
    return #self.events
end

function EventHandler:disable(id)
    if self.events[id] ~= nil then
        self.events[id][1] = false
        self.logger:trace("Event ID " .. id .. " disabled")
        return false
    else
        self.logger:trace("Event ID " .. id .. ": Can't disable!")
        return true
    end
end

function EventHandler:enable(id)
    if self.events[id] ~= nil then
        self.events[id][1] = true
        self.logger:trace("Event ID " .. id .. " enabled")
        return false
    else
        self.logger:trace("Event ID " .. id .. ": Can't enable!")
        return true
    end
end

function EventHandler:delete(id)
    return self:remove(id)
end

function EventHandler:remove(id)
    if self.events ~= nil then
        self.eventLinks[self.events[id][3]][self.events[id][4]] = nil
        self.events[id] = nil
        self.logger:trace("Event ID " .. id .. " removed")
        return false
    else
        self.logger:trace("Event ID " .. id .. ": Can't remove!")
        return true
    end
end

function EventHandler:throw(event)
    return self:event(event)
end
function EventHandler:event(event)
    local evStart = self.logger:getDate()

    if event.id == Events.ALL or event.id == Events.ERR then
        self.logger:err("Throw failed: Invalid ID (" .. event.id .. ")!")
        return true
    elseif event.id == Events.FRAME then
        self.logger:trace("Throw! ID " .. event.id .. ", calling " .. #self.eventLinks[Events.ALL] .. " + " .. #self.eventLinks[event.id] .. " events", 4)
    else
        self.logger:debug("Throw! ID " .. event.id .. ", calling " .. #self.eventLinks[Events.ALL] .. " + " .. #self.eventLinks[event.id] .. " events")
    end

    local status, err
    local successes = 0
    local fails = 0
    for k, v in pairs(self.eventLinks[Events.ALL]) do
        if self.events[v] ~= nil and self.events[v][1] then
            status, err = pcall(self.events[v][2], event:copy())

            if not status then
                self.logger:err("Event ID " .. v .. " LUA error: " .. dump(err))
                fails = fails + 1
                self:disable(v)
            elseif err then
                self.logger:warn("Event ID " .. v .. " failed to execute")
                fails = fails + 1
                self:disable(v)
            else
                successes = successes + 1
            end
        end
    end
    for k, v in pairs(self.eventLinks[event.id]) do
        if self.events[v] ~= nil and self.events[v][1] then
            status, err = pcall(self.events[v][2], event:copy())

            if not status then
                self.logger:err("Event ID " .. v .. " LUA error: " .. dump(err))
                fails = fails + 1
                self:disable(v)
            elseif err then
                self.logger:warn("Event ID " .. v .. " failed to execute")
                fails = fails + 1
                self:disable(v)
            else
                successes = successes + 1
            end
        end
    end

    if event.id == Events.FRAME then
        self.logger:trace("ID " .. event.id .. " finished in " .. (self.logger:getDate() - evStart) .. "s", 4)
        self.logger:trace("Successful events: " .. successes .. ", fails: " .. fails, 4)
    else
        self.logger:debug("ID " .. event.id .. " finished in " .. (self.logger:getDate() - evStart) .. "s")
        self.logger:debug("Successful events: " .. successes .. ", fails: " .. fails, 4)
    end

    return false
end

EventHandler.instance = EventHandler(true)
