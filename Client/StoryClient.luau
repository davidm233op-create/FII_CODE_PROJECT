local StoryClient = {}

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- // Storages
local Modules = ReplicatedStorage.Modules

-- // Modules
local Communicator = require(Modules.Communicator)
local Cutscenes = require(Modules.CutsceneModule)

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

-- // Workspace
local kitchenLightPuzzle = workspace:WaitForChild("Puzzles"):WaitForChild("LightPuzzles"):WaitForChild("KitchenLightPuzzle")
local Misc = workspace:WaitForChild("Misc")

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
