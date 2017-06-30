require("logger")
require("events")
require("tick")
require("intervals")

Node = {}
Node.__index = Node
setmetatable(Node, {
        __call = function(cls, ...)
            return cls.init(...)
        end,
})

Node.timeTypes = {
    ERR = -1,
    DEFAULT = 0,
    STATIC = 1
}
Node

function Node.init()
    local self = setmetatable({}, Node)
    self.type = "Node"
    self.logger = Logger(self.type)
    self:reset()
    return self
end

function Node:reset()
    self.time = 0
    self.timeType = false
end

-- Node container

NodeContainer = {}
NodeContainer.__index = NodeContainer
setmetatable(NodeContainer, {
        __call = function(cls, ...)
            return cls.init(...)
        end,
})

function NodeContainer.init()
    local self = setmetatable({}, NodeContainer)
    self.type = "NodeContainer"
    self.logger = Logger(self.type)
    return self
end
