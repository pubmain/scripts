-- js console for lua
local console = {}

local dump
if getgenv then
	getgenv().console = console
	dump =
		loadstring(game:HttpGet("https://raw.githubusercontent.com/pubmain/printdump/refs/heads/main/dump.lua"))().dump
else
	dump = tostring
end

-- todo: loadstring dump lib
local function GetText(...)
	local Text = ""
	for _, v in { ... } do
		Text = Text .. dump(v) .. " "
	end
	return Text
end

local function FormatMilis(num)
	if num < 1 then
		return tostring(num) .. "ms"
	end
	-- less than minute
	if num < 60 then
		return tostring(num) .. "s"
	end
	-- less than hour
	if num < 60 * 60 then
		if num > 60 * 60 * 2 then
			return tostring(num) .. " mins"
		end
		return tostring(num) .. "min"
	end
	-- less than day
	if num < 60 * 60 * 24 then
		if num > 60 * 60 * 24 * 2 then
			return tostring(num) .. " days"
		end
		return tostring(num) .. " day"
	end
	return tostring(num) .. " week"
end

function console.log(...)
	print(GetText(...))
end

function console.warn(...)
	warn(GetText(...))
end

function console.error(...)
	task.spawn(function(...)
		error(GetText(...))
	end, ...)
end

local TimeLabels = {}
function console.time(label)
	TimeLabels[label] = tick()
end

function console.timeEnd(label)
	if not TimeLabels[label] then
		return console.error(string.format('Label "%s" does not exist!', label))
	end
	console.log(string.format('Label "%s" took %s', label, FormatMilis(tick() - TimeLabels[label])))
	TimeLabels[label] = nil
end

-- note: i cant support console.table 😭
function console.table(obj)
	console.log(obj)
end

return console
