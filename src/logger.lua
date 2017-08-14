require("utils/round")

Logger = {}
Logger.__index = Logger
setmetatable(Logger, {
        __call = function(cls, ...)
            return cls.init(...)
        end,
})

-- Get system date
function Logger:getDate()
    return Logger.getDate()
end

function Logger.getDate()
    if Diff ~= nil and Diff.instance.useGameTime then
        return math.round(getMillisecondsSinceStartup(), 0)
    elseif Tick ~= nil and Tick.instance ~= nil then
        return Tick.instance:getAbsoluteTime()
    else
        return 0
    end
    --return game.tick -- coming soon
    --return os.date("%c ") -- %c prints full "d/a/te t:i:me" and an extra space
end
-- Using log4j error levels, refer to self.enabled = true
-- https://logging.apache.org/log4j/1.2/apidocs/org/apache/log4j/Level.html
Logger.LogLevels = {
    NONE = 0,
    EXC = 1,
    EXCEPTION = 1,
    FATAL = 1,
    ERR = 2,
    ERROR = 2,
    WARN = 3,
    WARNING = 3,
    LOG = 4,
    INFO = 4,
    DBG = 5,
    DEBUG = 5,
    TRACE = 7,
}
Logger.logLevel = require("settings/loglevel")

function Logger:exc(msg)
    self:fatal(msg)
end
function Logger:exception(msg)
    self:fatal(msg)
end
function Logger:fatal(msg)
    if Logger.logLevel >= Logger.LogLevels.FATAL then
        print(self:getDate() .. " [FATAL] <" .. self.name .. ">: " .. msg)
    end
    return false
end

function Logger:err(msg)
    self:error(msg)
    return false
end
function Logger:error(msg)
    if Logger.logLevel >= Logger.LogLevels.ERROR then
        print(self:getDate() .. " [ERROR] <" .. self.name .. ">: " .. msg)
    end
    return false
end

function Logger:warning(msg)
    return self:warn(msg)
end
function Logger:warn(msg)
    if Logger.logLevel >= Logger.LogLevels.WARN and self.enabled then
        print(self:getDate() .. " [WARN] <" .. self.name .. ">: " .. msg)
    end
    return false
end

function Logger:log(msg)
    return self:info(msg)
end
function Logger:info(msg)
    if Logger.logLevel >= Logger.LogLevels.INFO and self.enabled then
        print(self:getDate() .. " [INFO] <" .. self.name .. ">: " .. msg)
        -- print(msg)
    end
    return false
end

function Logger:dbg(msg)
    return self:debug(msg)
end
function Logger:debug(msg)
    if Logger.logLevel >= Logger.LogLevels.DEBUG and self.enabled then
        print(self:getDate() .. " [DEBUG] <" .. self.name .. ">: " .. msg)
    end
    return false
end

function Logger:trace(msg, lvl)
    if (lvl == nil and Logger.logLevel >= Logger.LogLevels.TRACE) or Logger.logLevel >= Logger.LogLevels.DEBUG + lvl and self.enabled then
        print(self:getDate() .. " [TRACE] <" .. self.name .. ">: " .. msg)
    end
    return false
end

function Logger:cName(name)
    return self:changeName(name)
end
function Logger:changeName(name)
    if type(name) ~= "string" then
        self.name = "unknown"
        return true
    else
        self.name = name
        return false
    end
end

function Logger:disable()
    self.enabled = false
    return false
end

function Logger:enable()
    self.enabled = true
    return false
end

function Logger:toggle()
    self.enabled = true
    return false
end

function Logger.init(name)
    local self = setmetatable({}, Logger)
    self.type = "Logger"
    self.enabled = true

    if type(name) ~= "string" then
        self.name = "unknown"
    else
        self.name = name
    end

    return self
end

Logger.Global = Logger("Global")
Logger.Global:err("LOGGER TEST - IGNORE ME")
Logger.Global:log("Log level is " .. Logger.logLevel)
