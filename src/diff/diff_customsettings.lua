require("diff")
require("../io/io_export")
require("../utils/json")

Diff.defaults_customsettings = {
    loadExternalSettings = true,
    updateHowToPlay = true
}

Diff.external_customsettings = {
    updateHowToPlay = true
}

table.merge(Diff.defaults, Diff.defaults_customsettings)
table.merge(Diff.external, Diff.external_customsettings)

EventHandler.instance:on(Events.INIT, function(ev)
        Diff.instance:loadValues(require("../../settings/game"))

        if IOEnabled and Diff.instance.loadExternalSettings then
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

EventHandler.instance:on(Events.INIT, function(ev)
        if IOEnabled and Diff.instance.updateHowToPlay then
            local lg = Logger("CustomDiff")
			local outputFiles = {
				Casual = io.open("mods\\Casual ShieldVR\\display.js", "wb"),
				Easy = io.open("mods\\Easy ShieldVR\\display.js", "wb"),
				Normal = io.open("mods\\Normal ShieldVR\\display.js", "wb"),
				Hard = io.open("mods\\Hard ShieldVR\\display.js", "wb"),
				Elite = io.open("mods\\Elite ShieldVR\\display.js", "wb")
			}
			local filesOverwritten = 0
			local settingsObj = {
				maxDiff = Diff.instance.maxAccel,
				avgDiff = math.floor(1/(1+Diff.instance.factAccel)*1000)/100,
				multiDiff = Diff.instance.doubleFactor*10,
				trillDiff = Diff.instance.minSpacing,
                synced = true
			}
            local settingsStr = "var diff = " .. json.encode(settingsObj) .. ";\n"
			for k,v in pairs(outputFiles) do
				lg:log("Overwriting " .. k .. " ShieldVR mod's settings file")
                v:write(settingsStr)
                v:close()
				filesOverwritten = filesOverwritten + 1
			end
        end
    end)
