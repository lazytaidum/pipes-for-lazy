local ServerScriptService = game:GetService("ServerScriptService")
local PipeDebugState = require(ServerScriptService.Server.Pipe.PipeDebugState)

local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

--// CONFIG
local PIPE_SIZE = Vector3.new(1, 1, 1)
local CHECK_SIZE = Vector3.new(0.8, 0.8, 0.8)
local STEP = 1

local MAX_SEGMENTS_PER_PIPE = 150

local PIPE_MATERIAL = Enum.Material.SmoothPlastic

local MIN_BRIGHTNESS = 0.55
local MAX_BRIGHTNESS = 1
local BRIGHTNESS_STEP = 0.015

local PIPE_ARCHETYPES = {
	{
		name = "LongRunner",
		forward = 5,
		side = 1,
		wall = 4,
		crowdPenalty = 3,
		baseColor = Color3.fromRGB(255, 80, 80),
	},
	{
		name = "WallHugger",
		forward = 3,
		side = 1,
		wall = 7,
		crowdPenalty = 2,
		baseColor = Color3.fromRGB(80, 255, 120),
	},
	{
		name = "Squirmy",
		forward = 2,
		side = 2,
		wall = 6,
		crowdPenalty = 1,
		baseColor = Color3.fromRGB(90, 140, 255),
	},
}

local PIPE_ATTRACTION_BOX_SIZE = Vector3.new(5, 1, 5)

-- How far the pipe "sniffs" for nearby walls
local ATTRACTION_BOX_SIZE = Vector3.new(3, 1, 3)

--// HELPERS

local function getTaggedContainers(tagName)
	local tagged = CollectionService:GetTagged(tagName)
	local containers = {}

	for _, instance in ipairs(tagged) do
		if instance:IsA("Folder") or instance:IsA("Model") then
			table.insert(containers, instance)
		end
	end

	return containers
end

local function getFirstTaggedContainer(tagName)
	local containers = getTaggedContainers(tagName)
	return containers[1]
end

local function applyBrightness(color, brightness)
	local r = math.clamp(color.R * brightness, 0, 1)
	local g = math.clamp(color.G * brightness, 0, 1)
	local b = math.clamp(color.B * brightness, 0, 1)
	return Color3.new(r, g, b)
end

local function makeIncludeParams(tagName)
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = getTaggedContainers(tagName)
	return params
end

local function makeCombinedBlockParams()
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include

	local filterInstances = {}

	for _, container in ipairs(getTaggedContainers("NoPipe")) do
		table.insert(filterInstances, container)
	end

	for _, container in ipairs(getTaggedContainers("Pipe")) do
		table.insert(filterInstances, container)
	end

	params.FilterDescendantsInstances = filterInstances
	return params
end

local function isBlocked(position, overlapParams, ignorePart)
	local overlapping = Workspace:GetPartBoundsInBox(CFrame.new(position), CHECK_SIZE, overlapParams)

	for _, part in ipairs(overlapping) do
		if part:IsA("BasePart") and part ~= ignorePart then
			return true, part
		end
	end

	return false, nil
end

local function waitForPermissionToGrow()
	while true do
		if not PipeDebugState.IsPaused then
			return
		end

		if PipeDebugState:ConsumeStep() then
			return
		end

		task.wait(0.05)
	end
end

local function countNearbyPipes(position, pipeParams, ignorePart)
	local nearby = workspace:GetPartBoundsInBox(CFrame.new(position), PIPE_ATTRACTION_BOX_SIZE, pipeParams)

	local count = 0
	for _, part in ipairs(nearby) do
		if part:IsA("BasePart") and part ~= ignorePart then
			count += 1
		end
	end

	return count
end

local function countNearbyWalls(position, noPipeParams)
	local nearby = Workspace:GetPartBoundsInBox(CFrame.new(position), ATTRACTION_BOX_SIZE, noPipeParams)

	local count = 0
	for _, part in ipairs(nearby) do
		if part:IsA("BasePart") then
			count += 1
		end
	end

	return count
end

local function createPipeSegment(pipeFolder, position, direction, color)
	local part = Instance.new("Part")
	part.Name = "PipeSegment"
	part.Size = PIPE_SIZE
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = true
	part.CanTouch = false
	part.Material = PIPE_MATERIAL
	part.Color = color
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.CFrame = CFrame.lookAt(position, position + direction)
	part.Parent = pipeFolder
	return part
end

local function getLeft(dir)
	return Vector3.new(-dir.Z, 0, dir.X)
end

local function getRight(dir)
	return Vector3.new(dir.Z, 0, -dir.X)
end

local function getSeedParts(container)
	local seeds = {}

	for _, descendant in ipairs(container:GetDescendants()) do
		if descendant:IsA("BasePart") then
			table.insert(seeds, descendant)
		end
	end

	return seeds
end

local function scoreMove(optionName, nextPosition, noPipeParams, pipeParams, ignorePart, archetype)
	local score = 0

	if optionName == "Forward" then
		score += archetype.forward
	else
		score += archetype.side
	end

	local nearbyWalls = countNearbyWalls(nextPosition, noPipeParams)
	score += nearbyWalls * archetype.wall

	local nearbyPipes = countNearbyPipes(nextPosition, pipeParams, ignorePart)
	score -= nearbyPipes * archetype.crowdPenalty

	return score
end

local function chooseBestMove(
	currentPosition,
	currentDirection,
	blockParams,
	noPipeParams,
	pipeParams,
	ignorePart,
	archetype
)
	local forward = currentDirection
	local left = getLeft(currentDirection)
	local right = getRight(currentDirection)

	local candidates = {
		{ name = "Forward", dir = forward },
		{ name = "Left", dir = left },
		{ name = "Right", dir = right },
	}

	local bestOption = nil
	local bestScore = -math.huge

	for _, option in ipairs(candidates) do
		local nextPosition = currentPosition + (option.dir * STEP)
		local blocked = isBlocked(nextPosition, blockParams, ignorePart)

		if not blocked then
			local score = scoreMove(option.name, nextPosition, noPipeParams, pipeParams, ignorePart, archetype)

			if score > bestScore then
				bestScore = score
				bestOption = {
					name = option.name,
					dir = option.dir,
					position = nextPosition,
					score = score,
				}
			end
		end
	end

	return bestOption
end

local function chooseArchetype()
	local totalWeight = 0

	for _, archetype in ipairs(PIPE_ARCHETYPES) do
		totalWeight += PipeDebugState:GetArchetypeWeight(archetype.name)
	end

	if totalWeight <= 0 then
		return PIPE_ARCHETYPES[1]
	end

	local roll = math.random() * totalWeight
	local running = 0

	for _, archetype in ipairs(PIPE_ARCHETYPES) do
		running += PipeDebugState:GetArchetypeWeight(archetype.name)

		if roll <= running then
			return archetype
		end
	end

	return PIPE_ARCHETYPES[#PIPE_ARCHETYPES]
end

--// PIPE GROWTH

local function growFromSeed(seedPart, pipeFolder, blockParams, noPipeParams, pipeParams)
	local archetype = chooseArchetype()
	print(seedPart.Name, "picked archetype:", archetype.name)

	local currentPosition = seedPart.Position

	local currentDirection = seedPart.CFrame.LookVector
	currentDirection = Vector3.new(math.round(currentDirection.X), 0, math.round(currentDirection.Z))

	if currentDirection.Magnitude == 0 then
		currentDirection = Vector3.new(1, 0, 0)
	end

	local currentBrightness = MIN_BRIGHTNESS
	local brightnessDirection = 1

	seedPart.Color = applyBrightness(archetype.baseColor, currentBrightness)
	seedPart.Material = PIPE_MATERIAL

	local function getDebugColor()
		local color = applyBrightness(archetype.baseColor, currentBrightness)

		currentBrightness += BRIGHTNESS_STEP * brightnessDirection

		if currentBrightness >= MAX_BRIGHTNESS then
			currentBrightness = MAX_BRIGHTNESS
			brightnessDirection = -1
		elseif currentBrightness <= MIN_BRIGHTNESS then
			currentBrightness = MIN_BRIGHTNESS
			brightnessDirection = 1
		end

		return color
	end

	for i = 1, MAX_SEGMENTS_PER_PIPE do
		waitForPermissionToGrow()

		local bestMove = chooseBestMove(
			currentPosition,
			currentDirection,
			blockParams,
			noPipeParams,
			pipeParams,
			seedPart,
			archetype
		)

		if not bestMove then
			warn(("Pipe seed '%s' stopped at segment %d: no valid moves left."):format(seedPart.Name, i))
			break
		end

		createPipeSegment(pipeFolder, bestMove.position, bestMove.dir, getDebugColor())
		currentPosition = bestMove.position
		currentDirection = bestMove.dir

		if not PipeDebugState.IsPaused then
			task.wait(PipeDebugState.GrowthDelay)
		end
	end
end

--// MAIN

local pipeFolder = getFirstTaggedContainer("Pipe")
if not pipeFolder then
	error("No folder/model tagged 'Pipe' was found")
end

local seedParts = getSeedParts(pipeFolder)
if #seedParts == 0 then
	error("The tagged 'Pipe' folder has no BasePart seeds inside it")
end

local blockParams = makeCombinedBlockParams()
local noPipeParams = makeIncludeParams("NoPipe")
local pipeParams = makeIncludeParams("Pipe")

for _, seedPart in ipairs(seedParts) do
	task.spawn(function()
		growFromSeed(seedPart, pipeFolder, blockParams, noPipeParams, pipeParams)
	end)
end
