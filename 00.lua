-- 🌲 H2K MOD MENU - 99 NIGHTS IN THE FOREST
-- Mod completo con Kill All, Speed, Infinite Jump, Insta Chests
-- Compatible Android Krnl - By H2K

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Services y Referencias
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ItemsFolder = Workspace:WaitForChild("Items")

-- Estados del mod
local ModState = {
    killAll = false,
    speed = false,
    infiniteJump = false,
    instaChests = false,
    bringScrap = false,
    isOpen = false,
    minimized = false
}

local Connections = {}
local originalWalkSpeed = Humanoid.WalkSpeed
local originalJumpPower = Humanoid.JumpPower

-- Herramientas y sus IDs de daño (del script original)
local toolsDamageIDs = {
    ["Old Axe"] = "1_8982038982",
    ["Good Axe"] = "112_8982038982", 
    ["Strong Axe"] = "116_8982038982",
    ["Chainsaw"] = "647_8992824875",
    ["Spear"] = "196_8999010016"
}

-- Posición del campamento
local campPosition = Vector3.new(0, 8, 0)

-- Limpiar GUI anterior
pcall(function()
    if LocalPlayer.PlayerGui:FindFirstChild("H2KNightsForest") then
        LocalPlayer.PlayerGui:FindFirstChild("H2KNightsForest"):Destroy()
    end
end)

-- Función para obtener herramienta equipable
local function getToolWithDamageID()
    for toolName, damageID in pairs(toolsDamageIDs) do
        local tool = LocalPlayer.Inventory:FindFirstChild(toolName)
        if tool then
            return tool, damageID
        end
    end
    return nil, nil
end

-- Función para equipar herramienta
local function equipTool(tool)
    if tool then
        pcall(function()
            RemoteEvents.EquipItemHandle:FireServer("FireAllClients", tool)
        end)
    end
end

-- Función de Kill All
local function executeKillAll()
    local character = LocalPlayer.Character
    if not character then return end
    
    local tool, damageID = getToolWithDamageID()
    if not tool or not damageID then
        return
    end
    
    equipTool(tool)
    wait(0.1)
    
    for _, mob in pairs(Workspace.Characters:GetChildren()) do
        if mob:IsA("Model") and mob ~= character then
            local part = mob:FindFirstChildWhichIsA("BasePart")
            if part then
                pcall(function()
                    RemoteEvents.ToolDamageObject:InvokeServer(
                        mob, tool, damageID, CFrame.new(part.Position)
                    )
                end)
            end
        end
    end
end

-- Función de Speed
local function toggleSpeed()
    ModState.speed = not ModState.speed
    if ModState.speed then
        Humanoid.WalkSpeed = 65
        -- Mantener velocidad activa
        Connections.speedConnection = Humanoid.Changed:Connect(function(property)
            if property == "WalkSpeed" and ModState.speed then
                Humanoid.WalkSpeed = 65
            end
        end)
    else
        if Connections.speedConnection then
            Connections.speedConnection:Disconnect()
            Connections.speedConnection = nil
        end
        Humanoid.WalkSpeed = originalWalkSpeed
    end
end

-- Función de Infinite Jump
local function toggleInfiniteJump()
    ModState.infiniteJump = not ModState.infiniteJump
    if ModState.infiniteJump then
        Connections.jumpConnection = UserInputService.JumpRequest:Connect(function()
            if ModState.infiniteJump and Humanoid then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if Connections.jumpConnection then
            Connections.jumpConnection:Disconnect()
            Connections.jumpConnection = nil
        end
    end
end

-- Función de Insta Open Chests
local function toggleInstaChests()
    ModState.instaChests = not ModState.instaChests
    if ModState.instaChests then
        Connections.chestConnection = Workspace.DescendantAdded:Connect(function(descendant)
            if ModState.instaChests and descendant:IsA("ClickDetector") then
                local parent = descendant.Parent
                if parent and (parent.Name:lower():find("chest") or parent.Name:lower():find("cofre")) then
                    wait(0.1)
                    pcall(function()
                        fireclickdetector(descendant)
                    end)
                end
            end
        end)
    else
        if Connections.chestConnection then
            Connections.chestConnection:Disconnect()
            Connections.chestConnection = nil
        end
    end
end

-- Función para traer chatarra al campamento
local function bringScrapToCamp()
    local scrapItems = {
        "UFO Junk", "UFO Component", "Old Car Engine", "Broken Fan", 
        "Old Microwave", "Bolt", "Sheet Metal", "Old Radio", "Tyre",
        "Washing Machine", "Broken Microwave"
    }
    
    for _, item in pairs(ItemsFolder:GetChildren()) do
        if table.find(scrapItems, item.Name) then
            local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
            if part then
                pcall(function()
                    RemoteEvents.RequestStartDraggingItem:FireServer(item)
                    wait(0.05)
                    item:SetPrimaryPartCFrame(CFrame.new(campPosition + Vector3.new(math.random(-5,5), 2, math.random(-5,5))))
                    wait(0.05)
                    RemoteEvents.StopDraggingItem:FireServer(item)
                end)
            end
        end
    end
end

-- Crear icono flotante H2K
local function createFloatingIcon()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "H2KIcon"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer.PlayerGui
    
    -- Icono en la esquina superior derecha
    local iconFrame = Instance.new("Frame")
    iconFrame.Name = "IconFrame"
    iconFrame.Size = UDim2.new(0, 55, 0, 55)
    iconFrame.Position = UDim2.new(1, -70, 0, 15)
    iconFrame.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
    iconFrame.BorderSizePixel = 0
    iconFrame.Parent = screenGui
    
    -- Esquinas redondeadas
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(1, 0)
    iconCorner.Parent = iconFrame
    
    -- Gradiente verde bosque
    local iconGradient = Instance.new("UIGradient")
    iconGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 139, 34)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 0))
    }
    iconGradient.Rotation = 45
    iconGradient.Parent = iconFrame
    
    -- Sombra
    local iconShadow = Instance.new("Frame")
    iconShadow.Size = UDim2.new(1, 6, 1, 6)
    iconShadow.Position = UDim2.new(0, -3, 0, -3)
    iconShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    iconShadow.BackgroundTransparency = 0.8
    iconShadow.ZIndex = iconFrame.ZIndex - 1
    iconShadow.Parent = iconFrame
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(1, 0)
    shadowCorner.Parent = iconShadow
    
    -- Texto H2K
    local iconText = Instance.new("TextLabel")
    iconText.Size = UDim2.new(1, 0, 1, 0)
    iconText.BackgroundTransparency = 1
    iconText.Text = "H2K"
    iconText.TextColor3 = Color3.fromRGB(255, 255, 255)
    iconText.TextSize = 16
    iconText.Font = Enum.Font.GothamBold
    iconText.TextStrokeTransparency = 0
    iconText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    iconText.Parent = iconFrame
    
    -- Botón clickeable
    local iconButton = Instance.new("TextButton")
    iconButton.Size = UDim2.new(1, 0, 1, 0)
    iconButton.BackgroundTransparency = 1
    iconButton.Text = ""
    iconButton.Parent = iconFrame
    
    return {
        gui = screenGui,
        frame = iconFrame,
        button = iconButton
    }
end

-- Crear mod menu principal
local function createModMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "H2KNightsForest"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer.PlayerGui
    
    -- Frame principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 340, 0, 420)
    mainFrame.Position = UDim2.new(0.5, -170, 0.5, -210)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Esquinas redondeadas
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 15)
    mainCorner.Parent = mainFrame
    
    -- Sombra
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 12, 1, 12)
    shadow.Position = UDim2.new(0, -6, 0, -6)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.8
    shadow.ZIndex = mainFrame.ZIndex - 1
    shadow.Parent = mainFrame
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 21)
    shadowCorner.Parent = shadow
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 15)
    headerCorner.Parent = header
    
    -- Gradiente header
    local headerGradient = Instance.new("UIGradient")
    headerGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 139, 34)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 0))
    }
    headerGradient.Rotation = 45
    headerGradient.Parent = header
    
    -- Logo y título
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0, 60, 1, 0)
    logo.Position = UDim2.new(0, 15, 0, 0)
    logo.BackgroundTransparency = 1
    logo.Text = "H2K"
    logo.TextColor3 = Color3.fromRGB(255, 255, 255)
    logo.TextSize = 20
    logo.Font = Enum.Font.GothamBold
    logo.TextStrokeTransparency = 0
    logo.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    logo.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -140, 1, 0)
    title.Position = UDim2.new(0, 80, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "99 Nights Forest"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.Gotham
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Botón minimizar
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(1, -70, 0, 10)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    minimizeBtn.TextSize = 18
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = header
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 6)
    minimizeCorner.Parent = minimizeBtn
    
    -- Botón cerrar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 6)
    closeBtnCorner.Parent = closeBtn
    
    -- Contenido
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -60)
    content.Position = UDim2.new(0, 10, 0, 55)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame
    
    -- Kill All
    local killAllSection = Instance.new("Frame")
    killAllSection.Size = UDim2.new(1, 0, 0, 50)
    killAllSection.Position = UDim2.new(0, 0, 0, 0)
    killAllSection.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
    killAllSection.BorderSizePixel = 0
    killAllSection.Parent = content
    
    local killAllCorner = Instance.new("UICorner")
    killAllCorner.CornerRadius = UDim.new(0, 8)
    killAllCorner.Parent = killAllSection
    
    local killAllLabel = Instance.new("TextLabel")
    killAllLabel.Size = UDim2.new(1, -80, 1, 0)
    killAllLabel.Position = UDim2.new(0, 15, 0, 0)
    killAllLabel.BackgroundTransparency = 1
    killAllLabel.Text = "Kill All Animals"
    killAllLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    killAllLabel.TextSize = 14
    killAllLabel.Font = Enum.Font.Gotham
    killAllLabel.TextXAlignment = Enum.TextXAlignment.Left
    killAllLabel.Parent = killAllSection
    
    local killAllBtn = Instance.new("TextButton")
    killAllBtn.Size = UDim2.new(0, 60, 0, 30)
    killAllBtn.Position = UDim2.new(1, -70, 0.5, -15)
    killAllBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    killAllBtn.Text = "KILL"
    killAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    killAllBtn.TextSize = 12
    killAllBtn.Font = Enum.Font.GothamBold
    killAllBtn.Parent = killAllSection
    
    local killAllBtnCorner = Instance.new("UICorner")
    killAllBtnCorner.CornerRadius = UDim.new(0, 6)
    killAllBtnCorner.Parent = killAllBtn
    
    -- Speed x65
    local speedSection = Instance.new("Frame")
    speedSection.Size = UDim2.new(1, 0, 0, 50)
    speedSection.Position = UDim2.new(0, 0, 0, 60)
    speedSection.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
    speedSection.BorderSizePixel = 0
    speedSection.Parent = content
    
    local speedCorner = Instance.new("UICorner")
    speedCorner.CornerRadius = UDim.new(0, 8)
    speedCorner.Parent = speedSection
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, -70, 1, 0)
    speedLabel.Position = UDim2.new(0, 15, 0, 0)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Speed x65"
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.TextSize = 14
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = speedSection
    
    local speedToggle = Instance.new("TextButton")
    speedToggle.Size = UDim2.new(0, 50, 0, 25)
    speedToggle.Position = UDim2.new(1, -60, 0.5, -12.5)
    speedToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    speedToggle.Text = "OFF"
    speedToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedToggle.TextSize = 11
    speedToggle.Font = Enum.Font.GothamBold
    speedToggle.Parent = speedSection
    
    local speedToggleCorner = Instance.new("UICorner")
    speedToggleCorner.CornerRadius = UDim.new(0, 6)
    speedToggleCorner.Parent = speedToggle
    
    -- Infinite Jump
    local jumpSection = Instance.new("Frame")
    jumpSection.Size = UDim2.new(1, 0, 0, 50)
    jumpSection.Position = UDim2.new(0, 0, 0, 120)
    jumpSection.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
    jumpSection.BorderSizePixel = 0
    jumpSection.Parent = content
    
    local jumpCorner = Instance.new("UICorner")
    jumpCorner.CornerRadius = UDim.new(0, 8)
    jumpCorner.Parent = jumpSection
    
    local jumpLabel = Instance.new("TextLabel")
    jumpLabel.Size = UDim2.new(1, -70, 1, 0)
    jumpLabel.Position = UDim2.new(0, 15, 0, 0)
    jumpLabel.BackgroundTransparency = 1
    jumpLabel.Text = "Infinite Jump"
    jumpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    jumpLabel.TextSize = 14
    jumpLabel.Font = Enum.Font.Gotham
    jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
    jumpLabel.Parent = jumpSection
    
    local jumpToggle = Instance.new("TextButton")
    jumpToggle.Size = UDim2.new(0, 50, 0, 25)
    jumpToggle.Position = UDim2.new(1, -60, 0.5, -12.5)
    jumpToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    jumpToggle.Text = "OFF"
    jumpToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    jumpToggle.TextSize = 11
    jumpToggle.Font = Enum.Font.GothamBold
    jumpToggle.Parent = jumpSection
    
    local jumpToggleCorner = Instance.new("UICorner")
    jumpToggleCorner.CornerRadius = UDim.new(0, 6)
    jumpToggleCorner.Parent = jumpToggle
    
    -- Insta Open Chests
    local chestsSection = Instance.new("Frame")
    chestsSection.Size = UDim2.new(1, 0, 0, 50)
    chestsSection.Position = UDim2.new(0, 0, 0, 180)
    chestsSection.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
    chestsSection.BorderSizePixel = 0
    chestsSection.Parent = content
    
    local chestsCorner = Instance.new("UICorner")
    chestsCorner.CornerRadius = UDim.new(0, 8)
    chestsCorner.Parent = chestsSection
    
    local chestsLabel = Instance.new("TextLabel")
    chestsLabel.Size = UDim2.new(1, -70, 1, 0)
    chestsLabel.Position = UDim2.new(0, 15, 0, 0)
    chestsLabel.BackgroundTransparency = 1
    chestsLabel.Text = "Insta Open Chests"
    chestsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    chestsLabel.TextSize = 14
    chestsLabel.Font = Enum.Font.Gotham
    chestsLabel.TextXAlignment = Enum.TextXAlignment.Left
    chestsLabel.Parent = chestsSection
    
    local chestsToggle = Instance.new("TextButton")
    chestsToggle.Size = UDim2.new(0, 50, 0, 25)
    chestsToggle.Position = UDim2.new(1, -60, 0.5, -12.5)
    chestsToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    chestsToggle.Text = "OFF"
    chestsToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    chestsToggle.TextSize = 11
    chestsToggle.Font = Enum.Font.GothamBold
    chestsToggle.Parent = chestsSection
    
    local chestsToggleCorner = Instance.new("UICorner")
    chestsToggleCorner.CornerRadius = UDim.new(0, 6)
    chestsToggleCorner.Parent = chestsToggle
    
    -- TP to Camp
    local campSection = Instance.new("Frame")
    campSection.Size = UDim2.new(1, 0, 0, 50)
    campSection.Position = UDim2.new(0, 0, 0, 240)
    campSection.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
    campSection.BorderSizePixel = 0
    campSection.Parent = content
    
    local campCorner = Instance.new("UICorner")
    campCorner.CornerRadius = UDim.new(0, 8)
    campCorner.Parent = campSection
    
    local campLabel = Instance.new("TextLabel")
    campLabel.Size = UDim2.new(1, -80, 1, 0)
    campLabel.Position = UDim2.new(0, 15, 0, 0)
    campLabel.BackgroundTransparency = 1
    campLabel.Text = "Teleport to Camp"
    campLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    campLabel.TextSize = 14
    campLabel.Font = Enum.Font.Gotham
    campLabel.TextXAlignment = Enum.TextXAlignment.Left
    campLabel.Parent = campSection
    
    local campBtn = Instance.new("TextButton")
    campBtn.Size = UDim2.new(0, 60, 0, 30)
    campBtn.Position = UDim2.new(1, -70, 0.5, -15)
    campBtn.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
    campBtn.Text = "TP"
    campBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    campBtn.TextSize = 12
    campBtn.Font = Enum.Font.GothamBold
    campBtn.Parent = campSection
    
    local campBtnCorner = Instance.new("UICorner")
    campBtnCorner.CornerRadius = UDim.new(0, 6)
    campBtnCorner.Parent = campBtn
    
    -- Bring Scrap
    local scrapSection = Instance.new("Frame")
    scrapSection.Size = UDim2.new(1, 0, 0, 50)
    scrapSection.Position = UDim2.new(0, 0, 0, 300)
    scrapSection.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
    scrapSection.BorderSizePixel = 0
    scrapSection.Parent = content
    
    local scrapCorner = Instance.new("UICorner")
    scrapCorner.CornerRadius = UDim.new(0, 8)
    scrapCorner.Parent = scrapSection
    
    local scrapLabel = Instance.new("TextLabel")
    scrapLabel.Size = UDim2.new(1, -80, 1, 0)
    scrapLabel.Position = UDim2.new(0, 15, 0, 0)
    scrapLabel.BackgroundTransparency = 1
    scrapLabel.Text = "Bring Scrap to Camp"
    scrapLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    scrapLabel.TextSize = 14
    scrapLabel.Font = Enum.Font.Gotham
    scrapLabel.TextXAlignment = Enum.TextXAlignment.Left
    scrapLabel.Parent = scrapSection
    
    local scrapBtn = Instance.new("TextButton")
    scrapBtn.Size = UDim2.new(0, 60, 0, 30)
    scrapBtn.Position = UDim2.new(1, -70, 0.5, -15)
    scrapBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    scrapBtn.Text = "BRING"
    scrapBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    scrapBtn.TextSize = 11
    scrapBtn.Font = Enum.Font.GothamBold
    scrapBtn.Parent = scrapSection
    
    local scrapBtnCorner = Instance.new("UICorner")
    scrapBtnCorner.CornerRadius = UDim.new(0, 6)
    scrapBtnCorner.Parent = scrapBtn
    
    -- Créditos
    local credits = Instance.new("TextLabel")
    credits.Size = UDim2.new(1, 0, 0, 15)
    credits.Position = UDim2.new(0, 0, 1, -15)
    credits.BackgroundTransparency = 1
    credits.Text = "by H2K"
    credits.TextColor3 = Color3.fromRGB(150, 150, 150)
    credits.TextSize = 11
    credits.Font = Enum.Font.GothamBold
    credits.Parent = content
    
    return {
        gui = screenGui,
        mainFrame = mainFrame,
        content = content,
        minimizeBtn = minimizeBtn,closeBtn = closeBtn,
        killAllBtn = killAllBtn,
        speedToggle = speedToggle,
        jumpToggle = jumpToggle,
        chestsToggle = chestsToggle,
        campBtn = campBtn,
        scrapBtn = scrapBtn
    }
end

-- Crear sistema completo
local icon = createFloatingIcon()
local menu = createModMenu()

-- Función para alternar visibilidad del menu
local function toggleMenu()
    ModState.isOpen = not ModState.isOpen
    menu.mainFrame.Visible = ModState.isOpen
    
    if ModState.isOpen then
        -- Animación de entrada
        menu.mainFrame.Size = UDim2.new(0, 0, 0, 0)
        menu.mainFrame:TweenSize(
            UDim2.new(0, 340, 0, 420),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Back,
            0.3,
            true
        )
    end
end

-- Función para minimizar
local function minimizeMenu()
    ModState.minimized = not ModState.minimized
    if ModState.minimized then
        menu.mainFrame:TweenSize(
            UDim2.new(0, 340, 0, 50),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.2,
            true
        )
        menu.content.Visible = false
    else
        menu.mainFrame:TweenSize(
            UDim2.new(0, 340, 0, 420),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.2,
            true
        )
        menu.content.Visible = true
    end
end

-- Función para actualizar UI de toggle
local function updateToggleUI(button, enabled, onColor, offColor)
    if enabled then
        button.BackgroundColor3 = onColor or Color3.fromRGB(34, 139, 34)
        button.Text = "ON"
        
        -- Efecto de brillo
        local glow = button:FindFirstChild("Glow") or Instance.new("UIGradient")
        glow.Name = "Glow"
        glow.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, button.BackgroundColor3)
        }
        glow.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.8),
            NumberSequenceKeypoint.new(1, 0.2)
        }
        glow.Parent = button
        
    else
        button.BackgroundColor3 = offColor or Color3.fromRGB(60, 60, 80)
        button.Text = "OFF"
        
        local glow = button:FindFirstChild("Glow")
        if glow then glow:Destroy() end
    end
end

-- Eventos del icono
icon.button.MouseButton1Click:Connect(function()
    -- Efecto visual del click
    icon.frame:TweenSize(
        UDim2.new(0, 50, 0, 50),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quad,
        0.1,
        true,
        function()
            icon.frame:TweenSize(
                UDim2.new(0, 55, 0, 55),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.1,
                true
            )
        end
    )
    toggleMenu()
end)

-- Eventos del menu principal
menu.closeBtn.MouseButton1Click:Connect(function()
    ModState.isOpen = false
    menu.mainFrame:TweenSize(
        UDim2.new(0, 0, 0, 0),
        Enum.EasingDirection.In,
        Enum.EasingStyle.Back,
        0.2,
        true,
        function()
            menu.mainFrame.Visible = false
        end
    )
end)

menu.minimizeBtn.MouseButton1Click:Connect(function()
    minimizeMenu()
end)

-- Eventos de funcionalidades
menu.killAllBtn.MouseButton1Click:Connect(function()
    executeKillAll()
    
    -- Feedback visual
    menu.killAllBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    menu.killAllBtn.Text = "DONE!"
    wait(0.3)
    menu.killAllBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    menu.killAllBtn.Text = "KILL"
end)

menu.speedToggle.MouseButton1Click:Connect(function()
    toggleSpeed()
    updateToggleUI(menu.speedToggle, ModState.speed)
end)

menu.jumpToggle.MouseButton1Click:Connect(function()
    toggleInfiniteJump()
    updateToggleUI(menu.jumpToggle, ModState.infiniteJump)
end)

menu.chestsToggle.MouseButton1Click:Connect(function()
    toggleInstaChests()
    updateToggleUI(menu.chestsToggle, ModState.instaChests)
end)

menu.campBtn.MouseButton1Click:Connect(function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(campPosition)
        
        -- Feedback visual
        menu.campBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        menu.campBtn.Text = "DONE!"
        wait(0.3)
        menu.campBtn.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
        menu.campBtn.Text = "TP"
    end
end)

menu.scrapBtn.MouseButton1Click:Connect(function()
    bringScrapToCamp()
    
    -- Feedback visual
    menu.scrapBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    menu.scrapBtn.Text = "DONE!"
    wait(0.5)
    menu.scrapBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    menu.scrapBtn.Text = "BRING"
end)

-- Hacer draggable el menu
local dragging = false
local dragStart = nil
local startPos = nil

menu.mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = menu.mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

menu.mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            local delta = input.Position - dragStart
            menu.mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end
end)

-- Auto-actualización del character al respawnear
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    RootPart = newChar:WaitForChild("HumanoidRootPart")
    
    originalWalkSpeed = Humanoid.WalkSpeed
    originalJumpPower = Humanoid.JumpPower
    
    -- Reaplica estados activos
    if ModState.speed then
        Humanoid.WalkSpeed = 65
        if Connections.speedConnection then
            Connections.speedConnection:Disconnect()
        end
        Connections.speedConnection = Humanoid.Changed:Connect(function(property)
            if property == "WalkSpeed" and ModState.speed then
                Humanoid.WalkSpeed = 65
            end
        end)
    end
end)

-- Notificación de carga exitosa
local function showLoadNotification()
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "H2KLoadNotification"
    notificationGui.Parent = LocalPlayer.PlayerGui
    
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 300, 0, 80)
    notification.Position = UDim2.new(0.5, -150, 0, -100)
    notification.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
    notification.BorderSizePixel = 0
    notification.Parent = notificationGui
    
    local notificationCorner = Instance.new("UICorner")
    notificationCorner.CornerRadius = UDim.new(0, 10)
    notificationCorner.Parent = notification
    
    local notificationText = Instance.new("TextLabel")
    notificationText.Size = UDim2.new(1, -20, 1, 0)
    notificationText.Position = UDim2.new(0, 10, 0, 0)
    notificationText.BackgroundTransparency = 1
    notificationText.Text = "H2K Mod Menu Loaded!\nClick H2K icon to open"
    notificationText.TextColor3 = Color3.fromRGB(255, 255, 255)
    notificationText.TextSize = 14
    notificationText.Font = Enum.Font.GothamBold
    notificationText.TextStrokeTransparency = 0
    notificationText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    notificationText.Parent = notification
    
    -- Animación de entrada
    notification:TweenPosition(
        UDim2.new(0.5, -150, 0, 20),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Back,
        0.5,
        true,
        function()
            wait(3)
            notification:TweenPosition(
                UDim2.new(0.5, -150, 0, -100),
                Enum.EasingDirection.In,
                Enum.EasingStyle.Back,
                0.3,
                true,
                function()
                    notificationGui:Destroy()
                end
            )
        end
    )
end

-- Protección anti-detección
local function antiDetection()
    -- Ocultar del explorador de desarrollador
    for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
        if gui.Name:find("H2K") then
            gui.Parent = game:GetService("CoreGui")
        end
    end
end

-- Ejecutar protección
spawn(antiDetection)

-- Mostrar notificación de carga
showLoadNotification()

-- Cleanup al salir del juego
game:BindToClose(function()
    for _, connection in pairs(Connections) do
        if connection and connection.Disconnect then
            connection:Disconnect()
        end
    end
end)