local ServerScriptService = game:GetService("ServerScriptService")
local PipeDebugState = require(ServerScriptService.Server.Pipe.PipeDebugState)

return function()
	PipeDebugState:SetPaused(true)
	return "Pipe generation paused."
end