require("../../../logger")
require("../../../events")
require("../../../vr/vr_export")
require("../../../diff/diff_export")
require("../helpers/accel_calc_v1")

sc_Accels_ColorTypes = {
    [0] = {
        0, 255, 0
    },
    [1] = {
        128, 255, 0
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

sc_Accels_PrevMax = 0
sc_Accels_PrevTime = -5
sc_Accels_Logger = Logger("AccelTracker")
sc_Accels_TotalFailed = 0

EventHandler.instance:on(Events.INIT, function(ev)
        EventHandler.instance:on(Events.NOTE, function(ev)
                if not ev.data:hasHands(Note.HandTypes.LEFT) then
                    return false
                end

                local id = ev.data.id
                local prevNote = NoteContainer.instance:getPrev(id, NoteContainer.FilterFlags.ASSIGNED + NoteContainer.FilterFlags.FILTER_HANDS + NoteContainer.FilterFlags.HAS_LEFT + NoteContainer.FilterFlags.ENABLED_ONLY)

                if prevNote ~= true then
                    local prevAccel = GetAccelValue(prevNote.endPos.x - prevNote.endSpan.x/2, ev.data.pos.x - ev.data.span.x/2, prevNote.endTime - ev.data.startTime)
                    local colorID = math.floor(5 * prevAccel / Diff.instance.maxAccelLeft)
                    if prevAccel > sc_Accels_PrevMax or ev.data.startTime > sc_Accels_PrevTime + 1 then
                        sc_Accels_PrevMax = prevAccel
                        sc_Accels_PrevTime = ev.data.startTime
                        SetScoreboardNote({
                                text = "Left Acceleration: " .. prevAccel,
                                color = sc_Accels_ColorTypes[colorID]
                            })
                    end
                    if prevAccel > Diff.instance.maxAccelLeft then
                        sc_Accels_TotalFailed = sc_Accels_TotalFailed + 1
                        sc_Accels_Logger:err("Very high acceleration: " .. prevAccel .. "!")
                        sc_Accels_Logger:debug("Previous note: " .. dump(prevNote))
                        sc_Accels_Logger:debug("Current note: " .. dump(ev.data))
                    end
                else
                    SetScoreboardNote({
                            text = "Left Acceleration: 0",
                            color = {0, 128, 255}
                        })
                end

                return false
            end
        )
        EventHandler.instance:on(Events.SCORE, function(ev)
            if sc_Accels_TotalFailed > 0 then
                sc_Accels_Logger:error("Total failed notes: " .. sc_Accels_TotalFailed)
            end
        end)
    end
)
