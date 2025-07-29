-- Prison Life Mod Menu - Kill All Methods
-- Optimizado para Android (solo táctil)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Variables globales
local killAllActive = false
local currentMethod = 1
local gui = nil
local isMinimized = false

-- Función para teletransportarse a un jugador
local function teleportToPlayer(targetPlayer)
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
           targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
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
    mainFrame.Size = UDim2.new(0, 220, 0, 320)
    mainFrame.Position = UDim2.new(0, 50, 0, 50)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(0.8, 0, 0, 30)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "Prison Menu"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame
    
    -- Botón minimizar
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeButton"
    minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
    minimizeBtn.Position = UDim2.new(1, -50, 0, 2.5)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 50)
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Text = "-"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.TextScaled = true
    minimizeBtn.Font = Enum.Font.SourceSansBold
    minimizeBtn.Parent = mainFrame
    
    -- Botón cerrar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -25, 0, 2.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.Parent = mainFrame
    
    -- Container para botones (para poder ocultar)
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.Size = UDim2.new(1, 0, 1, -30)
    buttonContainer.Position = UDim2.new(0, 0, 0, 30)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = mainFrame
    
    -- Botón 1: RemoteEvent Kill
    local btn1 = Instance.new("TextButton")
    btn1.Name = "RemoteKill"
    btn1.Size = UDim2.new(0.9, 0, 0, 40)
    btn1.Position = UDim2.new(0.05, 0, 0, 10)
    btn1.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
    btn1.BorderSizePixel = 0
    btn1.Text = "Remote Kill All"
    btn1.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn1.TextScaled = true
    btn1.Font = Enum.Font.SourceSans
    btn1.Parent = buttonContainer
    
    -- Botón 2: Melee Kill
    local btn2 = Instance.new("TextButton")
    btn2.Name = "MeleeKill"
    btn2.Size = UDim2.new(0.9, 0, 0, 40)
    btn2.Position = UDim2.new(0.05, 0, 0, 60)
    btn2.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
    btn2.BorderSizePixel = 0
    btn2.Text = "Melee Kill All"
    btn2.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn2.TextScaled = true
    btn2.Font = Enum.Font.SourceSans
    btn2.Parent = buttonContainer
    
    -- Botón 3: Damage Kill
    local btn3 = Instance.new("TextButton")
    btn3.Name = "DamageKill"
    btn3.Size = UDim2.new(0.9, 0, 0, 40)
    btn3.Position = UDim2.new(0.05, 0, 0, 110)
    btn3.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
    btn3.BorderSizePixel = 0
    btn3.Text = "Damage Kill All"
    btn3.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn3.TextScaled = true
    btn3.Font = Enum.Font.SourceSans
    btn3.Parent = buttonContainer
    
    -- Botón 4: Shoot Kill
    local btn4 = Instance.new("TextButton")
    btn4.Name = "ShootKill"
    btn4.Size = UDim2.new(0.9, 0, 0, 40)
    btn4.Position = UDim2.new(0.05, 0, 0, 160)
    btn4.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
    btn4.BorderSizePixel = 0
    btn4.Text = "Shoot Kill All"
    btn4.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn4.TextScaled = true
    btn4.Font = Enum.Font.SourceSans
    btn4.Parent = buttonContainer
    
    -- Botón 5: Auto Kill Toggle
    local btn5 = Instance.new("TextButton")
    btn5.Name = "AutoKill"
    btn5.Size = UDim2.new(0.9, 0, 0, 40)
    btn5.Position = UDim2.new(0.05, 0, 0, 210)
    btn5.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
    btn5.BorderSizePixel = 0
    btn5.Text = "Auto Kill: OFF"
    btn5.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn5.TextScaled = true
    btn5.Font = Enum.Font.SourceSans
    btn5.Parent = buttonContainer
    
    return screenGui, btn1, btn2, btn3, btn4, btn5, closeBtn, minimizeBtn, buttonContainer, mainFrame
end

-- Métodos de kill mejorados con TP y más daño
local function remoteKillAll()
    spawn(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                pcall(function()
                    -- TP al jugador
                    teleportToPlayer(player)
                    wait(0.1)
                    
                    -- Múltiples ataques con más daño
                    for i = 1, 10 do
                        if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                            if ReplicatedStorage:FindFirstChild("meleeEvent") then
                                ReplicatedStorage.meleeEvent:FireServer(player)
                            end
                            if ReplicatedStorage:FindFirstChild("DamageEvent") then
                                ReplicatedStorage.DamageEvent:FireServer(player.Character.Humanoid, 50)
                            end
                        end
                        wait(0.05)
                    end
                    wait(0.2)
                end)
            end
        end
    end)
end

local function meleeKillAll()
    spawn(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    -- TP al jugador
                    teleportToPlayer(player)
                    wait(0.1)
                    
                    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Handle") then
                        -- Ataques múltiples con más daño
                        for i = 1, 15 do
                            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                                if ReplicatedStorage:FindFirstChild("meleeEvent") then
                                    ReplicatedStorage.meleeEvent:FireServer(player.Character.HumanoidRootPart, tool.Handle)
                                end
                            end
                            wait(0.03)
                        end
                    end
                    wait(0.2)
                end)
            end
        end
    end)
end

local function damageKillAll()
    spawn(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                pcall(function()
                    -- TP al jugador
                    teleportToPlayer(player)
                    wait(0.1)
                    
                    -- Daño masivo repetido
                    for i = 1, 8 do
                        if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                            if ReplicatedStorage:FindFirstChild("DamageEvent") then
                                ReplicatedStorage.DamageEvent:FireServer(player.Character.Humanoid, 200)
                            end
                        end
                        wait(0.05)
                    end
                    wait(0.2)
                end)
            end
        end
    end)
end

local function shootKillAll()
    spawn(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                pcall(function()
                    -- TP al jugador
                    teleportToPlayer(player)
                    wait(0.1)
                    
                    local gun = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("M9") or 
                               LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("AK47") or
                               LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("M4A1")
                    
                    -- Disparos múltiples
                    for i = 1, 20 do
                        if player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                            if gun and gun:FindFirstChild("ShootEvent") then
                                gun.ShootEvent:FireServer(player.Character.Head.Position, player.Character.Head)
                            elseif ReplicatedStorage:FindFirstChild("ShootEvent") then
                                ReplicatedStorage.ShootEvent:FireServer(player.Character.Head.Position, player.Character.Head)
                            end
                        end
                        wait(0.02)
                    end
                    wait(0.2)
                end)
            end
        end
    end)
end

-- Auto kill loop mejorado
local function autoKillLoop()
    spawn(function()
        while killAllActive do
            wait(0.5)
            if currentMethod == 1 then
                remoteKillAll()
            elseif currentMethod == 2 then
                meleeKillAll()
            elseif currentMethod == 3 then
                damageKillAll()
            elseif currentMethod == 4 then
                shootKillAll()
            end
            wait(2)
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
            mainFrame.Size = UDim2.new(0, 220, 0, 30)
            minimizeBtn.Text = "+"
        else
            buttonContainer.Visible = true
            mainFrame.Size = UDim2.new(0, 220, 0, 320)
            minimizeBtn.Text = "-"
        end
    end)
    
    -- Conectar eventos de botones
    btn1.MouseButton1Click:Connect(function()
        currentMethod = 1
        remoteKillAll()
        print("Remote Kill All ejecutado con TP")
    end)
    
    btn2.MouseButton1Click:Connect(function()
        currentMethod = 2
        meleeKillAll()
        print("Melee Kill All ejecutado con TP")
    end)
    
    btn3.MouseButton1Click:Connect(function()
        currentMethod = 3
        damageKillAll()
        print("Damage Kill All ejecutado con TP")
    end)
    
    btn4.MouseButton1Click:Connect(function()
        currentMethod = 4
        shootKillAll()
        print("Shoot Kill All ejecutado con TP")
    end)
    
    btn5.MouseButton1Click:Connect(function()
        killAllActive = not killAllActive
        if killAllActive then
            btn5.Text = "Auto Kill: ON"
            btn5.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
            autoKillLoop()
            print("Auto Kill activado con TP")
        else
            btn5.Text = "Auto Kill: OFF"
            btn5.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
            print("Auto Kill desactivado")
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        killAllActive = false
        screenGui:Destroy()
        print("Mod Menu cerrado")
    end)
    
    print("Mod Menu Ultra cargado exitosamente!")
    print("Nuevo sistema: TP + Kill individual con más daño")
end

-- Inicializar el mod menu
initModMenu()

-- Función para reabrir el menú (opcional)
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        if gui and gui.Parent then
            gui:Destroy()
        else
            initModMenu()
        end
    end
end)