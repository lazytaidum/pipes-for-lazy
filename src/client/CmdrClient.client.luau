local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("Cmdr client bootstrap running")

local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient") :: ModuleScript)
Cmdr:SetActivationKeys({ Enum.KeyCode.F2 })