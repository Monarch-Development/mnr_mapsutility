---@diagnostic disable: duplicate-set-field, lowercase-global

if GetResourceState("ox_core") ~= "started" then return end

local Ox = require "@ox_core/lib/init"

client = {}

function client.Notify(msg, type)
    lib.notify({
        description = msg,
        position = "top",
        type = type or "inform",
    })
end