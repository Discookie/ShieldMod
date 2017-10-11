require("vr_note_container")
require("../utils/bind")
require("../utils/deepcopy")
require("../utils/dump")

NoteAssigner = {}
NoteAssigner.__index = NoteAssigner
setmetatable(NoteAssigner, {
        __call = function(cls, ...)
            return cls.init(...)
        end,
})

NoteAssigner.ApplicableTypes = {
    DEFAULT = 0,
    WEIGHT = 0,
    FORCE = 1,
    DISABLE = 2
}

function NoteAssigner.init(container)
    local self = setmetatable({}, NoteAssigner)
    self.type = "NoteAssigner"
    self.logger = Logger(self.type)
    self.logger:log("Init")

    self:reset()

    if container ~= nil then
        self:link(container)
    end

    return self
end

function NoteAssigner:reset()
    self._bound = false
    self._container = nil

    self._size = 0
    self._assigners = {}
    self._assignerOrder = {}
    self.logger:log("Reset")
end

function NoteAssigner:bind(container)
    return self:link(container)
end
function NoteAssigner:link(container)
    if type(container) ~= "table" or container.type ~= "NoteContainer" then
        return true
    end

    self._container = container
    self._container._oldAssign = self._container.assignPos
    self._container.assignPos = bindFunc(NoteAssigner.assignPos, self)
    self._bound = true

    return false
end

function NoteContainer:unlink()
    self._container.assignPos = self._container._oldAssign
    self._container = nil
    self._bound = false

    return false
end

-- Generator and applicable functions both take (noteID, assigner, container) as arguments
-- You can bind functions to a class with `bindFunc(Class.func, myClass)`
function NoteAssigner:add(name, generatorFunc, applicableFunc, weight, priority, forceReplace)
    if type(name) ~= "string" or type(generatorFunc) ~= "function" then
        self.logger:warn("add: Invalid assignment")
        return true
    end
    if self._assigners[name] then
        if not forceReplace then
            self.logger:warn("add: Assigner already exists")
            return true
        else
            self:remove(name)
        end
    end

    if type(applicableFunc) ~= "function" then
        applicableFunc = function(assigner, id) return NoteAssigner.ApplicableTypes.DEFAULT end
    end
    if type(weight) ~= "number" then
        weight = 1
    end
    weight = math.max(weight, 1)
    if type(priority) ~= "number" then
        priority = 15
    end
    priority = math.max(priority, 1)

    self._size = self._size + 1
    self._assigners[name] = {
        active = true,
        generatorFunc = generatorFunc,
        applicableFunc = applicableFunc,
        weight = weight,
        priority = priority,
        order = self._size
    }
    self._assignerOrder[self._size] = {
        deleted = false,
        active = true,
        weight = weight,
        priority = priority,
        name = name
    }
    self.logger:log("Loaded generator " .. name .. " successfully")
    return false
end

function NoteAssigner:modify(name, what)
    if type(what) ~= "table" or type(name) ~= "string" or not self._assigners[name] then
        self.logger:warn("modify: Does not exist!")
        return true
    end
    if what.weight then
        self._assigners[name].weight = math.max(1, what.weight)
        self._assignerOrder[self._assigners[name].order].weight = math.max(1, what.weight)
    end
    if what.priority or what.prio then
        self._assigners[name].priority = math.max(1, what.what.priority or what.prio)
        self._assignerOrder[self._assigners[name].order].priority = math.max(1, what.what.priority or what.prio)
    end
    if what.generatorFunc or what.generator then
        self._assigners[name].generatorFunc = what.generatorFunc or what.generator
    end
    if what.applicableFunc or what.applicable or what.applicability then
        self._assigners[name].applicableFunc = what.applicableFunc or what.applicable or what.applicability
    end
end

function NoteAssigner:delete(name)
    return NoteAssigner:remove(name)
end
function NoteAssigner:remove(name)
    if type(name) ~= "string" or not self._assigners[name] then
        self.logger:warn("remove: Does not exist!")
        return true
    else
        self._assignerOrder[self._assigners[name].order] = {deleted = true}
        self._assigners[name] = nil
        self.logger:log("Removed " .. name)
    end
end

function NoteAssigner:get(name)
    if name == nil then
        return deepcopy(self._assigners)
    elseif type(name) == "string" and self._assigners[name] then
        return deepcopy(self._assigners[name])
    else
        return true
    end
end

function NoteAssigner:enable(name)
    if type(name) ~= "string" or not self._assigners[name] then
        return true
    else
        self._assigners[name].active = true
        self._assignerOrder[self._assigners[name].order].active = true
    end
end

function NoteAssigner:disable(name)
    if type(name) ~= "string" or not self._assigners[name] then
        return true
    else
        self._assigners[name].active = false
        self._assignerOrder[self._assigners[name].order].active = false
    end
end

-- change this for custom assigning orders
function NoteAssigner.defaultNoteOrder(self, container)
    local ret = {}

    for k=1,container.size do
        ret[#ret+1]=k
    end

    return ret
end

function NoteAssigner:assignPos()
    if not self._bound or self._container._size == 0 then
        return true
    end

    local doIt = false
    for k,v in ipairs(self._assignerOrder) do
        if not v.deleted and v.active then
            doIt = true
            break
        end
    end

    if not doIt then
        return self._container:_oldAssign()
    end

    local order = self:defaultNoteOrder(self._container)
    local rand = math.random
    local successNotes = 0
    local failedNotes = 0
    local usedGenerators = {}
    for k,v in ipairs(order) do
        if self._container._notes[v].enabled then
            local priority = -1
            local contenders = {}
            local totalWeight = 0
            local forced = ""
            for l,u in ipairs(self._assignerOrder) do
                if not u.deleted and u.active and (priority < 1 or priority >= self._assigners[u.name].priority) then
                    local appl = self._assigners[u.name].applicableFunc(v, self, self._container)
                    if appl == NoteAssigner.ApplicableTypes.WEIGHT then
                        if priority > u.priority then
                            contenders = {}
                            totalWeight = 0
                            priority = u.priority
                            forced = ""
                        end

                        contenders[#contenders + 1] = u
                        totalWeight = totalWeight + self._assigners[u.name].weight
                    elseif appl == NoteAssigner.ApplicableTypes.FORCE then
                        if priority > u.priority then
                            contenders = {}
                            totalWeight = 0
                            priority = u.priority
                            forced = ""
                        end

                        if forced == "" then
                            forced = u
                        end
                    elseif appl == NoteAssigner.ApplicableTypes.DISABLE then

                    end
                end
            end
            if forced ~= "" then
                self._container._notes[v].generator = forced.name
                usedGenerators[forced.name] = usedGenerators[forced.name] and (usedGenerators[forced.name] + 1) or 1
                local status, err = pcall(self._assigners[forced.name].generatorFunc, v, self, self._container)

                if not status then
                    self.logger:err("Assigner " .. forced.name .. " LUA error: " .. dump(err))
                    failedNotes = failedNotes + 1
                elseif err then
                    self.logger:warn("Assigner " .. forced.name .. " failed to execute")
                    failedNotes = failedNotes + 1
                else
                    successNotes = successNotes + 1
                end
            elseif #contenders ~= 0 then
                local randomWeight = rand()*totalWeight
                local current = 1
                local cumulativeWeight = contenders[current].weight

                while cumulativeWeight < randomWeight do
                    current = current + 1
                    cumulativeWeight = cumulativeWeight + contenders[current].weight
                end

                self._container._notes[v].generator = contenders[current].name
                usedGenerators[contenders[current].name] = usedGenerators[contenders[current].name] and (usedGenerators[contenders[current].name] + 1) or 1
                local status, err = pcall(self._assigners[contenders[current].name].generatorFunc, v, self, self._container)

                if not status then
                    self.logger:err("Assigner " .. contenders[current].name .. " LUA error: " .. dump(err))
                    failedNotes = failedNotes + 1
                elseif err then
                    self.logger:warn("Assigner " .. contenders[current].name .. " failed to execute")
                    failedNotes = failedNotes + 1
                else
                    successNotes = successNotes + 1
                end
            else
                successNotes = successNotes + 1
                self._container._notes[v]:disable()
            end
        end
    end

    self.logger:log("Assigned " .. successNotes .. "/" .. (successNotes+failedNotes) .. " notes")

    self.logger:debug("Used generators: " .. dump(usedGenerators))
    return false
end
