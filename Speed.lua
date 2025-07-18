-- 🔥 Legends of Speed – ULTRA OP STEP FARMER 🔥
-- Recoge TODOS los orbes de pasos de TODOS los mapas al instante
-- ¡Compatible con Android, con botón interactivo!

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local tpStepsEnabled = false

-- 🔍 Filtro de orbes de pasos flotantes (excluye gemas y orbes normales)
local function getAllStepOrbs()
    local stepOrbs = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            local y = obj.Position.Y
            -- Condición: nombre contenga "step" y esté flotando (Y > 10), y no sea XP ni Gemas
            if (name:find("step") or name:find("+")) and not name:find("xp") and not name:find("gem") and y > 10 then
                table.insert(stepOrbs, obj)
            end
        end
    end
    return stepOrbs
end

-- 🚀 TP masivo a todos los orbes válidos
local function collectAllSteps()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local steps = getAllStepOrbs()
    for _, orb in ipairs(steps) do
        hrp.CFrame = CFrame.new(orb.Position + Vector3.new(0, 2.5, 0))
        task.wait(0.01) -- ultra rápido, pero estable
    end
end

-- 🌀 Ejecutar cada frame si está activado
RunService.Stepped:Connect(function()
    if tpStepsEnabled then
        pcall(collectAllSteps)
    end
end)

-- 🎛️ UI Interactiva (compatible con Android)
local function createUI()
    local oldGui = PlayerGui:FindFirstChild("LegendStepUI")
    if oldGui then oldGui:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "LegendStepUI"
    gui.ResetOnSpawn = false
    gui.Parent = PlayerGui

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 240, 0, 60)
    btn.Position = UDim2.new(0.03, 0, 0.78, 0)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextScaled = true
    btn.BorderSizePixel = 0
    btn.BackgroundTransparency = 0.2
    btn.Text = "⚡ STEP FARM OFF"
    btn.Parent = gui

    btn.MouseButton1Click:Connect(function()
        tpStepsEnabled = not tpStepsEnabled
        btn.Text = tpStepsEnabled and "⚡ STEP FARM ON" or "⚡ STEP FARM OFF"
    end)
    btn.TouchTap:Connect(btn.MouseButton1Click)

    Players.LocalPlayer.CharacterAdded:Connect(function()
        wait(1)
        createUI()
    end)
end

createUI()
