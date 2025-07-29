-- Prison Life - Kill All Mejorado (solo botón flotante)
-- TP a cada jugador + meleeEvent enviado 7 veces
-- Hecho para Android

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Crear GUI simple con botón Kill All
local gui = Instance.new("ScreenGui")
gui.Name = "KillAllTPGui"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local killButton = Instance.new("TextButton")
killButton.Name = "KillAllButton"
killButton.Size = UDim2.new(0, 160, 0, 50)
killButton.Position = UDim2.new(0, 20, 0, 60)
killButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
killButton.BorderSizePixel = 0
killButton.Text = "Kill All (TP + x7)"
killButton.TextColor3 = Color3.fromRGB(255, 255, 255)
killButton.TextScaled = true
killButton.Font = Enum.Font.SourceSansBold
killButton.Parent = gui

-- Teleportarse a un jugador
local function tpTo(position)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = CFrame.new(position + Vector3.new(0, 2, 0))
    end
end

-- Kill All con TP y 7 remotes
local function killAllImproved()
    local event = ReplicatedStorage:FindFirstChild("meleeEvent")
    if not event then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            tpTo(player.Character.HumanoidRootPart.Position)
            task.wait(0.1)
            for i = 1, 7 do
                event:FireServer(player)
                task.wait(0.05)
            end
        end
    end
end

killButton.MouseButton1Click:Connect(killAllImproved)