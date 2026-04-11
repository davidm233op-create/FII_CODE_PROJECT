local UI = {}

--Services
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local CollectionService = game:GetService("CollectionService")

--Local Player
local LocalPlayer = Players.LocalPlayer

--UI
local PlayerGuiPrefab = ReplicatedFirst:WaitForChild("PlayerGui")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--Workspace
local CurrentCamera = workspace.CurrentCamera

--Classes
local Tweens = require(script.Parent.Tweens)
local Sounds = require(script.Parent.Sounds)
local Alerts

function getTypeOfPlayer()
	return LocalPlayer:GetAttribute("PlayerIndex")
end

function UI.alertPlayerTypeIncompatible()
		local playerIndex = getTypeOfPlayer()

		if playerIndex == "P1" then
			local sentences = {
				"Need more brain!",
				"IQ too low!",
				"Read a book first!",
				"Not enough wisdom!",
				"Need more smarts!",
				"Learn more maths first!",
			}

			Alerts:SendAlert(sentences[math.random(1, #sentences)], {textColor = Color3.fromRGB(255, 92, 92)})
		elseif playerIndex == "P2" then
			local sentences = {
				"You're too weak!",
				"Not strong enough!",
				"Need more muscles!",
				"Go to the gym first!",
				"Too smart for this!",
				"IQ too high for this!",
			}

			Alerts:SendAlert(sentences[math.random(1, #sentences)], {textColor = Color3.fromRGB(255, 92, 92)})
		end
	end

local Abbreviations = {"k", "M", "B", "T", "Qa", "Qn", "Sx", "Sp", "Oc", "N"} -- Number Abbreviations

local f = math.floor --- Rounds down for example 1.99 becomes 1
local l10 = math.log10 -- Checks how many digits are in a number

function UI.AbbreviateNumber(Number: number, Decimals)
	return f(((Number < 1 and Number) or f(Number) / 10 ^ (l10(Number) - l10(Number) % 3)) * 10 ^ (Decimals or 3)) / 10 ^ (Decimals or 3)..(Abbreviations[f(l10(Number) / 3)] or "")
end

function UI.removeSpaces(str: string): string
	return string.gsub(str, "%s+", "")
end

function UI.toNDecimals(number, n)
	return string.format("%." .. n .. "f", number)
end


function UI.ApplyButtonTweens(Hitbox: TextButton, Button, Offset, Time, ES, ED, rotationInfluence, rotatedItem, params: {}?)
	local DefaultSize = Button.Size
	local DefaultRotation: number = 0
	
	if rotatedItem and rotationInfluence then
		DefaultRotation = rotatedItem.Rotation
	end
	
	local connections = {}
	
	connections[1] = Hitbox.MouseEnter:Connect(function()
		Sounds:Play("ButtonOn")
		Tweens.Tween(Button, "Size", DefaultSize + UDim2.new(Offset,0,Offset,0), Time, ES, ED)
		if rotationInfluence and rotatedItem then
			Tweens.Tween(rotatedItem, "Rotation", DefaultRotation + rotationInfluence, Time, ES, ED)
		end
	end)

	connections[2] = Hitbox.MouseLeave:Connect(function()
		Tweens.Tween(Button, "Size", DefaultSize, Time, ES, ED)
		if rotationInfluence and rotatedItem then
			Tweens.Tween(rotatedItem, "Rotation", DefaultRotation, Time, ES, ED)
		end
	end)
	
	if params and params.onlyHover == true then return connections end

	connections[3] = Hitbox.MouseButton1Down:Connect(function()
		Tweens.Tween(Button, "Size", DefaultSize, Time, ES, ED)
	end)

	connections[4] = Hitbox.MouseButton1Up:Connect(function()
		Sounds:Play("ButtonUp")
		Tweens.Tween(Button, "Size", DefaultSize + UDim2.new(Offset,0,Offset,0), Time, ES, ED)
	end)
	
	return connections
end

function UI.ApplyStrokeButtonTweens(StrokeTable, newColor: Color3, Hitbox: TextButton, Button, Offset, Time, ES, ED, rotationInfluence, rotatedItem, newThickness)
	local DefaultSize = Button.Size
	local DefaultStrokeColor: Color3
	local DefaultThickness: number
	
	if StrokeTable[1] == nil then
		DefaultStrokeColor = Color3.fromRGB(0, 0, 0)
		DefaultThickness = 1
	else
		DefaultStrokeColor = StrokeTable[1].Color
		DefaultThickness = StrokeTable[1].Thickness
	end
	
	local DefaultRotation: number = 0

	if rotatedItem and rotationInfluence then
		DefaultRotation = rotatedItem.Rotation
	end
	
	local function tweenAllStrokes(Color)
		for _, Stroke in ipairs(StrokeTable) do
			Tweens.Tween(Stroke, "Color", Color, Time, ES, ED)
		end
	end

	Hitbox.MouseEnter:Connect(function()
		Sounds:Play("ButtonOn")
		Tweens.Tween(Button, "Size", DefaultSize + UDim2.new(Offset,0,Offset,0), Time, ES, ED)
		tweenAllStrokes(newColor)
		if rotationInfluence and rotatedItem then
			Tweens.Tween(rotatedItem, "Rotation", DefaultRotation + rotationInfluence, Time, ES, ED)
		end
		
		if newThickness then
			Tweens.Tween(StrokeTable[1], "Thickness", newThickness, Time, ES, ED)
		end
	end)

	Hitbox.MouseLeave:Connect(function()
		Tweens.Tween(Button, "Size", DefaultSize, Time, ES, ED)
		tweenAllStrokes(DefaultStrokeColor)
		if rotationInfluence and rotatedItem then
			Tweens.Tween(rotatedItem, "Rotation", DefaultRotation, Time, ES, ED)
		end
		
		if newThickness then
			Tweens.Tween(StrokeTable[1], "Thickness", DefaultThickness, Time, ES, ED)
		end
	end)

	Hitbox.MouseButton1Down:Connect(function()
		Tweens.Tween(Button, "Size", DefaultSize, Time, ES, ED)
	end)

	Hitbox.MouseButton1Up:Connect(function()
		Sounds:Play("ButtonUp")
		Tweens.Tween(Button, "Size", DefaultSize + UDim2.new(Offset,0,Offset,0), Time, ES, ED)
	end)
end

function UI.PopText(Text, RotationStrenght, SizeStrenght, OriginalSize, OriginalRotation, PopTime)
	--Rotation Strenght 0 -> 90
	--Size Strenght 0 -> 1
	
	PopTime = PopTime or 0.1

	task.spawn(function()
		if RotationStrenght == 0 then return end
		local ntable = {-1,1}
		local negativity = ntable[math.random(#ntable)]

		Tweens.Tween(Text, "Rotation", (OriginalRotation or 0) + negativity * RotationStrenght,PopTime,Enum.EasingStyle.Bounce,Enum.EasingDirection.Out)
		task.wait(PopTime)
		Tweens.Tween(Text, "Rotation", (OriginalRotation or 0) - negativity * RotationStrenght,PopTime,Enum.EasingStyle.Bounce,Enum.EasingDirection.Out)
		task.wait(PopTime)
		Tweens.Tween(Text,"Rotation", 0, 0.1,Enum.EasingStyle.Bounce,Enum.EasingDirection.Out)
	end)

	task.spawn(function()
		Tweens.Tween(Text, "Size", OriginalSize + UDim2.new(SizeStrenght,0,SizeStrenght,0),PopTime,Enum.EasingStyle.Bounce,Enum.EasingDirection.Out)
		task.wait(PopTime)
		Tweens.Tween(Text, "Size", OriginalSize,PopTime,Enum.EasingStyle.Bounce,Enum.EasingDirection.Out)
	end)

end

function UI:LoadPlayerGui()
	for _, Item in ipairs(PlayerGuiPrefab:GetChildren()) do
		Item.Parent = PlayerGui
	end
end


local function HandleUIStrokesDimensions()
	
	local STUDIO_SCREEN_SIZE = Vector2.new(1920, 1080)
	local instanceAddedSignal = nil


	local function GetAverage(vector: Vector2): number
		return (vector.X + vector.Y) / 2
	end

	local studioAverage = GetAverage(STUDIO_SCREEN_SIZE)
	local currentScreenAverage = GetAverage(CurrentCamera.ViewportSize)


	local function AdjustThickness(ui: UIStroke)
		local ratio = ui.Thickness / studioAverage
		local thickness = currentScreenAverage * ratio

		ui.Thickness = thickness
	end


	local function ModifyUiStrokes()
		currentScreenAverage = GetAverage(CurrentCamera.ViewportSize)  -- re-calculate the screen average as it could've changed

		for _, ui: UIStroke in ipairs(CollectionService:GetTagged('UIStroke')) do
			AdjustThickness(ui)
		end

		if instanceAddedSignal then
			instanceAddedSignal:Disconnect()
		end
		instanceAddedSignal = CollectionService:GetInstanceAddedSignal("UIStrorke"):Connect(AdjustThickness)
	end
	
	ModifyUiStrokes()
end

function UI:TweenFullTransparency(Object: Instance, transparency, t, easingStyle, easingDirection)
	if Object:IsA("Frame") then
		Tweens.Tween(Object, "BackgroundTransparency", transparency, t, easingStyle, easingDirection)
	elseif Object:IsA("UIStroke") then
		Tweens.Tween(Object, "Transparency", transparency, t, easingStyle, easingDirection)
	elseif Object:IsA("TextLabel") then
		Tweens.Tween(Object, "TextTransparency", transparency, t, easingStyle, easingDirection)
		Tweens.Tween(Object, "BackgroundTransparency", transparency, t, easingStyle, easingDirection)
	elseif Object:IsA("TextButton") then
		Tweens.Tween(Object, "TextTransparency", transparency, t, easingStyle, easingDirection)
		Tweens.Tween(Object, "BackgroundTransparency", transparency, t, easingStyle, easingDirection)
	elseif Object:IsA("ImageLabel") then
		Tweens.Tween(Object, "ImageTransparency", transparency, t, easingStyle, easingDirection)
		Tweens.Tween(Object, "BackgroundTransparency", transparency, t, easingStyle, easingDirection)
	end
	
	for _, v in ipairs(Object:GetDescendants()) do
		if v:IsA("Frame") then
			Tweens.Tween(v, "BackgroundTransparency", transparency, t, easingStyle, easingDirection)
		elseif v:IsA("UIStroke") then
			Tweens.Tween(v, "Transparency", transparency, t, easingStyle, easingDirection)
		elseif v:IsA("TextLabel") then
			Tweens.Tween(v, "TextTransparency", transparency, t, easingStyle, easingDirection)
			Tweens.Tween(v, "BackgroundTransparency", transparency, t, easingStyle, easingDirection)
		elseif v:IsA("TextButton") then
			Tweens.Tween(v, "TextTransparency", transparency, t, easingStyle, easingDirection)
			Tweens.Tween(v, "BackgroundTransparency", transparency, t, easingStyle, easingDirection)
		elseif v:IsA("ImageLabel") then
			Tweens.Tween(v, "ImageTransparency", transparency, t, easingStyle, easingDirection)
			Tweens.Tween(v, "BackgroundTransparency", transparency, t, easingStyle, easingDirection)
		end
	end
end




function UI:convertToHMS(Seconds)
	local Minutes = (Seconds - Seconds%60)/60
	Seconds = Seconds - Minutes*60
	local Hours = (Minutes - Minutes%60)/60
	Minutes = Minutes - Hours*60
	return string.format("%02i", Hours)..":"..string.format("%02i", Minutes)..":"..string.format("%02i", Seconds)
end

function UI:secondsToShortHMS(seconds)
	seconds = math.floor(seconds)

	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = seconds % 60

	return string.format("%dh %dm %ds", h, m, s)
end

function UI:secondsToSmartShortHMS(seconds)
	seconds = math.floor(seconds)

	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = seconds % 60

	if h > 0 then
		if m > 0 then
			return string.format("%dh %dm %ds", h, m, s)
		else
			return string.format("%dh %ds", h, s)
		end
	elseif m > 0 then
		return string.format("%dm %ds", m, s)
	else
		return string.format("%ds", s)
	end
end



function UI:convertToMSMS(seconds)
	local minutes = math.floor(seconds / 60) % 100
	local sec = math.floor(seconds % 60)
	local ms = math.floor((seconds * 1000) % 1000)
	local ms1 = math.floor(ms / 100)
	local ms2 = math.floor((ms % 100) / 10)

	return string.format("%02d:%02d:%d%d", minutes, sec, ms1, ms2)
end

function UI:convertToMS(seconds)
	local minutes = math.floor(seconds / 60)
	local remainingSeconds = seconds % 60
	return string.format("%02d:%02d", minutes, remainingSeconds)
end


function UI:comma_value(amount)
	local formatted = amount
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return formatted
end


function UI.InsertSpaces(str: string)
	return (str:gsub("(%l)(%u)", "%1 %2"))
end

function LoadClasses()
	local FlowingTextEffect = require(script.CustomEffects.FlowingTextEffect)
	FlowingTextEffect:Init()
	
	local CustomChat = require(script.CustomChat)
	CustomChat:Init()
	
	local Menus = require(script.Menus)
	Menus:Init()
	
	local Interactables = require(script.Interactables)
	Interactables:Init()
end

function UI:Init()
	UI:LoadPlayerGui()
	HandleUIStrokesDimensions()
	LoadClasses()
	
	Alerts = require(script.Alerts)
end





return UI

