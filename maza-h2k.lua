-- Prison Life Mod Menu - Menú Minimizable Completo
-- Optimizado para Android (solo táctil)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Variables globales
local remoteKillActive = false
local gui = nil
local isMinimized = false

-- Función para teletransportarse a un jugador (INSTANTÁNEO)
local function teleportToPlayer(targetPlayer)
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
           targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- TP instantáneo sin animación
            LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2)
            LocalPlayer.Character.HumanoidRootPart.Anchored = true
            wait()
            LocalPlayer.Character.HumanoidRootPart.Anchored = false
        end
    end)
end

-- Función para crear la GUI
local function createGUI()
    -- Crear ScreenGui principal
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ModMenuGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui
    
    -- Frame principal (draggable)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 250, 0, 380)
    mainFrame.Position = UDim2.new(0, 30, 0, 30)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    -- Esquinas redondeadas
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 8)
    mainCorner.Parent = mainFrame
    
    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(0.7, 0, 0, 35)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "🔥 PRISON HACK 🔥"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame
    
    -- Esquinas para título
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 6)
    titleCorner.Parent = titleLabel
    
    -- Botón minimizar
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeButton"
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(1, -65, 0, 2.5)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.TextScaled = true
    minimizeBtn.Font = Enum.Font.SourceSansBold
    minimizeBtn.Parent = mainFrame
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 5)
    minimizeCorner.Parent = minimizeBtn
    
    -- Botón cerrar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -32, 0, 2.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 5)
    closeCorner.Parent = closeBtn
    
    -- Container para botones (para poder ocultar)
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.Size = UDim2.new(1, 0, 1, -35)
    buttonContainer.Position = UDim2.new(0, 0, 0, 35)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = mainFrame
    
    -- Función helper para crear botones
    local function createButton(name, text, color, position)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.new(0.9, 0, 0, 55)
        btn.Position = position
        btn.BackgroundColor3 = color
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextScaled = true
        btn.Font = Enum.Font.SourceSansBold
        btn.Parent = buttonContainer
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btn
        
        return btn
    end
    
    -- Botón 1: Instant Kill
    local btn1 = createButton("InstantKill", "💀 INSTANT KILL 💀", 
        Color3.fromRGB(150, 0, 0), UDim2.new(0.05, 0, 0, 10))
    
    -- Botón 2: Speed Kill  
    local btn2 = createButton("SpeedKill", "🚀 SPEED KILL 🚀", 
        Color3.fromRGB(100, 0, 150), UDim2.new(0.05, 0, 0, 75))
    
    -- Botón 3: Nuclear Kill
    local btn3 = createButton("NuclearKill", "☢️ NUCLEAR KILL ☢️", 
        Color3.fromRGB(255, 100, 0), UDim2.new(0.05, 0, 0, 140))
    
    -- Botón 4: Auto Kill Toggle
    local btn4 = createButton("AutoKill", "⚡ AUTO KILL: OFF ⚡", 
        Color3.fromRGB(0, 120, 0), UDim2.new(0.05, 0, 0, 205))
    
    -- Botón 5: Mass Destroy
    local btn5 = createButton("MassDestroy", "🔥 MASS DESTROY 🔥", 
        Color3.fromRGB(200, 0, 100), UDim2.new(0.05, 0, 0, 270))
    
    return screenGui, btn1, btn2, btn3, btn4, btn5, closeBtn, minimizeBtn, buttonContainer, mainFrame
end

-- Método 1: Instant Kill (MUERTE INSTANTÁNEA)
local function instantKill()
    spawn(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                pcall(function()
                    -- TP instantáneo
                    teleportToPlayer(player)
                    
                    -- BOMBARDEO MASIVO DE REMOTES
                    for i = 1, 40 do
                        spawn(function()
                            if player.Character and player.Character:FindFirstChild("Humanoid") then
                                -- Spam masivo de meleeEvent
                                if ReplicatedStorage:FindFirstChild("meleeEvent") then
                                    ReplicatedStorage.meleeEvent:FireServer(player)
                                    ReplicatedStorage.meleeEvent:FireServer(player.Character)
                                    ReplicatedStorage.meleeEvent:FireServer(player.Character.Humanoid)
                                end
                                
                                -- Daño masivo
                                if ReplicatedStorage:FindFirstChild("DamageEvent") then
                                    ReplicatedStorage.DamageEvent:FireServer(player.Character.Humanoid, 999999)
                                end
                                
                                -- RemoteEvents adicionales
                                if ReplicatedStorage:FindFirstChild("RemoteEvent") then
                                    ReplicatedStorage.RemoteEvent:FireServer("Damage", player, 999999)
                                end
                            end
                        end)
                    end
                    wait(0.05)
                end)
            end
        end
    end)
end

-- Método 2: Speed Kill (Ultra rápido)
local function speedKill()
    spawn(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                spawn(function()
                    pcall(function()
                        teleportToPlayer(player)
                        -- Kill ultra rápido (menos ataques pero más rápido)
                        for i = 1, 15 do
                            spawn(function()
                                if ReplicatedStorage:FindFirstChild("meleeEvent") then
                                    ReplicatedStorage.meleeEvent:FireServer(player)
                                end
                                if ReplicatedStorage:FindFirstChild("DamageEvent") then
                                    ReplicatedStorage.DamageEvent:FireServer(player.Character.Humanoid, 500000)
                                end
                            end)
                        end
                    end)
                end)
            end
        end
    end)
end

-- Método 3: Nuclear Kill (Bombardeo masivo)
local function nuclearKill()
    spawn(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                spawn(function()
                    pcall(function()
                        teleportToPlayer(player)
                        -- Bombardeo nuclear (más ataques)
                        for i = 1, 80 do
                            spawn(function()
                                if ReplicatedStorage:FindFirstChild("meleeEvent") then
                                    ReplicatedStorage.meleeEvent:FireServer(player)
                                    ReplicatedStorage.meleeEvent:FireServer(player.Character)
                                    ReplicatedStorage.meleeEvent:FireServer(player.Character.Humanoid)
                                    ReplicatedStorage.meleeEvent:FireServer(player.Character.Head)
                                end
                                if ReplicatedStorage:FindFirstChild("DamageEvent") then
                                    ReplicatedStorage.DamageEvent:FireServer(player.Character.Humanoid, 999999)
                                    ReplicatedStorage.DamageEvent:FireServer(player.Character.Humanoid, 999999)
                                end
                            end)
                        end
                    end)
                end)
            end
        end
    end)
end

-- Método 4: Mass Destroy (Destrucción masiva)
local function massDestroy()
    spawn(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                spawn(function()
                    pcall(function()
                        teleportToPlayer(player)
                        -- Destrucción total
                        for i = 1, 100 do
                            spawn(function()
                                if ReplicatedStorage:FindFirstChild("meleeEvent") then
                                    ReplicatedStorage.meleeEvent:FireServer(player)
                                    ReplicatedStorage.meleeEvent:FireServer(player.Character)
                                    ReplicatedStorage.meleeEvent:FireServer(player.Character.Humanoid)
                                    ReplicatedStorage.meleeEvent:FireServer(player.Character.Head)
                                    ReplicatedStorage.meleeEvent:FireServer(player.Character.HumanoidRootPart)
                                end
                                if ReplicatedStorage:FindFirstChild("DamageEvent") then
                                    ReplicatedStorage.DamageEvent:FireServer(player.Character.Humanoid, 999999)
                                    ReplicatedStorage.DamageEvent:FireServer(player.Character.Humanoid, 999999)
                                    ReplicatedStorage.DamageEvent:FireServer(player.Character.Humanoid, 999999)
                                end
                                if ReplicatedStorage:FindFirstChild("RemoteEvent") then
                                    ReplicatedStorage.RemoteEvent:FireServer("Kill", player, 999999)
                                    ReplicatedStorage.RemoteEvent:FireServer("Death", player.Character)
                                end
                            end)
                        end
                    end)
                end)
            end
        end
    end)
end

-- Auto kill loop continuo
local function continuousKill()
    spawn(function()
        while remoteKillActive do
            -- Ejecutar instant kill cada 0.3 segundos
            instantKill()
            wait(0.3)
            
            -- Verificar jugadores vivos y atacar
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                    spawn(function()
                        pcall(function()
                            teleportToPlayer(player)
                            for i = 1, 25 do
                                spawn(function()
                                    if ReplicatedStorage:FindFirstChild("meleeEvent") then
                                        ReplicatedStorage.meleeEvent:FireServer(player)
                                    end
                                    if ReplicatedStorage:FindFirstChild("DamageEvent") then
                                        ReplicatedStorage.DamageEvent:FireServer(player.Character.Humanoid, 999999)
                                    end
                                end)
                            end
                        end)
                    end)
                end
            end
            wait(0.15)
        end
    end)
end

-- Función principal
local function initModMenu()
    -- Eliminar GUI anterior si existe
    if PlayerGui:FindFirstChild("ModMenuGUI") then
        PlayerGui.ModMenuGUI:Destroy()
    end
    
    -- Crear nueva GUI
    local screenGui, btn1, btn2, btn3, btn4, btn5, closeBtn, minimizeBtn, buttonContainer, mainFrame = createGUI()
    gui = screenGui
    
    -- Función de minimizar
    minimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            buttonContainer.Visible = false
            mainFrame.Size = UDim2.new(0, 250, 0, 35)
            minimizeBtn.Text = "+"
        else
            buttonContainer.Visible = true
            mainFrame.Size = UDim2.new(0, 250, 0, 380)
            minimizeBtn.Text = "−"
        end
    end)
    
    -- Eventos de botones con efectos visuales
    btn1.MouseButton1Click:Connect(function()
        instantKill()
        -- Efecto visual
        btn1.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        wait(0.1)
        btn1.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        print("💀 INSTANT KILL EJECUTADO 💀")
    end)
    
    btn2.MouseButton1Click:Connect(function()
        speedKill()
        -- Efecto visual
        btn2.BackgroundColor3 = Color3.fromRGB(200, 0, 255)
        wait(0.1)
        btn2.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
        print("🚀 SPEED KILL EJECUTADO 🚀")
    end)
    
    btn3.MouseButton1Click:Connect(function()
        nuclearKill()
        -- Efecto visual
        btn3.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        wait(0.1)
        btn3.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        print("☢️ NUCLEAR KILL EJECUTADO ☢️")
    end)
    
    btn4.MouseButton1Click:Connect(function()
        remoteKillActive = not remoteKillActive
        if remoteKillActive then
            btn4.Text = "⚡ AUTO KILL: ON ⚡"
            btn4.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            continuousKill()
            print("⚡ AUTO KILL ACTIVADO - IMPARABLE ⚡")
        else
            btn4.Text = "⚡ AUTO KILL: OFF ⚡"
            btn4.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
            print("❌ AUTO KILL DESACTIVADO")
        end
    end)
    
    btn5.MouseButton1Click:Connect(function()
        massDestroy()
        -- Efecto visual
        btn5.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        wait(0.1)
        btn5.BackgroundColor3 = Color3.fromRGB(200, 0, 100)
        print("🔥 MASS DESTROY EJECUTADO 🔥")
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        remoteKillActive = false
        screenGui:Destroy()
        print("🔥 MOD MENU CERRADO 🔥")
    end)
    
    print("🔥 PRISON HACK MENU CARGADO 🔥")
    print("💀 Instant Kill - Muerte instantánea")
    print("🚀 Speed Kill - Kill ultra rápido")
    print("☢️ Nuclear Kill - Bombardeo masivo")
    print("⚡ Auto Kill - Kill continuo automático")
    print("🔥 Mass Destroy - Destrucción total")
end

-- Inicializar el mod menu
initModMenu()

-- Función para reabrir el menú con Insert
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        if gui and gui.Parent then
            gui:Destroy()
        else
            initModMenu()
        end
    end
end)