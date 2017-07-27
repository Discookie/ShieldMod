require("logger")
require("events")
require("tick")
require("intervals")
require("diff")
require("utils/deepcopy")

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


--[[
Note position type is split as the following:

Negative: Manual position
Non-negative:
    2 bit: Type of limiting
    2 bit: Type of spreading
--]]
Note.PosTypes = {
    MANUAL = -1, -- manual position
    AUTO = 0, -- use global defaults
    DIST  = 1, -- force distance limiting
    VEL   = 2, -- force velocity limiting
    ACCEL = 3, -- force acceleration limiting
    -- AUTO = 0  -- use global defaults
    LINEAR = 4, -- linear spreading
    LOG    = 8, -- logarithmic spreading
    SIN    = 12 -- sinoidal spreading, coming soon
}

Note.RenderTypes = {
    AUTO = 0,
    BREF   = 1,
    BR     = 2,
    UPDATE = 3
}

Note.handTypes = {
    AUTO = 0,
    LEFT   = 1,
    RIGHT  = 2,
    MIDDLE = 3
}

function Note.init(obj)
    local self = setmetatable({}, Note)
    self.type = "Note"
    self.logger = Logger(self.type)
    self:reset()
    self:set(obj)
    return self
end

function Note:reset()
    self.time = 0
    self.timeType = false -- false for track pos, true for seconds
    self.length = 1
    self.lengthType = false -- false for track pos, true for seconds
    self.stack = 4 -- meteors in the same position
    self.pos = {x = 0, y = 0} -- assign manual positions here
    self.posType = {xType = Note.PosTypes.AUTO, y = Note.PosTypes.AUTO} -- refer to Note.PosTypes
    self.curve = {r = 0, yaw = 0, pitch = 0} -- later passed to game as yaw, pitch, radius
    self.curveAuto = true -- automatically generate curvature
    objects = {note = "Meteor", tail = "Meteor_Tail"} -- alternatively, you can give a note length-size array of object names
    renderType = Note.RenderTypes.AUTO
end

function Note:set(obj)
    if obj ~= table then return true end
    for k, v in pairs(obj) do
        if k == "logger" then
            v.close()
        elseif self[k] and not (k == "PosTypes" or k == "RenderTypes" or k == "type") and type(v) ~= "function" then
            self[k] = v
        end
    end
    return false
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

function Note:toBREF()

end

function Note:lt(other)
    local myTime = self.time
    local myLength = self.length
    local otherTime = other.time
    local otherLength = other.length

    if not self.timeType then
        myTime = Track.instance:getSecondsFromPos(myTime)
    end
    if not self.lengthType then
        myLength = Track.instance:getSecondsFromPos(myLength)
    end

    if not other.timeType then
        otherTime = Track.instance:getSecondsFromPos(otherTime)
    end
    if not other.lengthType then
        otherLength = Track.instance:getSecondsFromPos(otherLength)
    end

    return myTime < otherTime or (myTime == otherTime and myLength <= otherLength)
end

-- Note container

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
    NOTES_ADDED = 1,
    POS_ASSIGNED = 2,
    RENDERED = 3
}

function NoteContainer.init()
    local self = setmetatable({}, NoteContainer)
    self.type = "NoteContainer"
    self.logger = Logger(self.type)
    self.enabled = false
    self.state = NoteContainer.States.DEFAULT
    self:reset()
    return self
end

function NoteContainer:reset()
    if self.enabled then
        self:disable()
    end

    self.notes = {}

    self.state = NoteContainer.States.DEFAULT

    self:enable()
end

function NoteContainer:empty()
    return self:reset()
end

function NoteContainer:add(note)
    if self.state > NoteContainer.States.NOTES_ADDED then
        return true
    else
        self.state = NoteContainer.States.NOTES_ADDED
    end
    if type(note) == "table" then
        if note.type == "Note" then
            self.notes[self.size] = note
        else
            local _note = Note(note)
            self.notes[self.size] = _note
        end
        table.sort(notes)
        return false
    else
        return true
    end
end

function NoteContainer:del(id) -- Depetes the n-th note, does NOT delete based on individual note ID!
    if self.state > NoteContainer.States.NOTES_ADDED then
        return true
    elseif id < #self.notes then
        table.remove(self.notes, id)
        return false
    else
        return true
    end
end

function NoteContainer:getNotes()
    return deepcopy(self.notes)
end

function NoteContainer:assign()

end

function NoteContainer:_showBREF(arr)
    if type(arr) == "table" then
        UpdateBatchRenderer({uniqueName = id, showLocations = arr})
    else
        local _arr = {}
        for i = 1, #self.notes do
            if self.notes[i].renderType == Note.RenderTypes.BREF or (self.notes[i].renderType == Note.RenderTypes.AUTO and Diff.instance.renderDefault == Note.RenderTypes.BREF) then
                _arr[#_arr] = i
            end
        end
        UpdateBatchRenderer({uniqueName = id, showLocations = _arr})
    end
    return false
end

function NoteContainer:_hideBREF(arr)
    if type(arr) == "table" then
        UpdateBatchRenderer({uniqueName = id, hideLocations = arr})
    else
        local _arr = {}
        for i = 1, #self.notes do
            if self.notes[i].renderType == Note.RenderTypes.BREF or (self.notes[i].renderType == Note.RenderTypes.AUTO and Diff.instance.renderDefault == Note.RenderTypes.BREF) then
                _arr[#_arr] = i
            end
        end
        UpdateBatchRenderer({uniqueName = id, hideLocations = _arr})
    end
    return false
end

function NoteContainer:_showBR(arr)
    -- TODO
end

function NoteContainer:_hideBR(arr)
    -- TODO
end

function NoteContainer:_showUpdate(arr)
    -- TODO
end

function NoteContainer:_hideUpdate(arr)
    -- TODO
end

function NoteContainer:showNotes(arr)
    if self.state < NoteContainer.States.RENDERED then
        return true
    end

    if type(arr) == "table" then
        local bref = {}
        local br = {}
        local update = {}
        for i = 1, #arr do
            if self.notes[arr[i]].renderType == Note.RenderTypes.BREF or (self.notes[arr[i]].renderType == Note.RenderTypes.AUTO and Diff.instance.renderDefault == Note.RenderTypes.BREF) then
                bref[#bref] = arr[i]
            elseif self.notes[arr[i]].renderType == Note.RenderTypes.BR or (self.notes[arr[i]].renderType == Note.RenderTypes.AUTO and Diff.instance.renderDefault == Note.RenderTypes.BR) then
                br[#br] = arr[i]
            elseif self.notes[arr[i]].renderType == Note.RenderTypes.UPDATE or (self.notes[arr[i]].renderType == Note.RenderTypes.AUTO and Diff.instance.renderDefault == Note.RenderTypes.UPDATE) then
                update[#update] = arr[i]
            end
        end
        self:_showBREF(bref)
        self:_showBR(br)
        self:_showUpdate(update)
    else
        self:_showBREF()
        self:_showBR()
        self:_showUpdate()
    end
    return false
end

function NoteContainer:hideNotes(arr)
    if self.state < NoteContainer.States.RENDERED then
        return true
    end

    if type(arr) == "table" then
        local bref = {}
        local br = {}
        local update = {}
        for i = 1, #arr do
            if self.notes[arr[i]].renderType == Note.RenderTypes.BREF or (self.notes[arr[i]].renderType == Note.RenderTypes.AUTO and Diff.instance.renderDefault == Note.RenderTypes.BREF) then
                bref[#bref] = arr[i]
            elseif self.notes[arr[i]].renderType == Note.RenderTypes.BR or (self.notes[arr[i]].renderType == Note.RenderTypes.AUTO and Diff.instance.renderDefault == Note.RenderTypes.BR) then
                br[#br] = arr[i]
            elseif self.notes[arr[i]].renderType == Note.RenderTypes.UPDATE or (self.notes[arr[i]].renderType == Note.RenderTypes.AUTO and Diff.instance.renderDefault == Note.RenderTypes.UPDATE) then
                update[#update] = arr[i]
            end
        end
        self:_hideBREF(bref)
        self:_hideBR(br)
        self:_hideUpdate(update)
    else
        self:_hideBREF()
        self:_hideBR()
        self:_hideUpdate()
    end
end

function NoteContainer:_createBREF()
    for i = 1, #self.notes do
        if self.notes[i].renderType == Note.RenderTypes.BREF or (self.notes[i].renderType == Note.RenderTypes.AUTO and Diff.instance.renderDefault == Note.RenderTypes.BREF) then
            bref[#bref] = i
        end
    end
end

function NoteContainer:_createBR()
    -- TODO
end

function NoteContainer:_createUpdate()
    -- TODO
end

function NoteContainer:createRenderer()
    if self.state == NoteContainer.States.RENDERED then
        self:hideNotes()
    elseif self.state < NoteContainer.States.POS_ASSIGNED then
        if self:assign() then
            return true
        end
    end

    self.id = NoteContainer.lastID
    NoteContainer.lastID = NoteContainer.lastID + 1
    self:_createBREF()
    self:_createBR()
    self:_createUpdate()
    self.rendered = true;
end

function NoteContainer:onUpdate(ev)

end

function NoteContainer:onTraffic(ev)

end

function NoteContainer:enable()
    if not self.enabled then
        self.enabled = true
        if self.state == NoteContainer.States.RENDERED then
            self:showNotes()
        end
    end
end

function NoteContainer:disable()
    if self.enabled then
        if self.state == NoteContainer.States.RENDERED then
            self:hideNotes()
        end
        self.enabled = false
    end
end

NoteContainer.instance = NoteContainer()
