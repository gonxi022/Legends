repeat wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- === Noclip Estado ===
local noclip = false

-- === GUI ===
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "NoclipSpyGUI"
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

-- === Loop de Noclip ===
RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- === Spy Avanzado de Remotes (Antiglitch) ===
local mt = getrawmetatable(game)
setreadonly(mt, false)
local old = mt.__namecall

local lastRemotes = {}
local function hashArgs(args)
    local hash = ""
    for _, v in ipairs(args) do
        hash = hash .. tostring(typeof(v)) .. ":" .. tostring(v) .. "|"
    end
    return hash
end

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if typeof(self) == "Instance" and (method == "FireServer" or method == "InvokeServer") then
        -- Ver si los argumentos tienen valor real
        local interesting = false
        for _, v in ipairs(args) do
            if typeof(v) == "CFrame" or typeof(v) == "Vector3" or typeof(v) == "Instance" or typeof(v) == "table" or (typeof(v) == "string" and #v > 3) then
                interesting = true
                break
            end
        end

        if interesting then
            local remotePath = self:GetFullName()
            local hash = remotePath .. hashArgs(args)

            if not lastRemotes[hash] then
                lastRemotes[hash] = true

                print("======== 🔍 REMOTE DETECTADO ========")
                print("📡 Remote:", remotePath)
                print("⚙️ Método:", method)
                for i, v in ipairs(args) do
                    print("Arg["..i.."]: ", v)
                end
                print("=====================================")
            end
        end
    end

    return old(self, unpack(args))
end)