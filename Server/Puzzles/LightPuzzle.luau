local LightPuzzle = {}

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- // Storages
local Objects = ReplicatedStorage.Objects
local PuzzleUtils = Objects.PuzzleUtils
local Modules = ReplicatedStorage.Modules

-- // Modules
local Communicator = require(Modules.Communicator)

-- // Classes
local Tweens = require(game.StarterPlayer.StarterPlayerScripts.Client.Tweens)
local Sounds = require(script.Parent.Parent.Sounds)

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


local OnPuzzleStarted = {
	["KitchenLightPuzzle"] = function(puzzleFolder: puzzleFolderType)
		if LightPuzzle.Variables.KitchenVariables then return end
		LightPuzzle.Variables.KitchenVariables = {
			MetalDoorAlpha = 0,
			ReceiverActive = false
		}
	end,
}

local OnReceiverActivated = {
	["KitchenLightPuzzle"] = function(puzzleFolder: puzzleFolderType, toggle: boolean)
		local others = puzzleFolder.Others
		local metalDoor = others.MetalDoor.PrimaryPart :: BasePart
		local variables = LightPuzzle.Variables
		
		local defaultCFrame = metalDoor:GetAttribute("DefaultCFrame") :: CFrame
		local upCFrame = metalDoor:GetAttribute("UpCFrame") :: CFrame
		local animationTime = 3
		
		if toggle == true then
			local sound = Sounds:PlayUnderInstance("MetalDoorOpening", metalDoor)
			Sounds:PlayUnderInstance("MetalDoorToggle", metalDoor, true)
			
			variables.KitchenVariables.ReceiverActive = true
			local connection
			local passedTime = animationTime * variables.KitchenVariables.MetalDoorAlpha
			connection = RunService.Heartbeat:Connect(function(dt: number)
				if variables.KitchenVariables.ReceiverActive == false or variables.KitchenVariables.MetalDoorAlpha >= 1 then
					connection:Disconnect()
					sound:Destroy()
					Sounds:PlayUnderInstance("MetalDoorToggle", metalDoor, true)
					return
				end
				
				passedTime += dt
				variables.KitchenVariables.MetalDoorAlpha = passedTime / animationTime
				metalDoor.CFrame = defaultCFrame:Lerp(upCFrame, variables.KitchenVariables.MetalDoorAlpha)
			end)
			
			for _, part: Part in others.Cable:GetChildren() do
				part.Material = Enum.Material.Neon
				Tweens.Tween(part, "Color", Color3.fromRGB(104, 177, 91), 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			end
		else
			local sound = Sounds:PlayUnderInstance("MetalDoorOpening", metalDoor)
			Sounds:PlayUnderInstance("MetalDoorToggle", metalDoor, true)
			
			variables.KitchenVariables.ReceiverActive = false
			local connection
			local passedTime = animationTime * variables.KitchenVariables.MetalDoorAlpha

			connection = RunService.Heartbeat:Connect(function(dt: number)
				if variables.KitchenVariables.ReceiverActive == true or variables.KitchenVariables.MetalDoorAlpha <= 0 then
					connection:Disconnect()
					sound:Destroy()
					Sounds:PlayUnderInstance("MetalDoorToggle", metalDoor, true)
					return
				end

				passedTime -= dt
				variables.KitchenVariables.MetalDoorAlpha = passedTime / animationTime
				metalDoor.CFrame = defaultCFrame:Lerp(upCFrame, variables.KitchenVariables.MetalDoorAlpha)
			end)
			
			for _, part: Part in others.Cable:GetChildren() do
				part.Material = Enum.Material.Metal
				Tweens.Tween(part, "Color", Color3.fromRGB(76, 76, 76), 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			end
		end
	end,
}

local BeamColors = {
	["KitchenLightPuzzle"] = Color3.fromRGB(255, 133, 52)
}


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
		if BeamColors[puzzleFolder.Name] then
			beam.Color = BeamColors[puzzleFolder.Name]
		end
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
	if BeamColors[puzzleFolder.Name] then
		beam.Color = BeamColors[puzzleFolder.Name]
	end
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

function BeamToggleReceiver(puzzleFolder: puzzleFolderType, toggle: boolean)
	
	if OnReceiverActivated[puzzleFolder.Name] then
		task.spawn(function()
			OnReceiverActivated[puzzleFolder.Name](puzzleFolder, toggle)
		end)
	end
end


function LightPuzzle.StartPuzzle(puzzleFolder: puzzleFolderType)
	if OnPuzzleStarted[puzzleFolder.Name] then
		task.spawn(function()
			OnPuzzleStarted[puzzleFolder.Name]()
		end)
	end
	
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
					BeamToggleReceiver(puzzleFolder, true)
				end
			else
				if previousActivatedReceivers[receiver] then
					receiver.Color = Color3.fromRGB(163, 162, 165)
					BeamToggleReceiver(puzzleFolder, false)
				end
			end
		end

		previousActivatedReceivers = currentActivatedReceivers
	end
	
	castAllLight()
	
	
	LightPuzzle.Heartbeats[puzzleFolder.Name] = game.RunService.Heartbeat:Connect(function()
		castAllLight()
	end)

end


function LightPuzzle.EndPuzzle(puzzleFolder: puzzleFolderType)
	
	for _, light in puzzleFolder.Light:GetChildren() do
		light:Destroy()
	end
	BeamToggleReceiver(puzzleFolder, false)
	for _, receiver in puzzleFolder.LightReceivers:GetChildren() do
		receiver.Color = Color3.fromRGB(163, 162, 165)
	end
	
	LightPuzzle.Heartbeats[puzzleFolder.Name]:Disconnect()
	LightPuzzle.Heartbeats[puzzleFolder.Name] = nil
end

function LightPuzzle.OnPuzzleAction(player: Player, action: string)

end


function LightPuzzle:Init()
	LightPuzzle.Variables = {}
	LightPuzzle.Heartbeats = {}
end


return LightPuzzle
