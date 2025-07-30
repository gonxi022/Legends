-- Kill All Prison Life funcional - Android KRNL - by ChatGPT + Gonxi

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Buscar Remotes importantes
local meleeEvent = ReplicatedStorage:FindFirstChild("meleeEvent")
local damageEvent = ReplicatedStorage:FindFirstChild("DamageEvent")
local equipEvent = ReplicatedStorage:FindFirstChild("EquipEvent")
local unequipEvent = ReplicatedStorage:FindFirstChild("UnequipEvent")
local refillEvent = ReplicatedStorage:FindFirstChild("RefillEvent")
local replicateEvent = ReplicatedStorage:FindFirstChild("ReplicateEvent")
local shootEvent = ReplicatedStorage:FindFirstChild("ShootEvent")
local soundEvent = ReplicatedStorage:FindFirstChild("SoundEvent")
local warnEvent = ReplicatedStorage:FindFirstChild("WarnEvent")
local updateEvent = ReplicatedStorage:FindFirstChild("UpdateEvent")
local upEvent = ReplicatedStorage:FindFirstChild("UpEvent")
local reloadEvent = ReplicatedStorage:FindFirstChild("ReloadEvent")

-- Variables
local killAllActive = false

-- GUI básico
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KillAllGUI"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 160, 0, 50)
frame.Position = UDim2.new(0, 10, 0.5, -25)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(1, -10, 1, -10)
button.Position = UDim2.new(0, 5, 0, 5)
button.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
button.TextColor3 = Color3.new(1,1,1)
button.TextScaled = true
button.Font = Enum.Font.SourceSansBold
button.Text = "Kill All [OFF]"
button.Parent = frame

-- Función para hacer kill all
local function doKillAll()
    if not killAllActive then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            -- Enviar varios ataques para asegurar kill
            for i = 1, 49 do
                pcall(function()
                    if meleeEvent then meleeEvent:FireServer(player) end
                    if damageEvent then damageEvent:FireServer(player) end
                    if equipEvent then equipEvent:FireServer() end
                    if unequipEvent then unequipEvent:FireServer() end
                    if refillEvent then refillEvent:FireServer() end
                    if replicateEvent then replicateEvent:FireServer() end
                    if shootEvent then shootEvent:FireServer() end
                    if soundEvent then soundEvent:FireServer() end
                    if warnEvent then warnEvent:FireServer() end
                    if updateEvent then updateEvent:FireServer() end
                    if upEvent then upEvent:FireServer() end
                    if reloadEvent then reloadEvent:FireServer() end
                end)
            end
        end
    end
end

-- Loop infinito para mantener activo
spawn(function()
    while true do
        if killAllActive then
            doKillAll()
        end
        task.wait(0.5) -- medio segundo para no saturar el servidor ni tu dispositivo
    end
end)

-- Toggle botón
button.MouseButton1Click:Connect(function()
    killAllActive = not killAllActive
    button.Text = killAllActive and "Kill All [ON]" or "Kill All [OFF]"
    button.BackgroundColor3 = killAllActive and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(200, 40, 40)
end)

print("💀 Kill All listo, activalo con el botón.")