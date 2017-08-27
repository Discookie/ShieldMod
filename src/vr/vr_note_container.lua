require("../traffic/traffic_export")
require("note")
require("../utils/bit")

NoteContainer = {}
NoteContainer.__index = NoteContainer
setmetatable(NoteContainer, {
        __call = function(cls, ...)
            return cls.init(...)
        end,
})

NoteContainer.lastID = 0

NoteContainer.States = {
    DEFAULT = 0,
    TRAFFIC_LOADED = 1,
    POS_ASSIGNED = 2,
    RENDERED = 3,
}

NoteContainer.FilterFlags = {
    DEFAULT = 0,
    UNASSIGNED = 1,
    ASSIGNED = 1 + 2,
    HAS_LEFT = 4 + 8,
    HAS_RIGHT = 4 + 16,
    HAS_PURPLE = 4 + 32,
    EXCLUSIVE_HANDS = 64,
    ENABLED_ONLY = 128
}

function NoteContainer.init()
    local self = setmetatable({}, NoteContainer)
    self.type = "NoteContainer"
    self.logger = Logger(self.type)
    self.logger:log("Init")

    self:reset()

    return self
end

function NoteContainer:generateLogJumps()
    if self.size <= 0 then
        return true
    end

    self._logJumps = {}
    self._logBackJumps = {}
    for i = 1, self.size do
        local j = 1
        local k = 1

        self._logJumps[i] = {}
        self._logBackJumps[self.size + 1 - i] = {}

        while i + k <= self.size do
            self._logJumps[i][j] = {i+k, self._notes[i+k].startTime}
            self._logBackJumps[self.size + 1 - i][j] = {self.size + 1 - i - k, self._notes[self.size + 1 - i - k].startTime}

            j = j + 1
            k = k * 2
        end
    end
    self._freshLogJumps = true
    return false
end

function NoteContainer:reset()
    if self._state == NoteContainer.States.RENDERED then
        self:hide()
    end

    if self._id then
        self._id = nil
    end
    if self._evid then
        EventHandler.instance:remove(self._evid)
    end
    if self._evid2 then
        EventHandler.instance:remove(self._evid)
    end
    self._id = NoteContainer.lastID
    NoteContainer.lastID = NoteContainer.lastID + 1
    self._evid = EventHandler.instance:on(Events.TRAFFIC, self.onTraffic, self)
    self._evid2 = EventHandler.instance:on(Events.POST_SKIN, self.postSkin, self)

    self._state = NoteContainer.States.DEFAULT

    self.size = 0
    self._notes = {}

    self._oneEmissive = false
    self._oneColor = false

    self._isHittable = true
    self._scaledByTrack = true

    self._freshLogJumps = false

    self.logger:log("Reset")
end

function NoteContainer:load(pos)
    if self._state == NoteContainer.States.RENDERED then
        self.logger:warn("Tried to add notes while rendered")
        return true
    elseif type(pos) ~= "table" then
        return true
    elseif pos.type ~= nil then
        altpos = {pos}
        pos = altpos
    end

    local failedNotes = 0

    for k,v in pairs(pos) do
        local newnote = Note(v)
        if newnote ~= true then
            self.size = self.size + 1
            self._notes[self.size] = newnote
            self._notes[self.size].id = self.size
        else
            failedNotes = failedNotes + 1
        end
    end
    self:sort()
    self.logger:log("Loaded " .. self.size .. "/" .. (self.size + failedNotes) .. " notes")
end

function NoteContainer:sort()
    local function comp(a, b)
        return a.startTime < b.startTime or (a.startTime == b.startTime and a.endTime < b.endTime)
    end
    table.sort(self._notes, comp)

    for k,v in ipairs(self._notes) do
        self._notes[k].id = k
    end

    self._state = NoteContainer.States.NOTES_ADDED

    self._freshLogJumps = false

    return false
end

function NoteContainer:set(opt, val)
    if opt == "notes" then
        self:reset()
        return self:load(val)
    elseif opt == "isHittable" or opt == "oneEmissive" or opt == "oneColor" then
        self["_" .. opt] = val
    else
        return true
    end
end

function NoteContainer:insert(mod)
    return self:load({mod})
end

function NoteContainer:change(id, mod)
    return self:modify(id, mod)
end
function NoteContainer:modify(id, mod)
    if id > 0 and id <= self.size then
        if type(mod) ~= table then
            return true
        end

        local ret = self._notes[id]:modify(mod)

        if mod.time ~= nil or mod.startTime ~= nil or mod.endTime ~= nil then
            self:sort()
        end

        return ret
    else
        return true
    end
end

function NoteContainer:remove(id)
    if id > 0 and id <= self.size then
        self._notes[self.id] = self._notes[self.size]
        self._notes[self.size] = nil
        self.size = self.size - 1
        self:sort()
    else
        return true
    end
end

function NoteContainer:get(what, isFlag)
    if isFlag then
        local floor = math.floor
        local filterAssign = what % 2 == 1
        local assigned = (floor(what / 2) % 2) == 1
        local filterHands = (floor(what / 4) % 2) == 1
        local hands = floor(what/8) % 8
        local excHands = floor(what/64)%2 == 1

        local ret = {}
        for k,v in pairs(self._notes) do
            if (not filterAssign or assigned == v.assigned) and (not filterHands or v:hasHands(hands, excHands)) then
                ret[#ret + 1] = deepcopy(v)
            end
        end
        return ret
    else
        if type(what) == "number" and what > 0 and what <= self.size then
            return self._notes[what]:copy()
        elseif type(what) == "string" and self["_" .. what] then
            return deepcopy(self["_" .. what])
        else
            return true
        end
    end
end

function NoteContainer:getNext(which, filter, count)
    if self.size <= 0 or type(which) ~= "number" then
        return true
    end

    if which < 0 then
        which = 0
    end
    if type(filter) ~= "number" then
        filter = NoteContainer.FilterFlags.DEFAULT
    end
    if type(count) ~= "number" or count <= 0 then
        count = 1
    end

    local floor = math.floor
    local filterAssign = filter % 2 == 1
    local assigned = (floor(filter / 2) % 2) == 1
    local filterHands = (floor(filter / 4) % 2) == 1
    local hands = floor(filter/8) % 8
    local excHands = floor(filter/64)%2 == 1
    local enOnly = floor(filter/128)%2 == 1

    while count > 0 and which < self.size do
        which = which + 1
        if ((not filterAssign or assigned == self._notes[which].assigned) and (not filterHands or self._notes[which]:hasHands(hands, excHands)) and (not enOnly or self._notes[which].enabled)) then -- don't question it, it works, i tested it thoroughly, fuck you, split lines by parentheses if you dont believe me
            count = count - 1
        end
    end

    if which >= self.size then
        return true
    else
        return self._notes[which]:copy()
    end
end

function NoteContainer:getPrevious(which, filter, count)
    return self:getPrev(which, filter, count)
end
function NoteContainer:getPrev(which, filter, count)
    if self.size <= 0 or type(which) ~= "number" then
        return true
    end

    if which > self.size + 1 then
        which = self.size + 1
    end
    if type(filter) ~= "number" then
        filter = NoteContainer.FilterFlags.DEFAULT
    end
    if type(count) ~= "number" or count <= 0 then
        count = 1
    end

    local floor = math.floor
    local filterAssign = filter % 2 == 1
    local assigned = (floor(filter / 2) % 2) == 1
    local filterHands = (floor(filter / 4) % 2) == 1
    local hands = floor(filter/8) % 8
    local excHands = floor(filter/64)%2 == 1
    local enOnly = floor(filter/128)%2 == 1

    while count > 0 and which > 1 do
        which = which - 1
        if ((not filterAssign or assigned == self._notes[which].assigned) and (not filterHands or self._notes[which]:hasHands(hands, excHands)) and (not enOnly or self._notes[which].enabled)) then -- don't question it, it works, i tested it thoroughly, fuck you, split lines by parentheses if you dont believe me
            count = count - 1
        end
    end
    if which <= 1 then
        return true
    else
        return self._notes[which]:copy()
    end
end

function NoteContainer:getBefore(time, filter)
    if self.size <= 0 then
        return true
    end

    if type(filter) ~= "number" then
        filter = NoteContainer.FilterFlags.DEFAULT
    end

    if not self._freshLogJumps then
        self:generateLogJumps()
        self._freshLogJumps = true
    end

    local min = math.min
    local floor = math.floor
    local current = self.size

    if type(time) ~= "number" then
        self.logger:warn("getBefore: invalid time")
        return true
    end

    local jumpCounter = #self._logBackJumps[current]

    while jumpCounter > 0 do
        if self._logBackJumps[current][jumpCounter][2] >= time then
            current = self._logBackJumps[current][jumpCounter][1]
            jumpCounter = min(jumpCounter - 1, #self._logBackJumps[current])
        else
            jumpCounter = jumpCounter - 1
        end
    end

    local filterAssign = filter % 2 == 1
    local assigned = (floor(filter / 2) % 2) == 1
    local filterHands = (floor(filter / 4) % 2) == 1
    local hands = floor(filter/8) % 8
    local excHands = floor(filter/64)%2 == 1
    local enOnly = floor(filter/128)%2 == 1

    while current > 0 and not ((not filterAssign or assigned == self._notes[current].assigned) and (not filterHands or self._notes[current]:hasHands(hands, excHands)) and (not enOnly or self._notes[current].enabled)) do
        current = current - 1
    end

    if current == 0 then
        return true
    else
        return self._notes[current]:copy()
    end
end

function NoteContainer:getAfter(time, filter)
    if self.size <= 0 then
        return true
    end

    if type(filter) ~= "number" then
        filter = NoteContainer.FilterFlags.DEFAULT
    end

    if not self._freshLogJumps then
        self:generateLogJumps()
        self._freshLogJumps = true
    end

    local min = math.min
    local floor = math.floor
    local current = 1

    if type(time) ~= "number" then
        self.logger:warn("getAfter: invalid time")
        return true
    end

    local jumpCounter = #self._logJumps[current]
    while jumpCounter > 0 do
        if self._logJumps[current][jumpCounter][2] <= time then
            current = self._logJumps[current][jumpCounter][1]
            jumpCounter = min(jumpCounter - 1, #self._logJumps[current])
        else
            jumpCounter = jumpCounter - 1
        end
    end

    local filterAssign = filter % 2 == 1
    local assigned = (floor(filter / 2) % 2) == 1
    local filterHands = (floor(filter / 4) % 2) == 1
    local hands = floor(filter/8) % 8
    local excHands = floor(filter/64)%2 == 1
    local enOnly = floor(filter/128)%2 == 1

    while current <= self.size and not ((not filterAssign or assigned == self._notes[current].assigned) and (not filterHands or self._notes[current]:hasHands(hands, excHands)) and (not enOnly or self._notes[current].enabled)) do
        current = current + 1
    end

    if current == self.size + 1 then
        return true
    else
        return self._notes[current]:copy()
    end
end

function NoteContainer:getClosest(time, filter)
    if self.size <= 0 then
        return true
    end

    if type(filter) ~= "number" then
        filter = NoteContainer.FilterFlags.DEFAULT
    end

    if not self._freshLogJumps then
        self:generateLogJumps()
        self._freshLogJumps = true
    end

    before = self:getBefore(time)
    after = self:getAfter(time)
    if before == true then
        return after
    elseif after == true then
        return before
    else
        if math.abs(time - before.startTime) > math.abs(time - after.startTime) then
            return after
        else
            return before
        end
    end
end

function NoteContainer:assignPos()
    local rand = math.random
    local abs = math.abs
    local min = math.min
    local max = math.max
    local done = {}

    self.logger:log("Using default positioning for " .. self.size .. " notes")

    for k,v in ipairs(self._notes) do
        done[k] = false
    end

    for k,v in ipairs(Track.instance:get("powerNodes")) do
        local lid = self:getBefore(Track.instance:getNode(v).time).id
        while self._notes[lid].lengthNode < 5 do
            lid = lid + 1
        end
        if not done[lid] then
            self._notes[lid]:setHand(Note.HandTypes.PURPLE)

            self._notes[lid].pos.x = (rand()-0.5) * Diff.instance.spanX + Diff.instance.spanX_offset
            local maxLocalTilt = 0
            for i=self._notes[lid].startNode,self._notes[lid].endNode do
                maxLocalTilt = max(maxLocalTilt, Track.instance:getNode(i).rot.y)
            end
            self._notes[lid].pos.y = math.pow((maxLocalTilt - Track.instance.minTilt) / (Track.instance.maxTilt - Track.instance.minTilt), 2) * Diff.instance.spanY + rand() * Diff.instance.spanY_random
            self._notes[lid].assigned = true
            done[lid] = true
        end
    end

    for k,v in ipairs(self._notes) do
        if not done[k] and self._notes[k].enabled then
            local nextTime = self:getNext(self._notes[k].id, NoteContainer.FilterFlags.ENABLED_ONLY)
            if nextTime == true or nextTime.startTime - self._notes[k].endTime > 4 or (nextTime.startTime - self._notes[k].endTime > 2 and Track.instance:getNode(self._notes[k].startNode).intensity > 0.5) then
                self._notes[k]:setHand(Note.HandTypes.LEFT + Note.HandTypes.RIGHT)

                self._notes[k].pos.x = Diff.instance.spanX_offset
                local maxLocalTilt = 0
                for i=self._notes[k].startNode,self._notes[k].endNode do
                    maxLocalTilt = max(maxLocalTilt, Track.instance:getNode(i).rot.y)
                end
                self._notes[k].pos.y = math.pow((maxLocalTilt - Track.instance.minTilt) / (Track.instance.maxTilt - Track.instance.minTilt), 2) * Diff.instance.spanY + rand() * Diff.instance.spanY_random

                self._notes[k].span.y = 0
                self._notes[k].span.x = rand() * (Diff.instance.maxCrosshandSpan + Diff.instance.maxDoubleSpan - 2 * Diff.instance.minDoubleSpan) - Diff.instance.maxCrosshandSpan

                if self._notes[k].span.x > 0-Diff.instance.minDoubleSpan then
                    self._notes[k].span.x = self._notes[k].span.x + 2 * Diff.instance.minDoubleSpan
                end

                self._notes[k].assigned = true
            elseif self:getPrev(k, NoteContainer.FilterFlags.ENABLED_ONLY) == true or (self._notes[k].startTime - self:getPrev(k, NoteContainer.FilterFlags.ENABLED_ONLY).endTime) > Diff.instance.minSpacing then
                if Track.instance:getNode(self._notes[k].startNode).intensity > Diff.instance.doubleIntensity and rand() < Diff.instance.doubleFactor then
                    self._notes[k]:setHand(Note.HandTypes.LEFT + Note.HandTypes.RIGHT)

                    self._notes[k].pos.x = (rand()-0.5) * (Diff.instance.spanX - 2 * Diff.instance.minDoubleSpan) + Diff.instance.spanX_offset
                    local maxLocalTilt = 0
                    for i=self._notes[k].startNode,self._notes[k].endNode do
                        maxLocalTilt = max(maxLocalTilt, Track.instance:getNode(i).rot.y)
                    end
                    self._notes[k].pos.y = math.pow((maxLocalTilt - Track.instance.minTilt) / (Track.instance.maxTilt - Track.instance.minTilt), 2) * Diff.instance.spanY + rand() * Diff.instance.spanY_random

                    self._notes[k].span.y = 0

                    local distToBorder = (Diff.instance.spanX / 2) - abs(self._notes[k].pos.x)
                    self._notes[k].span.x = rand() * (min(Diff.instance.maxCrosshandSpan, distToBorder) + min(Diff.instance.maxDoubleSpan, distToBorder) - 2 * Diff.instance.minDoubleSpan) - min(Diff.instance.maxCrosshandSpan, distToBorder)

                    if self._notes[k].span.x > 0-Diff.instance.minDoubleSpan then
                        self._notes[k].span.x = self._notes[k].span.x + 2 * Diff.instance.minDoubleSpan
                    end

                    self._notes[k].assigned = true
                else
                    if rand() < 0.5 then
                        self._notes[k]:setHand(Note.HandTypes.LEFT)
                    else
                        self._notes[k]:setHand(Note.HandTypes.RIGHT)
                    end

                    self._notes[k].pos.x = (rand()-0.5) * Diff.instance.spanX + Diff.instance.spanX_offset
                    local maxLocalTilt = 0
                    for i=self._notes[k].startNode,self._notes[k].endNode do
                        maxLocalTilt = max(maxLocalTilt, Track.instance:getNode(i).rot.y)
                    end
                    self._notes[k].pos.y = math.pow((maxLocalTilt - Track.instance.minTilt) / (Track.instance.maxTilt - Track.instance.minTilt), 2) * Diff.instance.spanY + rand() * Diff.instance.spanY_random

                    self._notes[k].assigned = true
                end
            else
                self._notes[k]:disable()
            end
        end
    end
    return false
end

function NoteContainer:show()

end

function NoteContainer:hide()

end

function NoteContainer:toggle()

end

function NoteContainer:render()
    local brefName  = tostring(self._id)
    local brefCount = {}

    local brefNodes      = {}
    local brefPos        = {}
    local brefHandTypes  = {}
    local brefIsHittable = {}

    local brefMaxNodes = {}
    local brefMaxDist  = {}

    local brefEmissives = {}
    local brefColors    = {}

    local brefScales        = {}
    local brefSpeeds        = {}
    local brefScaledByTrack = {}

    local brefDirections = {}
    local brefCurvePeaks = {}

    local brefWTF = 9

    local totalCount = 0

    for k,v in ipairs(self._notes) do
        local brefWannabe = self._notes[k]:toBREF()
        if #brefWannabe ~= 0 then
            for l,u in ipairs(brefWannabe) do
                if brefCount[u.tailedObject] == nil then
                    brefCount[u.tailedObject] = 1

                    brefNodes[u.tailedObject]      = {}
                    brefPos[u.tailedObject]        = {}
                    brefHandTypes[u.tailedObject]  = {}
                    brefIsHittable[u.tailedObject] = type(self._isHittable) == "table" and self._isHittable[u.tailedObject] or self._isHittable

                    brefMaxNodes[u.tailedObject] = Diff.instance.maxNotesShown
                    brefMaxDist[u.tailedObject]  = Diff.instance.maxDistanceShown

                    if self._oneEmissive then
                        brefEmissives[u.tailedObject] = type(self._oneEmissive) == "table" and self._oneEmissive[u.tailedObject] or self._oneEmissive
                    else
                        brefEmissives[u.tailedObject] = {}
                    end
                    if self._oneColor then
                        brefColors[u.tailedObject] = type(self._oneColor) == "table" and self._oneColor[u.tailedObject] or self._oneColor
                    else
                        brefColors[u.tailedObject] = {}
                    end

                    brefScales[u.tailedObject] = {}
                    brefSpeeds[u.tailedObject] = {}
                    brefScaledByTrack[u.tailedObject] = type(self._scaledByTrack) == "table" and self._scaledByTrack[u.tailedObject] or self._scaledByTrack

                    brefDirections[u.tailedObject] = {}
                    brefCurvePeaks[u.tailedObject] = {}

                else
                    brefCount[u.tailedObject] = brefCount[u.tailedObject] + 1
                end

                brefNodes[u.tailedObject][brefCount[u.tailedObject]]      = u.node
                brefPos[u.tailedObject][brefCount[u.tailedObject]]        = u.pos
                brefHandTypes[u.tailedObject][brefCount[u.tailedObject]]  = u.handType

                if not self._oneEmissive then
                    brefEmissives[u.tailedObject][brefCount[u.tailedObject]] = u.emissive
                end
                if not self._oneColor then
                    brefColors[u.tailedObject][brefCount[u.tailedObject]]    = u.color
                end

                brefScales[u.tailedObject][brefCount[u.tailedObject]] = u.scale
                brefSpeeds[u.tailedObject][brefCount[u.tailedObject]] = u.speed

                brefDirections[u.tailedObject][brefCount[u.tailedObject]] = u.direction
                brefCurvePeaks[u.tailedObject][brefCount[u.tailedObject]] = u.curvePeak
                totalCount = totalCount + 1
            end
        end
    end

    self.logger:debug("BrefCount: " .. dump(brefCount))
    self._renderedObjects = deepcopy(brefCount)

    for k,v in pairs(brefCount) do
        BatchRenderEveryFrame({
                uniqueName = self._id .. "_" .. k,
                prefabName = string.sub(k, 3),
                ismeteortail     = (string.sub(k, 1, 2) == "t_"),

                locations                 = brefNodes[k],
                override_impactpositions  = brefPos[k],
                typeids                   = brefHandTypes[k],
                broadcastimpactvelocities = brefIsHittable[k],

                maxShown         = brefMaxNodes[k],
                maxDistanceShown = brefMaxDist[k],

                emissivecolors = brefEmissives[k],
                colors         = brefColors[k],

                scales                                 = brefScales[k],
                songspeedratios                        = brefSpeeds[k],
                override_velocities_scaledbytrackspeed = brefScaledByTrack[k],

                override_velocities             = brefDirections[k],
                sinCurvePositionDistortionPeaks = brefCurvePeaks[k],
                afternodereached_numbernodesrendered = brefWTF
        })
    end
    self.logger:log("Rendered " .. totalCount .. " notes via BatchRenderEveryFrame")
end

function NoteContainer:onTraffic(ev)
    self:load(Traffic.instance:get())
end

function NoteContainer:postSkin(ev)
    self:assignPos()
    self:render()
end
