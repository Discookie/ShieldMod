require("../logger")
require("../utils/round")

IOEnabled = false

-- Optional: in previous versions, this will load the IO library
require("io_sandex")

require("io_check")

EventHandler.instance:on(Events.INIT, function(ev)
        local lg = Logger("IO Loader")
        lg:debug("Loading IO...")
        DoIOCheck()
        if not IOEnabled then
            if type(DoIOLoad) == "function" then
                DoIOLoad()
            end
            DoIOCheck()
            if not IOEnabled then
                    lg:error("Failed to load IO on second attempt - make sure you start your game with '+disablemodsecuritysandbox' or enable the 'io/sandex' module!")
                return true
            else
                lg:log("Loaded IO on second attempt")
            end
        else
            lg:log("Loaded IO on first attempt")
        end
    end)
