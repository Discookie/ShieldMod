require("../../../logger")
require("../../../events")
require("../../../intervals")
require("../../../vr/vr_export")
require("../../../diff/diff_export")
require("../helpers/accel_calc_v1")

sc_DoubleSpans_Colors = {
    [-1] = {
        0, 0, 255
    },
    [0] = {
        0, 128, 255
    },
    [1] = {
        0, 255, 0
    },
    [2] = {
        128, 255, 0
    },
    [3] = {
        255, 128, 0
    },
    [4] = {
        255, 0, 0
    },
    [5] = {
        255, 0, 128
    },
}

sc_DoubleSpans_Overall = {}
sc_DoubleSpans_Active = {}
sc_DoubleSpans_EventIDs = {}
sc_DoubleSpans_Count = 0
sc_DoubleSpans_Logger = Logger("DoubleSpanTracker")
sc_DoubleSpans_TotalFailed = 0

function sc_DoubleSpans_RemoveNote(tid)
    local id = tid[1]
	sc_DoubleSpans_Active[id] = nil
	Intervals.instance:remove(sc_DoubleSpans_EventIDs[id])
	sc_DoubleSpans_EventIDs[id] = nil

    if Diff.instance.debugDoubleSpanDisplay then
	   sc_DoubleSpans_RefreshScore()
    end
end

function sc_DoubleSpans_RefreshScore()
	local final = 0
	local isMax = Diff.instance.debugDoubleSpanDisplay == "Max"
	local isMaxNormal = Diff.instance.debugDoubleSpanDisplay == "Max Normal"
	local isMaxCrosshand = Diff.instance.debugDoubleSpanDisplay == "Max Crosshand"
	local isMin = Diff.instance.debugDoubleSpanDisplay == "Min"
	local isMinNormal = Diff.instance.debugDoubleSpanDisplay == "Min Normal"
	local isMinCrosshand = Diff.instance.debugDoubleSpanDisplay == "Min Crosshand"
	local isAvg = Diff.instance.debugDoubleSpanDisplay == "Avg"
	local isAvgNormal = Diff.instance.debugDoubleSpanDisplay == "Avg Normal"
	local isAvgCrosshand = Diff.instance.debugDoubleSpanDisplay == "Avg Crosshand"
	local isCurrent = Diff.instance.debugDoubleSpanDisplay == "Current"
	local isCurrentNormal = Diff.instance.debugDoubleSpanDisplay == "Current Normal"
	local isCurrentCrosshand = Diff.instance.debugDoubleSpanDisplay == "Current Crosshand"
	local fullCount = 0
	local max = math.max
    local min = math.min
    local abs = math.abs
	for k,v in pairs(sc_DoubleSpans_Active) do
        if isMax then
            final = max(final, abs(v))
        elseif isMin then
            final = final == 0 and abs(v) or min(final, abs(v))
        elseif isAvg then
            final = final + abs(v)
            fullCount = fullCount + 1
        end

        if v>=0 then
            if isMaxNormal then
                final = max(final, v)
            elseif isMinNormal then
                final = final == 0 and v or min(final, v)
            elseif isAvgNormal then
                final = final + v
                fullCount = fullCount + 1
            end
        end
        if v<=0 then
            if isMaxCrosshand then
                final = max(final, -v)
            elseif isMinCrosshand then
                final = final == 0 and -v or min(final, -v)
            elseif isAvgCrosshand then
                final = final - v
                fullCount = fullCount + 1
            end
        end
	end
    if fullCount > 0 then
        final = final / fullCount
    end
	if isCurrent then
        final = sc_DoubleSpans_Active[sc_DoubleSpans_Count]
    elseif isCurrentNormal and v>=0 then
        final = sc_DoubleSpans_Active[sc_DoubleSpans_Count]
    elseif isCurrentCrosshand and v<=0 then
        final = -sc_DoubleSpans_Active[sc_DoubleSpans_Count]
    end

    if (final or 0) == 0 then
	    SetScoreboardNote({
			text = Diff.instance.debugDoubleSpanDisplay .. " span: 0",
			color = sc_DoubleSpans_Colors[-1]
		})
    else
        local localColor = {}
        if isMaxNormal or isMinNormal or isAvgNormal or isCurrentNormal or (isCurrent and (final > 0)) then
            if final < Diff.instance.minDoubleSpan then
                localColor = sc_DoubleSpans_Colors[0]
            elseif final > Diff.instance.maxDoubleSpan then
                localColor = sc_DoubleSpans_Colors[5]
            else
                localColor = sc_DoubleSpans_Colors[math.floor(4*(final - Diff.instance.minDoubleSpan) / (Diff.instance.maxDoubleSpan - Diff.instance.minDoubleSpan))+1]
            end
        elseif isMaxCrosshand or isMinCrosshand or isAvgCrosshand or isCurrentCrosshand or (isCurrent and (final < 0)) then
            if abs(final) < Diff.instance.minDoubleSpan then
                localColor = sc_DoubleSpans_Colors[0]
            elseif abs(final) > Diff.instance.maxCrosshandSpan then
                localColor = sc_DoubleSpans_Colors[5]
            else
                localColor = sc_DoubleSpans_Colors[math.floor(4*(abs(final) - Diff.instance.minDoubleSpan) / (Diff.instance.maxCrosshandSpan - Diff.instance.minDoubleSpan))+1]
            end
        else
            if final < Diff.instance.minDoubleSpan then
                localColor = sc_DoubleSpans_Colors[0]
            elseif final > max(Diff.instance.maxDoubleSpan, Diff.instance.maxCrosshandSpan) then
                localColor = sc_DoubleSpans_Colors[5]
            else
                localColor = sc_DoubleSpans_Colors[math.floor(4*(final - Diff.instance.minDoubleSpan) / (max(Diff.instance.maxDoubleSpan, Diff.instance.maxCrosshandSpan) - Diff.instance.minDoubleSpan))+1]
            end
        end
	    SetScoreboardNote({
			text = Diff.instance.debugDoubleSpanDisplay .. " span: " .. final,
			color = localColor
		})
    end
end

EventHandler.instance:on(Events.INIT, function(ev)
        EventHandler.instance:on(Events.NOTE, function(ev)

                local id = ev.data.id

				if ev.data:hasHands(Note.HandTypes.LEFT + Note.HandTypes.RIGHT) and not ev.data:hasHands(Note.HandTypes.PURPLE, true) then
                    sc_DoubleSpans_Count = sc_DoubleSpans_Count + 1
                    sc_DoubleSpans_Active[sc_DoubleSpans_Count] = ev.data.span.x
                    sc_DoubleSpans_Overall[sc_DoubleSpans_Count] = ev.data.span.x
                    sc_DoubleSpans_EventIDs[sc_DoubleSpans_Count] = Intervals.instance:addInterval(Diff.instance.debugDoubleSpanTimer, true, sc_DoubleSpans_RemoveNote, {sc_DoubleSpans_Count})
                    if math.abs(ev.data.span.x) < Diff.instance.minDoubleSpan then
                        sc_DoubleSpans_Logger:error("Very small doublespan: " .. ev.data.span.x .. "!")

                        local prevLeft = NoteContainer.instance:getPrev(id, NoteContainer.FilterFlags.ASSIGNED + NoteContainer.FilterFlags.FILTER_HANDS + NoteContainer.FilterFlags.HAS_LEFT + NoteContainer.FilterFlags.ENABLED_ONLY)
                        local prevRight = NoteContainer.instance:getPrev(id, NoteContainer.FilterFlags.ASSIGNED + NoteContainer.FilterFlags.FILTER_HANDS + NoteContainer.FilterFlags.HAS_RIGHT + NoteContainer.FilterFlags.ENABLED_ONLY)

                        if prevLeft ~= true and prevRight ~= true and prevLeft.id == prevRight.id then
                            sc_DoubleSpans_Logger:debug("Previous double note: " .. dump(prevLeft))
                        else
                            if prevLeft ~= true then
                                sc_DoubleSpans_Logger:debug("Previous left note: " .. dump(prevLeft))
                            end
                            if prevRight ~= true then
                                sc_DoubleSpans_Logger:debug("Previous right note: " .. dump(prevRight))
                            end
                        end
                        sc_DoubleSpans_Logger:debug("Current note: " .. dump(ev.data))
                        sc_DoubleSpans_TotalFailed = sc_DoubleSpans_TotalFailed + 1
                    elseif ev.data.span.x > Diff.instance.maxDoubleSpan then
                        sc_DoubleSpans_Logger:error("Very large normal span: " .. ev.data.span.x .. "!")

                        local prevLeft = NoteContainer.instance:getPrev(id, NoteContainer.FilterFlags.ASSIGNED + NoteContainer.FilterFlags.FILTER_HANDS + NoteContainer.FilterFlags.HAS_LEFT + NoteContainer.FilterFlags.ENABLED_ONLY)
                        local prevRight = NoteContainer.instance:getPrev(id, NoteContainer.FilterFlags.ASSIGNED + NoteContainer.FilterFlags.FILTER_HANDS + NoteContainer.FilterFlags.HAS_RIGHT + NoteContainer.FilterFlags.ENABLED_ONLY)

                        if prevLeft ~= true and prevRight ~= true and prevLeft.id == prevRight.id then
                            sc_DoubleSpans_Logger:debug("Previous double note: " .. dump(prevLeft))
                        else
                            if prevLeft ~= true then
                                sc_DoubleSpans_Logger:debug("Previous left note: " .. dump(prevLeft))
                            end
                            if prevRight ~= true then
                                sc_DoubleSpans_Logger:debug("Previous right note: " .. dump(prevRight))
                            end
                        end
                        sc_DoubleSpans_Logger:debug("Current note: " .. dump(ev.data))
                        sc_DoubleSpans_TotalFailed = sc_DoubleSpans_TotalFailed + 1
                    elseif ev.data.span.x < -Diff.instance.maxCrosshandSpan then
                        sc_DoubleSpans_Logger:error("Very large crosshand span: " .. ev.data.span.x .. "!")

                        local prevLeft = NoteContainer.instance:getPrev(id, NoteContainer.FilterFlags.ASSIGNED + NoteContainer.FilterFlags.FILTER_HANDS + NoteContainer.FilterFlags.HAS_LEFT + NoteContainer.FilterFlags.ENABLED_ONLY)
                        local prevRight = NoteContainer.instance:getPrev(id, NoteContainer.FilterFlags.ASSIGNED + NoteContainer.FilterFlags.FILTER_HANDS + NoteContainer.FilterFlags.HAS_RIGHT + NoteContainer.FilterFlags.ENABLED_ONLY)

                        if prevLeft ~= true and prevRight ~= true and prevLeft.id == prevRight.id then
                            sc_DoubleSpans_Logger:debug("Previous double note: " .. dump(prevLeft))
                        else
                            if prevLeft ~= true then
                                sc_DoubleSpans_Logger:debug("Previous left note: " .. dump(prevLeft))
                            end
                            if prevRight ~= true then
                                sc_DoubleSpans_Logger:debug("Previous right note: " .. dump(prevRight))
                            end
                        end
                        sc_DoubleSpans_Logger:debug("Current note: " .. dump(ev.data))
                        sc_DoubleSpans_TotalFailed = sc_DoubleSpans_TotalFailed + 1
                    end

                    if Diff.instance.debugDoubleSpanDisplay then
                        sc_DoubleSpans_RefreshScore()
                    end
                end
                return false
            end
        )
        EventHandler.instance:on(Events.SCORE, function(ev)
            if sc_DoubleSpans_TotalFailed > 0 then
                sc_DoubleSpans_Logger:error("Total failed notes: " .. sc_DoubleSpans_TotalFailed)
            else
                sc_DoubleSpans_Logger:log("Total failed notes: 0")
            end
        end)
    end
)
