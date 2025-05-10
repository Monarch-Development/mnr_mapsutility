---@diagnostic disable: duplicate-set-field, lowercase-global

if GetResourceState("qbx_core") ~= "started" then return end

local QBX = exports.qbx_core

server = {}

function server.HasGroups(source, groups)
    return QBX:HasGroup(source, groups)
end