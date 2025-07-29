-- Prison Life - Kill All Global + God Mode (Android)
-- By Gonxi + GPT

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

local meleeEvent = ReplicatedStorage:FindFirstChild("meleeEvent") or ReplicatedStorage:FindFirstChildWhichIsA("RemoteEvent", true)

-- Crear ScreenGui
local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.ResetOnSpawn = false

-- Función para crear botones flotantes y draggable
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

-- Notificación rápida
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

-- Kill All Global sin moverte
local function killAllGlobal()
    local originalPos = Root.CFrame
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local targetHumanoid = player.Character.Humanoid
            if targetHumanoid.Health > 0 then
                local targetRoot = player.Character.HumanoidRootPart
                Root.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 0, 1))
                task.wait(0.015) -- breve delay para spoof
                for i = 1, 40 do
                    meleeEvent:FireServer(player)
                end
            end
        end
    end
    Root.CFrame = originalPos
    notificar("Kill All Global ejecutado")
end

-- God Mode toggle
local godModeActivo = false

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
end)

-- Crear botones en pantalla
crearBoton("☢️ Kill All Global", UDim2.new(0, 50, 0, 150), killAllGlobal)
crearBoton("🛡️ God Mode", UDim2.new(0, 50, 0, 210), toggleGodMode)