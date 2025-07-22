repeat wait() until game:IsLoaded()

-- Servicios
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Estado del noclip
local noclip = false

-- Remote para robar basura
local stealRemote = ReplicatedStorage:WaitForChild("voidSky")
    :WaitForChild("Remotes")
    :WaitForChild("Server")
    :WaitForChild("Objects")
    :WaitForChild("Trash")
    :WaitForChild("Steal")

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "TrashStealNoclipGUI"
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Botón Noclip
local noclipBtn = Instance.new("TextButton", gui)
noclipBtn.Size = UDim2.new(0, 220, 0, 50)
noclipBtn.Position = UDim2.new(0, 20, 0, 60)
noclipBtn.Text = "🚶‍♂️ Noclip: OFF"
noclipBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
noclipBtn.TextColor3 = Color3.new(1, 1, 1)
noclipBtn.Font = Enum.Font.SourceSansBold
noclipBtn.TextSize = 18

noclipBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
    noclipBtn.Text = noclip and "🚶‍♂️ Noclip: ON" or "🚶‍♂️ Noclip: OFF"
end)

-- Loop de Noclip
RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Botón Robo de Basura
local stealBtn = Instance.new("TextButton", gui)
stealBtn.Size = UDim2.new(0, 220, 0, 50)
stealBtn.Position = UDim2.new(0, 20, 0, 120)
stealBtn.Text = "🗑️ Robar TODAS las Basuras"
stealBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
stealBtn.TextColor3 = Color3.new(1, 1, 1)
stealBtn.Font = Enum.Font.SourceSansBold
stealBtn.TextSize = 18

stealBtn.MouseButton1Click:Connect(function()
    print("🔍 Escaneando toda la basura del mapa...")

    for _, trash in ipairs(workspace:GetDescendants()) do
        if trash:IsA("Model") and trash.Name == "Trash" and trash:FindFirstChild("ID") then
            local idValue = trash.ID
            if idValue:IsA("StringValue") and idValue.Value ~= "" then
                for _, targetPlayer in ipairs(Players:GetPlayers()) do
                    stealRemote:FireServer(targetPlayer.Name, idValue.Value)
                    print("✅ Robo enviado a:", targetPlayer.Name, "| Trash ID:", idValue.Value)
                end
            end
        end
    end
end)