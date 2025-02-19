-- im gonna update it more
loadstring(game:HttpGet("https://raw.githubusercontent.com/pubmain/scripts/refs/heads/main/dump.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/pubmain/scripts/refs/heads/main/debugutils.lua"))()

print("starting listening to remotes")
local values = getremotes()
local blacklist = {}
for i, v in values do
    if table.find(blacklist, v.Name) then continue end
    print("Listening to", v:GetFullName())
    if v.ClassName == "RemoteFunction" then
        local callback = getcallbackvalue(v, "OnClientInvoke")
        if not callback then continue end
        local old 
        old = hookfunction(callback, function(...)
            printdump("OnInvoke", v, ...)
            return old(...)
        end)
    else
        v.OnClientEvent:Connect(function(...)
            printdump("OnEvent", v, ...)
        end)
    end
end
