---@diagnostic disable: duplicate-set-field, lowercase-global

if GetResourceState("ox_core") ~= "started" then return end

local Ox = require "@ox_core/lib/init"

server = {}

function server.HasGroups(source, groups)
    local player = Ox.GetPlayer(source)
    if player.getGroup(groups) then
        return true
    end
end