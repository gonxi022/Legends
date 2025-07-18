-- Mega OP Collector para Legends of Speed (Checkpoints + Gemas)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local tpEnabled = false

-- Cache de checkpoints y gemas
local checkpoints = {}
local gems = {}

-- Función para actualizar caches
local function updateCaches()
    checkpoints = {}
    gems = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local lname = obj.Name:lower()
            if lname:find("checkpoint") or lname:find("step") then
                table.insert(checkpoints, obj)
            elseif lname:find("gem") then
                table.insert(gems, obj)
            end
        end
    end
end

-- Teletransporta a una lista de partes sin pausas perceptibles
local function teleportFast(partsList)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, part in ipairs(partsList) do
        pcall(function()
            hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
        end)
        task.wait(0.005) -- casi instantáneo, ajusta si detecta rubberband
    end
end

-- Loop principal que se ejecuta en Heartbeat
RunService.Heartbeat:Connect(function()
    if tpEnabled then
        pcall(function()
            updateCaches()
            teleportFast(checkpoints)
            teleportFast(gems)
        end)
    end
end)

-- UI para activar/desactivar
local function createUI()
    local oldGui = PlayerGui:FindFirstChild("LegendSpeedOPUI")
    if oldGui then oldGui:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "LegendSpeedOPUI"
    gui.ResetOnSpawn = false
    gui.Parent = PlayerGui

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 280, 0, 60)
    btn.Position = UDim2.new(0.03, 0, 0.78, 0)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextScaled = true
    btn.BorderSizePixel = 0
    btn.BackgroundTransparency = 0.15
    btn.Text = "⚡ LEGEND SPEED FARM OFF"
    btn.Parent = gui

    btn.MouseButton1Click:Connect(function()
        tpEnabled = not tpEnabled
        btn.Text = tpEnabled and "⚡ LEGEND SPEED FARM ON" or "⚡ LEGEND SPEED FARM OFF"
    end)
    btn.TouchTap:Connect(btn.MouseButton1Click)

    Players.LocalPlayer.CharacterAdded:Connect(function()
        wait(1)
        createUI()
    end)
end

createUI()
