-- 🧠 SPY DE REMOTEEVENTS: Muestra en consola todo lo que se llama desde FireServer
local mt = getrawmetatable(game)
setreadonly(mt, false)
local old = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if method == "FireServer" then
        print("⚠️ RemoteEvent detectado:")
        print("Nombre:", self:GetFullName())
        print("Args:", unpack(args))
    end
    return old(self, ...)
end)

-- 🧰 BOTONES FLOTANTES - FULL ANDROID COMPATIBLE

-- Crear GUI flotante
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "StealAFishMenu"
ScreenGui.ResetOnSpawn = false

-- Función para crear botones flotantes
local function crearBoton(texto, posY, callback)
    local boton = Instance.new("TextButton")
    boton.Size = UDim2.new(0, 180, 0, 42)
    boton.Position = UDim2.new(0, 20, 0, posY)
    boton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    boton.TextColor3 = Color3.fromRGB(255, 255, 255)
    boton.Text = texto
    boton.Font = Enum.Font.GothamBold
    boton.TextSize = 18
    boton.BackgroundTransparency = 0.2
    boton.BorderSizePixel = 0
    boton.Parent = ScreenGui
    boton.ZIndex = 1000

    boton.MouseButton1Click:Connect(callback)
end

-- VARIABLES
local fishList = {}
local autoGrab = false

-- FUNCIONES
local function actualizarListaDePeces()
    fishList = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("fish") and obj:FindFirstChild("HumanoidRootPart") then
            table.insert(fishList, obj)
        end
    end
end

-- 🔁 Loop Auto Grab
task.spawn(function()
    while true do
        if autoGrab then
            actualizarListaDePeces()
            local remote = game.ReplicatedStorage:FindFirstChild("StealFishEvent") -- CAMBIAR si descubrís otro
            for _, pez in pairs(fishList) do
                if remote then
                    pcall(function()
                        remote:FireServer(pez)
                    end)
                end
                task.wait(0.1)
            end
        end
        task.wait(1)
    end
end)

-- BOTONES
crearBoton("🔁 Auto Grab (ON/OFF)", 60, function()
    autoGrab = not autoGrab
    print("Auto Grab:", autoGrab and "Activado" or "Desactivado")
end)

crearBoton("🔄 Actualizar lista de peces", 110, function()
    actualizarListaDePeces()
    print("Detectados:", #fishList, "peces")
end)

crearBoton("🐟 Clonar peces cerca", 160, function()
    local player = game.Players.LocalPlayer
    local char = player.Character
    if not char then return end

    for _, pez in pairs(fishList) do
        local clon = pez:Clone()
        clon.Parent = workspace
        clon:SetPrimaryPartCFrame(char.PrimaryPart.CFrame + Vector3.new(math.random(-6,6), 0, math.random(-6,6)))
    end
end)

-- ✅ LISTO
print("✅ SCRIPT CARGADO - BOTONES FLOTANTES ACTIVOS")