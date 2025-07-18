-- Script Prison Life - Kill All excepto tú - Botón flotante interactivo para KRNL

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Función para matar a un jugador excepto tú
local function killPlayer(player)
    if player.Character and player.Character:FindFirstChild("Humanoid") and player ~= LocalPlayer then
        player.Character.Humanoid.Health = 0
    end
end

-- Función para matar a todos excepto tú
local function killAllExceptLocal()
    for _, player in pairs(Players:GetPlayers()) do
        killPlayer(player)
    end
end

-- Mata a cualquier jugador que se una después, excepto tú
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        wait(1) -- esperar que cargue el personaje
        killPlayer(player)
    end)
end)

-- Interfaz en CoreGui
local CoreGui = game:GetService("CoreGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PrisonLifeKillAllGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Botón flotante pequeño y draggable
local FloatButton = Instance.new("TextButton")
FloatButton.Size = UDim2.new(0, 80, 0, 40)
FloatButton.Position = UDim2.new(1, -90, 0, 20) -- esquina superior derecha
FloatButton.AnchorPoint = Vector2.new(1, 0)
FloatButton.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
FloatButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatButton.Text = "Kill All"
FloatButton.Font = Enum.Font.SourceSansBold
FloatButton.TextSize = 20
FloatButton.Parent = ScreenGui
FloatButton.Active = true
FloatButton.Draggable = true

FloatButton.MouseButton1Click:Connect(function()
    killAllExceptLocal()
end)

-- Ejecutar killAllExceptLocal al correr el script (opcional)
killAllExceptLocal()
