-- STEAL A FISH – FORZADOR DE ROBO (3 MÉTODOS) – BY CHATGPT
-- FUNCIONAL ANDROID (KRNL)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local StealEvent = ReplicatedStorage.voidSky.Remotes.Server.Objects.Trash.Steal

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "FishStealerGui"
ScreenGui.ResetOnSpawn = false

-- Variables globales para TrashInfo
_G.TrashInfoGuardado = nil
_G.AutoInterceptar = false

-- Función para crear botón flotante
local function crearBoton(nombre, posicion, callback)
	local boton = Instance.new("TextButton")
	boton.Size = UDim2.new(0, 160, 0, 40)
	boton.Position = posicion
	boton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	boton.TextColor3 = Color3.new(1, 1, 1)
	boton.TextScaled = true
	boton.Text = nombre
	boton.Font = Enum.Font.GothamBold
	boton.Parent = ScreenGui
	boton.MouseButton1Click:Connect(callback)
	return boton
end

-- BOTÓN 1: Usar último TrashInfo guardado
crearBoton("Robar Último TrashInfo", UDim2.new(0, 30, 0, 100), function()
	if _G.TrashInfoGuardado then
		pcall(function()
			StealEvent:FireServer(_G.TrashInfoGuardado)
		end)
	else
		warn("No hay TrashInfo guardado aún.")
	end
end)

-- BOTÓN 2: Activar interceptador y robar al instante
crearBoton("Auto-Interceptar Robo", UDim2.new(0, 30, 0, 160), function()
	_G.AutoInterceptar = not _G.AutoInterceptar
	if _G.AutoInterceptar then
		warn("🟢 Interceptador ACTIVADO")
	else
		warn("🔴 Interceptador DESACTIVADO")
	end
end)

-- BOTÓN 3: Spoof de base abierta (robo forzado)
crearBoton("Spoof Forzado", UDim2.new(0, 30, 0, 220), function()
	if _G.TrashInfoGuardado then
		for i = 1, 10 do
			pcall(function()
				StealEvent:FireServer(_G.TrashInfoGuardado)
			end)
			wait(0.1)
		end
	else
		warn("No hay TrashInfo para spoofear.")
	end
end)

-- INTERCEPTADOR de TrashInfo
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
	local args = {...}
	local method = getnamecallmethod()
	if tostring(self) == tostring(StealEvent) and method == "FireServer" and _G.AutoInterceptar then
		local trashData = args[1]
		if trashData and typeof(trashData) == "table" then
			_G.TrashInfoGuardado = trashData
			warn("Nuevo TrashInfo INTERCEPTADO y GUARDADO.")
		end
	end
	return oldNamecall(self, ...)
end)