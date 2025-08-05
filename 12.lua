-- GUI flotante (igual que antes)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "StealAFishForceStealMenu"
ScreenGui.ResetOnSpawn = false

local function crearBoton(texto, posY, callback)
    local boton = Instance.new("TextButton")
    boton.Size = UDim2.new(0, 180, 0, 40)
    boton.Position = UDim2.new(0, 20, 0, posY)
    boton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    boton.TextColor3 = Color3.fromRGB(255, 255, 255)
    boton.Text = texto
    boton.Font = Enum.Font.GothamBold
    boton.TextSize = 18
    boton.BackgroundTransparency = 0.15
    boton.BorderSizePixel = 0
    boton.Parent = ScreenGui

    boton.MouseButton1Click:Connect(callback)
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local stealEvent = ReplicatedStorage:WaitForChild("voidSky"):WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild("Objects"):WaitForChild("Trash"):WaitForChild("Steal")

local autoForceSteal = false

local function obtenerPeces()
    local objetos = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("trash") or obj.Name:lower():find("fish") then
            table.insert(objetos, obj)
        end
    end
    return objetos
end

-- Loop spam para forzar robo constante sin esperar
task.spawn(function()
    while true do
        if autoForceSteal then
            local peces = obtenerPeces()
            for _, pez in pairs(peces) do
                pcall(function()
                    stealEvent:FireServer(pez)
                end)
                -- espera mínima para no bloquear el hilo, casi spam
                task.wait(0.03)
            end
        end
        -- espera muy corta para ciclo continuo
        task.wait(0.1)
    end
end)

-- Botón flotante
crearBoton("🎣 Forzar robo (OFF)", 60, function()
    autoForceSteal = not autoForceSteal
    local estado = autoForceSteal and "ON" or "OFF"
    print("Forzar robo: " .. estado)
    ScreenGui:GetChildren()[1].Text = "🎣 Forzar robo (" .. estado .. ")"
end)