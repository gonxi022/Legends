-- 🔥 Legends of Speed - Paso AutoFarm Muy Roto (Todos los mundos, sin cooldown)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local pasoFarmActivado = false

-- 🔍 Buscar todos los pasos del juego (orbs naranjas)
local function getAllStepOrbs()
    local orbs = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("step") or obj.Name:lower():find("orb")) then
            table.insert(orbs, obj)
        end
    end
    return orbs
end

-- ⚡ Teletransporte rápido a todos los pasos
local function recogerPasos()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, paso in ipairs(getAllStepOrbs()) do
        hrp.CFrame = CFrame.new(paso.Position + Vector3.new(0, 2.5, 0))
        task.wait(0.01) -- pausa mínima para estabilidad
    end
end

-- 🔁 Activar el autofarm si está activado
RunService.Stepped:Connect(function()
    if pasoFarmActivado then
        pcall(recogerPasos)
    end
end)

-- 🧠 Crear interfaz para activar/desactivar
local function crearInterfaz()
    local anterior = PlayerGui:FindFirstChild("PasoUI")
    if anterior then anterior:Destroy() end

    local gui = Instance.new("ScreenGui", PlayerGui)
    gui.Name = "PasoUI"
    gui.ResetOnSpawn = false

    local boton = Instance.new("TextButton", gui)
    boton.Size = UDim2.new(0, 220, 0, 50)
    boton.Position = UDim2.new(0.03, 0, 0.78, 0)
    boton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    boton.TextColor3 = Color3.fromRGB(255, 255, 255)
    boton.TextScaled = true
    boton.Text = "👣 STEP FARM OFF"
    boton.BorderSizePixel = 0

    boton.MouseButton1Click:Connect(function()
        pasoFarmActivado = not pasoFarmActivado
        boton.Text = pasoFarmActivado and "👣 STEP FARM ON" or "👣 STEP FARM OFF"
    end)

    boton.TouchTap:Connect(boton.MouseButton1Click)

    Players.LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        crearInterfaz()
    end)
end

crearInterfaz()
