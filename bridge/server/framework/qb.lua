---@diagnostic disable: duplicate-set-field, lowercase-global

if GetResourceState("qb-core") ~= "started" then return end

local QBCore = exports["qb-core"]:GetCoreObject()

server = {}

function server.HasGroups(source, groups)
    local Player = QBCore.Functions.GetPlayer(source)
    if type(groups) == "table" then
        for _, group in pairs(groups) do
            if Player.PlayerData.job.name == group then
                return true
            end
        end
    elseif type(groups) == "string" then
        if Player.PlayerData.job.name == groups then
            return true
        end
    end
    return false
end