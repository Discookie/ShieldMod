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
Intervals.instance = Intervals()

function Intervals.init()
    local self = setmetatable({}, Intervals)
    self.type = "Intervals"
    self.logger = Logger(self.type)
    self:reset()
    EventHandler.instance:add(Events.FRAME, self.onFrame, self)
    return self
end

function Intervals:addInterval(timeout, isRelativeTime, callback, object)
    if object ~= nil then
        self._intervals[#self.intervals + 1] = {
            timeout,
            isRelativeTime,
            bindFunc(object, callback),
            Tick.instance:getAbsoluteTime(),
            0
        }
    else
        self._intervals[#self.intervals + 1] = {
            timeout,
            isRelativeTime,
            callback,
            Tick.instance:getAbsoluteTime(),
            0
        }
    end
    if isRelativeTime then
        self._intervals[#self.intervals][2] = true
        self._intervals[#self.intervals][4] = Tick.instance:getRelativeTime()
    end
    return #self._intervals
end

function Intervals:del(id)
    return self:delInterval(id)
end
function Intervals:delInterval(id)
    if self._intervals[id] == nil then
        return true
    else
        self._intervals[id] = nil
        return false
    end
end

function Intervals:onFrame(event)
    local floor = math.floor
    for k, v in ipairs(self._intervals) do
        while (not v[2] and (v[5] < floor((Tick.instance:getAbsoluteTime() - v[4]) / v[1]))) or (v[2] and (v[5] < floor((Tick.instance:getRelativeTime() - v[4]) / v[1]))) do
            v[3]()
            v[5] = v[5] + 1
        end
    end
end
