local CustomChat = {}

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Storages
local Modules = ReplicatedStorage.Modules

-- // Modules
local Communicator = require(Modules.Communicator)

-- // Classes
local TextFilter = require(script.TextFilter)

function OnMessageReceived(player: Player, message: string)
	if typeof(message) ~= "string" or #message == 0 then return end
	
	-- // Filter message in case of bad words, so we don't get the game banned.
	local filteredMessage = TextFilter.filterForBroadcast(message, player.UserId)
	
	local playerIndex = player:GetAttribute("PlayerIndex") :: "P1" | "P2" or "P1"
	Communicator.RemoteEvents.CustomChatMessage:FireAllClients(playerIndex, filteredMessage)
end

function CustomChat:Init()
	Communicator.RemoteEvents.CustomChatMessage.OnServerEvent:Connect(OnMessageReceived)
end


return CustomChat
