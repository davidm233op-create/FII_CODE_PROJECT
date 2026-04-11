local LightPuzzle = {}

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

-- // Storages
local Objects = ReplicatedStorage.Objects
local PuzzleUtils = Objects.PuzzleUtils
local Modules = ReplicatedStorage.Modules

-- // Modules
local Communicator = require(Modules.Communicator)

--Types
type puzzleFolderType = Folder & {
	LightSources: Folder & {BasePart},
	LightReceivers: Folder & {BasePart},
	Mirrors: Folder,
	Walls: Folder,
	Light: Folder,
}

-- // Constants
local MAX_BEAM_LENGTH = 100

function lerp(a, b, c)
	return a + (b - a) * c
end


function RaycastForward(puzzleFolder: puzzleFolderType, part: BasePart, range: number): RaycastResult
	local origin = part.CFrame.Position
	local direction = part.CFrame.LookVector
	return workspace:Raycast(origin, direction * range)
end

local function getReflectionDirection(incident: Vector3, normal: Vector3)
	return incident - 2 * incident:Dot(normal) * normal
end

function SpawnBeam(puzzleFolder: puzzleFolderType, source: BasePart)
	local raycast = RaycastForward(puzzleFolder, source, MAX_BEAM_LENGTH)
	local range = MAX_BEAM_LENGTH
	local beamLengthAddition = 0
	local light = {}
	
	while raycast and raycast.Instance.Parent == puzzleFolder.Mirrors do
		local hitPosition = raycast.Position
		range = (hitPosition - source.CFrame.Position).Magnitude

		local beam = PuzzleUtils.LightBeam:Clone()
		beam.Size = Vector3.new(range + beamLengthAddition, source.Size.X, source.Size.Y)
		beam.CFrame = source.CFrame * CFrame.new(0, 0, -range / 2) * CFrame.Angles(0, math.pi / 2, 0)
		beam.Parent = puzzleFolder.Light
		table.insert(light, beam)

		local reflectionDirection = getReflectionDirection(source.CFrame.LookVector, raycast.Normal)
		local lookTarget = hitPosition + reflectionDirection
		source = {
			CFrame = CFrame.lookAt(hitPosition, lookTarget),
			Size = source.Size
		}
		raycast = RaycastForward(puzzleFolder, source, MAX_BEAM_LENGTH)
	end
	
	if raycast then
		range = (raycast.Position - source.CFrame.Position).Magnitude
	else
		range = MAX_BEAM_LENGTH
	end
	
	local beam = PuzzleUtils.LightBeam:Clone()
	beam.Size = Vector3.new(range + beamLengthAddition, source.Size.X, source.Size.Y)
	beam.CFrame = source.CFrame * CFrame.new(0, 0, -range / 2) * CFrame.Angles(0, math.pi / 2, 0)
	beam.Parent = puzzleFolder.Light
	table.insert(light, beam)
	
	return raycast, light
end

function CleanBeam(puzzleFolder: puzzleFolderType)
	for _, beam: BasePart in puzzleFolder.Light:GetChildren() do
		beam:Destroy()
	end
end

function LightPuzzle.StartPuzzle(puzzleFolder: puzzleFolderType)
	local sources = puzzleFolder:WaitForChild("LightSources"):GetChildren()
	local receivers = puzzleFolder:WaitForChild("LightReceivers"):GetChildren()
	
	local previousActivatedReceivers = {}
	local currentActivatedReceivers = {}
	
	local function castAllLight()
		local currentActivatedReceivers = {}

		CleanBeam(puzzleFolder)

		for _, lightSource in sources do
			local raycast, light = SpawnBeam(puzzleFolder, lightSource)

			if raycast and raycast.Instance.Parent == puzzleFolder.LightReceivers then
				currentActivatedReceivers[raycast.Instance] = true

				for _, beam in light do
					beam.Color = Color3.fromRGB(84, 255, 46)
				end
			end
		end

		for _, receiver in receivers do
			if currentActivatedReceivers[receiver] then
				if not previousActivatedReceivers[receiver] then
					receiver.Color = Color3.fromRGB(84, 255, 46)
				end
			else
				if previousActivatedReceivers[receiver] then
					receiver.Color = Color3.fromRGB(163, 162, 165)
				end
			end
		end

		previousActivatedReceivers = currentActivatedReceivers
	end
	
	castAllLight()
	
	
	game.RunService.Heartbeat:Connect(function()
		castAllLight()
	end)
	
	--for _, wall: BasePart in puzzleFolder.Walls:GetChildren() do
	--	if wall:IsA("BasePart") then
	--		wall:GetPropertyChangedSignal("CFrame"):Connect(function()
	--			CleanBeam(puzzleFolder)
	--			SpawnBeam(puzzleFolder, lightSource)
	--		end)
	--	end
	--end
	
	--for _, mirror: BasePart in puzzleFolder.Mirrors:GetChildren() do
	--	if mirror:IsA("BasePart") then
	--		mirror:GetPropertyChangedSignal("CFrame"):Connect(function()
	--			CleanBeam(puzzleFolder)
	--			SpawnBeam(puzzleFolder, lightSource)
	--		end)
	--	end
	--end
end


function LightPuzzle.EndPuzzle(puzzleFolder: puzzleFolderType)
	
end

function LightPuzzle.OnPuzzleAction(player: Player, action: string)

end


function LightPuzzle:Init()
	
end


return LightPuzzle
