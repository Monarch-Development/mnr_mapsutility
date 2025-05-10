AddEventHandler("onClientResourceStart", function(resourceName)
    local scriptName = cache.resource or GetCurrentResourceName()
    if resourceName ~= scriptName then return end
    SetupBlips()
    SetupElevators()
    SetupSeats()
    SetupIPL()
end)