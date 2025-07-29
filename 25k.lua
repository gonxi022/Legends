-- Prison Life - Script Full
-- By Gonxi + GPT - Kill All Global, Speed x70, Noclip, God Mode - Menú minimizable

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local meleeEvent = ReplicatedStorage:FindFirstChild("meleeEvent") or ReplicatedStorage:FindFirstChildWhichIsA("RemoteEvent", true)

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.ResetOnSpawn = false
screenGui.Name = "GonxiMenu"

-- Crear menú base
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 160, 0, 200)
frame.Position = UDim2.new(0, 20, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, 0, 0, 30)
toggle.Text = "≡ Menú"
toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.TextScaled = true

local open = true
toggle.MouseButton1Click:Connect(function()
    open = not open
    for _, child in pairs(frame:GetChildren()) do
        if child ~= toggle then
            child.Visible = open
        end
    end
end)

function crearBoton(texto, posicion, funcion)
    local boton = Instance.new("TextButton", frame)
    boton.Size = UDim2.new(1, -10, 0, 30)
    boton.Position = UDim2.new(0, 5, 0, posicion)
    boton.Text = texto
    boton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    boton.TextColor3 = Color3.new(1, 1, 1)
    boton.TextScaled = true
    boton.BorderSizePixel = 0
    boton.Visible = true
    boton.MouseButton1Click:Connect(funcion)
end

-- Variables y funciones

local godMode = false
local speedActive = false
local noclipActive = false
local meleeLoop = false

-- Kill All por distancia máxima (spoof)
function killAllGlobal()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                for i = 1, 49 do
                    meleeEvent:FireServer(player)
                end
            end
        end
    end
end

-- Mantener activo el Kill All
task.spawn(function()
    while true do
        if meleeLoop then
            killAllGlobal()
        end
        task.wait(0.5)
    end
end)

-- Activar God Mode
RunService.Heartbeat:Connect(function()
    if godMode and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        hum.Health = math.huge
        hum.MaxHealth = math.huge
    end
end)

-- Activar Speed x70
RunService.Stepped:Connect(function()
    if speedActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 70
    end
end)

-- Activar Noclip (solo paredes)
RunService.Stepped:Connect(function()
    if noclipActive and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == true and part.Name ~= "HumanoidRootPart" and part.Position.Y > 2 then
                part.CanCollide = false
            end
        end
    end
end)

-- Reaplicar al morir
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if speedActive then char:WaitForChild("Humanoid").WalkSpeed = 70 end
end)

-- Botones
crearBoton("⚔️ Kill All (Loop)", 40, function()
    meleeLoop = not meleeLoop
end)

crearBoton("🛡️ God Mode", 75, function()
    godMode = not godMode
end)

crearBoton("💨 Speed x70", 110, function()
    speedActive = not speedActive
end)

crearBoton("🚪 Noclip (paredes)", 145, function()
    noclipActive = not noclipActive
end)