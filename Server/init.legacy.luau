-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Storages
local Modules = ReplicatedStorage.Modules

local Communicator = require(Modules.Communicator)
Communicator:Init()

local Sounds = require(script.Sounds)
Sounds:Init()

local ChapterHandler = require(script.ChapterHandler)
ChapterHandler:Init()

local PlayerHandler = require(script.PlayerHandler)
PlayerHandler:Init()

local CustomChat = require(script.CustomChat)
CustomChat:Init()

local Puzzles = require(script.Puzzles)
Puzzles:Init()

local StoryServer = require(script.StoryServer)
StoryServer:Init()