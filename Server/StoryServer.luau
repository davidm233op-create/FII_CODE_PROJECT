local StoryServer = {}

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- // Storages
local Modules = ReplicatedStorage.Modules

-- // Modules
local Communicator = require(Modules.Communicator)

-- // Classes
local LightPuzzle = require(script.Parent.Puzzles.LightPuzzle)
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
	StartStory = {
		func =  function()
			local puzzleFolder = workspace.Puzzles.LightPuzzles.LightPuzzle
			LightPuzzle.StartPuzzle(puzzleFolder)
			Communicator.RemoteEvents.StoryAction:FireAllClients("StartStory")
		end
	},
	
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
	
	task.delay(3, function()
		StoryFunctions.StartStory.func()
	end)

end

return StoryServer
