local Interactables = {}

-- // Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- // Storages
local Objects = ReplicatedStorage.Objects
local Highlights = Objects.Highlights

-- // Prefabs
local InteractableHighlight = Highlights.InteractableHighlight

-- // Local Player
local LocalPlayer = Players.LocalPlayer

-- // UI
local PlayerGui = LocalPlayer.PlayerGui
local Billboards = PlayerGui.Billboards
local InteractableBillboard = Billboards.InteractableBillboard

-- // Workspace
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- // Classes
local Tweens = require(script.Parent.Parent.Tweens)
local Sounds = require(script.Parent.Parent.Sounds)

-- // Constants
local MAX_TRIGGER_DISTANCE = 10

function GetClosestInteractable(originPosition: Vector3)
	local closest: BasePart | Model
	local minDistance = MAX_TRIGGER_DISTANCE
	
	for _, object in CollectionService:GetTagged("Interactable") do
		local distance
		if object:IsA("BasePart") then
			distance = (object.Position - originPosition).Magnitude
		elseif object:IsA("Model") then
			distance = (object:GetPivot().Position - originPosition).Magnitude
		end
		
		local maxDistance = object:GetAttribute("maxDistance") or MAX_TRIGGER_DISTANCE
		if distance < minDistance and distance < maxDistance then
			minDistance = distance
			closest = object
		end
	end
	
	return closest
end

function GetCharacterOriginPosition()
	return (Character:GetPivot() * CFrame.new(0, 0, -3)).Position
end




function HandleInteractableAnimations()
	local frame = InteractableBillboard.Frame.Frame :: Frame
	local function cancelTweens()
		Tweens.CancelTweens(frame)
		Tweens.CancelTweens(frame.Parent.Glow)
		Tweens.CancelTweens(frame.ActionText)
		Tweens.CancelTweens(frame.ActionText.UIStroke)
		Tweens.CancelTweens(frame.Interact)
		Tweens.CancelTweens(frame.KeybindFrame)
		Tweens.CancelTweens(frame.KeybindFrame.TextLabel)
		Tweens.CancelTweens(frame.KeybindFrame.TextLabel.UIStroke)
		Tweens.CancelTweens(frame.Parent)
		Tweens.CancelTweens(frame.Parent.CoverFrame)
	end
	
	local defaultKeybindName = "E"
	local defaultActionText = "[...]"
	local defaultInteractText = "Interact"
	
	local function ToggleInteractableBillboard(toggle: boolean, adornee: BasePart | Model)
		cancelTweens()
		
		if toggle == true then
			
			frame.KeybindFrame.TextLabel.Text = adornee:GetAttribute("Keybind") or defaultKeybindName
			frame.ActionText.Text = adornee:GetAttribute("ActionText") or defaultActionText
			frame.Interact.Text = adornee:GetAttribute("InteractText") or defaultInteractText
			
			frame.BackgroundTransparency = 1
			frame.Parent.Glow.ImageTransparency = 1
			frame.ActionText.TextTransparency = 1
			frame.ActionText.UIStroke.Transparency = 1
			frame.Interact.TextTransparency = 1
			frame.Interact.UIStroke.Transparency = 1
			
			frame.KeybindFrame.BackgroundTransparency = 1
			frame.KeybindFrame.TextLabel.TextTransparency = 1
			frame.KeybindFrame.Glow.ImageTransparency = 1
			frame.KeybindFrame.TextLabel.UIStroke.Transparency = 1
			
			frame.Parent.CoverFrame.BackgroundTransparency = 1
			
			frame.Parent.Rotation = 35
			frame.Parent.Position = UDim2.fromScale(0.5, 0.7)
			frame.Parent.Size = UDim2.fromScale(0.5, 0.2)
			
			local tt = 0.2
			Tweens.Tween(frame, "BackgroundTransparency", 0.3, tt, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			Tweens.Tween(frame.Parent.Glow, "ImageTransparency", 0.6, tt, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			Tweens.Tween(frame.ActionText, "TextTransparency", 0, tt, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			Tweens.Tween(frame.ActionText.UIStroke, "Transparency", 0, tt, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			Tweens.Tween(frame.Interact, "TextTransparency", 0, tt, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			Tweens.Tween(frame.Interact.UIStroke, "Transparency", 0, tt, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			Tweens.Tween(frame.KeybindFrame, "BackgroundTransparency", 0, tt, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			Tweens.Tween(frame.KeybindFrame.Glow, "ImageTransparency", 0.6, tt, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			Tweens.Tween(frame.KeybindFrame.TextLabel, "TextTransparency", 0, tt, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			Tweens.Tween(frame.KeybindFrame.TextLabel.UIStroke, "Transparency", 0, tt, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			Tweens.Tween(frame.Parent, "Rotation", 0, tt, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			Tweens.Tween(frame.Parent, "Position", UDim2.fromScale(0.5, 0.5), tt, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			Tweens.Tween(frame.Parent, "Size", UDim2.fromScale(0.85, 0.5), tt, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

			InteractableHighlight.Enabled = true
			InteractableBillboard.Enabled = true
			InteractableBillboard.Adornee = adornee
			InteractableHighlight.Adornee = adornee
		else
			InteractableBillboard.Adornee = nil
			InteractableHighlight.Adornee = nil
			InteractableHighlight.Enabled = false
			InteractableBillboard.Enabled = false
		end
	end
	
	RunService.Heartbeat:Connect(function()
		local originPosition = GetCharacterOriginPosition()
		local closestInteractable = GetClosestInteractable(originPosition)

		local visibleChanged = closestInteractable == Interactables.lastInteractable
		and closestInteractable ~= nil
		and (closestInteractable:GetAttribute("Visible") ~= Interactables.lastVisible)

		if closestInteractable == Interactables.lastInteractable and not visibleChanged then
			return
		end

		local isVisible = closestInteractable ~= nil and closestInteractable:GetAttribute("Visible") ~= false

		if not isVisible then
			ToggleInteractableBillboard(false)
		else
			ToggleInteractableBillboard(true, closestInteractable)
		end

		Interactables.lastInteractable = closestInteractable
		Interactables.lastVisible = closestInteractable and closestInteractable:GetAttribute("Visible")
	end)
	

end


function HandleInteractableWrappers()
	
	-- // At selected keybind we run every function for every interactable of that keybind call.
	Interactables.WrapperKeybinds = {} :: { 
		[Enum.KeyCode]: {
			[BasePart | Model]: {
				() -> any
			}
		} 
	}
	
	local frame = InteractableBillboard.Frame
	local function cancelTweens()
		Tweens.CancelTweens(frame.CoverFrame)
	end
	
	local function toggleKeybindPressed(toggle: boolean)
		cancelTweens()
		if toggle == true then
			Tweens.Tween(frame.CoverFrame, "BackgroundTransparency", 0.6, 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			Tweens.Tween(frame, "Size", UDim2.fromScale(0.7, 0.4), 0.1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

		else
			Tweens.Tween(frame.CoverFrame, "BackgroundTransparency", 1, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			Tweens.Tween(frame, "Size", UDim2.fromScale(0.85, 0.5), 0.05, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		end
	end
	
	UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
		if gameProcessedEvent then return end
		if Interactables.WrapperKeybinds[input.KeyCode] == nil then return end
		
		for interactable, funcTable in Interactables.WrapperKeybinds[input.KeyCode] do
			local isVisible = interactable:GetAttribute("Visible") == true or interactable:GetAttribute("Visible") == nil
			if interactable == Interactables.lastInteractable and isVisible then
				task.spawn(toggleKeybindPressed, true)
				break
			end
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessedEvent: boolean)
		if gameProcessedEvent then return end
		if Interactables.WrapperKeybinds[input.KeyCode] == nil then return end

		for interactable, funcTable in Interactables.WrapperKeybinds[input.KeyCode] do
			local isVisible = interactable:GetAttribute("Visible") == true or interactable:GetAttribute("Visible") == nil
			if interactable == Interactables.lastInteractable and isVisible then
				task.spawn(toggleKeybindPressed, false)
				for _, func in funcTable do
					task.spawn(func)
				end
				break
			end
		end
	end)
	
end


function Interactables.OnInteractablePressed(interactable: BasePart | Model, keybind: Enum.KeyCode)
	if typeof(interactable) ~= "Instance" or not (interactable:IsA("BasePart") or interactable:IsA("Model")) then error("Passed a non-interactable.") end
	if typeof(keybind) ~= "EnumItem" then error("Passed an invalid keybind.") end

	local returned = {}
	local passedFunc: () -> any
	returned.isConnected = false

	function returned:Connect(func: () -> any)
		if typeof(func) ~= "function" then error("Wrapper requires a function to be passed.") end

		passedFunc = func
		returned.isConnected = true

		Interactables.WrapperKeybinds[keybind] = Interactables.WrapperKeybinds[keybind] or {}
		Interactables.WrapperKeybinds[keybind][interactable] = Interactables.WrapperKeybinds[keybind][interactable] or {}
		table.insert(Interactables.WrapperKeybinds[keybind][interactable], func)

		return returned
	end

	function returned:Disconnect()
		if Interactables.WrapperKeybinds[keybind] == nil or Interactables.WrapperKeybinds[keybind][interactable] == nil then warn("Connection needs to exist.") return end

		local functionIndex = table.find(Interactables.WrapperKeybinds[keybind][interactable], passedFunc)
		if functionIndex == nil then warn("Function not found.") return end
		table.remove(Interactables.WrapperKeybinds[keybind][interactable], functionIndex)

		if #Interactables.WrapperKeybinds[keybind][interactable] == 0 then
			Interactables.WrapperKeybinds[keybind][interactable] = nil
		end

		if next(Interactables.WrapperKeybinds[keybind]) == nil then
			Interactables.WrapperKeybinds[keybind] = nil
		end

		passedFunc = nil
		returned.isConnected = false
	end

	return returned
end



function Interactables:Init()
	HandleInteractableAnimations()
	HandleInteractableWrappers()

end

return Interactables
