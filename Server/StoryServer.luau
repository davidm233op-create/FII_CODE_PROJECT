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
local Misc = workspace.Misc
local ChapterSpawnpoints = workspace.ChapterSpawnpoints

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


local customPlaySoundWithSubtitles = {
	["StartCutscene"] = function()
		
		task.wait(1.5)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"This is the story of one.. uh.. I mean two people who start their day at the office!",
			0.02
		)

		task.wait(6)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)

		task.wait(0.2)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"Two employees. Neither of them where they're supposed to be.",
			0.02
		)

		task.wait(4.2)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)
		
		task.wait(0.2)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"But they're here and happy to help each other.",
			0.02
		)

		task.wait(3)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)
		
		task.wait(0.2)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"Distinctively, one of them reads the memos during work hours..",
			0.02
		)

		task.wait(2.5)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)
		
		task.wait(0.2)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"The other doesn't even bother. But that's what makes us special!",
			0.02
		)
		
		task.wait(3.5)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)

		task.wait(0.2)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"We're all different in our own ways!",
			0.02
		)

		task.wait(3)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)
		
		task.wait(0.2)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"There is, however, one thing they have in common... Neither of them like the office.",
			0.02
		)

		task.wait(5)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)
		
		task.wait(0.2)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"So today they want to escape!",
			0.02
		)

		task.wait(2.5)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)
		
		task.wait(0.2)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"They find themselves each at their desks, ready to take this adventure on!",
			0.02
		)

		task.wait(5)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)
	end,
	
	["ServerDoorLocked"] = function()
		
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"The code was changed last Tuesday. Patricia from HR sent an email about it, but none of them read it!",
			0.02
		)
		
		task.wait(5)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)
		
		task.wait(0.2)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"So now they're going to have to find a way through that door!",
			0.02
		)

		task.wait(4)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)
	end,
	
	["2003Bookshelf"] = function()

		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"The bookshelf has been here since 2003! No one has moved it! No one has tried!",
			0.02
		)

		task.wait(5)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)

		task.wait(0.2)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"So one of them gets a bright idea!",
			0.02
		)

		task.wait(4)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)
	end,
	
	["ActivateStartPannel"] = function()

		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"It appears that pannel is going to have to be activated by somebody with above average intelligence!",
			0.02
		)

		task.wait(7.5)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)
	end,
	
	["AhTheServerRoom"] = function()

		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"Ah, yes! The server room! Home to fourteen years of backed-up spreadsheets..",
			0.02
		)

		task.wait(5.7)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)

		task.wait(0.2)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"Three dead plants, and one very confused router!",
			0.02
		)

		task.wait(5.5)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)
       	end,
	
	["NeedAccessCablePannel"] = function()

		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"It seems like they're gonna need access to that cable pannel!",
			0.02
		)

		task.wait(5.5)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)

	end,
	
	["WittyClearenceServerRoom"] = function()

		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"One's looking at a door. And the other's connecting cables.",
			0.02
		)

		task.wait(3.2)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)

		task.wait(0.2)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"Neither of them has clearance to be in this room. Fascinating.",
			0.02
		)

		task.wait(4)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)
	end,
	
	["PhysicsDegree"] = function()

		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"The break room. The last place anyone expected to need a physics degree!",
			0.02
		)

		task.wait(6.3)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)

	end,
	
	["TheMicrowaveSitsDark"] = function()

		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"The microwave sits dark! The feline in the corner sits, presumably...",
			0.02
		)

		task.wait(4.8)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)
		
		task.wait(0.3)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"Pettable!",
			0.02
		)
		task.wait(2)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)

	end,
	
	["TheMicrowaveHums"] = function()

		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"The microwave hums. It is not heating anything.",
			0.02
		)

		task.wait(4.8)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)

		task.wait(0.3)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"The Narrator chooses not to elaborate on why it's emitting light instead.",
			0.02
		)
		task.wait(6)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)

	end,
	
	["TheConferenceRoom"] = function()

		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"The conference room...! Nine-ish chairs! One projector! Zero attendees!",
			0.02
		)

		task.wait(6.2)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)

		task.wait(0.3)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"The meeting, according to the calendar, has been running since Thursday!",
			0.02
		)
		task.wait(6)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)

	end,
	
	["BreakTheProjector"] = function()

		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"The door is locked! The room, it seems, has a strict policy on leaving before the meeting is adjourned!",
			0.02
		)

		task.wait(6.4)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)

		task.wait(0.3)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"There is no one to adjourn it! Someone has to put an end to the presentation!",
			0.02
		)
		task.wait(6)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)

	end,
	
	["TheLobby"] = function()

		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"The lobby! A timeless classic, marble floors, tall ceilings, and..",
			0.02
		)

		task.wait(4)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)

		task.wait(0.3)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"Oh look! An elevator, just standing there, waiting!",
			0.02
		)
		
		task.wait(3)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)
		
		task.wait(0.9)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"Not that it's suggesting anything, no pressure, take your time!",
			0.02
		)
		
		task.wait(4.5)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)
		
		task.wait(0.3)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"It's not like the story is going to progress itself!",
			0.02
		)
		
		task.wait(4.5)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)

	end,
	
	["ElevatorExplain"] = function()

		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"Lovely little box, isn't it?",
			0.02
		)

		task.wait(2)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)

		task.wait(0.3)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"You'll notice the lower floors aren't particularly responsive today.",
			0.02
		)

		task.wait(3)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)

		task.wait(0.9)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"Floor nine, however, is open for business! There's a fire exit up there!",
			0.02
		)

		task.wait(4.5)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)

		task.wait(0.3)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"That's their way out, they said..",
			0.02
		)

		task.wait(4.5)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)

	end,
	
	["ExplosionExplanation"] = function()

		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"Well, that was unexpected. Don't worry, I'm sure it's nothing!",
			0.02
		)

		task.wait(4)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)

		task.wait(0.7)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"The lights going out after an unexpected explosive sound..",
			0.02
		)
		
		task.wait(4)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)
		
		task.wait(0.9)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"..is perfectly normal elevator behavior! Completely standard!",
			0.02
		)
		
		task.wait(5)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)
	end,
	

	["OpenElevatorDoor"] = function()

		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"Floor 9! And the door is almost open! Lovely!",
			0.02
		)

		task.wait(4)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)

		task.wait(0.7)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"Whoever designed this building was clearly very passionate about obstacles!",
			0.02
		)

		task.wait(4)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)

		task.wait(0.9)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"Someone with an appropriate amount of muscle might wanna have a word with it!",
			0.02
		)

		task.wait(5)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)
	end,
	
	["KeypadRoomHint"] = function()
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"Now.. There's a door with a keypad just ahead.",
			0.02
		)

		task.wait(4)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)

		task.wait(0.7)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"That seems like the sort of thing you'd wanna interact with!",
			0.02
		)

		task.wait(2.5)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)

		task.wait(0.9)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"Just a thought.",
			0.02
		)

		task.wait(2)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)
	end,
	
	["BigLobbyRoom"] = function()
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"Ah. The big lobby! You'll notice it's a bit.. open plan!",
			0.02
		)

		task.wait(4.5)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)

		task.wait(0.7)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"That's what happens when a **** goes off!",
			0.02
		)

		task.wait(2.5)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)

		task.wait(0.9)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"There's another one somewhere in here by the way.",
			0.02
		)

		task.wait(2)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)
		
		task.wait(0.9)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"Probably worth dealing with.",
			0.02
		)

		task.wait(3)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)
	end,
	
	["Disarmed"] = function()
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"Well.. you did it! The bomb is disarmed..",
			0.02
		)

		task.wait(3)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)

		task.wait(0.7)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"The building is still standing! You are still alive!",
			0.02
		)

		task.wait(2.5)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)

		task.wait(0.9)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			"I'll be honest I had my doubts.",
			0.02
		)

		task.wait(2)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0)
	end,
}

function PlaySoundWithSubtitles(soundName: string, text: string, timeBetweenCharacters: number, destroyDelayAfterFinish: number)
	local sound = Sounds[soundName]
	if customPlaySoundWithSubtitles[soundName] then
		task.spawn(function()
			sound:Play()
			customPlaySoundWithSubtitles[soundName]()
		end)
		return
	end
	
	task.spawn(function()
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(true, 
			text,
			0.03
		)

		task.wait(sound.TimeLength)
		task.wait(destroyDelayAfterFinish or 2)
		Communicator.RemoteEvents.ToggleSubtitles:FireAllClients(false, nil, 0.01)
	end)
	Sounds:Play(soundName)
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
			
			local axis = mirrorObject.Configuration:GetAttribute("rotateAxis")
			local orientationCFrame
			if axis == "z" then
				orientationCFrame = CFrame.fromOrientation(0, 0, math.rad(angleAddition))
			elseif axis == "y" then
				orientationCFrame = CFrame.fromOrientation(0, math.rad(angleAddition), 0)
			else
				orientationCFrame = CFrame.fromOrientation(math.rad(angleAddition), 0, 0)
			end
			
			local part = mirrorObject.Dynamic.PrimaryPart
			Tweens.Tween(part, "CFrame", part.CFrame * orientationCFrame, 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

			--local particles = mirrorObject.Dynamic.ParticlePart.ParticleEmitter
			--particles.Enabled = true
			--Sounds:PlayUnderInstance("StoneGrinding", particles.Parent, true, {95, 105, 100})
			--task.delay(1, function()
			--	particles.Enabled = false
			--end)
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
	
	
	
	-- // STORY START // -- -- // STORY START // -- -- // STORY START // -- -- // STORY START // -- -- // STORY START // --
	
	StartStory = {
		func = function()
			task.wait(5)
			NumberOrderPuzzle.StartPuzzle(Puzzles.NumberOrderPuzzles.Start)
			
			PlaySoundWithSubtitles("StartCutscene")
			task.wait(Sounds["StartCutscene"].TimeLength - 5)
			
			Communicator.RemoteEvents.StoryAction:FireAllClients("StartStory")
			
			task.wait(7)
			
			PlaySoundWithSubtitles("HeadTowardsServerDoor",
				"They head towards the door with the big glowing SERVER sign!",
				0.03
			)
			
			task.wait(Sounds["HeadTowardsServerDoor"].TimeLength)
			
			
			
			local door = Puzzles.MovableObjects.ServerDoor
			door.Interactable:SetAttribute("Visible", true)
		end
	},
	
	AttemptedToOpenServerDoor = {
		func = function()
			task.wait(2)
			PlaySoundWithSubtitles("ServerDoorLocked")
			task.wait(Sounds["ServerDoorLocked"].TimeLength)
			task.wait(2)
			PlaySoundWithSubtitles("2003Bookshelf")
			task.wait(Sounds["2003Bookshelf"].TimeLength)
			local bookshelf = Puzzles.MovableObjects.StartBookshelf
			bookshelf.Interactable:SetAttribute("Visible", true)
		end
	},
	
	StartBookshelfMoved = {
		func = function(player: Player, object: Model)
			task.wait(1)
			PlaySoundWithSubtitles("ActivateStartPannel")
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
			PlaySoundWithSubtitles("AhTheServerRoom")
			task.wait(Sounds["AhTheServerRoom"].TimeLength)
			
			task.wait(2)
			PlaySoundWithSubtitles("NeedAccessCablePannel")
			task.wait(Sounds["NeedAccessCablePannel"].TimeLength)

			Puzzles.BreakableGlass.ServerGlass.Interactable:SetAttribute("Visible", true)
			Puzzles.MovableObjects.ServerBox1.Interactable:SetAttribute("Visible", true)
			Puzzles.MovableObjects.ServerBox2.Interactable:SetAttribute("Visible", true)
		end
	},
	
	AccessedServerCables = {
		func = function(player: Player, puzzle: Model)
			task.wait(1)
			PlaySoundWithSubtitles("WittyClearenceServerRoom")
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
			Communicator.RemoteEvents.StoryAction:FireAllClients("KitchenDoorOpened")
			task.wait(2)
			PlaySoundWithSubtitles("PhysicsDegree")
			task.wait(Sounds["PhysicsDegree"].TimeLength)
			
			task.wait(2)
			PlaySoundWithSubtitles("TheMicrowaveSitsDark")
			task.wait(Sounds["TheMicrowaveSitsDark"].TimeLength)

			Misc.KitchenMicrowave.Interactable:SetAttribute("Visible", true)
		end
	},
	
	KitchenMicrowaveToggled = {
		func = function(player: Player, microwave: Model)
			if microwave:GetAttribute("Toggled") == true then return end
			
			if not microwave:GetAttribute("ToggledBefore") then
				microwave:SetAttribute("ToggledBefore", true)
				
				task.delay(2, function()
					PlaySoundWithSubtitles("TheMicrowaveHums")
				end)
			end
			
			microwave:SetAttribute("Toggled", true)
			microwave.Screen.Color = Color3.fromRGB(255, 191, 30)
			LightPuzzle.StartPuzzle(Puzzles.LightPuzzles.KitchenLightPuzzle)
			Sounds:PlayUnderInstance("Microwave5Seconds", microwave.Interactable, true)
			
			task.wait(3.5)
			microwave.Screen.Color = Color3.fromRGB(159, 161, 172)
			LightPuzzle.EndPuzzle(Puzzles.LightPuzzles.KitchenLightPuzzle)
			
			task.wait(1.5)
			microwave:SetAttribute("Toggled", false)
		end
	},
	
	ConferenceRoomUnlocked = {
		func = function(player: Player, puzzle: Model)
			for _, cable in puzzle.Details.WallCable:GetChildren() do
				cable.Material = Enum.Material.Neon
				Tweens.Tween(cable, "Color", Color3.fromRGB(173, 100, 35), 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			end
			
			Puzzles.MovableObjects.ConferenceRoomDoor.Interactable:SetAttribute("Visible", true)
		end
	},
	
	ConferenceRoomOpened = {
		func = function(player: Player, puzzle: Model)
			NumberOrderPuzzle.StartPuzzle(Puzzles.NumberOrderPuzzles.Conference)
			
			PlaySoundWithSubtitles("TheConferenceRoom")
		end
	},
	
	ConferencePuzzleDone = {
		func = function(player: Player, puzzle: Model)
			local door = Puzzles.MovableObjects.ArchiveRoomDoor
			door:SetAttribute("puzzleDone", true)
			
			for _, cable in puzzle.Details.WallCable:GetChildren() do
				cable.Material = Enum.Material.Neon
				Tweens.Tween(cable, "Color", Color3.fromRGB(173, 100, 35), 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			end
			
			if door:GetAttribute("boxMoved") then
				Communicator.BindableEvents.StoryAction:Fire(player, "ConferenceRoomPuzzleAllDone")
			end
		end
	},
	
	ConferenceBoxMoved = {
		func = function(player: Player, puzzle: Model)
			local door = Puzzles.MovableObjects.ArchiveRoomDoor
			door:SetAttribute("boxMoved", true)

			if door:GetAttribute("puzzleDone") then
				Communicator.BindableEvents.StoryAction:Fire(player, "ConferenceRoomPuzzleAllDone")
			end
		end
	},
	
	ConferenceRoomPuzzleAllDone = {
		func = function()
			Puzzles.MovableObjects.ArchiveRoomDoor.Interactable:SetAttribute("Visible", true)
		end
	},
	
	AttemptedOpeningArchiveDoor = {
		func = function()
			Puzzles.MovableObjects.ArchiveRoomDoor.Interactable:SetAttribute("Visible", false)
			
			PlaySoundWithSubtitles("BreakTheProjector")
			task.wait(Sounds["BreakTheProjector"].TimeLength)
			
			Communicator.RemoteEvents.StoryAction:FireAllClients("AttemptedOpeningArchiveDoor")
			Misc.Projector.Interactable:SetAttribute("Visible", true)
		end
	},
	
	ConferenceProjectorBroken = {
		func = function(player: Player, projector: Model)
			Puzzles.MovableObjects.ArchiveRoomDoor.Interactable:SetAttribute("Visible", true)
			Puzzles.MovableObjects.ArchiveRoomDoor.Configuration:SetAttribute("increment", 1)
			
			projector.LightPart:Destroy()
			projector.Light:Destroy()
			projector.Interactable.Particles.Enabled = true
			Sounds:PlayUnderInstance("ProjectorDestroyed", projector.Interactable, true)
			projector.Interactable:SetAttribute("Visible", false)
			projector.Screen.SurfaceGui:Destroy()
		end
	},
	
	ArchiveDoorOpened = {
		func = function()
			Communicator.RemoteEvents.StoryAction:FireAllClients("ArchiveDoorOpened")
			for _, v in Players:GetChildren() do
				local character = v.Character
				character.HumanoidRootPart.Anchored = true
			end
			
			task.wait(8)
			for _, v in Players:GetChildren() do
				v:Kick("Chapter 1 finished! Rejoin to try out chapter 2! :)")
			end
		end
	},
	
	
	StartChapter2 = {
		func = function()
			for _, v in Players:GetChildren() do
				v.Character:PivotTo(ChapterSpawnpoints.Chapter2.CFrame)
			end
			Communicator.RemoteEvents.StoryAction:FireAllClients("StartChapter2")
		end
	},
	
	ElevatorRoomDoorOpened = {
		func = function(door: Model)
			PlaySoundWithSubtitles("TheLobby")
			task.wait(Sounds["TheLobby"].TimeLength)
			
			local elevatorHitbox = Misc.ElevatorHitbox
			local playersInsideElevator = 0
			
			local characters = {}
			for _, player in Players:GetChildren() do
				table.insert(characters, player.Character)
			end 
			
			local insideElevatorRange = 7
			while playersInsideElevator < #characters do
				playersInsideElevator = 0
				for _, char: Model in characters do
					local distanceBetween = (char:GetPivot().Position - elevatorHitbox.Position).Magnitude
					if distanceBetween <= insideElevatorRange then
						playersInsideElevator += 1
					end
				end
				task.wait()
			end
			
			Communicator.BindableEvents.StoryAction:Fire(Players:FindFirstChildWhichIsA("Player"),
				"EnteredElevator")
		end
	},
	
	
	EnteredElevator = {
		func = function(door: Model)
			local door = Misc.FirstElevatorDoors
			door.DoorBlocker.CanCollide = true
			Sounds:Play("ElevatorDoorToggling")
			
			Tweens.Tween(door.LeftElevatorDoor.Main, "CFrame",
				door.LeftElevatorDoor:GetAttribute("ClosedCFrame"),
				0.5, Enum.EasingStyle.Sine,
				Enum.EasingDirection.Out)
			
			Tweens.Tween(door.RightElevatorDoor.Main, "CFrame",
				door.RightElevatorDoor:GetAttribute("ClosedCFrame"),
				0.5, Enum.EasingStyle.Sine,
				Enum.EasingDirection.Out)
			
			task.wait(2)
			
			PlaySoundWithSubtitles("ElevatorExplain")
			task.wait(Sounds["ElevatorExplain"].TimeLength)
			
			task.wait(1)
			
			local floorScreen = Misc.ElevatorFloorSelector.Screen.SurfaceGui
			floorScreen["9thFloorGreen"].Visible = true
			Sounds:PlayUnderInstance("ElevatorDing", floorScreen.Parent, true)
			task.wait(0.5)
			Sounds.ElevatorMoving:Play()
			for i = 4, 7 do
				task.wait(2)
				floorScreen.TextLabel.Text = tostring(i)
			end
			
			Communicator.RemoteEvents.StoryAction:FireAllClients("ElevatorExplosion")
			Sounds.ElevatorMoving:Stop()
			
			task.wait(3.5)
			Communicator.RemoteEvents.StoryAction:FireAllClients("FixElevator")
			Communicator.RemoteEvents.StoryAction:FireAllClients("ToggleNightVision", true)
			
			task.wait(1)
			PlaySoundWithSubtitles("ExplosionExplanation")
			task.wait(Sounds["ExplosionExplanation"].TimeLength)

			Puzzles.MovableObjects.ElevatorPannel.Interactable:SetAttribute("Visible", true)
		end
	},
	
	CompletedElevatorCables = {
		func = function(player: Player, puzzle: Model)
			for _, cable in puzzle.Details.WallCables:GetChildren() do
				cable.Material = Enum.Material.Neon
				Tweens.Tween(cable, "Color", Color3.fromRGB(173, 100, 35), 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			end
			Puzzles.MovableObjects.ElevatorPannel.Interactable:SetAttribute("Visible", false)
			
			task.wait(2)
			Communicator.RemoteEvents.StoryAction:FireAllClients("ToggleNightVision", false)
			task.wait(1.5)
			Sounds:Play("ElevatorDing")
			task.wait(1)
			Sounds.ElevatorMoving:Play()
			
			local floorScreen = Misc.ElevatorFloorSelector2.Screen.SurfaceGui
			for i = 7, 9 do
				task.wait(2)
				floorScreen.TextLabel.Text = tostring(i)
			end
			
			Sounds:Play("ElevatorDing")
			Sounds.ElevatorMoving:Stop()
			
			task.wait(2)
			local secondElevatorDoors = Misc.SecondElevatorDoors
			Tweens.Tween(secondElevatorDoors.LeftElevatorDoor.Main, "CFrame",
				secondElevatorDoors.LeftElevatorDoor:GetAttribute("AlmostOpenCFrame"), 1,
				Enum.EasingStyle.Back, Enum.EasingDirection.Out
			)
			Tweens.Tween(secondElevatorDoors.RightElevatorDoor.Main, "CFrame",
				secondElevatorDoors.RightElevatorDoor:GetAttribute("AlmostOpenCFrame"), 1,
				Enum.EasingStyle.Back, Enum.EasingDirection.Out
			)
			task.wait(2)
			
			
			PlaySoundWithSubtitles("OpenElevatorDoor")
			task.wait(Sounds["OpenElevatorDoor"].TimeLength)
			task.wait(1)
			secondElevatorDoors.Interactable:SetAttribute("Visible", true)
			Communicator.RemoteEvents.StoryAction:FireAllClients("OpenElevatorDoors")
		end
	},
	
	OpenedElevatorDoors = {
		func = function(player: Player, puzzle: Model)
			
			local secondElevatorDoors = Misc.SecondElevatorDoors
			Tweens.Tween(secondElevatorDoors.LeftElevatorDoor.Main, "CFrame",
				secondElevatorDoors.LeftElevatorDoor:GetAttribute("OpenCFrame"), 1,
				Enum.EasingStyle.Back, Enum.EasingDirection.Out
			)
			Tweens.Tween(secondElevatorDoors.RightElevatorDoor.Main, "CFrame",
				secondElevatorDoors.RightElevatorDoor:GetAttribute("OpenCFrame"), 1,
				Enum.EasingStyle.Back, Enum.EasingDirection.Out
			)
			secondElevatorDoors.Interactable:SetAttribute("Visible", false)
			secondElevatorDoors.DoorBlocker.CanCollide = false
			
			task.wait(2)
			PlaySoundWithSubtitles("KeypadRoomHint")
			task.wait(Sounds["KeypadRoomHint"].TimeLength)
			
			for i, part in Puzzles.MovableObjects:GetChildren() do
				if string.find(part.Name, "AfterElevatorDoor") then
					part.Interactable:SetAttribute("Visible", true)
				end

			end
			
			local generatedCorrectCode = tostring(math.random(1000, 9999))
			Puzzles.CodePuzzles.CodePuzzle.Configuration:SetAttribute("GeneratedCode", generatedCorrectCode)
			
			local pickedi = math.random(1, 4)
			for i, part in Misc.PossibleCodes:GetChildren() do
				if pickedi== i then
					part.SurfaceGui.TextLabel.Text = generatedCorrectCode
				else
					local randomCode = tostring(math.random(1000, 9999))
					part.SurfaceGui.TextLabel.Text = randomCode
				end
				
				
			end
		end
	},
	
	BigLobbyRoomUnlocked = {
		func = function(player: Player, puzzle: Model)
			Puzzles.MovableObjects.BigLobbyRoom.Interactable:SetAttribute("Visible", true)
			
			local manual = Misc.BombManual
			local bomb = Puzzles.BombPuzzles.BombPuzzle
			
			manual.Interactable:SetAttribute("Visible", false)
			bomb.Interactable:SetAttribute("Visible", false)
			
			task.wait(3)
			
			PlaySoundWithSubtitles("BigLobbyRoom")
			task.wait(Sounds["BigLobbyRoom"].TimeLength)
			
			manual.Interactable:SetAttribute("Visible", true)
			bomb.Interactable:SetAttribute("Visible", true)
		end
	},
	
	BombDefused = {
		func = function(player: Player, puzzle: Model)
			Sounds.EmotionalEnding.Volume = 0
			Tweens.Tween(Sounds.EmotionalEnding, "Volume", 0.2, 15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			Sounds.EmotionalEnding:Play()
			
			PlaySoundWithSubtitles("Disarmed")
			task.wait(Sounds["Disarmed"].TimeLength)
			
			Communicator.RemoteEvents.StoryAction:FireAllClients("BombDefused")
			
		end
	},
	
	Chapter2Ended = {
		func = function(player: Player, puzzle: Model)
			for _, v in Players:GetChildren() do
				v:Kick("You have escaped the office! :)")
			end
			
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
	

end

return StoryServer
