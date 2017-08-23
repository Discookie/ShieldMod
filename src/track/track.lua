require("../logger")
require("../diff/diff_export")
require("../events")
require("../tick")
require("../utils/deepcopy")

Track = {}

Track.__index = Track

setmetatable(Track, {
        __call = function(cls, ...)
            return cls.init(...)
        end
})

function Track.init()
    local self = setmetatable({}, Track)
    self.type = "Track"
    self.logger = Logger(self.type)
    self:reset()
    return self
end

function Track:reset()
    if self.id then
        EventHandler.instance:del(self._id)
        EventHandler.instance:del(self._frameid)
    end
    self.track = {}

    self:clear()
    self._id = EventHandler.instance:on(Events.TRACK, self.onTrack, self)
    self._frameid = EventHandler.instance:on(Events.FRAME, self.onFrame, self)
    return false
end

function Track:clear()
    self.size = 0

    self._track = {[0] = {
            type = "Node",
            maxAir = 0,
            jumpAirTime = 0,
            AjumpAirTime = 0,
            pos = {
                x = 0,
                y = 0,
                z = 0
            },
            rot = {
                x = 0,
                y = 0,
                z = 0,

                pan = 0,
                tilt = 0,
                roll = 0
            },
            funkyrot = false,
            color = {
                r = 255,
                g = 255,
                b = 255,
                a = 0
            },
            intensity = 0,
            trafficStrength = 0,
            AtrafficStrength = 0,
            time = -5
        }}
    self._maxAir = {}
    self._jumpAirTime = {}
    self._AjumpAirTime = {}

    self._pos = {} -- x-y-z
    self._rot = {} -- x-y-z, aka pan-tilt-roll
    self._funkyRot = {}

    self._color = {} -- r-g-b-a
    self._intensity = {}

    self._trafficStrength = {}
    self._AtrafficStrength = {}

    self._time = {}

    self.current = 0
    self.currentNode = deepcopy(self._track[0])

    self.minTilt = 0
    self.maxTilt = 0

    return false
end

function Track:generateLogJumps()
    if self.size <= 0 then
        return true
    end

    self._logJumps = {}

    for i = 1, self.size do
        local j = 1
        local k = 1

        self._logJumps[i] = {}

        while i + k <= self.size do
            self._logJumps[i][j] = {i+k, self._time[i+k]}

            j = j + 1
            k = k * 2
        end
    end
    return false
end

function Track:process()
    self:clear()
    local lastTime = -5
    for k, v in ipairs(self.track) do
        self._track[k] = deepcopy(self._track[0])

        self.size = self.size + 1
        if v.maxair ~= nil then
            self._maxAir[k] = v.maxair
            self._track[k].maxAir = v.maxair
        else
            self._maxAir[k] = 0
            self._track[k].maxAir = 0
        end
        if v.jumpairtime ~= nil then
            self._jumpAirTime[k] = v.jumpairtime
            self._track[k].jumpAirTime = v.jumpairtime
        else
            self._jumpAirTime[k] = 0
            self._track[k].jumpAirTime = 0
        end
        if v.antiairtime ~= nil then
            self._AjumpAirTime[k] = v.antiairtime
            self._track[k].AjumpAirTime = v.antiairtime
        else
            self._AjumpAirTime[k] = 0
            self._track[k].AjumpAirTime = 0
        end

        if v.pos ~= nil then
            self._pos[k] = v.pos
            self._track[k].pos = v.pos
        else
            self._pos[k] = {x = 0, y = 0, z = 0}
            self._track[k].pos = {x = 0, y = 0, z = 0}
        end
        if v.rot ~= nil then
            self._rot[k] = {x = v.rot.x, roll = v.rot.x,  y = v.rot.y, tilt = v.rot.y,  z = v.rot.z, pan = v.rot.z}
            self._track[k].rot = {x = v.rot.x, roll = v.rot.x,  y = v.rot.y, tilt = v.rot.y,  z = v.rot.z, pan = v.rot.z}
        else
            self._rot[k] = {x = 0, y = 0, z = 0, pan = 0, tilt = 0, roll = 0}
            self._track[k].rot = {x = 0, y = 0, z = 0, pan = 0, tilt = 0, roll = 0}
        end
        if v.funkyrot ~= nil then
            self._funkyRot[k] = v.funkyrot
            self._track[k].funkyRot = v.funkyrot
        else
            self._funkyRot[k] = false
            self._track[k].funkyRot = false
        end

        if v.color ~= nil then
            self._color[k] = v.color
            self._track[k].color = v.color
        else
            self._color[k] = {r = 255, g = 255, b = 255, a = 0}
            self._track[k].color = {r = 255, g = 255, b = 255, a = 0}
        end
        if v.intensity ~= nil then
            self._intensity[k] = v.intensity
            self._track[k].intensity = v.intensity
        else
            self._intensity[k] = 0
            self._track[k].intensity = 0
        end

        if v.trafficstrength ~= nil then
            self._trafficStrength[k] = v.trafficstrength
            self._track[k].trafficStrength = v.trafficstrength
        else
            self._trafficStrength[k] = 0
            self._track[k].trafficStrength = 0
        end
        if v.antitrafficstrength ~= nil then
            self._AtrafficStrength[k] = v.antitrafficstrength
            self._track[k].AtrafficStrength = v.antitrafficstrength
        else
            self._AtrafficStrength[k] = 0
            self._track[k].AtrafficStrength = 0
        end

        if v.seconds ~= nil then
            self._time[k] = v.seconds
            self._track[k].time = v.seconds
            lastTime = v.seconds
        else
            self._time[k] = lastTime
            self._track[k].time = lastTime
        end

        self._track[k].id = k
    end

    local min = math.min
    local max = math.max

    for i=1,self.size do
        self.minTilt = min(self.minTilt, self._rot[i].tilt)
        self.maxTilt = max(self.maxTilt, self._rot[i].tilt)
    end

    self:generateLogJumps()

    return false
end

function Track:load(tr)
    if type(tr) == "table" then
        self.track = tr
    elseif GameStates.current == PRE_TRACK then
        return true
    else
        self.track = GetTrack()
    end

    self:process()

    return false
end

function Track:timeToNode(sec)
    if self.size <= 0 then
        return true
    end

    local min = math.min
    local current = 1

    local jumpCounter = #self._logJumps[current]

    while jumpCounter > 0 do
        if self._logJumps[current][jumpCounter][2] > sec then
            current = self._logJumps[current][jumpCounter][1]
            jumpCounter = min(jumpCounter - 1, #self._logJumps[current])
        else
            jumpCounter = jumpCounter - 1
        end
    end
    return deepcopy(self._track[current])
end

function Track:nodeToTime(num)
    if num <= 0 then
        return self._time[1]
    elseif num <= self.size then
        return self._time[num]
    else
        return self._time[self.size]
    end
end

function Track:getNode(num)
    if num > 0 and num <= self.size then
        local ret = self._track[num]
    else
        return self._track[0]
    end
end

function Track:get(varname)
    if varname == nil then
        return deepcopy(self._track)
    elseif self["_" .. varname] then
        return deepcopy(self["_" .. varname])
    else
        return true
    end
end

function Track:onTrack(ev)
    self.track = ev.data
    self:process()
    return false
end

function Track:onFrame(ev)
    self.currentNode = self:timeToNode(Tick.instance:getRelativeTime())
    self.currentID = self.currentNode.id
    return false
end
