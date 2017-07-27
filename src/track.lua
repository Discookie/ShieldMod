require("logger")
require("events")
require("utils/deepcopy")

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
    end
    self.track = {}

    self:clear()
    self._id = EventHandler.instance:on(Events.TRACK, self.onTrack, self)
    return false
end

function Track:clear()
    self.length = 0

    self._track = {[0] = {
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
                z = 0
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
    return false
end

function Track:process()
    self:clear()
    local lastTime = -5
    for k, v in ipairs(self.track) do
        self._track[k] = deepcopy(self._track[0])

        self.length = self.length + 1
        if v.maxair ~= nil then
            self._maxAir[k] = v.maxair
            self._track[k].maxAir = v.maxair
        else
            self._maxAir[k] = 0
        end
        if v.jumpairtime ~= nil then
            self._jumpAirTime[k] = v.jumpairtime
            self._track[k].jumpAirTime = v.jumpairtime
        else
            self._jumpAirTime[k] = 0
        end
        if v.antiairtime ~= nil then
            self._AjumpAirTime[k] = v.antiairtime
            self._track[k].AjumpAirTime = v.antiairtime
        else
            self._AjumpAirTime[k] = 0
        end

        if v.pos ~= nil then
            self._pos[k] = v.pos
            self._track[k].pos = v.pos
        else
            self._pos[k] = {x = 0, y = 0, z = 0}
        end
        if v.rot ~= nil then
            self._rot[k] = v.rot
            self._track[k].rot = v.rot
        else
            self._rot[k] = {x = 0, y = 0, z = 0}
        end
        if v.funkyrot ~= nil then
            self._funkyRot[k] = v.funkyrot
            self._track[k].funkyRot = v.funkyrot
        else
            self._funkyRot[k] = false
        end

        if v.color ~= nil then
            self._color[k] = v.color
        else
            self._color[k] = {r = 255, g = 255, b = 255, a = 0}
        end
        if v.intensity ~= nil then
            self._intensity[k] = v.intensity
        else
            self._intensity[k] = 0
        end

        if v.trafficstrength ~= nil then
            self._trafficStrength[k] = v.trafficstrength
        else
            self._trafficStrength[k] = 0
        end
        if v.antitrafficstrength ~= nil then
            self._AtrafficStrength[k] = v.antitrafficstrength
        else
            self._AtrafficStrength[k] = 0
        end

        if v.seconds ~= nil then
            self._time[k] = v.seconds
            lastTime = v.seconds
        else
            self._time[k] = lastTime
        end
    end
    return false
end

function Track:load(tr)
    if tr ~= nil then
        self.track = tr
    elseif GameStates.current == PRE_TRACK then
        return true
    else
        self.track = GetTrack()
    end

    self:process()
    return false
end

function Track:onTrack(ev)
    self.track = ev.data
    self:process()
    return false
end

function Track:timeToNode(sec)
    local lo = 1
    local hi = self.length
    local cur = 0
    local floor = math.floor


    if sec < self._seconds[lo] then
        return lo
    elseif sec > self._seconds[hi] then
        return hi
    end

    while (hi - lo)>1 do
        cur = floor((hi + lo)/2)
        if self._seconds[cur] > sec then
            hi = cur
        else
            lo = cur
        end
    end

    if (self._seconds[hi] - sec) > (sec - self._seconds[lo]) then
        return lo
    else
        return hi
    end
end

function Track:nodeToTime(num)
    if num <= 0 then
        return self._seconds[1]
    elseif num <= self.length then
        return self._seconds[num]
    else
        return self._seconds[self.length]
    end
end

function Track:getNode(num)
    if num > 0 and num <= self.length then
        local ret = self._track[num]
    else
        return self._track[0]
    end
end

function Track:get(varname)
    if self["_" .. varname] then
        return deepcopy(self["_" .. varname])
    else
        return true
    end
end

Track.instance = Track()
