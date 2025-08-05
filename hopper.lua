-- Steal A Fish Server Hopper para Android/KRNL
-- Optimizado para pantalla táctil

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local gameId = game.PlaceId

-- Variables globales
local isScanning = false
local serverList = {}
local gui = nil

-- Función para crear la GUI optimizada para móvil
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StealFishHopper"
    screenGui.Parent = CoreGui
    screenGui.ResetOnSpawn = false
    
    -- Marco principal (más grande para móvil)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -175, 0.1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Esquinas redondeadas
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.fromRGB(20, 120, 200)
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "🐟 Steal A Fish Server Hopper"
    titleLabel.TextColor3 = Color3.white
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleLabel
    
    -- Botón de escaneo (grande para móvil)
    local scanButton = Instance.new("TextButton")
    scanButton.Name = "ScanButton"
    scanButton.Size = UDim2.new(0.9, 0, 0, 50)
    scanButton.Position = UDim2.new(0.05, 0, 0, 60)
    scanButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    scanButton.BorderSizePixel = 0
    scanButton.Text = "🔍 Escanear Servidores"
    scanButton.TextColor3 = Color3.white
    scanButton.TextSize = 18
    scanButton.Font = Enum.Font.GothamBold
    scanButton.Parent = mainFrame
    
    local scanCorner = Instance.new("UICorner")
    scanCorner.CornerRadius = UDim.new(0, 8)
    scanCorner.Parent = scanButton
    
    -- Lista de servidores con scroll
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ServerList"
    scrollFrame.Size = UDim2.new(0.9, 0, 0, 330)
    scrollFrame.Position = UDim2.new(0.05, 0, 0, 120)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    scrollFrame.Parent = mainFrame
    
    local scrollCorner = Instance.new("UICorner")
    scrollCorner.CornerRadius = UDim.new(0, 8)
    scrollCorner.Parent = scrollFrame
    
    -- Layout para la lista
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = scrollFrame
    
    -- Estado del escaneo
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(0.9, 0, 0, 25)
    statusLabel.Position = UDim2.new(0.05, 0, 0, 460)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Listo para escanear"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.TextSize = 14
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = mainFrame
    
    -- Botón cerrar
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.white
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeButton
    
    -- Hacer draggable (para reposicionar en móvil)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    titleLabel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    titleLabel.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                updateInput(input)
            end
        end
    end)
    
    -- Eventos
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    scanButton.MouseButton1Click:Connect(function()
        if not isScanning then
            startServerScan()
        end
    end)
    
    return screenGui, scrollFrame, statusLabel, scanButton
end

-- Función para analizar el servidor actual
local function analyzeCurrentServer()
    local serverData = {
        serverId = game.JobId,
        players = #Players:GetPlayers(),
        maxValue = 0,
        fishCount = 0,
        topFish = "Ninguno"
    }
    
    -- Buscar información de peces (adaptar según el juego)
    -- Esto es un ejemplo, necesitarás ajustarlo según la struktura específica de Steal A Fish
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- Intentar obtener stats del jugador
            local leaderstats = player:FindFirstChild("leaderstats")
            if leaderstats then
                local money = leaderstats:FindFirstChild("Money") or leaderstats:FindFirstChild("Cash")
                if money and money.Value > serverData.maxValue then
                    serverData.maxValue = money.Value
                end
            end
            
            -- Buscar información de peces en el jugador
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                for _, tool in pairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") and string.find(string.lower(tool.Name), "fish") then
                        serverData.fishCount = serverData.fishCount + 1
                        -- Aquí podrías agregar lógica para detectar peces raros
                    end
                end
            end
        end
    end
    
    -- Calcular puntuación del servidor
    local score = serverData.maxValue / 1000 + serverData.fishCount * 10 + serverData.players * 5
    serverData.score = math.floor(score)
    
    return serverData
end

-- Función para crear item de servidor en la lista
local function createServerItem(serverData, parent)
    local serverFrame = Instance.new("Frame")
    serverFrame.Size = UDim2.new(1, -10, 0, 80)
    serverFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    serverFrame.BorderSizePixel = 0
    serverFrame.Parent = parent
    
    local serverCorner = Instance.new("UICorner")
    serverCorner.CornerRadius = UDim.new(0, 6)
    serverCorner.Parent = serverFrame
    
    -- Info del servidor
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(0.7, 0, 1, 0)
    infoLabel.Position = UDim2.new(0, 5, 0, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = string.format("🎯 Puntuación: %d\n👥 Jugadores: %d\n💰 Max Dinero: $%s", 
        serverData.score, serverData.players, tostring(serverData.maxValue))
    infoLabel.TextColor3 = Color3.white
    infoLabel.TextSize = 14
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.Parent = serverFrame
    
    -- Botón unirse (grande para móvil)
    local joinButton = Instance.new("TextButton")
    joinButton.Size = UDim2.new(0.25, -10, 0.6, 0)
    joinButton.Position = UDim2.new(0.72, 0, 0.2, 0)
    joinButton.BackgroundColor3 = Color3.fromRGB(20, 150, 220)
    joinButton.BorderSizePixel = 0
    joinButton.Text = "Unirse"
    joinButton.TextColor3 = Color3.white
    joinButton.TextSize = 16
    joinButton.Font = Enum.Font.GothamBold
    joinButton.Parent = serverFrame
    
    local joinCorner = Instance.new("UICorner")
    joinCorner.CornerRadius = UDim.new(0, 4)
    joinCorner.Parent = joinButton
    
    -- Evento para unirse al servidor
    joinButton.MouseButton1Click:Connect(function()
        joinButton.Text = "Uniendo..."
        joinButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        
        -- Intentar unirse al servidor
        pcall(function()
            TeleportService:TeleportToPlaceInstance(gameId, serverData.serverId, LocalPlayer)
        end)
    end)
    
    return serverFrame
end

-- Función principal de escaneo
local function startServerScan()
    if isScanning then return end
    
    isScanning = true
    local _, scrollFrame, statusLabel, scanButton = gui.MainFrame, gui.MainFrame.ServerList, gui.MainFrame.Status, gui.MainFrame.ScanButton
    
    scanButton.Text = "⏳ Escaneando..."
    scanButton.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
    statusLabel.Text = "Iniciando escaneo de servidores..."
    
    -- Limpiar lista anterior
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    serverList = {}
    local serversScanned = 0
    local maxServers = 15  -- Límite para evitar lag en móvil
    
    local function scanNextServer()
        if serversScanned >= maxServers then
            -- Finalizar escaneo
            isScanning = false
            scanButton.Text = "🔍 Escanear Servidores"
            scanButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            statusLabel.Text = string.format("Escaneo completado - %d servidores encontrados", #serverList)
            
            -- Ordenar servidores por puntuación
            table.sort(serverList, function(a, b) return a.score > b.score end)
            
            -- Mostrar solo los mejores servidores
            for i, serverData in ipairs(serverList) do
                if i <= 10 then -- Mostrar solo top 10
                    createServerItem(serverData, scrollFrame)
                end
            end
            
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #serverList * 85)
            return
        end
        
        serversScanned = serversScanned + 1
        statusLabel.Text = string.format("Escaneando servidor %d/%d...", serversScanned, maxServers)
        
        -- Analizar servidor actual antes de saltar
        local currentServerData = analyzeCurrentServer()
        if currentServerData.score > 50 then  -- Solo guardar servidores "buenos"
            table.insert(serverList, currentServerData)
        end
        
        -- Saltar al siguiente servidor
        wait(1) -- Pequeña pausa para evitar rate limiting
        TeleportService:Teleport(gameId, LocalPlayer)
    end
    
    -- Iniciar el primer escaneo
    scanNextServer()
end

-- Crear GUI
gui = createGUI()

print("✅ Steal A Fish Server Hopper cargado!")
print("📱 Optimizado para Android/KRNL")
print("🎮 ¡Listo para encontrar los mejores servidores!")