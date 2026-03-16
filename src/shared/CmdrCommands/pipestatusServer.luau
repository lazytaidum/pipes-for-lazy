local ServerScriptService = game:GetService("ServerScriptService")
local PipeDebugState = require(ServerScriptService.Server.Pipe.PipeDebugState)

return function()
	local weights = PipeDebugState.ArchetypeWeights

	return table.concat({
		("Paused: %s"):format(tostring(PipeDebugState.IsPaused)),
		("GrowthDelay: %.3f"):format(PipeDebugState.GrowthDelay),
		("LongRunner: %.2f"):format(weights.LongRunner),
		("WallHugger: %.2f"):format(weights.WallHugger),
		("Squirmy: %.2f"):format(weights.Squirmy),
	}, "\n")
end