-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Storages
local Modules = ReplicatedStorage.Modules

local Communicator = require(Modules.Communicator)
Communicator:Init()

local UI = require(script.UI)
UI:Init()

local Sounds = require(script.Sounds)
Sounds:Init()

local Puzzles = require(script.Puzzles)
Puzzles:Init()

local StoryClient = require(script.StoryClient)
StoryClient:Init()
