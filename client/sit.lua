local ConfigSit = lib.load("config.sit")
local IsSitting = false
local ClonedEntity = false
local OldEntity = 0

local function RotateOffset(offset, heading)
    local rad = math.rad(heading)
    local cosH = math.cos(rad)
    local sinH = math.sin(rad)

    local newX = offset.x * cosH - offset.y * sinH
    local newY = offset.x * sinH + offset.y * cosH

    return vec3(newX, newY, offset.z)
end

local function IsSeatOccupied(entity)
    local model = GetEntityModel(entity)
    local configModel = ConfigSit.Models[model]
    if not configModel then return end

    local entityNetID = NetworkGetNetworkIdFromEntity(entity)
    local verifySeats = lib.callback.await("mnr_mapsutility:server:GetModelSeats", 200, entityNetID)

    if verifySeats == 0 then
        return false, 1
    end

    if verifySeats == configModel.maxseats then
        return true, false
    else
        return false, verifySeats + 1
    end
end

local function CloneAndNetworkEntity(entity)
    if not DoesEntityExist(entity) then
        return nil, nil
    end

    local model = GetEntityModel(entity)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end

    local entityCoords = GetEntityCoords(entity)
    local entityHeading = GetEntityHeading(entity)
    local clonedEntity = CreateObject(model, entityCoords.x, entityCoords.y, entityCoords.z, true, true, false)
    if not DoesEntityExist(clonedEntity) then
        return nil, nil
    end

    SetEntityHeading(clonedEntity, entityHeading)
    FreezeEntityPosition(clonedEntity, true)

    NetworkRegisterEntityAsNetworked(clonedEntity)

    SetEntityVisible(entity, false, false)
    OldEntity = entity

    ClonedEntity = true
    return clonedEntity
end

local function NetworkChair(entity, action)
    if action == "register" then
        if not entity then return false, nil end

        local isLocal = NetworkGetEntityIsLocal(entity)
        if isLocal then
            NetworkRegisterEntityAsNetworked(entity)
        end

        Wait(100)

        local isNetworked = NetworkGetEntityIsNetworked(entity)
        if isNetworked then
            return true, entity
        else
            local clonedEntity = CloneAndNetworkEntity(entity)
            if clonedEntity then
                return true, clonedEntity
            else
                return false, nil
            end
        end
    end

    if action == "unregister" then
        if ClonedEntity then
            SetEntityAsNoLongerNeeded(entity)
            SetEntityVisible(OldEntity, true, false)
            NetworkUnregisterNetworkedEntity(entity)
            DeleteEntity(entity)
            ClonedEntity = false
        end
    end
end

local function PlaySit(entity, seatID)
    IsSitting = entity
    local entityNetID = NetworkGetNetworkIdFromEntity(entity)
    TriggerServerEvent("mnr_mapsutility:server:ModelRegistration", entityNetID, seatID)

    local playerPed = cache.ped or PlayerPedId()
    local model = GetEntityModel(entity)
    local configModel = ConfigSit.Models[model]

    local entityCoords = GetEntityCoords(entity)
    local entityHeading = GetEntityHeading(entity)
    local seatOffset = configModel.seats[seatID].offset
    local rotatedOffset = RotateOffset(seatOffset, entityHeading)
    local position = entityCoords + rotatedOffset
    local heading = entityHeading + seatOffset.w
    SetEntityCoords(playerPed, position.x, position.y, position.z, true, false, false, false)

    if configModel.anim.scenario then
        TaskStartScenarioAtPosition(playerPed, configModel.anim.scenario, position.x, position.y, position.z, heading, 0, true, true)
    end

    local getup = lib.addKeybind({
        name = "get-up",
        description = "Used for get up from a seat",
        defaultKey = "E",
        disabled = true,
        onReleased = function(self)
            lib.hideTextUI()
            ClearPedTasks(playerPed)
            seatID -= 1
            TriggerServerEvent("mnr_mapsutility:server:ModelRegistration", entityNetID, seatID)
            if seatID == 0 then
                NetworkChair(entity, "unregister")
            end
            self:disable(true)
            IsSitting = false
        end
    })

    lib.showTextUI(locale("textui.sit"))
    getup:disable(false)
end

RegisterNetEvent("mnr_mapsutility:client:Sit", function(data)
    if not data.entity then return end
    if IsSitting and IsSitting == data.entity then return end

    local model = GetEntityModel(data.entity)
    local configModel = ConfigSit.Models[model]
    if not configModel then return end

    local networkSuccess, entity = NetworkChair(data.entity, "register")
    if not networkSuccess then return end

    local seatOccupied, seatID = IsSeatOccupied(entity)
    if seatOccupied then
        return client.Notify(locale("notify.seat-occupied"), "error")
    end

    PlaySit(entity, seatID)
end)


local models = {}

for model in pairs(ConfigSit.Models) do
    models[#models+1] = model
end

target.AddModels(models)