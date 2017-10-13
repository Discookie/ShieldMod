require("events")
require("tick")
require("utils/bind")
require("logger")

Intervals = {}
Intervals.__index = Intervals
setmetatable(Intervals, {
        __call = function(cls, ...)
            return cls.init(...)
        end,
})

function Intervals.init()
    local self = setmetatable({}, Intervals)
    self.type = "Intervals"
    self.logger = Logger(self.type)
    self.logger:log("Init")
    self:reset()
    EventHandler.instance:add(Events.FRAME, self.onFrame, self)
    return self
end

function Intervals:reset()
    self.logger:trace("Reset")
    if (self._id ~= nil) then
        EventHandler.instance:remove(self._id)
    end
    EventHandler.instance:on(Events.FRAME, self.onFrame, self)
    self._intervals = {}
    self._count = 0
end

function Intervals:addInterval(timeout, isRelativeTime, callback, object)
    self._count = self._count + 1
    if object ~= nil then
        self._intervals[self._count] = {
            timeout,
            isRelativeTime,
            bindFunc(callback, object),
            Tick.instance:getAbsoluteTime(),
            0
        }
    else
        self._intervals[self._count] = {
            timeout,
            isRelativeTime,
            callback,
            Tick.instance:getAbsoluteTime(),
            0
        }
    end
    if isRelativeTime then
        self._intervals[self._count][4] = Tick.instance:getRelativeTime()

        self.logger:trace("New interval ID " .. self._count .. " with relative start " .. self._intervals[self._count][4] .. " loop " .. self._intervals[self._count][1], 3)
    else
        self.logger:trace("New interval ID " .. self._count .. " with absolute start " .. self._intervals[self._count][4] .. " loop " .. self._intervals[self._count][1], 3)
    end
    return self._count
end

function Intervals:del(id)
    return self:delInterval(id)
end
function Intervals:remove(id)
    return self:delInterval(id)
end
function Intervals:removeInterval(id)
    return self:delInterval(id)
end
function Intervals:delInterval(id)
    if self._intervals[id] == nil then
        self.logger:warn("Interval ID " .. tostring(id) .. ": Can't remove!")
        return true
    else
        self._intervals[id] = nil
        self.logger:trace("Interval ID " .. id .. " removed", 3)
        return false
    end
end

function Intervals:onFrame(event)
    local floor = math.floor
    local count = 0
    local excCount = 0
    for k, v in pairs(self._intervals) do
        count = count + 1
        while (not v[2] and (v[5] < floor((Tick.instance:getAbsoluteTime() - v[4]) / v[1]))) or (v[2] and (v[5] < floor((Tick.instance:getRelativeTime() - v[4]) / v[1]))) do
            v[3]()
            v[5] = v[5] + 1
            excCount = excCount + 1
        end
    end
    self.logger:trace("Executed " .. excCount .. " out of " .. count, 5)
end

EventHandler.instance:on(Events.INIT, function(ev)
        Intervals.instance = Intervals()
    end)
