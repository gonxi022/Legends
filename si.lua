-- STEAL A FISH REAL SERVER HOPPER - ANDROID KRNL
-- Busca servidores con jugadores que tienen peces caros reales
-- NO se une automáticamente - TÚ eliges el servidor

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local gameId = game.PlaceId

-- Variables globales
local isScanning = false
local foundServers = {}
local scanCount = 0
local maxScans = 18
local myOriginalServerId = game.JobId

-- Mutaciones y peces raros conocidos en Steal A Fish
local rareFishTypes = {
    -- Mutaciones raras
    "magma", "crystal", "void", "shadow", "golden", "rainbow", "prismatic",
    "diamond", "platinum", "cosmic", "celestial", "mythic", "legendary",
    -- Peces caros comunes
    "shark", "whale", "octopus", "ray", "swordfish", "marlin", "tuna",
    "bass", "salmon", "trout", "cod", "halibut", "mackerel"
}

-- Crear GUI desde cero para Android
local function createMobileGUI()
    -- Eliminar GUI anterior si existe
    local existingGUI = PlayerGui:FindFirstChild("StealFishRealHopper")
    if existingGUI then
        existingGUI:Destroy()
    end
    
    -- Crear ScreenGui principal
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StealFishRealHopper"
    screenGui.Parent = PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Marco principal (tamaño móvil)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 370, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -185, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.new(0.08, 0.08, 0.15)
    mainFrame.BackgroundTransparency = 0
    mainFrame.BorderSizePixel = 4
    mainFrame.BorderColor3 = Color3.new(0.2, 0.6, 0.9)
    mainFrame.Active = true
    mainFrame.Visible = true
    mainFrame.Parent = screenGui
    
    -- Esquinas redondeadas
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 15)
    mainCorner.Parent = mainFrame
    
    -- Título principal
    local titleFrame = Instance.new("Frame")
    titleFrame.Size = UDim2.new(1, -8, 0, 50)
    titleFrame.Position = UDim2.new(0, 4, 0, 4)
    titleFrame.BackgroundColor3 = Color3.new(0.1, 0.4, 0.8)
    titleFrame.BackgroundTransparency = 0
    titleFrame.BorderSizePixel = 0
    titleFrame.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🐟 STEAL A FISH HOPPER 🐟"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextSize = 20
    titleLabel.TextScaled = false
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextStrokeTransparency = 0.3
    titleLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    titleLabel.Parent = titleFrame
    
    -- Info de búsqueda
    local infoFrame = Instance.new("Frame")
    infoFrame.Size = UDim2.new(1, -8, 0, 35)
    infoFrame.Position = UDim2.new(0, 4, 0, 60)
    infoFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.25)
    infoFrame.BackgroundTransparency = 0
    infoFrame.BorderSizePixel = 1
    infoFrame.BorderColor3 = Color3.new(0.3, 0.3, 0.4)
    infoFrame.Parent = mainFrame
    
    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 8)
    infoCorner.Parent = infoFrame
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, 0, 1, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "🎯 Buscando: Peces raros, mutaciones, jugadores con rebirths"
    infoLabel.TextColor3 = Color3.new(0.8, 1, 0.8)
    infoLabel.TextSize = 14
    infoLabel.TextScaled = true
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.TextStrokeTransparency = 0.7
    infoLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    infoLabel.Parent = infoFrame
    
    -- Botones de control
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, -8, 0, 45)
    buttonFrame.Position = UDim2.new(0, 4, 0, 105)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = mainFrame
    
    -- Botón escanear
    local scanButton = Instance.new("TextButton")
    scanButton.Name = "ScanButton"
    scanButton.Size = UDim2.new(0.48, 0, 1, 0)
    scanButton.Position = UDim2.new(0, 0, 0, 0)
    scanButton.BackgroundColor3 = Color3.new(0.1, 0.7, 0.1)
    scanButton.BackgroundTransparency = 0
    scanButton.BorderSizePixel = 2
    scanButton.BorderColor3 = Color3.new(0.05, 0.4, 0.05)
    scanButton.Text = "🔍 BUSCAR PECES"
    scanButton.TextColor3 = Color3.new(1, 1, 1)
    scanButton.TextSize = 18
    scanButton.TextScaled = false
    scanButton.Font = Enum.Font.SourceSansBold
    scanButton.TextStrokeTransparency = 0.5
    scanButton.TextStrokeColor3 = Color3.new(0, 0, 0)
    scanButton.Active = true
    scanButton.Visible = true
    scanButton.Parent = buttonFrame
    
    -- Botón detener
    local stopButton = Instance.new("TextButton")
    stopButton.Name = "StopButton"
    stopButton.Size = UDim2.new(0.48, 0, 1, 0)
    stopButton.Position = UDim2.new(0.52, 0, 0, 0)
    stopButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    stopButton.BackgroundTransparency = 0
    stopButton.BorderSizePixel = 2
    stopButton.BorderColor3 = Color3.new(0.5, 0.1, 0.1)
    stopButton.Text = "⏹️ DETENER"
    stopButton.TextColor3 = Color3.new(1, 1, 1)
    stopButton.TextSize = 18
    stopButton.TextScaled = false
    stopButton.Font = Enum.Font.SourceSansBold
    stopButton.TextStrokeTransparency = 0.5
    stopButton.TextStrokeColor3 = Color3.new(0, 0, 0)
    stopButton.Active = true
    stopButton.Visible = false
    stopButton.Parent = buttonFrame
    
    local scanCorner = Instance.new("UICorner")
    scanCorner.CornerRadius = UDim.new(0, 8)
    scanCorner.Parent = scanButton
    
    local stopCorner = Instance.new("UICorner")
    stopCorner.CornerRadius = UDim.new(0, 8)
    stopCorner.Parent = stopButton
    
    -- Lista de servidores con scroll
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ServerList"
    scrollFrame.Size = UDim2.new(1, -8, 0, 250)
    scrollFrame.Position = UDim2.new(0, 4, 0, 160)
    scrollFrame.BackgroundColor3 = Color3.new(0.12, 0.12, 0.2)
    scrollFrame.BackgroundTransparency = 0
    scrollFrame.BorderSizePixel = 2
    scrollFrame.BorderColor3 = Color3.new(0.25, 0.25, 0.35)
    scrollFrame.ScrollBarThickness = 12
    scrollFrame.ScrollBarImageColor3 = Color3.new(0.4, 0.4, 0.5)
    scrollFrame.ScrollBarImageTransparency = 0
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Active = true
    scrollFrame.Visible = true
    scrollFrame.Parent = mainFrame
    
    local scrollCorner = Instance.new("UICorner")
    scrollCorner.CornerRadius = UDim.new(0, 10)
    scrollCorner.Parent = scrollFrame
    
    -- Layout para la lista
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 6)
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    listLayout.Parent = scrollFrame
    
    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingTop = UDim.new(0, 8)
    listPadding.PaddingBottom = UDim.new(0, 8)
    listPadding.PaddingLeft = UDim.new(0, 8)
    listPadding.PaddingRight = UDim.new(0, 8)
    listPadding.Parent = scrollFrame
    
    -- Estado del escaneo
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(1, -8, 0, 25)
    statusFrame.Position = UDim2.new(0, 4, 0, 418)
    statusFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.3)
    statusFrame.BackgroundTransparency = 0
    statusFrame.BorderSizePixel = 1
    statusFrame.BorderColor3 = Color3.new(0.4, 0.4, 0.5)
    statusFrame.Parent = mainFrame
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 6)
    statusCorner.Parent = statusFrame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, 0, 1, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "✅ Listo para buscar servidores con peces caros"
    statusLabel.TextColor3 = Color3.new(0.6, 1, 0.6)
    statusLabel.TextSize = 13
    statusLabel.TextScaled = false
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.TextStrokeTransparency = 0.7
    statusLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    statusLabel.Parent = statusFrame
    
    -- Botón cerrar
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 35, 0, 35)
    closeButton.Position = UDim2.new(1, -40, 0, 10)
    closeButton.BackgroundColor3 = Color3.new(0.9, 0.2, 0.2)
    closeButton.BackgroundTransparency = 0
    closeButton.BorderSizePixel = 2
    closeButton.BorderColor3 = Color3.new(0.6, 0.1, 0.1)
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextSize = 18
    closeButton.TextScaled = false
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Active = true
    closeButton.Visible = true
    closeButton.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 17)
    closeCorner.Parent = closeButton
    
    -- Sistema de arrastrar para móvil
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    titleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    titleFrame.InputChanged:Connect(function(input)
        if dragging and dragStart and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    titleFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- Eventos de botones
    closeButton.MouseButton1Click:Connect(function()
        print("Cerrando Steal A Fish Hopper...")
        screenGui:Destroy()
    end)
    
    scanButton.MouseButton1Click:Connect(function()
        if not isScanning then
            startServerScanning(scanButton, stopButton, statusLabel, scrollFrame)
        end
    end)
    
    stopButton.MouseButton1Click:Connect(function()
        print("Deteniendo escaneo...")
        isScanning = false
        scanButton.Visible = true
        stopButton.Visible = false
        statusLabel.Text = "⏹️ Escaneo detenido por el usuario"
        statusLabel.TextColor3 = Color3.new(1, 0.7, 0.3)
    end)
    
    return screenGui, scrollFrame, statusLabel, scanButton, stopButton
end

-- Función para analizar el servidor actual buscando peces reales
local function analyzeServerForFish()
    local serverData = {
        serverId = game.JobId,
        playerCount = #Players:GetPlayers(),
        fishFound = {},
        rareFishCount = 0,
        rebirthPlayers = 0,
        totalValue = 0,
        topPlayer = "Ninguno",
        maxMoney = 0,
        isGoodServer = false
    }
    
    -- Analizar cada jugador en el servidor
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local playerMoney = 0
            local playerRebirths = 0
            local playerFish = {}
            
            -- Buscar dinero en leaderstats
            local leaderstats = player:FindFirstChild("leaderstats")
            if leaderstats then
                -- Buscar dinero
                local money = leaderstats:FindFirstChild("Money") or leaderstats:FindFirstChild("Cash") or leaderstats:FindFirstChild("Coins")
                if money and tonumber(money.Value) then
                    playerMoney = tonumber(money.Value)
                    if playerMoney > serverData.maxMoney then
                        serverData.maxMoney = playerMoney
                        serverData.topPlayer = player.DisplayName or player.Name
                    end
                end
                
                -- Buscar rebirths
                local rebirths = leaderstats:FindFirstChild("Rebirths") or leaderstats:FindFirstChild("Rebirth")
                if rebirths and tonumber(rebirths.Value) then
                    playerRebirths = tonumber(rebirths.Value)
                    if playerRebirths > 0 then
                        serverData.rebirthPlayers = serverData.rebirthPlayers + 1
                    end
                end
            end
            
            -- Buscar peces en el workspace (casas/bases de jugadores)
            if Workspace:FindFirstChild("Houses") or Workspace:FindFirstChild("Plots") or Workspace:FindFirstChild("Bases") then
                local housesFolder = Workspace:FindFirstChild("Houses") or Workspace:FindFirstChild("Plots") or Workspace:FindFirstChild("Bases")
                
                for _, house in pairs(housesFolder:GetChildren()) do
                    -- Buscar si esta casa pertenece al jugador
                    local owner = house:GetAttribute("Owner") or house:FindFirstChild("Owner")
                    if owner and (owner == player.Name or owner.Value == player.Name) then
                        -- Buscar peces en la casa
                        local fishFolder = house:FindFirstChild("Fish") or house:FindFirstChild("FishCollection") or house:FindFirstChild("Aquarium")
                        if fishFolder then
                            for _, fishItem in pairs(fishFolder:GetChildren()) do
                                if fishItem:IsA("Model") or fishItem:IsA("Part") or fishItem:IsA("Tool") then
                                    local fishName = string.lower(fishItem.Name)
                                    
                                    -- Detectar peces raros
                                    for _, rareFish in pairs(rareFishTypes) do
                                        if string.find(fishName, rareFish) then
                                            table.insert(serverData.fishFound, {
                                                player = player.DisplayName or player.Name,
                                                fish = fishItem.Name,
                                                type = rareFish
                                            })
                                            serverData.rareFishCount = serverData.rareFishCount + 1
                                            break
                                        end
                                    end
                                    
                                    -- Detectar mutaciones por efectos visuales
                                    if fishItem:FindFirstChild("Sparkles") or fishItem:FindFirstChild("Fire") or fishItem:FindFirstChild("PointLight") then
                                        table.insert(serverData.fishFound, {
                                            player = player.DisplayName or player.Name,
                                            fish = fishItem.Name,
                                            type = "mutation"
                                        })
                                        serverData.rareFishCount = serverData.rareFishCount + 1
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            -- Buscar peces en el inventario del jugador
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                for _, tool in pairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") then
                        local toolName = string.lower(tool.Name)
                        for _, rareFish in pairs(rareFishTypes) do
                            if string.find(toolName, rareFish) then
                                table.insert(serverData.fishFound, {
                                    player = player.DisplayName or player.Name,
                                    fish = tool.Name,
                                    type = rareFish
                                })
                                serverData.rareFishCount = serverData.rareFishCount + 1
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Calcular si este servidor vale la pena
    local moneyScore = math.floor(serverData.maxMoney / 1000000) -- Millones
    local fishScore = serverData.rareFishCount * 50
    local rebirthScore = serverData.rebirthPlayers * 100
    local playerScore = serverData.playerCount * 10
    
    serverData.totalValue = moneyScore + fishScore + rebirthScore + playerScore
    serverData.isGoodServer = (serverData.rareFishCount > 0 or serverData.rebirthPlayers > 0 or serverData.maxMoney > 1000000)
    
    return serverData
end

-- Crear elemento de servidor en la lista
local function createServerListItem(serverData, parent)
    local serverFrame = Instance.new("Frame")
    serverFrame.Size = UDim2.new(1, -10, 0, 85)
    serverFrame.BackgroundColor3 = Color3.new(0.18, 0.18, 0.28)
    serverFrame.BackgroundTransparency = 0
    serverFrame.BorderSizePixel = 2
    serverFrame.BorderColor3 = Color3.new(0.35, 0.35, 0.45)
    serverFrame.Visible = true
    serverFrame.Parent = parent
    
    local serverCorner = Instance.new("UICorner")
    serverCorner.CornerRadius = UDim.new(0, 8)
    serverCorner.Parent = serverFrame
    
    -- Indicador de calidad lateral
    local qualityBar = Instance.new("Frame")
    qualityBar.Size = UDim2.new(0, 8, 1, 0)
    qualityBar.Position = UDim2.new(0, 0, 0, 0)
    qualityBar.BorderSizePixel = 0
    qualityBar.BackgroundTransparency = 0
    qualityBar.Parent = serverFrame
    
    -- Color según calidad del servidor
    if serverData.rareFishCount >= 5 or serverData.rebirthPlayers >= 3 then
        qualityBar.BackgroundColor3 = Color3.new(0.9, 0.1, 0.9) -- Magenta para súper buenos
    elseif serverData.rareFishCount >= 2 or serverData.rebirthPlayers >= 1 then
        qualityBar.BackgroundColor3 = Color3.new(1, 0.8, 0.1) -- Dorado para buenos
    else
        qualityBar.BackgroundColor3 = Color3.new(0.7, 0.7, 0.7) -- Gris para regulares
    end
    
    local qualityCorner = Instance.new("UICorner")
    qualityCorner.CornerRadius = UDim.new(0, 8)
    qualityCorner.Parent = qualityBar
    
    -- Información del servidor
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(0, 220, 1, 0)
    infoLabel.Position = UDim2.new(0, 15, 0, 0)
    infoLabel.BackgroundTransparency = 1
    
    local moneyText = serverData.maxMoney >= 1000000 and string.format("%.1fM", serverData.maxMoney/1000000) or string.format("%.0fK", serverData.maxMoney/1000)
    
    infoLabel.Text = string.format("🎯 Valor: %d | 👥 Jugadores: %d\n🐟 Peces Raros: %d | 🔄 Rebirths: %d\n💰 Max Dinero: $%s | 👑 Top: %s", 
        serverData.totalValue, 
        serverData.playerCount,
        serverData.rareFishCount, 
        serverData.rebirthPlayers,
        moneyText,
        string.len(serverData.topPlayer) > 12 and string.sub(serverData.topPlayer, 1, 12).."..." or serverData.topPlayer
    )
    infoLabel.TextColor3 = Color3.new(1, 1, 1)
    infoLabel.TextSize = 12
    infoLabel.TextScaled = false
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextYAlignment = Enum.TextYAlignment.Center
    infoLabel.TextStrokeTransparency = 0.8
    infoLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    infoLabel.Parent = serverFrame
    
    -- Botón unirse (SOLO MANUAL)
    local joinButton = Instance.new("TextButton")
    joinButton.Size = UDim2.new(0, 90, 0, 50)
    joinButton.Position = UDim2.new(1, -100, 0.5, -25)
    joinButton.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
    joinButton.BackgroundTransparency = 0
    joinButton.BorderSizePixel = 2
    joinButton.BorderColor3 = Color3.new(0.1, 0.4, 0.1)
    joinButton.Text = "🎣 UNIRSE"
    joinButton.TextColor3 = Color3.new(1, 1, 1)
    joinButton.TextSize = 16
    joinButton.TextScaled = false
    joinButton.Font = Enum.Font.SourceSansBold
    joinButton.TextStrokeTransparency = 0.5
    joinButton.TextStrokeColor3 = Color3.new(0, 0, 0)
    joinButton.Active = true
    joinButton.Visible = true
    joinButton.Parent = serverFrame
    
    local joinCorner = Instance.new("UICorner")
    joinCorner.CornerRadius = UDim.new(0, 8)
    joinCorner.Parent = joinButton
    
    -- Evento MANUAL para unirse (NO automático)
    joinButton.MouseButton1Click:Connect(function()
        print("UNIÓN MANUAL iniciada para servidor:", serverData.serverId)
        joinButton.Text = "UNIENDO..."
        joinButton.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
        
        wait(0.7)
        
        -- Solo se une cuando el usuario presiona el botón manualmente
        local success = pcall(function()
            if serverData.serverId and serverData.serverId ~= "" and serverData.serverId ~= myOriginalServerId then
                print("Teleportando a servidor específico:", serverData.serverId)
                TeleportService:TeleportToPlaceInstance(gameId, serverData.serverId, LocalPlayer)
            else
                print("Teleportando a servidor aleatorio del juego")
                TeleportService:Teleport(gameId, LocalPlayer)
            end
        end)
        
        if not success then
            print("Error en teleportación")
            joinButton.Text = "ERROR"
            joinButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
            wait(2.5)
            joinButton.Text = "🎣 UNIRSE"
            joinButton.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
        end
    end)
    
    return serverFrame
end

-- Función principal de escaneo de servidores
function startServerScanning(scanBtn, stopBtn, statusLabel, serverListFrame)
    if isScanning then 
        print("Ya hay un escaneo en progreso")
        return 
    end
    
    print("=== INICIANDO ESCANEO REAL DE STEAL A FISH ===")
    isScanning = true
    foundServers = {}
    scanCount = 0
    
    -- Cambiar estado de botones
    scanBtn.Visible = false
    stopBtn.Visible = true
    statusLabel.Text = "🔍 Iniciando búsqueda de servidores con peces raros..."
    statusLabel.TextColor3 = Color3.new(1, 0.8, 0.4)
    
    -- Limpiar lista anterior
    for _, child in pairs(serverListFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Función recursiva para escanear servidores
    local function scanNextServer()
        if not isScanning then 
            print("Escaneo cancelado por el usuario")
            return 
        end
        
        if scanCount >= maxScans then
            -- Terminar el escaneo
            print("Límite de escaneos alcanzado")
            isScanning = false
            scanBtn.Visible = true
            stopBtn.Visible = false
            statusLabel.Text = string.format("✅ Escaneo completado: %d servidores con peces encontrados", #foundServers)
            statusLabel.TextColor3 = Color3.new(0.6, 1, 0.6)
            
            -- Ordenar servidores por valor total
            table.sort(foundServers, function(a, b) 
                return a.totalValue > b.totalValue 
            end)
            
            -- Recrear lista ordenada
            for _, child in pairs(server
-- Recrear lista ordenada
            for _, child in pairs(serverListFrame:GetChildren()) do
                if child:IsA("Frame") then 
                    child:Destroy() 
                end
            end
            
            -- Mostrar solo los mejores servidores
            for i, serverData in ipairs(foundServers) do
                if i <= 8 then -- Top 8 servidores
                    createServerListItem(serverData, serverListFrame)
                end
            end
            
            -- Actualizar tamaño del canvas
            serverListFrame.CanvasSize = UDim2.new(0, 0, 0, math.min(#foundServers, 8) * 91)
            print("=== ESCANEO TERMINADO - LISTA MOSTRADA ===")
            return
        end
        
        scanCount = scanCount + 1
        statusLabel.Text = string.format("🔄 Analizando servidor %d/%d...", scanCount, maxScans)
        
        -- Esperar para analizar el servidor actual
        wait(2)
        
        -- Analizar servidor actual en busca de peces
        local currentServerData = analyzeServerForFish()
        print(string.format("Servidor %d analizado: %d peces raros, %d jugadores con rebirths", 
            scanCount, currentServerData.rareFishCount, currentServerData.rebirthPlayers))
        
        -- Solo agregar servidores que valgan la pena
        if currentServerData.isGoodServer and currentServerData.serverId ~= myOriginalServerId then
            table.insert(foundServers, currentServerData)
            createServerListItem(currentServerData, serverListFrame)
            serverListFrame.CanvasSize = UDim2.new(0, 0, 0, #foundServers * 91)
            print("✅ Servidor valioso agregado a la lista")
        else
            print("❌ Servidor descartado (no tiene peces valiosos o es el servidor original)")
        end
        
        -- Pausa antes de saltar al siguiente servidor
        wait(2)
        
        -- Saltar al siguiente servidor SOLO para escanear (NO para unirse)
        if isScanning then
            print("Saltando al siguiente servidor para continuar escaneando...")
            TeleportService:Teleport(gameId, LocalPlayer)
        end
    end
    
    -- Iniciar el primer escaneo después de una pequeña pausa
    wait(1.5)
    scanNextServer()
end

-- Inicializar el hopper
print("Inicializando Steal A Fish Real Hopper...")
wait(1)

-- Crear la GUI
local gui, serverListFrame, statusLabel, scanButton, stopButton = createMobileGUI()

-- Mensajes de confirmación
print("✅ STEAL A FISH REAL HOPPER CARGADO CORRECTAMENTE!")
print("🎣 Busca servidores con peces raros reales del juego")
print("🔍 Analiza mutaciones, rebirths, y colecciones de peces")
print("📱 Optimizado para Android/KRNL sin errores visuales") 
print("🎯 NO se une automáticamente - TÚ eliges el servidor")
print("▶️ Presiona 'BUSCAR PECES' para empezar el escaneo")

-- Notificación en pantalla
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "🐟 Steal A Fish Hopper Cargado";
    Text = "¡Busca servidores con peces raros! NO se une automáticamente.";
    Duration = 6;
})