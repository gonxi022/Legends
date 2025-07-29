-- Prison Life - Kill All + God Mode (Botones Arrastrables)
-- Kill All: TP a cada jugador + meleeEvent enviado 15 veces
-- God Mode: Funcional para Prison Life Android/KRNL

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Variables para God Mode y Kill All
local godModeEnabled = false
local godConnection = nil
local killAllEnabled = false
local killAllConnection = nil

-- Crear GUI con botones arrastrables
local gui = Instance.new("ScreenGui")
gui.Name = "PrisonLifeHackGui"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

-- Función para hacer botones arrastrables
local function makeDraggable(frame)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Botón Kill All
local killButton = Instance.new("TextButton")
killButton.Name = "KillAllButton"
killButton.Size = UDim2.new(0, 180, 0, 50)
killButton.Position = UDim2.new(0, 20, 0, 60)
killButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
killButton.BorderSizePixel = 0
killButton.Text = "Kill All: OFF"
killButton.TextColor3 = Color3.fromRGB(255, 255, 255)
killButton.TextScaled = true
killButton.Font = Enum.Font.SourceSansBold
killButton.Parent = gui

-- Agregar bordes redondeados al botón Kill All
local killCorner = Instance.new("UICorner")
killCorner.CornerRadius = UDim.new(0, 8)
killCorner.Parent = killButton

-- Botón God Mode
local godButton = Instance.new("TextButton")
godButton.Name = "GodModeButton"
godButton.Size = UDim2.new(0, 180, 0, 50)
godButton.Position = UDim2.new(0, 20, 0, 120)
godButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
godButton.BorderSizePixel = 0
godButton.Text = "God Mode: OFF"
godButton.TextColor3 = Color3.fromRGB(255, 255, 255)
godButton.TextScaled = true
godButton.Font = Enum.Font.SourceSansBold
godButton.Parent = gui

-- Agregar bordes redondeados al botón God Mode
local godCorner = Instance.new("UICorner")
godCorner.CornerRadius = UDim.new(0, 8)
godCorner.Parent = godButton

-- Hacer botones arrastrables
makeDraggable(killButton)
makeDraggable(godButton)

-- Teleportarse a un jugador
local function tpTo(position)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = CFrame.new(position + Vector3.new(0, 2, 0))
    end
end

-- Kill All automático en bucle (súper rápido)
local function toggleKillAll()
    if not killAllEnabled then
        -- Activar Kill All automático
        killAllEnabled = true
        killButton.Text = "Kill All: ON"
        killButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        
        local event = ReplicatedStorage:FindFirstChild("meleeEvent")
        if not event then 
            warn("meleeEvent no encontrado!")
            killAllEnabled = false
            killButton.Text = "Kill All: OFF"
            killButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            return 
        end
        
        -- Bucle automático súper rápido
        killAllConnection = RunService.Heartbeat:Connect(function()
            if not killAllEnabled then return end
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    -- TP instantáneo
                    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.CFrame = CFrame.new(player.Character.HumanoidRootPart.Position + Vector3.new(0, 2, 0))
                        
                        -- Enviar 15 hits súper rápido
                        for i = 1, 15 do
                            event:FireServer(player)
                        end
                    end
                end
            end
        end)
        
    else
        -- Desactivar Kill All
        killAllEnabled = false
        killButton.Text = "Kill All: OFF"
        killButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        if killAllConnection then
            killAllConnection:Disconnect()
            killAllConnection = nil
        end
    end
end

-- God Mode funcional para Prison Life
local function toggleGodMode()
    if not godModeEnabled then
        -- Activar God Mode
        godModeEnabled = true
        godButton.Text = "God Mode: ON"
        godButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        -- Método 1: Regenerar salud constantemente
        godConnection = RunService.Heartbeat:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                local humanoid = LocalPlayer.Character.Humanoid
                if humanoid.Health < humanoid.MaxHealth then
                    humanoid.Health = humanoid.MaxHealth
                end
            end
        end)
        
        -- Método 2: Manejar eventos de daño (para Prison Life específicamente)
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        
        -- Prevenir muerte
        humanoid.HealthChanged:Connect(function(health)
            if godModeEnabled and health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
        
        -- Método 3: Protección adicional para Prison Life
        spawn(function()
            while godModeEnabled do
                task.wait(0.1)
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.Health = LocalPlayer.Character.Humanoid.MaxHealth
                end
            end
        end)
        
    else
        -- Desactivar God Mode
        godModeEnabled = false
        godButton.Text = "God Mode: OFF"
        godButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        
        if godConnection then
            godConnection:Disconnect()
            godConnection = nil
        end
    end
end

-- Reactivar funciones cuando spawne
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1) -- Esperar a que cargue completamente
    
    -- Reactivar God Mode si estaba activado
    if godModeEnabled then
        toggleGodMode()
        toggleGodMode() -- Toggle dos veces para reactivar
    end
    
    -- Reactivar Kill All si estaba activado
    if killAllEnabled then
        toggleKillAll()
        toggleKillAll() -- Toggle dos veces para reactivar
    end
end)

-- Conectar eventos de botones
killButton.MouseButton1Click:Connect(toggleKillAll)
godButton.MouseButton1Click:Connect(toggleGodMode)

print("Prison Life Hack GUI cargado - Kill All automático + God Mode!")