local PlayerHandler = {}

-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Storages
local Modules = ReplicatedStorage.Modules

-- // Modules
local Communicator = require(Modules.Communicator)

function OnPlayerAdded(player: Player)
	player:SetAttribute("PlayerIndex", "P2")
	PlayerHandler.TotalPlayers += 1
	
	if PlayerHandler.TotalPlayers == 1 then
		Communicator.RemoteEvents.PlayerSelectionAction:FireClient(player, "wait")
		
		task.spawn(function()
			while PlayerHandler.TotalPlayers == 1 do
				task.wait()
			end
			
			Communicator.RemoteEvents.PlayerSelectionAction:FireClient(player, "choose")
		end)
		
		
	elseif PlayerHandler.TotalPlayers == 2 then
		task.wait(3)
		Communicator.RemoteEvents.PlayerSelectionAction:FireClient(player, "choose")
		
	end
end


function OnPlayerSelectionAction(player: Player, action: "choseP1" | "choseP2")
	if typeof(action) ~= "string" then return end
	
	if action == "choseP1" then
		player:SetAttribute("PlayerIndex", "P1")
		PlayerHandler.P1 = player
		Communicator.RemoteEvents.PlayerSelectionAction:FireAllClients("otherPlayerChose", {role = "P1", player = player})
		
		if PlayerHandler.P1 and PlayerHandler.P2 then
			Communicator.RemoteEvents.PlayerSelectionAction:FireAllClients("bothPlayersChose")
		end
	elseif action == "choseP2" then
		player:SetAttribute("PlayerIndex", "P2")
		PlayerHandler.P2 = player
		Communicator.RemoteEvents.PlayerSelectionAction:FireAllClients("otherPlayerChose", {role = "P2", player = player})
		
		if PlayerHandler.P1 and PlayerHandler.P2 then
			Communicator.RemoteEvents.PlayerSelectionAction:FireAllClients("bothPlayersChose")
		end
	end
end


function PlayerHandler:Init()
	PlayerHandler.P1 = nil :: Player
	PlayerHandler.P2 = nil :: Player
	PlayerHandler.TotalPlayers = 0
	
	Players.PlayerAdded:Connect(OnPlayerAdded)
	Communicator.RemoteEvents.PlayerSelectionAction.OnServerEvent:Connect(OnPlayerSelectionAction)
end

return PlayerHandler
