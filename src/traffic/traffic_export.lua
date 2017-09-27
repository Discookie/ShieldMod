require("freq")

EventHandler.instance:on(Events.INIT, function(ev)
        FreqTraffic.instance = FreqTraffic()
    end)

require("traffic")


EventHandler.instance:on(Events.INIT, function(ev)
        Traffic.instance = Traffic()
        TrafficEvents.instance = TrafficEvents(Traffic.instance)
    end)
