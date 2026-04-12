local MovableObjects = {}

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Storages
local Modules = ReplicatedStorage.Modules

-- // Modules
local Communicator = require(Modules.Communicator)

-- // Classes
local Tweens = require(game.StarterPlayer.StarterPlayerScripts.Client.Tweens)
local Sounds = require(game.ServerScriptService.Server.Sounds)


local CustomActions = {
	["SmallOfficeDoor"] = function(player: Player, action: string, object: Model)
		if action ~= "Completed" then return end

		Sounds:PlayUnderInstance("DoorOpening", object.MovedObject.PrimaryPart, true)
	end,
	
	["BookShelf1"] = function(player: Player, action: string, object: Model)
		if action ~= "Completed" then return end
		Sounds:PlayUnderInstance("SlideBookShelf", object.MovedObject.PrimaryPart, true, {45, 55, 100})
	end,
	
	["Box"] = function(player: Player, action: string, object: Model)
		if action ~= "Completed" then return end
		Sounds:PlayUnderInstance("BoxMoved", object.MovedObject.PrimaryPart, true, {95, 105, 100})
	end,
	
	["StartBookshelf"] = function(player: Player, action: string, object: Model)
		if action ~= "Completed" then return end
		Sounds:PlayUnderInstance("SlideBookShelf", object.MovedObject.PrimaryPart, true, {45, 55, 100})

		if object.Configuration:GetAttribute("alpha") == 1 then
			Communicator.BindableEvents.StoryAction:Fire(player, "StartBookshelfMoved", object)
		end
	end,
	
	["ServerBox1"] = function(player: Player, action: string, object: Model)
		if action ~= "Completed" then return end
		Sounds:PlayUnderInstance("BoxMoved", object.MovedObject.PrimaryPart, true, {95, 105, 100})
	end,
	
	["ServerBox2"] = function(player: Player, action: string, object: Model)
		if action ~= "Completed" then return end
		Sounds:PlayUnderInstance("BoxMoved", object.MovedObject.PrimaryPart, true, {95, 105, 100})
	end,
	
	["ServerDoor"] = function(player: Player, action: string, object: Model)
		if action ~= "Completed" then return end

		if object.Configuration:GetAttribute("increment") == 0 then
			Sounds:PlayUnderInstance("LockedDoor", object.MovedObject.PrimaryPart, true)
			Communicator.BindableEvents.StoryAction:Fire(player, "AttemptedToOpenServerDoor", object)
			object.Interactable:SetAttribute("Visible", false)
			object.Configuration:SetAttribute("increment", 1)
			object.Configuration:SetAttribute("endAtAlpha", true)
		else
			Sounds:PlayUnderInstance("DoorOpening", object.MovedObject.PrimaryPart, true)
			Communicator.BindableEvents.StoryAction:Fire(player, "ServerRoomOpened", object)
		end
	end,
	
	["KitchenDoor"] = function(player: Player, action: string, object: Model)
		if action ~= "Completed" then return end

		Sounds:PlayUnderInstance("DoorOpening", object.MovedObject.PrimaryPart, true)
		Communicator.BindableEvents.StoryAction:Fire(player, "KitchenDoorOpened", object)
	end,
	
	
	["ConferenceBox"] = function(player: Player, action: string, object: Model)
		if action ~= "Completed" then return end
		Sounds:PlayUnderInstance("BoxMoved", object.MovedObject.PrimaryPart, true, {95, 105, 100})
		Communicator.BindableEvents.StoryAction:Fire(player, "ConferenceBoxMoved", object)
	end,
	
	["ConferenceRoomDoor"] = function(player: Player, action: string, object: Model)
		if action ~= "Completed" then return end
		
		Sounds:PlayUnderInstance("DoorOpening", object.MovedObject.PrimaryPart, true)
		Communicator.BindableEvents.StoryAction:Fire(player, "ConferenceRoomOpened", object)
	end,
	
	["ArchiveRoomDoor"] = function(player: Player, action: string, object: Model)
		if action ~= "Completed" then return end
		
		if not object:GetAttribute("checkedDoor") and object.Configuration:GetAttribute("increment") == 0 then
			object:SetAttribute("checkedDoor", true)
			Sounds:PlayUnderInstance("LockedDoor", object.MovedObject.PrimaryPart, true)
			Communicator.BindableEvents.StoryAction:Fire(player, "AttemptedOpeningArchiveDoor", object)
			return
		end
		
		if object.Configuration:GetAttribute("increment") == 0 then
			Sounds:PlayUnderInstance("LockedDoor", object.MovedObject.PrimaryPart, true)
			return
		end
		
		Sounds:PlayUnderInstance("DoorOpening", object.MovedObject.PrimaryPart, true)
		Communicator.BindableEvents.StoryAction:Fire(player, "ArchiveDoorOpened", object)
	end,
}


function MovableObjects.OnPuzzleAction(player: Player, action: string, ...)
	local object = ...
	
	if action == "Completed" then
		if MovableObjects.Debounces[object] then return end
		MovableObjects.Debounces[object] = true
		task.delay(1, function()
			MovableObjects.Debounces[object] = nil
		end)
		
		local increment = object.Configuration:GetAttribute("increment")
		local alpha = object.Configuration:GetAttribute("alpha")
		local endAtAlpha = object.Configuration:GetAttribute("endAtAlpha")
		
		local nextAlpha
		if increment >= 0 then
			nextAlpha = math.min(1, alpha + increment)
			if nextAlpha == 1 then
				object.Configuration:SetAttribute("increment", -increment)
			end
		else
			nextAlpha = math.max(0, alpha + increment)
			if nextAlpha == 0 then
				object.Configuration:SetAttribute("increment", -increment)
			end
		end
		
		increment = object.Configuration:GetAttribute("increment")
		
		if nextAlpha == 1 and endAtAlpha then
			object.Interactable:SetAttribute("Visible", false)
		end
		object.Configuration:SetAttribute("alpha", nextAlpha)
		
		Tweens.Tween(object.MovedObject.PrimaryPart, "CFrame", object.Position1.CFrame:Lerp(object.Position2.CFrame, nextAlpha), 1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	end
	
	if CustomActions[object.Name] then
		CustomActions[object.Name](player, action, ...)
	end
end


function MovableObjects.StartPuzzle(puzzle: Model)
	
end


function MovableObjects:Init()
	MovableObjects.Debounces = {}
end

return MovableObjects
