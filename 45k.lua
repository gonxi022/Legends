local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

local meleeEvent = ReplicatedStorage:FindFirstChild("meleeEvent") or ReplicatedStorage:FindFirstChildWhichIsA("RemoteEvent", true)

local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.ResetOnSpawn = false

local killAllActivo = false
local godModeActivo = false
local speedActivo = false

local MELEE_DISTANCE = 15 -- distancia para atacar

local function crearBoton(texto, posicion, callback)
    local boton = Instance.new("TextButton")
    boton.Size = UDim2.new(0, 140, 0, 45)
    boton.Position = posicion
    boton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    boton.TextColor3 = Color3.fromRGB(255, 255, 255)
    boton.TextScaled = true
    boton.Text = texto
    boton.Active = true
    boton.Draggable = true
    boton.Parent = screenGui
    boton.MouseButton1Click:Connect(callback)
    return boton
end

local function notificar(texto)
    local notif = Instance.new("TextLabel", screenGui)
    notif.Size = UDim2.new(0, 300, 0, 50)
    notif.Position = UDim2.new(0.5, -150, 0, 10)
    notif.BackgroundTransparency = 0.3
    notif.BackgroundColor3 = Color3.new(0, 0, 0)
    notif.Text = texto
    notif.TextColor3 = Color3.new(1, 1, 1)
    notif.TextScaled = true
    game:GetService("Debris"):AddItem(notif, 2)
end

local function aplicarSpeed()
    if Humanoid then
        if speedActivo then
            Humanoid.WalkSpeed = 60
        else
            Humanoid.WalkSpeed = 16
        end
    end
end

local function loopKillCercano()
    while killAllActivo do
        for _, player in pairs(Players:GetPlayers()) do
            if not killAllActivo then break end
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                local targetRoot = player.Character.HumanoidRootPart
                local distance = (targetRoot.Position - Root.Position).Magnitude
                if distance <= MELEE_DISTANCE and player.Character.Humanoid.Health > 0 then
                    for i = 1, 49 do
                        meleeEvent:FireServer(player)
                    end
                end
            end
        end
        task.wait(0.2)
    end
end

local function toggleKillAll()
    killAllActivo = not killAllActivo
    if killAllActivo then
        notificar("Kill All Cercano ACTIVADO")
        spawn(loopKillCercano)
    else
        notificar("Kill All Cercano DESACTIVADO")
    end
end

local function toggleGodMode()
    godModeActivo = not godModeActivo
    if godModeActivo then
        notificar("God Mode ACTIVADO")
    else
        notificar("God Mode DESACTIVADO")
    end
end

local function toggleSpeed()
    speedActivo = not speedActivo
    aplicarSpeed()
    if speedActivo then
        notificar("Speed x60 ACTIVADO")
    else
        notificar("Speed DESACTIVADO")
    end
end

RunService.Heartbeat:Connect(function()
    if godModeActivo and Humanoid then
        Humanoid.Health = math.huge
        Humanoid.MaxHealth = math.huge
        if Root.Velocity.Y < -100 then
            Root.Velocity = Vector3.new(0, 0, 0)
        end
    end
    aplicarSpeed()
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    Root = char:WaitForChild("HumanoidRootPart")
    aplicarSpeed()
    if killAllActivo then
        spawn(loopKillCercano)
    end
end)

crearBoton("⚔️ Kill All Cercano", UDim2.new(0, 50, 0, 150), toggleKillAll)
crearBoton("🛡️ God Mode", UDim2.new(0, 50, 0, 210), toggleGodMode)
crearBoton("⚡ Speed x60", UDim2.new(0, 50, 0, 270), toggleSpeed)