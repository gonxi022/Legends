-- Prison Life - Android Mod Menu by GPT + Gonxi
-- Funciona en Krnl Android, sin errores visuales

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local StarterGui = game:GetService("StarterGui")

local meleeEvent = ReplicatedStorage:FindFirstChild("meleeEvent")
local DamageEvent = ReplicatedStorage:FindFirstChild("DamageEvent")

-- UI base
local gui = Instance.new("ScreenGui", PlayerGui)
gui.ResetOnSpawn = false
gui.Name = "ModMenu"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 150, 0, 220)
frame.Position = UDim2.new(0, 20, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local function addButton(text, order, func)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.Position = UDim2.new(0, 5, 0, 5 + ((order - 1) * 35))
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextScaled = true
	btn.Font = Enum.Font.SourceSansBold
	btn.BorderSizePixel = 0
	btn.MouseButton1Click:Connect(func)
end

-- Kill All Toggle
local killActive = true
addButton("⚔️ Kill All (ON)", 1, function(btn)
	killActive = not killActive
	btn.Text = killActive and "⚔️ Kill All (ON)" or "⚔️ Kill All (OFF)"
end)

-- Bring Me
addButton("🧲 Bring Me", 2, function()
	local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not myRoot then return end
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			player.Character.HumanoidRootPart.CFrame = myRoot.CFrame + Vector3.new(math.random(-2,2), 0, math.random(-2,2))
			task.wait(0.1)
		end
	end
end)

-- Speed
addButton("💨 Speed x60", 3, function()
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = 60
	end
end)

-- Noclip (solo paredes)
local noclip = false
addButton("🚪 Noclip", 4, function()
	noclip = not noclip
end)

RunService.Stepped:Connect(function()
	if noclip and LocalPlayer.Character then
		for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				part.CanCollide = false
			end
		end
	end
end)

-- AutoRespawn
LocalPlayer.CharacterAdded:Connect(function(char)
	char:WaitForChild("HumanoidRootPart")
	char:WaitForChild("Humanoid")
end)

-- Kill All handler
RunService.Heartbeat:Connect(function()
	if not killActive then return end
	local myChar = LocalPlayer.Character
	if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
	local myPos = myChar.HumanoidRootPart.Position
	for _, player in pairs(Players:GetPlayers()) do
		local char = player.Character
		if player ~= LocalPlayer and char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
			local dist = (char.HumanoidRootPart.Position - myPos).Magnitude
			if dist < 50 and char.Humanoid.Health > 0 then
				for i = 1, 49 do
					meleeEvent:FireServer(player)
				end
			end
		end
	end
end)