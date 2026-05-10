local StoryClient = {}

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

-- // Storages
local Modules = ReplicatedStorage.Modules

-- // Modules
local Communicator = require(Modules.Communicator)
local Cutscenes = require(Modules.CutsceneModule)

-- // Lighting
local NightVisionBlur = Lighting.NightVisionBlur

-- // Local Player
local LocalPlayer = Players.LocalPlayer

-- // UI
local PlayerGui = LocalPlayer.PlayerGui
local Hud = PlayerGui.Hud
local BlackScreen = Hud.BlackScreen

-- // Classes
local Interactables = require(script.Parent.UI.Interactables)
local Objective = require(script.Parent.UI.Objective)
local Alerts = require(script.Parent.UI.Alerts)
local UI = require(script.Parent.UI)
local Tweens = require(script.Parent.Tweens)
local CameraShaker = require(script.Parent.CameraShaker)
local Sounds = require(script.Parent.Sounds)

-- // Workspace
local kitchenLightPuzzle = workspace:WaitForChild("Puzzles"):WaitForChild("LightPuzzles"):WaitForChild("KitchenLightPuzzle")
local Misc = workspace:WaitForChild("Misc")
local CurrentCamera = workspace.CurrentCamera

local function ShakeCamera(Preset)
	local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCf)
		CurrentCamera.CFrame = CurrentCamera.CFrame * shakeCf
	end)

	camShake:Start()
	camShake:Shake(CameraShaker.Presets[Preset])
end

function getTypeOfPlayer()
	return LocalPlayer:GetAttribute("PlayerIndex")
end

function handleMirrorObjects(LightPuzzleFolder)
	local mirrorObjects = LightPuzzleFolder:WaitForChild("MirrorObjects")
	local wallObjects = LightPuzzleFolder:WaitForChild("Walls")

	for _, mirror in mirrorObjects:GetChildren() do

		for _, clicker in mirror:WaitForChild("Interactables"):GetChildren() do
			if not clicker:HasTag("Interactable") then continue end

			Interactables.OnInteractablePressed(clicker, Enum.KeyCode.E):Connect(function()
				if getTypeOfPlayer() == "P2" then
					UI.alertPlayerTypeIncompatible()
					return
				end

				Communicator.RemoteEvents.StoryAction:FireServer("RotateMirror", mirror, clicker)
			end)
		end

	end

	for _, wall in wallObjects:GetChildren() do

		for _, clicker in wall:WaitForChild("Interactables"):GetChildren() do
			if not clicker:HasTag("Interactable") then continue end

			Interactables.OnInteractablePressed(clicker, Enum.KeyCode.E):Connect(function()
				if getTypeOfPlayer() == "P2" then
					UI.alertPlayerTypeIncompatible()
					return
				end

				Communicator.RemoteEvents.StoryAction:FireServer("MoveWall", wall, clicker)
			end)
		end

	end
end

local StoryFunctions = {
	StartStory = {
		func = function()
			Tweens.Tween(BlackScreen, "BackgroundTransparency", 1, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			task.spawn(function()
				Cutscenes.InitiateCutscene(workspace.Cutscenes.StartCutscene)
			end)
			task.wait(5)
			Tweens.Tween(BlackScreen, "BackgroundTransparency", 0, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			task.wait(2)
			Tweens.Tween(BlackScreen, "BackgroundTransparency", 1, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			task.delay(1, function()
				BlackScreen.Visible = false
			end)
			
			
			
		end
	},
	
	KitchenDoorOpened = {
		func = function()
			handleMirrorObjects(kitchenLightPuzzle)
			
			local kitchenMicrowave = Misc.KitchenMicrowave
			Interactables.OnInteractablePressed(kitchenMicrowave.Interactable, Enum.KeyCode.E):Connect(function()
				Communicator.RemoteEvents.StoryAction:FireServer("KitchenMicrowaveToggled", kitchenMicrowave)
			end)


		end
	},
	
	AttemptedOpeningArchiveDoor = {
		func = function()
			
			local projector = Misc.Projector
			Interactables.OnInteractablePressed(projector.Interactable, Enum.KeyCode.E):Connect(function()
				Communicator.RemoteEvents.StoryAction:FireServer("ConferenceProjectorBroken", projector)
			end)
		end
	},
	
	ArchiveDoorOpened = {
		func = function()
			Tweens.Tween(Hud.WhiteScreen, "BackgroundTransparency", 0, 5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		end
	},
	
	StartChapter2 = {
		func = function()
			task.wait(2)
			Tweens.Tween(BlackScreen, "BackgroundTransparency", 1, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			task.delay(1, function()
				BlackScreen.Visible = false
			end)
		end,
	},
	
	ElevatorExplosion = {
		func = function()
			Tweens.Tween(Lighting.DarkCorrection, "TintColor", Color3.fromRGB(0, 0, 0), 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			task.delay(0.5, function()
				local secondElevatorCheckpoint = Misc:WaitForChild("ElevatorHitbox")
				LocalPlayer.Character:PivotTo(secondElevatorCheckpoint.CFrame)
			end)
			ShakeCamera("Explosion")
			Sounds:Play("ElevatorExplosion")
			task.wait(2.3)
			Sounds:Play("ElevatorDing")
		end,
	},
	
	ToggleNightVision = {
		func = function(toggle: boolean)
			if toggle == true then
				Sounds:Play("NightVisionOn")
				UI.ToggleScreenGrain(toggle)
				Lighting.NightVisionBlur.Size = 25
				Tweens.Tween(Lighting.NightVisionBlur, "Size", 2, 2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				Tweens.Tween(Lighting.NightVisionCorrection, "TintColor", Color3.fromRGB(64, 230, 55), 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			else
				Sounds:Play("NightVisionOff")
				UI.ToggleScreenGrain(false)
				Lighting.NightVisionBlur.Size = 25
				Tweens.Tween(Lighting.NightVisionBlur, "Size", 2, 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				Tweens.Tween(Lighting.NightVisionCorrection, "TintColor", Color3.fromRGB(255, 255, 255), 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			end
		end,
	},
	
	FixElevator = {
		func = function()
			Tweens.Tween(Lighting.DarkCorrection, "TintColor", Color3.fromRGB(255, 255, 255), 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			local secondElevatorCheckpoint = Misc:WaitForChild("SecondElevatorDoors"):WaitForChild("ElevatorHitbox")
			LocalPlayer.Character:PivotTo(secondElevatorCheckpoint.CFrame)
		end,
	},
	
	OpenElevatorDoors = {
		func = function()
			local secondElevatorDoors = Misc.SecondElevatorDoors
			
			local connection
			connection = Interactables.OnInteractablePressed(secondElevatorDoors.Interactable, Enum.KeyCode.E):Connect(function()
				if getTypeOfPlayer() == "P2" then
					UI.alertPlayerTypeIncompatible()
					return
				end
				connection:Disconnect()
				secondElevatorDoors.Interactable:SetAttribute("Visible", false)
				Communicator.RemoteEvents.StoryAction:FireServer("OpenedElevatorDoors")
			end)
		end,
	},
	
	BombDefused = {
		func = function()
			task.wait(1)
			Tweens.Tween(Hud.WhiteScreen, "BackgroundTransparency", 0, 2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			task.wait(2)
			local endScenes = Hud.Chapter2EndingScenes
			local image = endScenes.ImageLabel
			endScenes.Visible = true
			task.wait(1)
			Tweens.Tween(Hud.WhiteScreen, "BackgroundTransparency", 1, 2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			
			task.wait(4)
			Tweens.Tween(image, "AnchorPoint", Vector2.new(0.74, 0.25), 2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			
			task.wait(4)
			Tweens.Tween(image, "AnchorPoint", Vector2.new(0.26, 0.75), 2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			
			task.wait(4)
			Tweens.Tween(image, "AnchorPoint", Vector2.new(0.76, 0.75), 2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			
			task.wait(4)
			Tweens.Tween(image, "ImageTransparency", 1, 2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			task.wait(2)
			Communicator.RemoteEvents.StoryAction:FireServer("Chapter2Ended")
		end,
	},
}

function OnStoryAction(action: string, ...)
	if typeof(action) ~= "string" then return end
	if StoryFunctions[action] then
		StoryFunctions[action].func(...)
	end
end

function StoryClient:Init()
	Communicator.RemoteEvents.StoryAction.OnClientEvent:Connect(OnStoryAction)
end

return StoryClient
