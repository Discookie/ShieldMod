require("events")

function SetCam()
    local logger = Logger("Camera")
    HideBuiltinPlayerObjects()
    SetCamera({
		pos = {0,2,-1.5},
		rot = {-10,0,0},
		railoffset = "detached"
	})
    logger:log("Camera and object override from mod")
end

EventHandler.instance:on(Events.POST_SKIN, SetCam)
