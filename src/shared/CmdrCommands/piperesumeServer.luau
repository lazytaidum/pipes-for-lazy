local ServerScriptService = game:GetService("ServerScriptService")
local PipeDebugState = require(ServerScriptService.Server.Pipe.PipeDebugState)

return function()
	PipeDebugState:SetPaused(false)
	return "Pipe generation resumed."
end