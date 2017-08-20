require("../logger")
require("../events")
require("../utils/deepcopy")
require("../utils/dump")
require("../note")
require("../diff/diff_export")
require("../track/track_export")
require("../tick")

Traffic = {}

Traffic.__index = Traffic

setmetatable(Traffic, {
        __call = function(cls, ...)
            return cls.init(...)
        end
})

function Traffic.init()
    local self = setmetatable({}, Traffic)
    self.type = "Traffic"
    self.logger = Logger(self.type)
    self.logger:log("Init")
    self:reset()
    return self
end

Traffic.Types = {
    GREY = Diff.instance.greyType,
    NORMAL = Diff.instance.normalType,
    INVERT = Diff.instance.invertType
}

function Traffic:reset()
    if self._id ~= nil then
        EventHandler.instance:remove(self._id)
    end
    if self._id2 ~= nil then
        EventHandler.instance:remove(self._id2)
    end
    self._id = EventHandler.instance:on(Events.TRAFFIC, self.onTraffic, self)
    self._id2 = EventHandler.instance:on(Events.FRAME, self.onFrame, self)

    self:clear()

    self.logger:log("Reset")

    return false
end

function Traffic:clear()
    self.size = 0

    self.traffic = {}
    self._traffic = {}

    self._active = {}

    self._time = {}
    self._node = {}

    self._start = {}
    self._length = {}
    self._fin = {}

    self._startTime = {}
    self._lengthTime = {}
    self._finTime = {}

    self._type = {}
    self._lane = {}

    self._strength = {}
    self._strafe = {}

    self._logJumps = {}
    self._logBackJumps = {}

    self.currentID = 0
    self.nextTime = 7200
end

function Traffic:generateLogJumps()
    if self.size <= 0 then
        return true
    end

    self._logJumps = {}
    self._logBackJumps = {}

    for i = 1, self.size - 1 do
        local j = 1
        local k = 1

        self._logJumps[i] = {}
        self._logBackJumps[self.size + 1 - i] = {}

        while i + k <= self.size do
            self._logJumps[i][j] = {i+k, self._time[i+k]}
            self._logBackJumps[self.size + 1 - i][j] = {self.size + 1 - i - k, self._time[self.size + 1 - i - k]}

            j = j + 1
            k = k * 2
        end
    end
    return false
end

function Traffic:sort()
    local function comp(a, b)
        return a.time < b.time
    end
    local newTraffic = deepcopy(self._traffic)
    table.sort(newTraffic, comp)
    return self:load(newTraffic)
end

function Traffic:load(array)
    if type(array) ~= "table" or type(array[1]) ~= "table" then
        return true
    end

    local oldSize = self.size

    self:clear()

    for k,v in ipairs(array) do
        self.size = self.size + 1

        self.traffic[self.size] = v
        self.traffic[self.size].id = self.size

        self._traffic[self.size] = {}
        self._traffic[self.size].id = self.size

        if v.active == nil then
            self._active[self.size] = true
            self._traffic[self.size].active = true
        else
            self._active[self.size] = v.active
            self._traffic[self.size].active = v.active
        end

        self._node[self.size] = v.node or v.impactnode
        self._traffic[self.size].node = v.node or v.impactnode
        self._time[self.size] = Track.instance:nodeToTime(self._node[self.size])
        self._traffic[self.size].time = Track.instance:nodeToTime(self._node[self.size])

        self._start[self.size] = v.start or v.chainstart or self._node[self.size]
        self._traffic[self.size].start = v.start or v.chainstart or self._node[self.size]
        self._fin[self.size] = v.fin or v.chainend or (2 * self._node[self.size] - self._start[self.size])
        self._traffic[self.size].fin = v.fin or v.chainend or (2 * self._node[self.size] - self._start[self.size])
        self._length[self.size] = self._fin[self.size] - self._start[self.size]
        self._traffic[self.size].length = self._fin[self.size] - self._start[self.size]

        self._startTime[self.size] = v.startTime or Track.instance:nodeToTime(self._start[self.size])
        self._traffic[self.size].startTime = v.startTime or Track.instance:nodeToTime(self._start[self.size])
        self._finTime[self.size] = v.finTime or Track.instance:nodeToTime(self._fin[self.size])
        self._traffic[self.size].finTime = v.finTime or Track.instance:nodeToTime(self._fin[self.size])
        self._lengthTime[self.size] = self._finTime[self.size] - self._startTime[self.size]
        self._traffic[self.size].lengthTime = self._finTime[self.size] - self._startTime[self.size]

        self._type[self.size] = v.type
        self._lane[self.size] = v.lane

        self._strength[self.size] = v.strength
        self._strafe[self.size] = v.strafe
    end

    self:generateLogJumps()

    self.currentID = self:getBefore(Tick.instance:getRelativeTime()).id
    if self.currentID < self.size then
        self.nextTime = self._traffic[self.currentID + 1]
    else
        self.nextTime = 7200
    end

    if oldSize == 0 then
        self.logger:log("Loaded traffic table successfully")
        self.logger:log("Total traffic count: " .. self.size)
    else
        self.logger:trace("Changed traffic table successfully", 1)
        self.logger:trace("Added " .. (self.size - oldsize) .. " blocks, total: " .. self.size, 1)
    end

    return false
end

function Traffic:get(name)
    if name == nil then
        return deepcopy(self._traffic)
    elseif type(name) == "number" and name > 0 and name <= self.size then
        return deepcopy(self._traffic[name])
    elseif self["_" .. name] ~= nil then
        return deepcopy(self["_" .. name])
    elseif name == "end" then
        return deepcopy(self._fin)
    elseif name == "endTime" then
        return deepcopy(self._finTime)
    else
        self.logger:warn("get: lookup failed")
        self.logger:debug("name = " .. name)
        return true
    end
end

function Traffic:add(new)
    return self:insert(new)
end
function Traffic:insert(new)
    if type(new) ~= "table" or (new.time == nil and new.seconds == nil) then
        self.logger:warn("insert: Not a valid block")
        self.logger:debug("new = " .. dump(new))
        return true
    end
    new.active = true
    new.time = new.time or new.seconds
    self._traffic[self.size] = new
    return self:sort()
end

function Traffic:mod(id, mod)
    return self:change(id, mod)
end
function Traffic:modify(id, mod)
    return self:change(id, mod)
end
function Traffic:change(id, mod)
    if id <= 0 or id > self.length or type(mod) ~= "table" then
        self.logger:warn("change: Invalid ")
        self.logger:debug("id = " .. id .. ", mod = " .. dump(mod))
        return true
    end

    for k,v in mod do
        if self["_" .. k] then
            self["_" .. k][id] = v
            self._traffic[id][k] = v
        end
    end
end

function Traffic:rem(id)
    return self:delete(id)
end
function Traffic:remove(id)
    return self:delete(id)
end
function Traffic:del(id)
    return self:delete(id)
end
function Traffic:delete(id)
    self._traffic[id] = self._traffic[self.size]
    self._traffic[self.size] = nil
    return self:sort()
end

function Traffic:getLast(count)
    if type(count) ~= "number" then
        count = 0
    end

    if self.currentID - count <= 0 then
        self.logger:warn("getLast: invalid count")
        self.logger:debug("count = " .. count)
        return true
    end

    return deepcopy(self._traffic[self.currentID - count])
end
function Traffic:getNext(count)
    if type(count) ~= "number" then
        count = 0
    end

    if self.currentID + count >= self.size then
        self.logger:warn("getNext: invalid count")
        self.logger:debug("count = " .. count)
        return true
    end

    return deepcopy(self._traffic[self.currentID + 1 + count])
end

function Traffic:getClosest(time, isRelative)
    if self.size <= 0 then
        return true
    end

    if type(time) ~= "number" then
        if isRelative == false then
            self.logger:warn("getClosest: invalid time")
            return true
        else
            return self._traffic[self.currentID] or true
        end
    else
        time = math.max(time, 0)
        if isRelative then
            time = Tick.instance:getRelativeTime() + time
        end
    end
    id = self:getBefore(time).id

    if id == self.size then
        return self._traffic[id]
    end
end

function Traffic:getBefore(time, isRelative)
    if self.size <= 0 then
        return true
    end

    local min = math.min
    local current = -1

    if type(time) ~= "number" then
        if isRelative == false then
            self.logger:warn("getBefore: invalid time")
            return true
        else
            return self._traffic[self.currentID] or true
        end
    else
        time = math.max(time, 0)
        if isRelative then
            time = Tick.instance:getRelativeTime() - time
            current = self.currentID
        else
            current = self.size
        end
    end
    local jumpCounter = #self._logBackJumps[current]

    while jumpCounter > 0 do
        if self._logBackJumps[current][jumpCounter][2] <= time then
            current = self._logBackJumps[current][jumpCounter][1]
            jumpCounter = min(jumpCounter - 1, #self._logBackJumps[current])
        else
            jumpCounter = jumpCounter - 1
        end
    end

    return deepcopy(self._traffic[current])
end
function Traffic:getAfter(time, isRelative)
    if self.size <= 0 then
        return true
    end

    local min = math.min
    local current = -1

    if type(time) ~= "number" then
        if isRelative == false then
            self.logger:warn("getBefore: invalid time")
        else
            return self._traffic[min(self.currentID+1, self.size)]
        end
    else
        time = math.max(time, 0)
        if isRelative then
            time = Tick.instance:getRelativeTime() + time
            current = self.currentID + 1
        else
            current = 1
        end
    end

    local jumpCounter = #self._logJumps[current]

    while jumpCounter > 0 do
        if self._logJumps[current][jumpCounter][2] > time then
            current = self._logJumps[current][jumpCounter][1]
            jumpCounter = min(jumpCounter - 1, #self._logJumps[current])
        else
            jumpCounter = jumpCounter - 1
        end
    end

    return deepcopy(self._traffic[current])
end

function Traffic:onTraffic(event)
    self:load(event.data)
end

function Traffic:onFrame(event)
    if self.nextTime <= Tick.instance:getRelativeTime() then
        self.currentID = self.currentID + 1

        if self.currentID < self.size then
            self.nextTime = self._traffic[self.currentID + 1]
        else
            self.nextTime = 7200
        end
    end
end
