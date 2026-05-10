local Tweens = {}

-- Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- List of supported transparency properties for UI
local transparencyProps = {
	"BackgroundTransparency",
	"TextTransparency",
	"TextStrokeTransparency",
	"ImageTransparency",
	"ScrollBarImageTransparency"
}

function Tweens.Tween(instance, property, finalProperty, tweenTime, easingStyle, easingDirection)
	local tweenInfo = TweenInfo.new(tweenTime, easingStyle, easingDirection)
	local propertyTable = {[property] = finalProperty}
	local tween = TweenService:Create(instance, tweenInfo, propertyTable)
	tween:Play()

	Tweens.ActiveTweens = Tweens.ActiveTweens or {}
	Tweens.ActiveTweens[instance] = Tweens.ActiveTweens[instance] or {}
	table.insert(Tweens.ActiveTweens[instance], tween)

	tween.Completed:Connect(function()
		if not Tweens.ActiveTweens or not Tweens.ActiveTweens[instance] then return end
		local index = table.find(Tweens.ActiveTweens[instance], tween)
		if index then
			table.remove(Tweens.ActiveTweens[instance], index)
		end
	end)

	return tween
end

function Tweens.CancelTweens(instance)
	if Tweens.ActiveTweens and Tweens.ActiveTweens[instance] then
		for _, tween in Tweens.ActiveTweens[instance] do
			tween:Cancel()
		end
		Tweens.ActiveTweens[instance] = nil
	end
end

local TweenService = game:GetService("TweenService")

function Tweens.TweenBeamTransparency(beam, targetTransparency, duration, easingStyle, easingDirection)
	local startTransparency = beam.Transparency.Keypoints[1].Value
	local valueObj = Instance.new("NumberValue")
	valueObj.Value = startTransparency

	local tween = TweenService:Create(valueObj, TweenInfo.new(duration, easingStyle, easingDirection), {Value = targetTransparency})

	local connection
	connection = RunService.RenderStepped:Connect(function()
		beam.Transparency = NumberSequence.new(valueObj.Value)
	end)

	tween.Completed:Connect(function()
		connection:Disconnect()
		valueObj:Destroy()
	end)

	tween:Play()
end

function Tweens.TweenChildren(instance, property, finalProperty, tweenTime, easingStyle, easingDirection)
	for _, child in ipairs(instance:GetChildren()) do
		if child[property] ~= nil then
			local tweenInfo = TweenInfo.new(tweenTime, easingStyle, easingDirection)
			local propertyTable = {[property] = finalProperty}

			local tween = TweenService:Create(child, tweenInfo, propertyTable)
			tween:Play()
		end
	end
end

function hasProperty(object, propertyName)
	local success, _ = pcall(function() 
		object[propertyName] = object[propertyName]
	end)
	return success
end


function Tweens.TweenAllTransparency(root, finalValue, tweenTime, easingStyle, easingDirection, ignoreMain)
	local objects = {}
	local tweens = {}

	local function collectObjects(obj)
		if not (ignoreMain and obj == root) then
			for _, prop in ipairs(transparencyProps) do
				if hasProperty(obj, prop) ~= false then
					if obj:GetAttribute("Default_" .. prop) == nil then
						obj:SetAttribute("Default_" .. prop, obj[prop])
					end
					table.insert(objects, {instance = obj, prop = prop})
				end
			end
		end
		for _, child in ipairs(obj:GetDescendants()) do
			collectObjects(child)
		end
	end
	collectObjects(root)

	for _, data in ipairs(objects) do
		local obj, prop = data.instance, data.prop
		local targetValue = (finalValue == -1)
			and (obj:GetAttribute("Default_" .. prop) or 0)
			or finalValue

		local tweenInfo = TweenInfo.new(tweenTime, easingStyle, easingDirection)
		local propertyTable = {[prop] = targetValue}

		local tween = TweenService:Create(obj, tweenInfo, propertyTable)
		tween:Play()

		table.insert(tweens, tween)
	end

	return tweens
end

function Tweens.TweenScale(model: Model, startScale : number, endScale : number, tweenTime, easingStyle, easingDirection)
	local elapsed = 0
	local scale = 0
	local tweenConnection

	local function onStep(deltaTime : number)
		elapsed = math.min(elapsed + deltaTime, tweenTime)

		local alpha = TweenService:GetValue(elapsed / tweenTime, easingStyle, easingDirection)

		scale = startScale + alpha * (endScale - startScale)

		model:ScaleTo(scale)

		if elapsed == tweenTime then
			tweenConnection:Disconnect()
		end
	end

	tweenConnection = RunService.Heartbeat:Connect(onStep)
end


function Tweens.CancelTweensFromTable(t: {Tween})
	for i, tween: Tween in t do
		if typeof(tween) ~= "Tween" then continue end
		tween:Cancel()
		t[i] = nil
	end
end

function Tweens.RecordDescendantsDefaultTransparencies(object: Instance)
	local propertyNames =  {
		Transparency = true,
		BackgroundTransparency = true,
		ImageTransparency = true
	}

	for _, descendant in object:GetDescendants() do
		for name, _ in propertyNames do
			if hasProperty(descendant, name) then
				descendant:SetAttribute("Default" .. name, descendant[name])
			end
		end
	end
end


function Tweens.TweenDescendantsToDefaultTransparencies(object, t, es, ed)
	local propertyNames =  {
		Transparency = true,
		BackgroundTransparency = true,
		ImageTransparency = true
	}

	for _, descendant in object:GetDescendants() do
		if descendant:IsA("UIGradient") then continue end

		for name, _ in propertyNames do
			local defaultValue = descendant:GetAttribute("Default" .. name)
			if defaultValue then
				TweenService:Create(descendant, TweenInfo.new(t, es, ed), {[name] = defaultValue}):Play()
			end
		end
	end
end


function Tweens.TweenDescendantsToTransparency(object, value, t, es, ed)
	local propertyNames =  {
		Transparency = true,
		BackgroundTransparency = true,
		ImageTransparency = true
	}

	for _, descendant in object:GetDescendants() do
		if descendant:IsA("UIGradient") then continue end

		for name, _ in propertyNames do
			local defaultValue = descendant:GetAttribute("Default" .. name)
			if defaultValue then
				TweenService:Create(descendant, TweenInfo.new(t, es, ed), {[name] = value}):Play()
			end
		end
	end
end


return Tweens
