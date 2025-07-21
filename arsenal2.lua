local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local settings = {
    noclip = false,
    fly = false,
    autoKill = false,
    killAura = false,
    autoCollect = false,
    godMode = false,
    speed = 16,
    flySpeed = 50,
}

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ArsenalModMenu"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false

-- Background semi-transparente
local bg = Instance.new("Frame")
bg.Size = UDim2.new(1,0,1,0)
bg.BackgroundColor3 = Color3.new(0,0,0)
bg.BackgroundTransparency = 0.5
bg.Visible = false
bg.Parent = screenGui

-- Botón principal menú
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0,50,0,50)
toggleBtn.Position = UDim2.new(0,10,0.5,-25)
toggleBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
toggleBtn.Text = "≡"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.TextScaled = true
toggleBtn.Parent = screenGui
toggleBtn.ZIndex = 10

-- Frame menú
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0,250,0,350)
menuFrame.Position = UDim2.new(0,70,0.5,-175)
menuFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
menuFrame.BorderSizePixel = 0
menuFrame.Visible = false
menuFrame.Parent = screenGui
menuFrame.ZIndex = 11

-- UIStroke para el frame
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.new(1,1,1)
stroke.Thickness = 2
stroke.Parent = menuFrame

-- Crear botón toggle
local function createToggle(name, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9,0,0,40)
    btn.Position = UDim2.new(0.05,0,0,posY)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = name .. ": OFF"
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = menuFrame
    btn.ZIndex = 12
    btn.AutoButtonColor = true

    btn.MouseButton1Click:Connect(function()
        settings[name] = not settings[name]
        btn.Text = name .. ": " .. (settings[name] and "ON" or "OFF")
        if name == "fly" and not settings.fly then
            -- Reset fly velocity on disable
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
            end
        end
    end)

    return btn
end

local noclipBtn = createToggle("noclip", 10)
local flyBtn = createToggle("fly", 60)
local autoKillBtn = createToggle("autoKill", 110)
local killAuraBtn = createToggle("killAura", 160)
local autoCollectBtn = createToggle("autoCollect", 210)
local godModeBtn = createToggle("godMode", 260)

-- Slider para speed
local speedLabel = Instance.new("TextLabel")
speedLabel.Text = "Speed: " .. settings.speed
speedLabel.Size = UDim2.new(0.9,0,0,30)
speedLabel.Position = UDim2.new(0.05,0,0,310)
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextScaled = true
speedLabel.Parent = menuFrame
speedLabel.ZIndex = 12

local speedSlider = Instance.new("TextBox")
speedSlider.Size = UDim2.new(0.9,0,0,30)
speedSlider.Position = UDim2.new(0.05,0,0,340)
speedSlider.Text = tostring(settings.speed)
speedSlider.ClearTextOnFocus = false
speedSlider.TextColor3 = Color3.new(1,1,1)
speedSlider.BackgroundColor3 = Color3.fromRGB(50,50,50)
speedSlider.Font = Enum.Font.Gotham
speedSlider.TextScaled = true
speedSlider.Parent = menuFrame
speedSlider.ZIndex = 12

speedSlider.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local val = tonumber(speedSlider.Text)
        if val and val >= 16 and val <= 200 then
            settings.speed = val
            speedLabel.Text = "Speed: " .. val
        else
            speedSlider.Text = tostring(settings.speed)
        end
    end
end)

-- Toggle menú
toggleBtn.MouseButton1Click:Connect(function()
    menuFrame.Visible = not menuFrame.Visible
    bg.Visible = menuFrame.Visible
end)

-- Noclip loop
RunService.Stepped:Connect(function()
    if settings.noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    elseif LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end)

-- Fly
local flyVelocity = Vector3.new(0,0,0)
local flying = false

local function getFlyDirection()
    local dir = Vector3.new()
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        dir = dir + (Camera.CFrame.LookVector)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        dir = dir - (Camera.CFrame.LookVector)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        dir = dir - (Camera.CFrame.RightVector)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        dir = dir + (Camera.CFrame.RightVector)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        dir = dir + Vector3.new(0,1,0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        dir = dir - Vector3.new(0,1,0)
    end
    return dir.Unit
end

RunService.Heartbeat:Connect(function()
    if settings.fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local dir = getFlyDirection()
        if dir.Magnitude > 0 then
            hrp.Velocity = dir * settings.flySpeed
            flying = true
        elseif flying then
            hrp.Velocity = Vector3.new(0,0,0)
            flying = false
        end
    end
end)

-- Auto Kill loop
spawn(function()
    while true do
        task.wait(0.3)
        if settings.autoKill then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Team ~= LocalPlayer.Team and p.Character and p.Character:FindFirstChild("Humanoid") then
                    p.Character.Humanoid.Health = 0
                end
            end
        end
    end
end)

-- Kill Aura loop (ataque automático a jugadores cercanos)
spawn(function()
    while true do
        task.wait(0.1)
        if settings.killAura and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Team ~= LocalPlayer.Team and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
                    local dist = (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if dist < 10 then
                        p.Character.Humanoid.Health = 0
                    end
                end
            end
        end
    end
end)

-- Auto Collect (recolectar items automáticamente)
spawn(function()
    while true do
        task.wait(0.5)
        if settings.autoCollect and workspace:FindFirstChild("ItemSpawns") then
            for _, item in pairs(workspace.ItemSpawns:GetChildren()) do
                if item:IsA("BasePart") and (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then
                    local hrp = LocalPlayer.Character.HumanoidRootPart
                    local dist = (hrp.Position - item.Position).Magnitude
                    if dist < 20 then
                        hrp.CFrame = item.CFrame
                    end
                end
            end
        end
    end
end)

-- God Mode (no te bajan la vida)
if LocalPlayer.Character then
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.HealthChanged:Connect(function(health)
            if settings.godMode and health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        wait(1)
        -- Podés agregar inicialización para nuevos personajes si necesitás
    end)
end)