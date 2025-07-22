repeat wait() until game:IsLoaded()

-- Servicios
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Noclip estado
local noclip = false

-- Remote Steal confirmado
local stealRemote = ReplicatedStorage:WaitForChild("voidSky")
    :WaitForChild("Remotes")
    :WaitForChild("Server")
    :WaitForChild("Objects")
    :WaitForChild("Trash")
    :WaitForChild("Steal")

-- GUI flotante
local gui = Instance.new("ScreenGui")
gui.Name = "TrashNoclipGUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Draggable Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 130)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Botón Noclip
local noclipBtn = Instance.new("TextButton")
noclipBtn.Size = UDim2.new(1, -20, 0, 50)
noclipBtn.Position = UDim2.new(0, 10, 0, 10)
noclipBtn.Text = "🚶‍♂️ Noclip: OFF"
noclipBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 200)
noclipBtn.TextColor3 = Color3.new(1, 1, 1)
noclipBtn.Font = Enum.Font.SourceSansBold
noclipBtn.TextSize = 18
noclipBtn.Parent = frame

noclipBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
    noclipBtn.Text = noclip and "🚶‍♂️ Noclip: ON" or "🚶‍♂️ Noclip: OFF"
end)

-- Loop Noclip
RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Botón Steal
local stealBtn = Instance.new("TextButton")
stealBtn.Size = UDim2.new(1, -20, 0, 50)
stealBtn.Position = UDim2.new(0, 10, 0, 70)
stealBtn.Text = "🗑️ Robar TODAS las Basuras"
stealBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
stealBtn.TextColor3 = Color3.new(1, 1, 1)
stealBtn.Font = Enum.Font.SourceSansBold
stealBtn.TextSize = 18
stealBtn.Parent = frame

-- Función de robo forzado
stealBtn.MouseButton1Click:Connect(function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local originalPos = hrp.Position
    local count = 0

    for _, trash in ipairs(workspace:GetDescendants()) do
        if trash:IsA("Model") and trash.Name == "Trash" and trash:FindFirstChild("ID") then
            local idValue = trash.ID
            if idValue:IsA("StringValue") and idValue.Value ~= "" then
                local trashPos = trash:FindFirstChild("PrimaryPart") and trash.PrimaryPart.Position
                    or (trash:FindFirstChild("Base") and trash.Base.Position)
                    or trash:GetModelCFrame().Position

                -- Teletransportarse cerca (por si hay verificación)
                if trashPos then
                    hrp.CFrame = CFrame.new(trashPos + Vector3.new(0, 3, 0))
                    wait(0.1) -- Para evitar spam
                end

                stealRemote:FireServer(LocalPlayer.Name, idValue.Value)
                count += 1
            end
        end
    end

    -- Volver a posición original
    task.delay(1, function()
        hrp.CFrame = CFrame.new(originalPos)
    end)

    stealBtn.Text = "✅ Robadas: " .. count
    wait(2)
    stealBtn.Text = "🗑️ Robar TODAS las Basuras"
end)