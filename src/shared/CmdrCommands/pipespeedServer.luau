local ServerScriptService = game:GetService("ServerScriptService")
local PipeDebugState = require(ServerScriptService.Server.Pipe.PipeDebugState)

return function(_, delayValue: number)
	PipeDebugState:SetGrowthDelay(delayValue)
	return ("Pipe growth delay set to %.3f"):format(PipeDebugState.GrowthDelay)
end