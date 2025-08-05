-- 🐟 STEAL A FISH – FORZAR ROBO BASE CERRADA
-- By ChatGPT for KRNL Android
-- Menú flotante con 3 métodos para forzar robo

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local StealRemote = ReplicatedStorage:WaitForChild("voidSky"):WaitForChild("Remotes").Server.Objects.Trash.Steal

-- UI SETUP
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "StealAFishMenu"

local function createButton(name, posY, callback)
	local btn = Instance.new("TextButton", gui)
	btn.Size = UDim2.new(0, 180, 0, 40)
	btn.Position = UDim2.new(0, 20, 0, posY)
	btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 16
	btn.Text = name
	btn.BorderSizePixel = 0
	btn.BackgroundTransparency = 0.1
	btn.AutoButtonColor = true
	btn.MouseButton1Click:Connect(callback)
end

-- 🧠 MÉTODO 1: SPOOF DOOR ABIERTA
createButton("Spoof Puerta Abierta", 0.2, function()
	local baseStatus = workspace:FindFirstChild("DoorOpen")
	if baseStatus and baseStatus:IsA("BoolValue") then
		baseStatus.Value = true
		print("✅ Estado de puerta spoofeado: abierta.")
	else
		warn("❌ No se encontró el BoolValue 'DoorOpen'")
	end
end)

-- 🔁 MÉTODO 2: USAR TrashInfo CAPTURADO
local savedTrashInfo = nil

createButton("Guardar TrashInfo", 0.3, function()
	-- Usa el spy para capturar TrashInfo una vez manualmente
	print("👀 Toca un pez para capturar TrashInfo (usa el spy)")
end)

createButton("Forzar Robo con TrashInfo", 0.4, function()
	if savedTrashInfo then
		StealRemote:FireServer(savedTrashInfo)
		print("✅ Enviado Steal con TrashInfo guardado")
	else
		warn("❌ Aún no guardaste ningún TrashInfo")
	end
end)

-- 🧠 MÉTODO 3: INTERCEPTAR Y AUTO-REUSAR TrashInfo
local hookmetamethod = hookmetamethod or hookfunction
if hookmetamethod then
	hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
		local args = {...}
		if getnamecallmethod() == "FireServer" and tostring(self) == "Steal" then
			savedTrashInfo = args[1]
			warn("📥 TrashInfo interceptado y guardado automáticamente.")
		end
		return self:FireServer(...)
	end))
end