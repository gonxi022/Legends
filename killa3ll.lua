local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

local meleeEvent = ReplicatedStorage:FindFirstChild("meleeEvent") or ReplicatedStorage:FindFirstChildWhichIsA("RemoteEvent", true)

local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.ResetOnSpawn = false

local killAllActivo = false
local godModeActivo = false

-- Speed x60
local speedValue = 60

-- Función para aplicar speed
local function aplicarSpeed()
    if Character and Humanoid then
        Humanoid.WalkSpeed = speedValue
    end
end

-- Reconectar variables al morir/revivir
local function onCharacterAdded(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    Root = char:WaitForChild("HumanoidRootPart")
    aplicarSpeed()
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- Función para crear botón draggable
local function crearBoton(texto, posicion, callback)
    local boton = Instance.new("TextButton")
    boton.Size = UDim2.new(0, 140, 0, 45)
    boton.Position = posicion
    boton.BackgroundColor3 = Color3.fromRGB(30,30,30)
    boton.TextColor3 = Color3.fromRGB(255,255,255)
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
    notif.BackgroundTransparency = 0.4
    notif.BackgroundColor3 = Color3.new(0, 0, 0)
    notif.TextColor3 = Color3.new(1, 1, 1)
    notif.TextScaled = true
    notif.Text = texto
    game:GetService("Debris"):AddItem(notif, 2)
end

-- Loop Kill All con spoof y 49 ataques
local function loopKillAll()
    local originalPos = Root.CFrame
    while killAllActivo do
        for _, player in pairs(Players:GetPlayers()) do
            if not killAllActivo then break end
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                local targetHumanoid = player.Character.Humanoid
                if targetHumanoid.Health > 0 then
                    local targetRoot = player.Character.HumanoidRootPart
                    Root.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 0, 1))
                    task.wait(0.02)
                    for i = 1, 49 do
                        meleeEvent:FireServer(player)
                    end
                end
            end
        end
        Root.CFrame = originalPos
        task.wait(0.3)
    end
    Root.CFrame = originalPos
end

local function toggleKillAll()
    killAllActivo = not killAllActivo
    if killAllActivo then
        notificar("Kill All ACTIVADO")
        aplicarSpeed()
        spawn(loopKillAll)
    else
        notificar("Kill All DESACTIVADO")
        if Humanoid then
            Humanoid.WalkSpeed = 16 -- vuelve a normal
        end
    end
end

-- God Mode toggle
local function toggleGodMode()
    godModeActivo = not godModeActivo
    if godModeActivo then
        notificar("God Mode ACTIVADO")
    else
        notificar("God Mode DESACTIVADO")
    end
end

RunService.Heartbeat:Connect(function()
    if godModeActivo and Humanoid then
        Humanoid.Health = math.huge
        Humanoid.MaxHealth = math.huge
        if Root.Velocity.Y < -100 then
            Root.Velocity = Vector3.new(0,0,0)
        end
    end
    if killAllActivo then
        aplicarSpeed()
    end
end)

-- Iniciar speed aunque no active killall aún
aplicarSpeed()

-- Crear botones
crearBoton("☢️ Kill All", UDim2.new(0, 50, 0, 150), toggleKillAll)
crearBoton("🛡️ God Mode", UDim2.new(0, 50, 0, 210), toggleGodMode)