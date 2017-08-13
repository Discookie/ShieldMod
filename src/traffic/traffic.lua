require("../logger")
require("../events")
require("../utils/deepcopy")
require("../note")

Traffic = {}

Traffic.__index = Traffic

setmetatable(Traffic, {
        __call = function(cls, ...)
            return cls.init(...)
        end
})

function Traffic.init()

end
