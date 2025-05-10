---@diagnostic disable: duplicate-set-field, lowercase-global

if GetResourceState("ps-inventory") ~= "started" then return end

local ps_inventory = exports["ps-inventory"]

inventory = {}

function inventory.GetItemCount(source, items)
    local count = ps_inventory:GetItemCount(source, items)

    return count
end