-- 📦 UI LIB PARA ANDROID FLOAT
loadstring(game:HttpGet("https://raw.githubusercontent.com/GhostPlayer352/Test4/main/Lib.lua"))()

-- 📜 CREAR LA VENTANA
local Window = Lib:CreateWindow("STEAL A FISH OP 🐠", Vector2.new(300, 400), Enum.KeyCode.RightControl)

-- VARIABLES
local fishList = {}
local autoGrab = false

-- FUNCION: DETECTAR PECES Y LISTAR
local function actualizarListaDePeces()
    fishList = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("fish") and obj:FindFirstChild("HumanoidRootPart") then
            table.insert(fishList, obj)
        end
    end
end

-- FUNCION: INTENTAR ROBAR UN PEZ (CAMBIAR NOMBRE DE EVENTO SI ES NECESARIO)
local function robarPez(fish)
    local event = game.ReplicatedStorage:FindFirstChild("StealFishEvent") -- Cambiar si se llama distinto
    if event and fish then
        pcall(function()
            event:FireServer(fish)
        end)
    end
end

-- FUNCION: LOOP AUTOMÁTICO DE ROBO
task.spawn(function()
    while true do
        if autoGrab then
            actualizarListaDePeces()
            for _, pez in pairs(fishList) do
                robarPez(pez)
                task.wait(0.15)
            end
        end
        task.wait(1)
    end
end)

-- 📌 PESTAÑA 1: AUTO GRAB
local tab1 = Window:CreateTab("Auto Grab")

tab1:CreateToggle("Activar Auto Grab", false, function(state)
    autoGrab = state
end)

-- 📌 PESTAÑA 2: CLONAR PECES CERCANOS (CLIENTE)
local tab2 = Window:CreateTab("Clonar Peces")

tab2:CreateButton("Actualizar lista de peces", function()
    actualizarListaDePeces()
    print("Se detectaron " .. tostring(#fishList) .. " peces.")
end)

tab2:CreateButton("Clonar peces cerca tuyo", function()
    local player = game.Players.LocalPlayer
    local char = player.Character
    if not char then return end

    for _, pez in pairs(fishList) do
        local clon = pez:Clone()
        clon.Parent = workspace
        clon:SetPrimaryPartCFrame(char.PrimaryPart.CFrame + Vector3.new(math.random(-7,7), 0, math.random(-7,7)))
    end
end)