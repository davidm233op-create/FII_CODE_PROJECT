local StoryServer = {}

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- // Storages
local Modules = ReplicatedStorage.Modules

-- // Modules
local Communicator = require(Modules.Communicator)

-- // Workspace
local Puzzles = workspace.Puzzles

-- // Classes
local LightPuzzle = require(script.Parent.Puzzles.LightPuzzle)
local NumberOrderPuzzle = require(script.Parent.Puzzles.NumberOrderPuzzle)

local Tweens = require(game.StarterPlayer.StarterPlayerScripts.Client.Tweens)
local Sounds = require(script.Parent.Sounds)


function DebounceCheck(player: Player, debounceName: string, cooldown: number)
	if not StoryServer.Debounces[player] then return true end
	if StoryServer.Debounces[player][debounceName] then return true end
	StoryServer.Debounces[player][debounceName] = true
	
	task.delay(cooldown, function()
		if StoryServer.Debounces[player] == nil then return end
		StoryServer.Debounces[player][debounceName] = nil
	end)
	
	return nil
end


local StoryFunctions = {
	RotateMirror = {
		func = function(player: Player, mirrorObject: Model, clicker: BasePart)
			if DebounceCheck(player, "rotatingMirror", 1.5) then return end

			local angleAddition
			if clicker.Name == "Rotate1" then
				angleAddition = 15
			else
				angleAddition = -15
			end

			local part = mirrorObject.Dynamic.PrimaryPart
			Tweens.Tween(part, "CFrame", part.CFrame * CFrame.fromOrientation(math.rad(angleAddition), 0, 0), 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

			local particles = mirrorObject.Dynamic.ParticlePart.ParticleEmitter
			particles.Enabled = true
			Sounds:PlayUnderInstance("StoneGrinding", particles.Parent, true, {95, 105, 100})
			task.delay(1, function()
				particles.Enabled = false
			end)
		end
	},

	MoveWall = {
		func = function(player: Player, wallObject: Model, clicker: BasePart)
			local statePart = wallObject.States:FindFirstChild(clicker.Name)
			if wallObject.Wall.Main.CFrame == statePart.CFrame then return end

			if DebounceCheck(player, "movingWall", 3) then return end

			Tweens.Tween(wallObject.Wall.Main, "CFrame", statePart.CFrame, 3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

			local particles = wallObject.Wall.ParticlePart.ParticleEmitter
			particles.Enabled = true
			Sounds:PlayUnderInstance("StoneGrindingSlow", particles.Parent, true)
			task.delay(3, function()
				particles.Enabled = false
			end)
		end
	},
	
	StartStory = {
		func = function()
			NumberOrderPuzzle.StartPuzzle(Puzzles.NumberOrderPuzzles.Start)
			Communicator.RemoteEvents.StoryAction:FireAllClients("StartStory")
			
			Sounds:Play("HeadTowardsServerDoor")
			task.wait(Sounds["HeadTowardsServerDoor"].TimeLength)
			local door = Puzzles.MovableObjects.ServerDoor
			door.Interactable:SetAttribute("Visible", true)
		end
	},
	
	AttemptedToOpenServerDoor = {
		func = function()
			task.wait(2)
			Sounds:Play("ServerDoorLocked")
			task.wait(Sounds["ServerDoorLocked"].TimeLength)
			task.wait(2)
			Sounds:Play("2003Bookshelf")
			task.wait(Sounds["2003Bookshelf"].TimeLength)
			local bookshelf = Puzzles.MovableObjects.StartBookshelf
			bookshelf.Interactable:SetAttribute("Visible", true)
		end
	},
	
	StartBookshelfMoved = {
		func = function(player: Player, object: Model)
			Sounds:Play("ActivateStartPannel")
			task.wait(Sounds["ActivateStartPannel"].TimeLength)
			Puzzles.NumberOrderPuzzles.Start.Interactable:SetAttribute("Visible", true)
		end
	},
	
	ServerRoomUnlocked = {
		func = function(player: Player, puzzle: Model)
			for _, cable in puzzle.Details.WallCable:GetChildren() do
				cable.Material = Enum.Material.Neon
				Tweens.Tween(cable, "Color", Color3.fromRGB(173, 100, 35), 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			end
			
			local door = Puzzles.MovableObjects.ServerDoor
			door.Interactable:SetAttribute("Visible", true)
		end
	},
	
	ServerRoomOpened = {
		func = function(player: Player, puzzle: Model)
			task.wait(2)
			Sounds:Play("AhTheServerRoom")
			task.wait(Sounds["AhTheServerRoom"].TimeLength)
			
			task.wait(2)
			Sounds:Play("NeedAccessCablePannel")
			task.wait(Sounds["NeedAccessCablePannel"].TimeLength)
			Puzzles.BreakableGlass.ServerGlass.Interactable:SetAttribute("Visible", true)
			Puzzles.MovableObjects.ServerBox1.Interactable:SetAttribute("Visible", true)
			Puzzles.MovableObjects.ServerBox2.Interactable:SetAttribute("Visible", true)
		end
	},
	
	AccessedServerCables = {
		func = function(player: Player, puzzle: Model)
			task.wait(1)
			Sounds:Play("WittyClearenceServerRoom")
		end
	},
	
	CompletedServerCables = {
		func = function(player: Player, puzzle: Model)
			for _, cable in puzzle.Details.WallCable:GetChildren() do
				cable.Material = Enum.Material.Neon
				Tweens.Tween(cable, "Color", Color3.fromRGB(173, 100, 35), 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			end

			local door = Puzzles.MovableObjects.KitchenDoor
			door.Interactable:SetAttribute("Visible", true)
		end
	},
	
	KitchenDoorOpened = {
		func = function(player: Player, puzzle: Model)
			task.wait(2)
			Sounds:Play("KitchenWittyRemark")
		end
	},
	
}

function OnStoryAction(player: Player, action: string, ...)
	if typeof(action) ~= "string" then return end
	if StoryFunctions[action] then
		StoryFunctions[action].func(player, ...)
	end
end


function OnPlayerAdded(player: Player)
	StoryServer.Debounces[player] = {}
end


function OnPlayerRemoving(player: Player)
	StoryServer.Debounces[player] = nil
end


function StoryServer:Init()
	StoryServer.Debounces = {}
	Players.PlayerAdded:Connect(OnPlayerAdded)
	Players.PlayerRemoving:Connect(OnPlayerRemoving)
	Communicator.RemoteEvents.StoryAction.OnServerEvent:Connect(OnStoryAction)
	Communicator.BindableEvents.StoryAction.Event:Connect(OnStoryAction)
	
	task.delay(3, function()
		StoryFunctions.StartStory.func()
	end)

end

return StoryServer
