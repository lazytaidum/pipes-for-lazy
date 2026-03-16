local ServerScriptService = game:GetService("ServerScriptService")
local PipeDebugState = require(ServerScriptService.Server.Pipe.PipeDebugState)

return function(_, amount: number?)
	local stepAmount = amount or 1
	stepAmount = math.max(1, math.floor(stepAmount))

	PipeDebugState:AddSteps(stepAmount)

	return ("Queued %d pipe step(s). Pending now: %d"):format(
		stepAmount,
		PipeDebugState.PendingSteps
	)
end