
Note = {}
Note.__index = Note
setmetatable(Note, {
        __call = function(cls, ...)
            return cls.init(...)
        end,
        __lt = function(a, b)
            return a:lt(b)
        end
})

Note.Objects = {
    AUTO = 0,
    DEFAULT = "Meteor",
    DEFAULT_TAIL = "Meteor_Tail"
}

Note.HandTypes = {
    AUTO = 0,
    LEFT   = 1,
    RIGHT  = 2,
    PURPLE = 4
}

function Note.init(obj)
    local self = setmetatable({}, Note)
    self.type = "Note"
    self.logger = Logger(self.type)
    self:reset()
    self:set(obj)
    return self
end

function Note.defaultOffset(id, pos, span, handType)
    return {
        pos = {x = pos.x, y = pos.y},
        span = {x = span.x, y = span.y}
    }
end

function Note:reset()
    self.enabled = true
    self.startTime = 0
    self.startNode = 0
    self.lengthTime = 0
    self.lengthNode = 1
    self.endTime = 0
    self.endNode = 0
    self.handType = Note.HandTypes.AUTO
    self.stack = 1 -- meteors in the same position
    self.pos = {x = 0, y = 0} -- assign manual positions here
    self.span = {x = 0, y = 0}
    self.offsetFunc = Note.defaultOffset
    self.assigned = false
    self.curve = {roll = 0, tilt = 0, pan = -1} -- The next one should be pan-tilt-roll? More testing is needed
    -- I only have "The game does this for us" as the official documentation LUL
    self.autoCurve = true
    self.objects = {note = Note.Objects.DEFAULT, tail = Note.Objects.DEFAULT_TAIL} -- alternatively, you can give a note length-size array of object names
    self.scales = {note = Diff.instance.noteScale, tail = Diff.instance.tailScale} -- same as above
    self.speeds = {Diff.instance.meteorSpeed} -- || --
    self.colors = {{53, 141, 255}, {255, 52, 0}, {103, 53, 176}}
    self.emissives = self.colors
end

function Note:modify(obj)
    return self:set(obj)
end
function Note:load(obj)
    return self:set(obj)
end
function Note:set(obj)
    if type(obj) ~= "table" then
        return true
    end

    if obj.type == "Note" then
        self.id = obj.id or 0
        self.enabled = obj.enabled
        self.startTime = obj.startTime
        self.startNode = obj.startNode
        self.endTime = obj.endTime
        self.endNode = obj.endNode
        self.lengthTime = obj.lengthTime
        self.lengthNode = obj.lengthNode
        self.handType = obj.handType
        self.stack = obj.stack
        self.pos = deepcopy(obj.pos)
        self.assigned = obj.assigned
        self.curve = deepcopy(obj.curve)
        self.autoCurve = obj.autoCurve
        self.objects = deepcopy(obj.objects)
        self.scales = deepcopy(obj.scales)
        self.speeds = deepcopy(obj.speeds)
        self.colors = deepcopy(obj.colors)
        self.emissives = (obj.colors == obj.emissives) and self.colors or deepcopy(obj.emissives)
        return false
    end

    if obj.node ~= nil or obj.startNode ~= nil then
        self.startNode = obj.startNode or obj.node
        self.startTime = obj.startTime or obj.time or Track.instance:nodeToTime(self.startNode)
    elseif obj.time ~= nil or obj.startTime ~= nil then
        self.startTime = obj.startTime or obj.time
        self.startNode = Track.instance:timeToNode(self.start)
    end
    if obj.endNode ~= nil then
        self.endNode = obj.endNode
        self.endTime = obj.endTime or Track.instance:nodeToTime(self.endNode)
    else
        self.endTime = obj.endTime or self.startTime
        self.endNode = Track.instance:timeToNode(self.endTime)
    end

    self.lengthTime = self.endTime - self.startTime
    self.lengthNode = self.endNode - self.startNode + 1

    self.offsetFunc = obj.offsetFunc or self.offsetFunc

    self.stack = obj.stack or self.stack
    if obj.pos then
        self.assigned = true
        self.pos.x = obj.pos.x or self.pos.x
        self.pos.y = obj.pos.y or self.pos.y
    end
    if obj.span then
        self.assigned = true
        self.span.x = obj.span.x or self.span.x
        self.span.y = obj.span.y or self.span.y
    end
    if obj.curve then
        self.curve = deepcopy(obj.curve)
        self.autoCurve = false
    end
    if obj.objects then
        self.objects = deepcopy(obj.objects)
    end
    if obj.scales then
        self.scales = deepcopy(obj.scales)
    end
    if obj.speeds then
        self.speeds = deepcopy(obj.speeds)
    end
    if obj.colors then
        self.colors = deepcopy(obj.colors)
        if obj.emissives then
            if obj.emissives == obj.colors then
                self.emissives = self.colors
            else
                self.emissives = deepcopy(obj.emissives)
            end
        end
    elseif obj.emissives then
        self.emissives = deepcopy(obj.emissives)
    end

    return false
end

function Note:enable()
    self.enabled = true
end

function Note:disable()
    self.enabled = false
end

function Note:toggle()
    self.enabled = not self.enabled
end

function Note:get()
    local ret = {}
    for k, v in pairs(self) do
        if k ~= "PosTypes" and k ~= "RenderTypes" and type(v) ~= "function" then
            ret[k] = v
        end
    end
    return ret
end

function Note:setHand(hand)
    if hand == 0 then
        return true
    end
    if self.assigned and self.handType >= 3 and hand < 3 then
        if hand == 2 then
            self.pos.x = self.pos.x + self.span.x / 2
            self.pos.y = self.pos.y + self.span.y / 2
        else
            self.pos.x = self.pos.x - self.span.x / 2
            self.pos.y = self.pos.y - self.span.y / 2
        end
    end

    self.handType = hand

    return false
end

function Note:hasHands(hands, excHands)
    local floor = math.floor
    return (
        hands%2 == self.handType%2 or (not excHands and self.handType%2 == 0)
    ) and (
        floor(hands/2)%2 == floor(self.handType/2)%2 or (not excHands and floor(self.handType/2)%2 == 0)
    ) and (
        floor(hands/4)%2 == floor(self.handType/4)%2 or (not excHands and floor(self.handType/4)%2 == 0)
    )
end

function Note:calcCurves(realPos)
    return {
        z = math.max(Diff.instance.spanZ - Diff.instance.spanZ_factor, math.sqrt(Diff.instance.spanZ*Diff.instance.spanZ - realPos.x*realPos.x - (realPos.y - Diff.instance.chestHeight)*(realPos.y - Diff.instance.chestHeight))),
        roll = self.autoCurve and 0 or self.curve.roll,
        tilt = self.autoCurve and 0 or self.curve.tilt,
        pan = self.autoCurve and -1 or self.curve.pan,
        peakX = realPos.x * Diff.instance.curveFactorX,
        peakY = math.min(math.max(realPos.y * Diff.instance.curveFactorY, Diff.instance.curveY_min), Diff.instance.curveY_max),
        peakZ = 0
    }
end

function Note:clone()
    return Note:copy()
end
function Note:copy()
    return Note(self)
end

function Note:toBREF()
    if not self.enabled then
        return {}
    end

    local floor = math.floor

    local ret = {}
    for i=1,(self.lengthNode) do
        local preSpanPos = self.offsetFunc(i, self.pos, self.span, Note.HandTypes.PURPLE)
        if floor(self.handType/4)%2==1 then
            local postSpanPos = {
                x = preSpanPos.pos.x,
                y = preSpanPos.pos.y
            }
            local curves = self:calcCurves(postSpanPos)
            local outPos = {postSpanPos.x, postSpanPos.y + Diff.instance.chestHeight, curves.z}
            local outDir = {curves.roll, curves.tilt, curves.pan}
            local obj = self.objects[i] or (i ~= 1 and self.objects.tail) or self.objects.note or self.objects[1]
            local tailedObj = (i~=1 and "t_" or "h_") .. obj
            local peaks = {curves.peakX, curves.peakY, curves.peakZ}

            local purp = {
                tailedObject = tailedObj,
                object = obj,
                node = self.startNode + i,
                pos = outPos,
                handType = 2,
                emissive = self.emissives[3],
                color = self.colors[3],
                scale = self.scales[i] or (i ~= 1 and self.scales.tail) or self.scales.note or self.scales[1],
                speed = self.speeds[i] or (i ~= 1 and self.speeds.tail) or self.speeds.note or self.speeds[1],
                direction = outDir,
                curvePeak = peaks
            }
            ret[#ret+1] = purp
        end
        if floor(self.handType/2)%2==1 then
            local postSpanPos = {
                x = preSpanPos.pos.x + preSpanPos.span.x,
                y = preSpanPos.pos.y + preSpanPos.span.y
            }
            local curves = self:calcCurves(postSpanPos)
            local outPos = {postSpanPos.x, postSpanPos.y + Diff.instance.chestHeight, curves.z}
            local outDir = {curves.roll, curves.tilt, curves.pan}
            local obj = self.objects[i] or (i ~= 1 and self.objects.tail) or self.objects.note or self.objects[1]
            local tailedObj = (i ~= 1 and "h_" or "t_") .. obj
            local peaks = {curves.peakX, curves.peakY, curves.peakZ}

            local rig = {
                tailedObject = tailedObj,
                object = obj,
                node = self.startNode + i,
                pos = outPos,
                handType = 1,
                emissive = self.emissives[2],
                color = self.colors[2],
                scale = self.scales[i] or (i ~= 1 and self.scales.tail) or self.scales.note or self.scales[1],
                speed = self.speeds[i] or (i ~= 1 and self.speeds.tail) or self.speeds.note or self.speeds[1],
                direction = outDir,
                curvePeak = peaks
            }
            ret[#ret+1] = rig
        end
        if self.handType%2==1 then
            local postSpanPos = {
                x = preSpanPos.pos.x - preSpanPos.span.x,
                y = preSpanPos.pos.y - preSpanPos.span.y
            }
            local curves = self:calcCurves(postSpanPos)
            local outPos = {postSpanPos.x, postSpanPos.y + Diff.instance.chestHeight, curves.z}
            local outDir = {curves.roll, curves.tilt, curves.pan}
            local obj = self.objects[i] or (i ~= 1 and self.objects.tail) or self.objects.note or self.objects[1]
            local tailedObj = (i ~= 1 and "h_" or "t_") .. obj
            local peaks = {curves.peakX, curves.peakY, curves.peakZ}

            local lef = {
                tailedObject = tailedObj,
                object = obj,
                node = self.startNode + i,
                pos = outPos,
                handType = 0,
                emissive = self.emissives[1],
                color = self.colors[1],
                scale = self.scales[i] or (i ~= 1 and self.scales.tail) or self.scales.note or self.scales[1],
                speed = self.speeds[i] or (i ~= 1 and self.speeds.tail) or self.speeds.note or self.speeds[1],
                direction = outDir,
                curvePeak = peaks
            }
            ret[#ret+1] = lef
        end
    end

    return ret
end
