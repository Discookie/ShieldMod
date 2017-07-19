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


--[[
Node position type is split as the following:

Negative: Manual position
Non-negative:
    2 bits: Type of limiting
    2 bit: Type of spreading
--]]
Node.PosTypes = {
    MANUAL = -1, -- manual position
    AUTO = 0, -- use global defaults
    DIST = 1, -- force distance limiting
    VEL = 2, -- force velocity limiting
    ACCEL = 3, -- force acceleration limiting
    -- AUTO = 0 -- use global defaults
    LINEAR = 4 -- linear spreading
    LOG = 8 -- logarithmic spreading
    SIN = 12 -- sinoidal spreading
}

Node.RenderTypes = {
    AUTO = 0,
    BREF = 1,
    BR = 2,
    UPDATE = 3
}

function Node.init()
    local self = setmetatable({}, Node)
    self.type = "Node"
    self.logger = Logger(self.type)
    self.id = -1
    self:reset()
    return self
end

function Node:reset()
    self.time = 0
    self.timeType = false -- false for nodes, true for seconds
    self.length = 1
    self.lengthType = false -- false for nodes, true for seconds
    self.stack = 4 -- meteors in the same position
    self.pos = {x = 0, y = 0} -- assign manual positions here
    self.posType = {xType = Node.PosTypes.AUTO, y = Node.PosTypes.AUTO} -- refer to Node.PosTypes
    self.curve = {r = 0, yaw = 0, pitch = 0} -- later passed to game as yaw, pitch, radius
    self.curveAuto = true -- automatically generate curvature
    objects = {node = "Meteor", tail = "Meteor_Tail"} -- alternatively, you can give a l-long array of object names
    renderTypes = Node.RenderTypes.AUTO
end

function Node:set(obj)
    if obj ~= table then return true end
    for k, v in pairs(obj) do
        if self[k] and k ~= "PosTypes" and k ~= "lastID" and k ~= "RenderTypes" and type(v) ~= "function" then
            self[k] = v
        end
    end
    return false
end

function Node:get()
    local ret = {}
    for k, v in pairs(self) do
        if k ~= "PosTypes" and k ~= "lastID" and k ~= "RenderTypes" and type(v) ~= "function" then
            ret[k] = v
        end
    end
end

-- Node container

NodeContainer = {}
NodeContainer.__index = NodeContainer
setmetatable(NodeContainer, {
        __call = function(cls, ...)
            return cls.init(...)
        end,
})

NodeContainer.lastID = 0

function NodeContainer.init()
    local self = setmetatable({}, NodeContainer)
    self.type = "NodeContainer"
    self.logger = Logger(self.type)
    self.id = NodeContainer.lastID
    NodeContainer.lastID = NodeContainer.lastID + 1
    return self
end
