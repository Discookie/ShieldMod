require("../../../logger")
require("../../../events")
require("../../../intervals")
require("../../../vr/vr_export")
require("../../../diff/diff_export")
require("../helpers/accel_calc_v1")

sc_Accels_Colors = {
    [-1] = {
        0, 0, 255
    },
    [0] = {
        0, 255, 64
    },
    [1] = {
        64, 255, 0
    },
    [2] = {
        255, 128, 0
    },
    [3] = {
        255, 0, 0
    },
    [4] = {
        255, 0, 128
    },
}

sc_Accels_Overall = {}
sc_Accels_Active = {}
sc_Accels_EventIDs = {}
sc_Accels_Count = 0
sc_Accels_Logger = Logger("AccelTracker")
sc_Accels_TotalFailed = 0
sc_Accels_Mode = "Avg"
sc_Accels_Timer = 5

function sc_Accels_RemoveNote(tid)
    local id = tid[1]
	sc_Accels_Active[id] = nil
	sc_Accels_RefreshScore()
	Intervals.instance:remove(sc_Accels_EventIDs[id])
	sc_Accels_EventIDs[id] = nil
end

function sc_Accels_RefreshScore()
	local final = 0
	local isMax = sc_Accels_Mode == "Max"
	local isAvg = sc_Accels_Mode == "Avg"
	local isCurrent = sc_Accels_Mode == "Current"
	local fullCount = 0
	local max = math.max
	for k,v in pairs(sc_Accels_Active) do
		if isAvg then
			final = final + v
		end
		if isMax then
			final = max(final, v)
        end
        fullCount = fullCount + 1
	end
    if isAvg then
        if fullCount > 0 then
            final = final / fullCount
        else
            final = 0
        end
    end
	if isCurrent then
        final = sc_Accels_Active[sc_Accels_Count]
    end

    if final == 0 then
	   SetScoreboardNote({
			text = sc_Accels_Mode .. " Acceleration: " .. final,
			color = sc_Accels_Colors[-1]
		})
    else
	   SetScoreboardNote({
			text = sc_Accels_Mode .. " Acceleration: " .. final,
			color = sc_Accels_Colors[math.floor(5*final/Diff.instance.maxAccel)]
		})
    end
end

EventHandler.instance:on(Events.INIT, function(ev)
        EventHandler.instance:on(Events.NOTE, function(ev)

                local id = ev.data.id
				local leftid = 0
				local rightid = 0

				if ev.data:hasHands(Note.HandTypes.LEFT) then
                	local prevLeft = NoteContainer.instance:getPrev(id, NoteContainer.FilterFlags.ASSIGNED + NoteContainer.FilterFlags.FILTER_HANDS + NoteContainer.FilterFlags.HAS_LEFT + NoteContainer.FilterFlags.ENABLED_ONLY)
                    local prevAccelLeft = 0

					if prevLeft ~= true then
                        prevAccelLeft = GetAccelValue(prevLeft.endPos.x - prevLeft.endSpan.x/2, ev.data.pos.x - ev.data.span.x/2, ev.data.startTime - prevLeft.endTime)
					end

                    if prevAccelLeft > 0 then
                        sc_Accels_Count = sc_Accels_Count + 1
                        sc_Accels_Active[sc_Accels_Count] = prevAccelLeft
                        sc_Accels_EventIDs[sc_Accels_Count] = Intervals.instance:addInterval(sc_Accels_Timer, true, sc_Accels_RemoveNote, {sc_Accels_Count})

                        if prevAccelLeft > Diff.instance.maxAccelLeft then
                            sc_Accels_TotalFailed = sc_Accels_TotalFailed + 1
                            sc_Accels_Logger:err("Very high acceleration: " .. prevAccelLeft .. "!")
                            sc_Accels_Logger:debug("Previous note: " .. dump(prevLeft))
                            sc_Accels_Logger:debug("Current note: " .. dump(ev.data))
                        end
                    end
                end

				if ev.data:hasHands(Note.HandTypes.RIGHT) then
                	local prevRight = NoteContainer.instance:getPrev(id, NoteContainer.FilterFlags.ASSIGNED + NoteContainer.FilterFlags.FILTER_HANDS + NoteContainer.FilterFlags.HAS_RIGHT + NoteContainer.FilterFlags.ENABLED_ONLY)
                    local prevAccelRight = 0

					if prevRight ~= true then
                        prevAccelRight = GetAccelValue(prevRight.endPos.x + prevRight.endSpan.x/2, ev.data.pos.x + ev.data.span.x/2, ev.data.startTime - prevRight.endTime)
					end

                    if prevAccelRight > 0 then
                        sc_Accels_Count = sc_Accels_Count + 1
                        sc_Accels_Active[sc_Accels_Count] = prevAccelRight
                        sc_Accels_EventIDs[sc_Accels_Count] = Intervals.instance:addInterval(sc_Accels_Timer, true, sc_Accels_RemoveNote, {sc_Accels_Count})

                        if prevAccelRight > Diff.instance.maxAccelRight then
                            sc_Accels_TotalFailed = sc_Accels_TotalFailed + 1
                            sc_Accels_Logger:err("Very high acceleration: " .. prevAccelRight .. "!")
                            sc_Accels_Logger:debug("Previous note: " .. dump(prevRight))
                            sc_Accels_Logger:debug("Current note: " .. dump(ev.data))
                        end
                    end
                end

                sc_Accels_RefreshScore()
                return false
            end
        )
        EventHandler.instance:on(Events.SCORE, function(ev)
            if sc_Accels_TotalFailed > 0 then
                sc_Accels_Logger:error("Total failed notes: " .. sc_Accels_TotalFailed)
            else
                sc_Accels_Logger:log("Total failed notes: 0")
            end
        end)
    end
)
