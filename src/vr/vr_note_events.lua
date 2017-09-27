require("../logger")
require("../events")
require("../track/track_export")
require("vr_note_container")
require("../tick")

NoteEvents = {}

NoteEvents.__index = NoteEvents

setmetatable(NoteEvents, {
        __call = function(cls, ...)
            return cls.init(...)
        end
})

function NoteEvents.init(container)
    local self = setmetatable({}, NoteEvents)
    self.type = "NoteEvents"
    self.logger = Logger(self.type)
    self.logger:log("Init")
    self:reset()
    if container ~= nil then
        self:bind(container)
    end
    return self
end

function NoteEvents:reset()
    if self.bound then
        self:unbind()
    end
    if not Events.NOTE then
        Events.AddEvent("NOTE")
    end
    self.bound = false
    self.container = nil
    self.current = 0
    self.frameID = -1
end

function NoteEvents:bind(container)
    if type(container) ~= "table" or container.type ~= "NoteContainer" then
        self.logger:warn("bound: Invalid container to bind to")
        return true
    end
    if self.bound then
        self:unbind()
    end
    self.bound = true
    self.container = container
    self.oldRender = self.container.render
    self.container.render = function(cont)
        local ret = self.oldRender(cont)
        local ret2 = bindFunc(self.onRender, self)()
        return ret or ret2
    end
    self._id = EventHandler.instance:on(Events.FRAME, self.onFrame, self)
    return false
end

function NoteEvents:unbind()
    if not self.bound then
        return false
    end
    if self._id then
        EventHandler.instance:remove(self._id)
    end
    self.container.render = self.oldRender
    self.container = nil
    self.bound = false
    return false
end

function NoteEvents:onRender()
    if not self.bound then return true end
    self.nextNote = self.container:getAfter(Tick.instance:getRelativeTime(), NoteContainer.FilterFlags.ASSIGNED + NoteContainer.FilterFlags.ENABLED_ONLY)
    if self.nextNote ~= true then
        self.nextTime = self.nextNote.startTime
    else
        self.nextTime = 7200
    end
end

function NoteEvents:onFrame(event)
    if not self.bound then return true end
    if self.nextTime < Tick.instance:getRelativeTime() then
        local ev = Event(Events.NOTE, self.container.currentID)
        EventHandler.instance:throw(ev)

        self.nextNote = self.container:getNext(self.nextNote.id, NoteContainer.FilterFlags.ASSIGNED + NoteContainer.FilterFlags.ENABLED_ONLY)
        if self.nextNote ~= true then
            self.nextTime = self.nextNote.startTime
        else
            self.nextTime = 7200
        end
    end
end
