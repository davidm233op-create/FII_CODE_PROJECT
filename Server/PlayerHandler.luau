local PlayerHandler = {}

-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Storages
local Modules = ReplicatedStorage.Modules

-- // Modules
local Communicator = require(Modules.Communicator)

-- // Workspace
local ChapterValue = workspace:WaitForChild("Chapter")

function OnPlayerAdded(player: Player)
	player:SetAttribute("PlayerIndex", "P2")
	PlayerHandler.TotalPlayers += 1

	if PlayerHandler.TotalPlayers == 1 then
		player:SetAttribute("PlayerIndex", "P1")
	elseif PlayerHandler.TotalPlayers == 2 then
		player:SetAttribute("PlayerIndex", "P2")
	end
	
	while ChapterValue.Value == 0 do
		task.wait(1)
	end
	
	task.wait(1.5)

	Communicator.RemoteEvents.PlayerSelectionAction:FireClient(player, "choose")
end


function OnPlayerSelectionAction(player: Player, action: "choseP1" | "choseP2")
	if typeof(action) ~= "string" then return end
	
	if action == "choseP1" then
		player:SetAttribute("PlayerIndex", "P1")
		PlayerHandler.P1 = player
		Communicator.RemoteEvents.PlayerSelectionAction:FireAllClients("otherPlayerChose", {role = "P1", player = player})
		
		if PlayerHandler.P1 and PlayerHandler.P2 then
			Communicator.RemoteEvents.PlayerSelectionAction:FireAllClients("bothPlayersChose")
			
			if ChapterValue.Value == 1 then
				Communicator.BindableEvents.StoryAction:Fire(player, "StartStory")
			elseif ChapterValue.Value == 2 then
				Communicator.BindableEvents.StoryAction:Fire(player, "StartChapter2")
			end
			
		end
		
	elseif action == "choseP2" then
		player:SetAttribute("PlayerIndex", "P2")
		PlayerHandler.P2 = player
		Communicator.RemoteEvents.PlayerSelectionAction:FireAllClients("otherPlayerChose", {role = "P2", player = player})
		
		if PlayerHandler.P1 and PlayerHandler.P2 then
			Communicator.RemoteEvents.PlayerSelectionAction:FireAllClients("bothPlayersChose")
			
			if ChapterValue.Value == 1 then
				Communicator.BindableEvents.StoryAction:Fire(player, "StartStory")
			elseif ChapterValue.Value == 2 then
				Communicator.BindableEvents.StoryAction:Fire(player, "StartChapter2")
			end
			
		end
		
	end
end


function PlayerHandler:Init()
	task.spawn(function()
		PlayerHandler.P1 = nil :: Player
		PlayerHandler.P2 = nil :: Player
		PlayerHandler.TotalPlayers = 0

		Players.PlayerAdded:Connect(OnPlayerAdded)
		Players.PlayerRemoving:Connect(function()
			for _, player in Players:GetChildren() do
				player:Kick()
			end
		end)

		while ChapterValue.Value == 0 do
			task.wait(1)
		end
		
		print("Started")

		Communicator.RemoteEvents.PlayerSelectionAction.OnServerEvent:Connect(OnPlayerSelectionAction)
	end)
end

return PlayerHandler
