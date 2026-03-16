local PipeDebugState = {}

PipeDebugState.IsPaused = false
PipeDebugState.GrowthDelay = 0.12
PipeDebugState.PendingSteps = 0

PipeDebugState.ArchetypeWeights = {
	LongRunner = 1,
	WallHugger = 1,
	Squirmy = 1,
}

function PipeDebugState:SetPaused(isPaused: boolean)
	self.IsPaused = isPaused
end

function PipeDebugState:SetGrowthDelay(delayValue: number)
	self.GrowthDelay = math.max(0, delayValue)
end

function PipeDebugState:SetArchetypeWeight(name: string, weight: number)
	if self.ArchetypeWeights[name] == nil then
		error(("Unknown archetype '%s'"):format(name))
	end

	self.ArchetypeWeights[name] = math.max(0, weight)
end

function PipeDebugState:GetArchetypeWeight(name: string): number
	return self.ArchetypeWeights[name] or 0
end

function PipeDebugState:AddSteps(amount: number)
	self.PendingSteps += math.max(0, amount)
end

function PipeDebugState:ConsumeStep(): boolean
	if self.PendingSteps > 0 then
		self.PendingSteps -= 1
		return true
	end

	return false
end

return PipeDebugState