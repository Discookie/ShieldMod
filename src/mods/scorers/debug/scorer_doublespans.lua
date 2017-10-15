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
        0, 255, 64
    },
    [2] = {
        64, 255, 0
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
sc_DoubleSpans_Mode = "Min"
sc_DoubleSpans_Timer = 1

function sc_DoubleSpans_RemoveNote(tid)
    local id = tid[1]
	sc_DoubleSpans_Active[id] = nil
	sc_DoubleSpans_RefreshScore()
	Intervals.instance:remove(sc_DoubleSpans_EventIDs[id])
	sc_DoubleSpans_EventIDs[id] = nil
end

function sc_DoubleSpans_RefreshScore()
	local final = 0
	local isMax = sc_DoubleSpans_Mode == "Max"
	local isMaxNormal = sc_DoubleSpans_Mode == "Max Normal"
	local isMaxCrosshand = sc_DoubleSpans_Mode == "Max Crosshand"
	local isMin = sc_DoubleSpans_Mode == "Min"
	local isMinNormal = sc_DoubleSpans_Mode == "Min Normal"
	local isMinCrosshand = sc_DoubleSpans_Mode == "Min Crosshand"
	local isAvg = sc_DoubleSpans_Mode == "Avg"
	local isAvgNormal = sc_DoubleSpans_Mode == "Avg Normal"
	local isAvgCrosshand = sc_DoubleSpans_Mode == "Avg Crosshand"
	local isCurrent = sc_DoubleSpans_Mode == "Current"
	local isCurrentNormal = sc_DoubleSpans_Mode == "Current Normal"
	local isCurrentCrosshand = sc_DoubleSpans_Mode == "Current Crosshand"
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

    if final == 0 then
	    SetScoreboardNote({
			text = sc_DoubleSpans_Mode .. " span: " .. final,
			color = sc_DoubleSpans_Colors[-1]
		})
    else
        local localColor = {}
        if isMaxNormal or isMinNormal or isAvgNormal or isCurrentNormal or (final > 0 and isCurrent) then
            if final < Diff.instance.minDoubleSpan then
                localColor = sc_DoubleSpans_Colors[0]
            elseif final > Diff.instance.maxDoubleSpan then
                localColor = sc_DoubleSpans_Colors[5]
            else
                localColor = sc_DoubleSpans_Colors[math.floor(4*(final - Diff.instance.minDoubleSpan) / (Diff.instance.maxDoubleSpan - Diff.instance.minDoubleSpan))+1]
            end
        elseif isMaxCrosshand or isMinCrosshand or isAvgCrosshand or isCurrentCrosshand or (final < 0 and isCurrent) then
            if final < Diff.instance.minDoubleSpan then
                localColor = sc_DoubleSpans_Colors[0]
            elseif final > Diff.instance.maxCrosshandSpan then
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
			text = sc_DoubleSpans_Mode .. " span: " .. final,
			color = localColor
		})
    end
end

EventHandler.instance:on(Events.INIT, function(ev)
        EventHandler.instance:on(Events.NOTE, function(ev)

                local id = ev.data.id

				if ev.data:hasHands(Note.HandTypes.LEFT + Note.HandTypes.RIGHT) then
                    sc_DoubleSpans_Count = sc_DoubleSpans_Count + 1
                    sc_DoubleSpans_Active[sc_DoubleSpans_Count] = ev.data.span.x
                    sc_DoubleSpans_Overall[sc_DoubleSpans_Count] = ev.data.span.x
                    sc_DoubleSpans_EventIDs[sc_DoubleSpans_Count] = Intervals.instance:addInterval(sc_DoubleSpans_Timer, true, sc_DoubleSpans_RemoveNote, {sc_DoubleSpans_Count})
                end
                sc_DoubleSpans_RefreshScore()
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
