require("../logger")

Diff = {}
Diff.__index = Diff
setmetatable(Diff, {
        __call = function(cls, ...)
            return cls.init(...)
        end,
})

Diff.defaults = {}

function Diff.init(values)
    local self = setmetatable({}, Diff)
    self.type = "Diff"
    self.logger = Logger(self.type)
    self:loadDefaults()
    if values ~= nil then
        self:loadValues(values)
    end
    return self
end

function Diff:loadDefaults()
    for k, v in pairs(Diff.defaults) do
        self[k] = v
    end

    return false
end

function Diff:loadValues(values)
    if type(values) ~= "table" then
        return true
    end
    for k, v in pairs(values) do
        if type(v) == "nil" or (type(v) == "string" and (v == "" or v == "default")) then
            self[k] = Diff.defaults[k]
        end
        self[k] = v
    end

    return false
end
