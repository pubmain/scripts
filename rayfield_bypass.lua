function shallow_copy(t)
    local t2 = {}
    for k, v in pairs(t) do
        t2[k] = v
    end
    return t2
end
local old = loadstring
loadstring = function(code)
    local search = "function RayfieldLibrary%:CreateWindow%(Settings%)"
    local func = old(code)
    if not func then
        return warn("loadstring failed to parse lua code")
    end

    return function(...)
        local module = func(...)
        if type(module) ~= "table" then
            return module
        end
        if not string.find(code, search) then
            return module
        end
        if not module.CreateWindow then
            return module
        end
        local old = module.CreateWindow
        module.CreateWindow = function(self, settings)
            -- copy the array to prevent detection
            local settings = shallow_copy(settings)
            settings.KeySystem = nil
            game.StarterGui:SetCore(
                "SendNotification",
                {
                    Title = "pubmain/rayfield_bypass.lua",
                    Text = "Succesfully bypassed: " .. settings.Name,
                    Duration = 5
                }
            )
            return old(self, settings)
        end

        game.StarterGui:SetCore(
            "SendNotification",
            {
                Title = "pubmain/rayfield_bypass.lua",
                Text = "Succesfully hooked rayfield lib",
                Duration = 5
            }
        )
        return module
    end
end
game.StarterGui:SetCore(
    "SendNotification",
    {
        Title = "pubmain/rayfield_bypass.lua",
        Text = "pubmain rayfield bypasser has been activated",
        Duration = 5
    }
)
