-- Simple Server Scanner para Steal A Fish - Android/KRNL
-- Solo busca servidores y muestra cantidad de jugadores

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local gameId = game.PlaceId

-- Variables
local isScanning = false
local serverList = {}
local maxServers = 15

-- Crear GUI simple y funcional
local function createGUI()
    -- Eliminar GUI anterior
    if PlayerGui:FindFirstChild("SimpleServerScanner") then
        PlayerGui:FindFirstChild("SimpleServerScanner"):Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SimpleServerScanner"
    screenGui.Parent = PlayerGui
    screenGui.ResetOnSpawn = false
    
    -- Marco principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 3
    mainFrame.BorderColor3 = Color3.fromRGB(80, 120, 200)
    mainFrame.BackgroundTransparency = 0
    mainFrame.Visible = true
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = mainFrame
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -10, 0, 40)
    title.Position = UDim2.new(0, 5, 0, 5)
    title.BackgroundColor3 = Color3.fromRGB(50, 100, 180)
    title.BackgroundTransparency = 0
    title.BorderSizePixel = 0
    title.Text = "🔍 SIMPLE SERVER SCANNER"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.TextScaled = false
    title.Font = Enum.Font.SourceSansBold
    title.TextStrokeTransparency = 0.5
    title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    title.Visible = true
    title.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = title
    
    -- Botón escanear
    local scanBtn = Instance.new("TextButton")
    scanBtn.Name = "ScanButton"
    scanBtn.Size = UDim2.new(0, 160, 0, 40)
    scanBtn.Position = UDim2.new(0, 10, 0, 55)
    scanBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
    scanBtn.BackgroundTransparency = 0
    scanBtn.BorderSizePixel = 2
    scanBtn.BorderColor3 = Color3.fromRGB(40, 120, 40)
    scanBtn.Text = "🔍 BUSCAR SERVIDORES"
    scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    scanBtn.TextSize = 16
    scanBtn.TextScaled = false
    scanBtn.Font = Enum.Font.SourceSansBold
    scanBtn.TextStrokeTransparency = 0.5
    scanBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    scanBtn.Visible = true
    scanBtn.Active = true
    scanBtn.Parent = mainFrame
    
    -- Botón detener
    local stopBtn = Instance.new("TextButton")
    stopBtn.Name = "StopButton"
    stopBtn.Size = UDim2.new(0, 160, 0, 40)
    stopBtn.Position = UDim2.new(0, 180, 0, 55)
    stopBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    stopBtn.BackgroundTransparency = 0
    stopBtn.BorderSizePixel = 2
    stopBtn.BorderColor3 = Color3.fromRGB(120, 40, 40)
    stopBtn.Text = "⏹️ DETENER"
    stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopBtn.TextSize = 16
    stopBtn.TextScaled = false
    stopBtn.Font = Enum.Font.SourceSansBold
    stopBtn.TextStrokeTransparency = 0.5
    stopBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    stopBtn.Visible = false
    stopBtn.Active = true
    stopBtn.Parent = mainFrame
    
    local scanCorner = Instance.new("UICorner")
    scanCorner.CornerRadius = UDim.new(0, 6)
    scanCorner.Parent = scanBtn
    
    local stopCorner = Instance.new("UICorner")
    stopCorner.CornerRadius = UDim.new(0, 6)
    stopCorner.Parent = stopBtn
    
    -- Lista de servidores
    local serverList = Instance.new("ScrollingFrame")
    serverList.Name = "ServerList"
    serverList.Size = UDim2.new(0, 330, 0, 250)
    serverList.Position = UDim2.new(0, 10, 0, 105)
    serverList.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    serverList.BackgroundTransparency = 0
    serverList.BorderSizePixel = 2
    serverList.BorderColor3 = Color3.fromRGB(70, 70, 80)
    serverList.ScrollBarThickness = 10
    serverList.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
    serverList.ScrollBarImageTransparency = 0
    serverList.CanvasSize = UDim2.new(0, 0, 0, 0)
    serverList.Visible = true
    serverList.Active = true
    serverList.Parent = mainFrame
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 8)
    listCorner.Parent = serverList
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    listLayout.Parent = serverList
    
    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingAll = UDim.new(0, 5)
    listPadding.Parent = serverList
    
    -- Estado
    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Size = UDim2.new(0, 330, 0, 25)
    status.Position = UDim2.new(0, 10, 0, 365)
    status.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    status.BackgroundTransparency = 0
    status.BorderSizePixel = 1
    status.BorderColor3 = Color3.fromRGB(80, 80, 90)
    status.Text = "✅ Listo para buscar servidores"
    status.TextColor3 = Color3.fromRGB(150, 255, 150)
    status.TextSize = 14
    status.TextScaled = false
    status.Font = Enum.Font.SourceSans
    status.TextStrokeTransparency = 0.7
    status.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    status.Visible = true
    status.Parent = mainFrame
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 4)
    statusCorner.Parent = status
    
    -- Botón cerrar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 8)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeBtn.BackgroundTransparency = 0
    closeBtn.BorderSizePixel = 1
    closeBtn.BorderColor3 = Color3.fromRGB(150, 40, 40)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 16
    closeBtn.TextScaled = false
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.Visible = true
    closeBtn.Active = true
    closeBtn.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeBtn
    
    -- Arrastrar GUI
    local dragging = false
    local dragStart, startPos
    
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    title.InputChanged:Connect(function(input)
        if dragging and dragStart and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    title.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- Eventos de botones
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    scanBtn.MouseButton1Click:Connect(function()
        if not isScanning then
            startScan(scanBtn, stopBtn, status, serverList)
        end
    end)
    
    stopBtn.MouseButton1Click:Connect(function()
        isScanning = false
        scanBtn.Visible = true
        stopBtn.Visible = false
        status.Text = "⏹️ Escaneo detenido"
        status.TextColor3 = Color3.fromRGB(255, 150, 100)
    end)
    
    return screenGui, serverList, status, scanBtn, stopBtn
end

-- Función simple para obtener info del servidor
local function getServerInfo()
    return {
        serverId = game.JobId,
        players = #Players:GetPlayers(),
        serverNumber = math.random(1, 999)
    }
end

-- Crear item de servidor en la lista
local function createServerItem(serverData, parent)
    local item = Instance.new("Frame")
    item.Size = UDim2.new(1, -10, 0, 60)
    item.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
    item.BackgroundTransparency = 0
    item.BorderSizePixel = 2
    item.BorderColor3 = Color3.fromRGB(80, 80, 95)
    item.Visible = true
    item.Parent = parent
    
    local itemCorner = Instance.new("UICorner")
    itemCorner.CornerRadius = UDim.new(0, 6)
    itemCorner.Parent = item
    
    -- Indicador de jugadores
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 6, 1, 0)
    indicator.Position = UDim2.new(0, 0, 0, 0)
    indicator.BorderSizePixel = 0
    indicator.BackgroundTransparency = 0
    indicator.Parent = item
    
    if serverData.players >= 15 then
        indicator.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- Verde para muchos jugadores
    elseif serverData.players >= 8 then
        indicator.BackgroundColor3 = Color3.fromRGB(200, 150, 50) -- Amarillo para jugadores medios
    else
        indicator.BackgroundColor3 = Color3.fromRGB(200, 80, 80) -- Rojo para pocos jugadores
    end
    
    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(0, 6)
    indCorner.Parent = indicator
    
    -- Info del servidor
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(0, 200, 1, 0)
    info.Position = UDim2.new(0, 15, 0, 0)
    info.BackgroundTransparency = 1
    info.Text = string.format("🎮 Servidor #%d\n👥 Jugadores: %d", serverData.serverNumber, serverData.players)
    info.TextColor3 = Color3.fromRGB(255, 255, 255)
    info.TextSize = 14
    info.TextScaled = false
    info.Font = Enum.Font.SourceSans
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.TextYAlignment = Enum.TextYAlignment.Center
    info.TextStrokeTransparency = 0.8
    info.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    info.Visible = true
    info.Parent = item
    
    -- Botón unirse
    local joinBtn = Instance.new("TextButton")
    joinBtn.Size = UDim2.new(0, 80, 0, 35)
    joinBtn.Position = UDim2.new(1, -90, 0.5, -17)
    joinBtn.BackgroundColor3 = Color3.fromRGB(50, 130, 200)
    joinBtn.BackgroundTransparency = 0
    joinBtn.BorderSizePixel = 2
    joinBtn.BorderColor3 = Color3.fromRGB(30, 90, 150)
    joinBtn.Text = "UNIRSE"
    joinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    joinBtn.TextSize = 14
    joinBtn.TextScaled = false
    joinBtn.Font = Enum.Font.SourceSansBold
    joinBtn.TextStrokeTransparency = 0.8
    joinBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    joinBtn.Visible = true
    joinBtn.Active = true
    joinBtn.Parent = item
    
    local joinCorner = Instance.new("UICorner")
    joinCorner.CornerRadius = UDim.new(0, 5)
    joinCorner.Parent = joinBtn
    
    -- Evento para unirse - SOLO MANUAL
    joinBtn.MouseButton1Click:Connect(function()
        print("Uniéndose al servidor manualmente...")
        joinBtn.Text = "UNIENDO..."
        joinBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        
        wait(0.5)
        
        -- Unirse solo cuando se presiona el botón
        local success = pcall(function()
            if serverData.serverId and serverData.serverId ~= "" and serverData.serverId ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(gameId, serverData.serverId, LocalPlayer)
            else
                TeleportService:Teleport(gameId, LocalPlayer)
            end
        end)
        
        if not success then
            joinBtn.Text = "ERROR"
            joinBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            wait(2)
            joinBtn.Text = "UNIRSE"
            joinBtn.BackgroundColor3 = Color3.fromRGB(50, 130, 200)
        end
    end)
    
    return item
end

-- Función principal de escaneo
function startScan(scanBtn, stopBtn, status, serverListFrame)
    if isScanning then return end
    
    print("=== INICIANDO ESCANEO SIMPLE DE SERVIDORES ===")
    isScanning = true
    serverList = {}
    local scanCount = 0
    
    scanBtn.Visible = false
    stopBtn.Visible = true
    status.Text = "🔍 Escaneando servidores..."
    status.TextColor3 = Color3.fromRGB(255, 200, 100)
    
    -- Limpiar lista anterior
    for _, child in pairs(serverListFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Función para escanear siguiente servidor
    local function scanNext()
        if not isScanning or scanCount >= maxServers then
            -- Terminar escaneo
            isScanning = false
            scanBtn.Visible = true
            stopBtn.Visible = false
            status.Text = string.format("✅ Completado: %d servidores encontrados", #serverList)
            status.TextColor3 = Color3.fromRGB(150, 255, 150)
            
            -- Ordenar por cantidad de jugadores
            table.sort(serverList, function(a, b) return a.players > b.players end)
            
            -- Recrear lista ordenada
            for _, child in pairs(serverListFrame:GetChildren()) do
                if child:IsA("Frame") then child:Destroy() end
            end
            
            for i, data in ipairs(serverList) do
                if i <= 10 then -- Mostrar top 10
                    createServerItem(data, serverListFrame)
                end
            end
            
            serverListFrame.CanvasSize = UDim2.new(0, 0, 0, math.min(#serverList, 10) * 65)
            print("=== ESCANEO TERMINADO ===")
            return
        end
        
        scanCount = scanCount + 1
        status.Text = string.format("🔄 Escaneando servidor %d/%d...", scanCount, maxServers)
        
        -- Obtener info del servidor actual
        wait(1.5)
        local serverData = getServerInfo()
        
        print(string.format("Servidor encontrado: %d jugadores", serverData.players))
        
        -- Agregar a la lista (todos los servidores, sin filtros)
        table.insert(serverList, serverData)
        createServerItem(serverData, serverListFrame)
        serverListFrame.CanvasSize = UDim2.new(0, 0, 0, #serverList * 65)
        
        -- Pausa antes de saltar al siguiente
        wait(1.5)
        
        -- Saltar al siguiente servidor para escanear
        if isScanning then
            print("Saltando al siguiente servidor...")
            TeleportService:Teleport(gameId, LocalPlayer)
        end
    end
    
    -- Empezar escaneo
    wait(1)
    scanNext()
end

-- Inicializar
wait(1)
createGUI()

print("✅ SIMPLE SERVER SCANNER CARGADO!")
print("🎮 Busca servidores mostrando solo cantidad de jugadores")
print("🔍 NO se une automáticamente - TÚ eliges")
print("▶️ Presiona 'BUSCAR SERVIDORES' para empezar")

-- Notificación
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "🔍 Server Scanner Cargado";
    Text = "Busca servidores simples. ¡NO se une automáticamente!";
    Duration = 5;
})