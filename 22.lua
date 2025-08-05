-- Servicios
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local gameId = game.PlaceId

-- Configuración
local maxServersToScan = 15
local minFishValue = 1000000000000 -- 1T mínimo por pez
local minMoney = 50000000000000 -- 50T mínimo dinero
local scanned = {}
local serverResults = {}

-- Interfaz GUI
local function createGui()
    local g = Instance.new("ScreenGui", PlayerGui)
    g.Name = "FishScannerGui"
    g.ResetOnSpawn = false
    local frame = Instance.new("Frame", g)
    frame.Size = UDim2.new(0, 360, 0, 480)
    frame.Position = UDim2.new(0.5, -180, 0.5, -240)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,30)
    frame.BorderSizePixel = 2
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -10, 0, 40)
    title.Position = UDim2.new(0,5,0,5)
    title.Text = "Fish & Rich Server Scanner"
    title.TextScaled = true
    title.TextColor3 = Color3.new(1,1,1)
    title.BackgroundTransparency = 1
    -- Botones
    local btnScan = Instance.new("TextButton", frame)
    btnScan.Text = "🔍 Escanear servidores"
    btnScan.Size = UDim2.new(0,160,0,40); btnScan.Position = UDim2.new(0,10,0,55)
    local btnStop = Instance.new("TextButton", frame)
    btnStop.Text = "⏹️ Detener"; btnStop.Size = UDim2.new(0,160,0,40); btnStop.Position = UDim2.new(0,180,0,55); btnStop.Visible = false

    -- Scroll para resultados
    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1,-20,0,350); scroll.Position = UDim2.new(0,10,0,110)
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.ScrollBarThickness = 8

    local status = Instance.new("TextLabel", frame)
    status.Size = UDim2.new(1,-20,0,25); status.Position = UDim2.new(0,10,0,470-30)
    status.Text = "Listo."
    status.TextColor3 = Color3.new(0.7,1,0.7); status.BackgroundTransparency = 1

    return {gui=g, frame=frame, btnScan=btnScan, btnStop=btnStop, scroll=scroll, status=status}
end

-- Analizar riqueza en servidor actual
local function analyzeCurrentServer()
    local players = Players:GetPlayers()
    local richestMoney = 0
    local bestFish = 0
    local richCount = 0
    for _, pl in pairs(players) do
        if pl ~= LocalPlayer then
            local money = 0
            local leader = pl:FindFirstChild("leaderstats")
            if leader then
                for _, child in pairs(leader:GetChildren()) do
                    if tonumber(child.Value) then
                        money = math.max(money, tonumber(child.Value))
                    end
                end
            end
            local fishSum = 0
            for _, loc in pairs({pl.Backpack, pl.Character}) do
                if loc then
                    for _, tool in pairs(loc:GetChildren()) do
                        if tool:IsA("Tool") then
                            local val = tool:GetAttribute("Value") or tool:GetAttribute("Worth") or tool:GetAttribute("Price") or 0
                            fishSum = fishSum + tonumber(val)
                        end
                    end
                end
            end
            if money >= minMoney or fishSum >= minFishValue then
                richCount = richCount + 1
                richestMoney = math.max(richestMoney, money)
                bestFish = math.max(bestFish, fishSum)
            end
        end
    end
    return {
        serverId = game.JobId,
        richPlayers = richCount,
        maxMoney = richestMoney,
        maxFish = bestFish
    }
end

-- Crear ítem de servidor
local function displayServer(data, parent)
    local frm = Instance.new("Frame", parent)
    frm.Size = UDim2.new(1,-10,0,80); frm.BackgroundColor3 = Color3.fromRGB(30,30,45); frm.BorderSizePixel = 1
    scroll = parent
    -- Info
    local lbl = Instance.new("TextLabel", frm)
    lbl.Size = UDim2.new(0.7,0,1,0); lbl.Position = UDim2.new(0,5,0,0)
    lbl.Text = string.format("ID:%s | Ricos:%d | MaxMoney:%s | MaxFish:%s",
        tostring(data.serverId), data.richPlayers,
        data.maxMoney>=1000000000000 and (string.format("%.1fT", data.maxMoney/1e12)) or tostring(data.maxMoney),
        data.maxFish>=1e12 and (string.format("%.1fT", data.maxFish/1e12)) or tostring(data.maxFish))
    lbl.TextScaled = true; lbl.TextColor3 = Color3.new(1,1,1); lbl.BackgroundTransparency = 1
    -- Botón Unirse
    local btn = Instance.new("TextButton", frm)
    btn.Size = UDim2.new(0.25,0,0.6,0); btn.Position = UDim2.new(0.7,0,0.2,0)
    btn.Text = "➤ Unirse"; btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(200,180,50)
    btn.MouseButton1Click:Connect(function()
        btn.Text = "Uniendo..."
        TeleportService:TeleportToPlaceInstance(gameId, data.serverId, LocalPlayer)
    end)
    parent.CanvasSize = UDim2.new(0,0,#parent:GetChildren()*85)
end

-- Lógica principal
local ui = createGui()
local scanning = false
ui.btnScan.MouseButton1Click:Connect(function()
    if scanning then return end
    scanning = true
    ui.btnScan.Visible = false; ui.btnStop.Visible = true
    ui.status.Text = "Escaneando servidores..."
    local count = 0
    local function nextScan()
        if not scanning or count >= maxServersToScan then
            scanning = false
            ui.btnScan.Visible = true; ui.btnStop.Visible = false
            ui.status.Text = "Escaneo completado."
            return
        end
        count += 1
        ui.status.Text = ("Analizando servidor %d/%d"):format(count, maxServersToScan)
        wait(2)
        local info = analyzeCurrentServer()
        table.insert(serverResults, info)
        displayServer(info, ui.scroll)
        wait(1)
        TeleportService:Teleport(gameId, LocalPlayer)
    end
    nextScan()
end)

ui.btnStop.MouseButton1Click:Connect(function()
    scanning = false
    ui.btnScan.Visible = true; ui.btnStop.Visible = false
    ui.status.Text = "Escaneo detenido por ti."
end)

print("Script cargado: FishScanner funcional.")