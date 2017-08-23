require("events")

function SetCam()
    local logger = Logger("Camera")
    SetCamera({
		pos = {0,2,-1.5},
		rot = {-10,0,0},
		railoffset = "detached"
	})
    logger:log("Camera override from mod")
end

EventHandler.instance:on(Events.POST_SKIN, SetCam)
