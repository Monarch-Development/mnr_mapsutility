lib.callback.register("mnr_mapsutility:server:HasAccess", function(source, floor)
    local hasItem, hasJob = true, true

    if floor.item ~= false then
        hasItem = inventory.GetItemCount(source, floor.item) < 1
    end

    if floor.jobs ~= false then
        hasJob = server.HasGroups(source, floor.jobs)
    end

    return hasItem and hasJob
end)