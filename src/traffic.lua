require("logger")
require("events")
require("utils/deepcopy")

Traffic = {}

Traffic.__index = Traffic

setmetatable(Traffic, {
        __call = function(cls, ...)
            return cls.init(...)
        end
})

function Track.init()

end
