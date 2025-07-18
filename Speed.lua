local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Flag para activar/desactivar el kill all
local KillAllActive = false

-- Función para matar un jugador (excepto tú)
local function killPlayer(player)
    if player.Character and player.Character:FindFirstChild("Humanoid") and player ~= LocalPlayer then
        player.Character.Humanoid.Health = 0
    end
end

-- Función que mata a todos los jugadores (excepto tú) continuamente mientras KillAllActive == true
local function KillAllLoop()
    spawn(function()
        while KillAllActive do
            for _, player in pairs(Players:GetPlayers()) do
                killPlayer(player)
            end
            wait(0.5)
        end
    end)
end

-- Crear UI flotante
local CoreGui = game:GetService("CoreGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KillAllGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local FloatButton = Instance.new("TextButton")
FloatButton.Size = UDim2.new(0, 80, 0, 40)
FloatButton.Position = UDim2.new(1, -90, 0, 20)
FloatButton.AnchorPoint = Vector2.new(1, 0)
FloatButton.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
FloatButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatButton.Text = "Kill All: OFF"
FloatButton.Font = Enum.Font.SourceSansBold
FloatButton.TextSize = 18
FloatButton.Parent = ScreenGui
FloatButton.Active = true
FloatButton.Draggable = true

-- Toggle botón
FloatButton.MouseButton1Click:Connect(function()
    KillAllActive = not KillAllActive
    FloatButton.Text = KillAllActive and "Kill All: ON" or "Kill All: OFF"
    if KillAllActive then
        KillAllLoop()
    end
end)

-- Mata a nuevos jugadores cuando entren, si está activo
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(1)
        if KillAllActive then
            killPlayer(player)
        end
    end)
end)
