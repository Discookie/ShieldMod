require("../logger")
require("../events")
require("../utils/deepcopy")
require("../utils/dump")
require("../diff/diff_export")
require("../track/track_export")
require("../tick")

TrafficEvents = {}

TrafficEvents.__index = TrafficEvents

setmetatable(TrafficEvents, {
        __call = function(cls, ...)
            return cls.init(...)
        end
})

function TrafficEvents.init(traffic)
    local self = setmetatable({}, TrafficEvents)
    self.type = "TrafficEvents"
    self.logger = Logger(self.type)
    self.logger:log("Init")
    self:reset()
    if traffic ~= nil then
        self:bind(traffic)
    end
    return self
end

function TrafficEvents:reset()
    if self.bound then
        self:unbind()
    end
    if not Events.BLOCK then
        Events.AddEvent("BLOCK")
    end
    self.bound = false
    self.traffic = nil
    self.current = 0
    self.frameID = -1
end

function TrafficEvents:bind(traffic)
    if type(traffic) ~= "table" or traffic.type ~= "Traffic" then
        self.logger:warn("bound: Invalid traffic to bind to")
        return true
    end
    if self.bound then
        self:unbind()
    end
    self.bound = true
    self.traffic = traffic
    self.oldSort = self.traffic.sort
    self.traffic.sort = function(traf)
        local ret = self.oldSort(traf)
        local ret2 = bindFunc(self.onTrafficChange, self)()
        return ret or ret2
    end
    self._id = EventHandler.instance:on(Events.FRAME, self.onFrame, self)
    return false
end

function TrafficEvents:unbind()
    if not self.bound then
        return false
    end
    if self._id then
        EventHandler.instance:remove(self._id)
    end
    self.traffic.sort = self.oldSort
    self.traffic = nil
    self.bound = false
    return false
end

function TrafficEvents:onTrafficChange()
    if not self.bound then return true end
    self.nextTime = self.traffic.nextTime
end

function TrafficEvents:onFrame(event)
    if not self.bound then return true end
    if self.nextTime < Tick.instance:getRelativeTime() then
        local ev = Event(Events.BLOCK, self.traffic.currentID)
        EventHandler.instance:throw(ev)
        self.nextTime = self.traffic.nextTime
    end
end
