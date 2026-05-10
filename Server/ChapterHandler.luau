local ChapterHandler = {}

-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Storages
local Modules = ReplicatedStorage.Modules

-- // Modules
local Communicator = require(Modules.Communicator)

-- // Constants
local PlayerCount = 2

function OnPlayerAdded(player: Player)
	
end


function PlayersFullyLoaded()
	Communicator.RemoteEvents.ChapterSelectionAction:FireAllClients("Start")
end


function BothVoted()
	if ChapterHandler.VotedChapters.Chapter1 == 1 and ChapterHandler.VotedChapters.Chapter2 == 1 then
		-- // Tie, pick randomly
		local randomChapter = math.random(1, 2)
		Communicator.RemoteEvents.ChapterSelectionAction:FireAllClients("VotingFinished", randomChapter, true)
		ChapterHandler.ChapterValue.Value = randomChapter
	elseif ChapterHandler.VotedChapters.Chapter1 and ChapterHandler.VotedChapters.Chapter1 >= PlayerCount then
		-- // Chapter 1
		Communicator.RemoteEvents.ChapterSelectionAction:FireAllClients("VotingFinished", 1)
		ChapterHandler.ChapterValue.Value = 1
	elseif ChapterHandler.VotedChapters.Chapter2 and ChapterHandler.VotedChapters.Chapter2 >= PlayerCount then
		-- // Chapter 2
		Communicator.RemoteEvents.ChapterSelectionAction:FireAllClients("VotingFinished", 2)
		ChapterHandler.ChapterValue.Value = 2
	end
	
end


function OnChapterSelectionAction(player: Player, action: string, ...)
	if action == "ScreenLoaded" then
		ChapterHandler.LoadedPlayers += 1
		
		if ChapterHandler.LoadedPlayers >= PlayerCount then
			PlayersFullyLoaded()
		end
		
	elseif action == "VotedChapter" then
		local chapterName = ...
		Communicator.RemoteEvents.ChapterSelectionAction:FireAllClients("Voted", player.UserId, chapterName)
		ChapterHandler.TotalVoters += 1
		
		
		if ChapterHandler.VotedChapters[chapterName] then
			ChapterHandler.VotedChapters[chapterName] += 1
		else
			ChapterHandler.VotedChapters[chapterName] = 1
		end
		
		if ChapterHandler.TotalVoters >= PlayerCount then
			BothVoted()
		end
	end
end

function ChapterHandler:Init()
	ChapterHandler.ChapterValue = Instance.new("IntValue")
	ChapterHandler.ChapterValue.Value = 0
	ChapterHandler.ChapterValue.Name = "Chapter"
	ChapterHandler.ChapterValue.Parent = workspace
	
	ChapterHandler.LoadedPlayers = 0
	ChapterHandler.TotalVoters = 0
	ChapterHandler.VotedChapters = {}
	Players.PlayerAdded:Connect(OnPlayerAdded)
	Communicator.RemoteEvents.ChapterSelectionAction.OnServerEvent:Connect(OnChapterSelectionAction)
end

return ChapterHandler
