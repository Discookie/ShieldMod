function DoIOCheck()
    IOEnabled = false
    local lg = Logger("IOCheck")
    if type(io) ~= "table" then
        lg:debug("IO does not exist - make sure you start your game with '+disablemodsecuritysandbox' or enable the 'io/sandex' module!")
        return true
    elseif type(io.open) ~= "function" or type(io.close) ~= "function" then
        lg:debug("IO exists but cannot open files")
        return true
    elseif type(io.write) ~= "function" or type(io.read) ~= "function" then
        lg:debug("IO exists but cannot read and write")
        return true
    else
        lg:debug("IO enabled")
        IOEnabled = true
        return false
    end
end
