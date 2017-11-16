require("diff")
require("../io/io_export")
require("../utils/json")

EventHandler.instance:on(Events.INIT, function(ev)
        Diff.instance:loadValues(require("../../settings/game"))

        if IOEnabled then
            local lg = Logger("CustomDiff")
            lg:log("Loading settings from 'Audioshield\\settings\\diff.json'...")

            local df, err = io.open("settings\\diff.json", "rb")

            if df == nil then
                lg:log("File open failed: " .. tostring(err))
                return false
            end

            local valstr = df:read("*all")
            df:close()

            local valid, vals = pcall(json.decode, valstr)
            if not valid then
                lg:warn("Error while decoding file: " .. tostring(vals))
                lg:debug("Str: " .. tostring(valstr))
            elseif Diff.instance:loadExternal(vals) then
                lg:warn("Failed to load some values")
                lg:debug("Vals: " .. dump(vals))
            else
                lg:log("Loaded all values successfully")
                lg:trace("Vals: " .. dump(vals), 1)
            end
        end
    end)
