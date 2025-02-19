--[[
util functions to filter out game scripts
]]
--[[
    util functions to filter out roblox default scripts
]]
local function isbuiltinscript(script)
    -- note: it works by checking if the script is in the Players 
    --       because all of the builtin scripts are added there
    --       and we check if it exists in any locations in the code
    if script:IsDescendantOf(game:GetService("Players")) then
        local searches = {
            game:GetService("StarterGui"),
            game:GetService("StarterPlayer"),
            game:GetService("Backpack")
        }
        for _, location in searches do
            if location:FindFirstChild(script.Name, true) == nil then
                return true
            end
        end
    end
    return false
end

local function getgamescripts()
    local out = getrunningscripts()
    for i, script in out do
        if isbuiltinscript(script) then
            table.remove(out, i)
        end
    end
    return out
end

local function getgamemodules()
    local out = getloadedmodules()
    for i, script in out do
        if isbuiltinscript(script) then
            table.remove(out, i)
        end
    end
    return out
end

local function getremotes()
    local out = {}
    function handler(values)
        for _, remote in values do
            if remote:IsA("RemoteFunction") or remote:IsA("RemoteEvent") then
                table.insert(out, remote)
            end
        end
    end
    handler(getnilinstances())
    handler(workspace:GetDescendants())
    handler(game:GetService("ReplicatedStorage"):GetDescendants())
    handler(game:GetService("Players").LocalPlayer:GetDescendants())
    return out    
end

getgenv().getgamescripts = getgamescripts
getgenv().getgamemodules = getgamemodules
getgenv().isbuiltinscript = isbuiltinscript
getgenv().isdefaultrobloxscript = isbuiltinscript
getgenv().getremotes = getremotes
