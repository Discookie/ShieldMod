require("../logger")
require("../utils/deepcopy")

FreqTraffic = {}

FreqTraffic.__index = FreqTraffic

setmetatable(FreqTraffic, {
        __call = function(cls, ...)
            return cls.init(...)
        end
})

function FreqTraffic.init()
    local self = setmetatable({}, FreqTraffic)
    self.type = "FreqTraffic"
    self.logger = Logger(self.type)
    self.logger:log("Init")
    self:reset()
    return self
end

function FreqTraffic:reset()
    if self._id ~= nil then
        EventHandler.instance:remove(self._id)
    end
    self._id = EventHandler.instance:on(Events.PRE_TRAFFIC, self.onFreq, self)

    self._freq = {}
    self._size = 0
    self._lengths = {}
    self._total = 0
    self.logger:log("Reset")
    return false
end

function FreqTraffic:load(array)
    return self:set(array)
end
function FreqTraffic:set(array)
    if type(array) ~= "table" then
        return true
    end

    if type(array[1]) == "table" then
        if type(array[1][1]) == "table" then
            for k,v in array do
                self._size = self._size + 1
                self._freq[self._size] = v
                self._lengths[self._size] = 0
                for l,b in v do
                    self._lengths[self._size] = self._lengths[self._size] + 1
                    self._total = self._total + 1
                end
            end
            self.logger:log("Loaded freq table successfully")
            self.logger:debug("Segment count: ".. self._size)
            self.logger:debug("Total count: " .. self._total)
        else

        end
    else

    end

    return false
end

function FreqTraffic:get(id, id2)
    if type(id) ~= "number" then
        return deepcopy(self._freq)
    elseif 0 < id and id <= self._size then
        if type(id2) ~= "number" then
            return deepcopy(self._freq[id])
        elseif 0 < id2 and id2 <= self._lengths[id] then
            return deepcopy(self._freq[id][id2])
        else
            self.logger:warn("get: Invalid ID2")
            self.logger:debug("ID: " .. tostring(id) .. ", ID2: " .. tostring(id2))
            return true
        end
    else
        self.logger:warn("get: Invalid ID")
        self.logger:debug("ID: " .. tostring(id) .. ", ID2: " .. tostring(id2))
        return true
    end
end

--[[
Later found out that it is not possible to set custom freqTables, but possible to set the number of them. This should be done via the Diff_GameSettings module.
--]]

--[[function FreqTraffic:apply()
    self.logger:log("Applying custom FreqTraffic tables...")
    -- blackmagic
    self.logger:log("Applied successfully.")
end--]]

function FreqTraffic:onFreq(event)
    self:load(event.data)
end
