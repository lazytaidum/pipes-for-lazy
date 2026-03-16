local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Cmdr = require(Packages:WaitForChild("Cmdr") :: ModuleScript)

Cmdr:RegisterDefaultCommands()

local cmdFolder = Shared:WaitForChild("CmdrCommands")

for _, child in ipairs(cmdFolder:GetChildren()) do
	if child:IsA("ModuleScript") then
		local ok, result = pcall(require, child)

		if ok then
			print(("REQUIRE OK | %s | typeof=%s"):format(child.Name, typeof(result)))
		else
			warn(("REQUIRE FAIL | %s | %s"):format(child.Name, tostring(result)))
		end
	end
end

Cmdr:RegisterCommandsIn(Shared:WaitForChild("CmdrCommands"))

--// Server started cleanup!

local SERVER_REMOVE = CollectionService:GetTagged("OnServerStart_Remove")

for _, tagged in pairs(SERVER_REMOVE) do
	tagged:Destroy()
end