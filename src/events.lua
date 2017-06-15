EventHandler = {}
EventHandler.__index = EventHandler
setmetatable(EventHandler, {
        __call = function(cls, ...)
            return cls.init(...)
        end,
})

function EventHandler.init()
    local self = setmetatable({}, EventHandler)
    self.type = "EventHandler"
    self:reset()
    return self
end

function EventHandler:reset()
    self._intervals
end

function EventHandler:add(event, callback)

end

function EventHandler:disable(id)

end

function EventHandler:enable(id)

end

function EventHandler:delete(id)
    self:remove(id)
end

function EventHandler:remove(id)

end

function EventHandler:addInterval(seconds, callback)

end

function EventHandler:removeInterval(id)

end

function EventHandler:event(event)

end
