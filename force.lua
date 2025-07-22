repeat wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- === Noclip ===
local noclip = false

-- === GUI ===
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "NoclipStealGUI"
gui.ResetOnSpawn = false

-- === Botón de Noclip ===
local btnNoclip = Instance.new("TextButton", gui)
btnNoclip.Size = UDim2.new(0, 200, 0, 50)
btnNoclip.Position = UDim2.new(0, 20, 0, 60)
btnNoclip.Text = "🚶‍♂️ Noclip: OFF"
btnNoclip.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
btnNoclip.TextColor3 = Color3.new(1, 1, 1)
btnNoclip.Font = Enum.Font.SourceSansBold
btnNoclip.TextSize = 18

btnNoclip.MouseButton1Click:Connect(function()
    noclip = not noclip
    btnNoclip.Text = noclip and "🚶‍♂️ Noclip: ON" or "🚶‍♂️ Noclip: OFF"
end)

RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- === Forzar Robo de Basura ===

local stealRemote = ReplicatedStorage:WaitForChild("voidSky")
    :WaitForChild("Remotes")
    :WaitForChild("Server")
    :WaitForChild("Objects")
    :WaitForChild("Trash")
    :WaitForChild("Steal")

-- Botón: Robar todo
local btnSteal = Instance.new("TextButton", gui)
btnSteal.Size = UDim2.new(0, 200, 0, 50)
btnSteal.Position = UDim2.new(0, 20, 0, 120)
btnSteal.Text = "🗑️ Robar TODAS las Basuras"
btnSteal.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
btnSteal.TextColor3 = Color3.new(1, 1, 1)
btnSteal.Font = Enum.Font.SourceSansBold
btnSteal.TextSize = 18

btnSteal.MouseButton1Click:Connect(function()
    print("🔄 Escaneando jugadores y robando...")
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- Buscar ID de basura si está visible en Workspace
            for _, trash in pairs(workspace:GetDescendants()) do
                if trash:IsA("Model") and trash.Name == "Trash" and trash:FindFirstChild("ID") then
                    local idValue = trash.ID
                    if idValue:IsA("StringValue") then
                        stealRemote:FireServer(player.Name, idValue.Value)
                        print("✅ Robado de:", player.Name, " | ID:", idValue.Value)
                    end
                end
            end
        end
    end
end)