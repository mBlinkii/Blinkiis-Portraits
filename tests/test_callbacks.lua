local BP = newBP({ "api.lua" })
local got = {}

BP:Fire("PortraitSetup", "nobody listens")
truthy(true, "firing without subscribers is safe")

BP.API.RegisterCallback(got, "PortraitSetup", function(_, portrait)
	got.setup = portrait
end)
BP:Fire("PortraitSetup", "P")
eq(got.setup, "P", "callback receives portrait")

BP.API.UnregisterCallback(got, "PortraitSetup")
BP:Fire("PortraitSetup", "Q")
eq(got.setup, "P", "unregistered callback silent")

local other = {}
BP.API.RegisterCallback(got, "PortraitsLoaded", function()
	error("boom")
end)
BP.API.RegisterCallback(other, "PortraitsLoaded", function()
	other.after = true
end)
BP:Fire("PortraitsLoaded")
truthy(other.after, "error in one handler does not stop others")

BP.Portraits = { player = {}, target = {} }
local n = 0
for key, portrait in BP.API:GetPortraits() do
	if BP.Portraits[key] == portrait then n = n + 1 end
end
eq(n, 2, "GetPortraits iterates key and portrait")

function BP:IsSecretValue(v)
	return v == "secret"
end
function BP:SafeValue(v)
	if v ~= "secret" then return v end
end
eq(BP.API:IsSecretValue("secret"), true, "IsSecretValue forwards")
eq(BP.API:SafeValue(5), 5, "SafeValue forwards plain values")
eq(BP.API:SafeValue("secret"), nil, "SafeValue forwards secret handling")

BP.GetUnitColor = function(_, unit)
	return { unit = unit }
end
eq(BP.API:GetUnitColor("target").unit, "target", "GetUnitColor forwards")
