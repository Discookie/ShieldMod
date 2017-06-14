Node = {}
Node.__index = Node
setmetatable(Node, {
        __call = function(cls, ...)
            return cls.init(...)
        end,
})

function Node.init()
    local self = setmetatable({}, Node)
    self.type = "Node"

    return self
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

    return self
end
