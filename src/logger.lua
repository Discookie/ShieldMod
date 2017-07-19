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
    return ""
    --return game.tick -- coming soon
    --return os.date("%c ") -- %c prints full "d/a/te t:i:me" and an extra space
end
-- Using log4j error levels, refer to self.enabled = true
-- https://logging.apache.org/log4j/1.2/apidocs/org/apache/log4j/Level.html
function Logger:exc(msg)
    self:fatal(msg)
end
function Logger:exception(msg)
    self:fatal(msg)
end
function Logger:fatal(msg)
    if logLevel > 0 and self.enabled then
        print(self:getDate() .. " [FATAL] <" .. self.name .. ">: " .. msg)
    end
    return false
end

function Logger:err(msg)
    self:error(msg)
    return false
end
function Logger:error(msg)
    if logLevel > 1 and self.enabled then
        print(self:getDate() .. " [ERROR] <" .. self.name .. ">: " .. msg)
    end
    return false
end

function Logger:warning(msg)
    return self:warn(msg)
end
function Logger:warn(msg)
    if logLevel > 2 and self.enabled then
        print(self:getDate() .. " [WARN] <" .. self.name .. ">: " .. msg)
    end
    return false
end

function Logger:log(msg)
    return self:info(msg)
end
function Logger:info(msg)
    if logLevel > 3 and self.enabled then
        print(self:getDate() .. " [INFO] <" .. self.name .. ">: " .. msg)
        -- print(msg)
    end
    return false
end

function Logger:dbg(msg)
    return self:debug(msg)
end
function Logger:debug(msg)
    if logLevel > 4 and self.enabled then
        print(self:getDate() .. " [DEBUG] <" .. self.name .. ">: " .. msg)
    end
    return false
end

function Logger:trace(msg, lvl)
    if (lvl == nil and logLevel > 6) or logLevel > 4+lvl and self.enabled then
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
