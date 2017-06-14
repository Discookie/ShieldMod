EventHandler = {}
EventHandler.__index = EventHandler
setmetatable(EventHandler, {
        __call = function(cls, ...)
            return cls.init(...)
        end,
})

function EventHandler.init()
    local self = setmetatable({}, EventHandler)
    self.type = "Node"

    return self
end
