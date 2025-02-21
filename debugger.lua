-- note: this isnt finished yet
--loadstring(game:HttpGet("https://raw.githubusercontent.com/pubmain/scripts/main/dump.lua"))()
local module = {
    enviroment = {},
    origNamecall = nil,
    namecallListeners = {},
    functionHooks = {}
}
module.__index = module
getfenv().debugger = module

function module.new(env, print_info)
    print("debugger.lua: created new debugger instance")
    local self = setmetatable({
        enviroment = env,
        origNamecall = nil,
        namecallListeners = {}
    }, module)

    self.origNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
        local method = getnamecallmethod()
        for name, callback in self.namecallListeners do
            local retsignal, out = callback(method, ...)
            if retsignal then
                if print_info then
                    print("debugger.lua: " .. name .. " hooked " .. method)
                    print("debugger.lua: " .. name .. " argc " .. #out)
                end
                return table.unpack(out)
            end
        end
        return self.origNamecall(...)
    end))

    return self
end

function module:blockGetRequest(search, dontFix)
    if search then
        if not dontFix then
            search = search:gsub("%.", "%%.")
        end
        self.namecallListeners["blockGetRequest:" .. search] = function(method, _, url)
            if method == "HttpGet" then
                if url:find(search) ~= nil then
                    print("debugger.lua: blocked", url)
                    return true, {}
                end
            end
            return false
        end
    else
        self.namecallListeners["blockGetRequest"] = function(method, _, url)
            if method == "HttpGet" then
                print("debugger.lua: blocked", url)
                return true, {}
            end
            return false
        end
    end
end

function module:hookGetRequest(callback, search, dontFix)
    if not dontFix and search then
        search = search:gsub("%.", "%%.")
    end
    if search then
        self.namecallListeners["hookGetRequest:" .. search] = function(method, _, url)
            if method == "HttpGet" then
                if url:find(search) ~= nil then
                    local out = { pcall(callback, self.origNamecall, url) }
                    local success, out = out[1], { table.unpack(out, 2) }
                    if success then
                        return true, { table.unpack(out) }
                    end
                    local reason = out[2]
                    print("debugger:hookGetRequest:" .. search .. " failed", reason)
                end
            end
            return false
        end
    else
        self.namecallListeners["hookGetRequest"] = function(method, _, url)
            if method == "HttpGet" then
                local out = { pcall(callback, self.origNamecall, url) }
                local success, out = out[1], { table.unpack(out, 2) }
                if success then
                    return true, { table.unpack(out) }
                end
                local reason = out[2]
                print("debugger:hookGetRequest failed", reason)
            end
            return false
        end
    end
end

function module:hookFunction(func, hook, id)
    if not id then
        id = crypt.hash(crypt.generatebytes(8), "sha1")
    end
    local old
    old = hookfunction(func, function(...)
        local out = { pcall(hook, old, ...) }
        local success, out = out[1], { table.unpack(out, 2) }
        if not success then
            local reason = out[1]
            error("debugger.lua:hookFunction " .. id .. " failed: " .. reason)
        end
