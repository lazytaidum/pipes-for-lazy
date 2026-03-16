local ServerScriptService = game:GetService("ServerScriptService")
local PipeDebugState = require(ServerScriptService.Server.Pipe.PipeDebugState)

return function(_, archetypeName: string, weight: number)
	PipeDebugState:SetArchetypeWeight(archetypeName, weight)

	return ("%s weight set to %.2f"):format(
		archetypeName,
		PipeDebugState:GetArchetypeWeight(archetypeName)
	)
end