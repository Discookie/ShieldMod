require("../../diff/diff_export")
require("../../track/track_export")
require("../../vr/vr_export")

function AutoGenY(note)
    local maxLocalTilt = 0
    for i=note.startNode,note.endNode do
        maxLocalTilt = max(maxLocalTilt, Track.instance:getNode(i).rot.y)
    end
    note.pos.y = math.pow((maxLocalTilt - Track.instance.minTilt) / (Track.instance.maxTilt - Track.instance.minTilt), 2) * Diff.instance.spanY + rand() * Diff.instance.spanY_random

    note.span.y = 0
end
