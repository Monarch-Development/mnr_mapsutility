local Elevators = lib.load("config.elevators")

local function ShowMenu(floors, label, index)
    local menu = {}
    for i = 1, #floors do
        local floorOption = {
            title = floors[i].title,
            description = floors[i].description,
            icon = floors[i].locked and "fas fa-lock" or "fas fa-lock-open",
            iconColor = floors[i].locked and "#FF0000" or "#008000",
            onSelect = function()
                local hasAccess = lib.callback.await("mnr_mapsutility:server:HasAccess", false, floors[i])
                if floors[i].locked and not hasAccess then
                    return client.Notify(locale("notify.access-denied"), "error")
                end

                DoScreenFadeOut(1000)
                Wait(2000)

                local playerPed = cache.ped or PlayerPedId()
                local targetZone = floors[i].zones[index]
                if not targetZone or not targetZone.coords then
                    targetZone = floors[i].zones[1]
                end
                SetEntityCoords(playerPed, targetZone.coords.x, targetZone.coords.y, targetZone.coords.z, false, false, false, false)
                SetEntityHeading(playerPed, targetZone.coords.w)

                Wait(2000)
                DoScreenFadeIn(1000)

                client.Notify(locale("notify.reached-floor"), "success")
            end,
            metadata = {
                {
                    label = locale("menu.access"),
                    value = (floors[i].locked and locale("menu.locked") or locale("menu.unlocked"))
                }
            },
        }
        menu[#menu + 1] = floorOption
    end

    local menuId = "elevator_menu"
    lib.registerContext({
        id = menuId,
        title = label,
        options = menu,
        onExit = function()
        end
    })

    lib.showContext(menuId)
end

local function CreateElevator(name, data)
    for _, floorData in pairs(data.floors) do
        for index, zoneData in pairs(floorData.zones) do
            lib.zones.box({
                coords = vec3(zoneData.coords.x, zoneData.coords.y, zoneData.coords.z),
                size = zoneData.size,
                rotation = zoneData.coords.w,
                onEnter = function()
                    lib.showTextUI(locale("textui.elevator"), {
                        position = "left-center",
                        icon = "fa-solid fa-building",
                    })
                end,
                onExit = function()
                    lib.hideTextUI()
                end,
                inside = function()
                    if IsControlJustReleased(0, 38) then
                        ShowMenu(data.floors, data.label, index)
                    end
                end,
                debug = Elevators[name].debug,
            })
        end
    end
end

local function CreateElevators()
    for name, data in pairs(Elevators) do
        CreateElevator(name, data)
    end
end

function SetupElevators()
    CreateElevators()
end