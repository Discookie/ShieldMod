require("diff")
require("../io/io_export")
require("../utils/json")

EventHandler.instance:on(Events.INIT, function(ev)
        Diff.instance:loadValues(require("../../settings/game"))

        if IOEnabled then
            local lg = Logger("CustomDiff")

            local settingsPath = "settings"

            lg:log("Loading settings from 'Audioshield\\" .. settingsPath .. "\\game.json'...")

            local settingsFile, err = io.open(settingsPath .. "\\game.json", "rb")

            if settingsFile == nil then
                if err == settingsPath .. "\\game.json: No such file or directory" then

                    lg:log("File not found! Creating file...")
                    settingsFile, err = io.open(settingsPath .. "\\game.json", "wb")

                    if settingsFile == nil then
                        lg:err("Failed to create file! Make sure there is a 'settings' folder in your Audioshield directory!")

                        return true
                    else
                        local defaultSettings = "{\n    "
                        defaultSettings = defaultSettings .. "\"maxAccel\": " .. Diff.instance.maxAccel .. ",\n    "
                        defaultSettings = defaultSettings .. "\"factAccel\": " .. Diff.instance.factAccel .. ",\n    \n    "
                        defaultSettings = defaultSettings .. "\"minDoubleSpan\": " .. Diff.instance.minDoubleSpan .. ",\n    "
                        defaultSettings = defaultSettings .. "\"maxDoubleSpan\": " .. Diff.instance.maxDoubleSpan .. ",\n    "
                        defaultSettings = defaultSettings .. "\"maxCrosshandSpan\": " .. Diff.instance.maxCrosshandSpan .. ",\n    \n    "
                        defaultSettings = defaultSettings .. "\"spanX\": " .. Diff.instance.spanX .. ",\n    \n    "
                        defaultSettings = defaultSettings .. "\"chestHeight\": " .. Diff.instance.chestHeight .. ",\n    \n    "
                        defaultSettings = defaultSettings .. "\"ballchainSpeed\": " .. Diff.instance.ballchainSpeed .. ",\n    "
                        defaultSettings = defaultSettings .. "\"meteorSpeed\": " .. Diff.instance.meteorSpeed .. "\n}"

                        settingsFile:write(defaultSettings)
                        settingsFile:close()
                    end
                else
                    lg:log("File open failed: " .. tostring(err))
                end
                return false
            end

            local valstr = settingsFile:read("*all")
            settingsFile:close()

            if valstr == "" then
                lg:log("File is empty! Creating file...")
                settingsFile, err = io.open(settingsPath .. "\\game.json", "wb")

                if settingsFile == nil then
                    lg:err("Failed to create file! Make sure there is a 'settings' folder in your Audioshield directory!")

                    return true
                else
                    local defaultSettings = "{\n    "
                    defaultSettings = defaultSettings .. "\"maxAccel\": " .. Diff.instance.maxAccel .. ",\n    "
                    defaultSettings = defaultSettings .. "\"factAccel\": " .. Diff.instance.factAccel .. ",\n    \n    "
                    defaultSettings = defaultSettings .. "\"minDoubleSpan\": " .. Diff.instance.minDoubleSpan .. ",\n    "
                    defaultSettings = defaultSettings .. "\"maxDoubleSpan\": " .. Diff.instance.maxDoubleSpan .. ",\n    "
                    defaultSettings = defaultSettings .. "\"maxCrosshandSpan\": " .. Diff.instance.maxCrosshandSpan .. ",\n    \n    "
                    defaultSettings = defaultSettings .. "\"spanX\": " .. Diff.instance.spanX .. ",\n    \n    "
                    defaultSettings = defaultSettings .. "\"chestHeight\": " .. Diff.instance.chestHeight .. ",\n    \n    "
                    defaultSettings = defaultSettings .. "\"ballchainSpeed\": " .. Diff.instance.ballchainSpeed .. ",\n    "
                    defaultSettings = defaultSettings .. "\"meteorSpeed\": " .. Diff.instance.meteorSpeed .. "\n}"

                    settingsFile:write(defaultSettings)
                    settingsFile:close()
                end
            end

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
