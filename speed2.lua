local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")


local speed = Instance.new("TextButton")
speed.Name = "Speed"
speed.Size = UDim2.new(0, 150, 0, 50)
speed.Position = UDim2.new(0, 120, 0, 40)
speed.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
speed.Text = "Speed Off"
speed.Parent = gui

local speedActivo = false

speed.MouseButton1Click:Connect(function()
  speedActivo = not speedActivo
  if speedActivo then
    player.Character.Humanoid.WalkSpeed = 80
      speed.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
      speed.Text = "Speed On"
      
    else
        player.Character.Humanoid.WalkSpeed = 16
        speed.Text = "Speed Off"
        speed.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
  end
end)