-- XAN HUB - safe client-side UI demo
-- Local interface only. This does not exploit MM2, alter server state,
-- reveal roles, target other players, or bypass game rules.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
if not player then
    warn("XAN HUB: LocalPlayer is unavailable.")
    return
end

local playerGui = player:WaitForChild("PlayerGui")
local old = playerGui:FindFirstChild("XAN_HUB")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "XAN_HUB"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(330, 245)
main.Position = UDim2.new(0.5, -165, 0.5, -122)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(137, 75, 255)
stroke.Thickness = 1.5
stroke.Parent = main

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 42)
top.BackgroundColor3 = Color3.fromRGB(31, 23, 48)
top.BorderSizePixel = 0
top.Parent = main
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.fromOffset(14, 0)
title.BackgroundTransparency = 1
title.Text = "XAN HUB"
title.TextColor3 = Color3.fromRGB(224, 205, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(30, 28)
close.Position = UDim2.new(1, -38, 0, 7)
close.BackgroundColor3 = Color3.fromRGB(76, 43, 105)
close.Text = "×"
close.TextColor3 = Color3.new(1, 1, 1)
close.Font = Enum.Font.GothamBold
close.TextSize = 20
close.Parent = top
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 7)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -28, 0, 30)
status.Position = UDim2.fromOffset(14, 54)
status.BackgroundTransparency = 1
status.Text = "Welcome, " .. player.DisplayName
status.TextColor3 = Color3.fromRGB(195, 185, 210)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = main

local function makeButton(text, y, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -28, 0, 38)
    button.Position = UDim2.fromOffset(14, y)
    button.BackgroundColor3 = Color3.fromRGB(48, 34, 68)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(235, 225, 250)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 13
    button.AutoButtonColor = true
    button.Parent = main
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
    button.MouseButton1Click:Connect(callback)
end

makeButton("UI Demo: Toggle Accent", 91, function()
    local purple = stroke.Color == Color3.fromRGB(137, 75, 255)
    local target = purple and Color3.fromRGB(40, 190, 170) or Color3.fromRGB(137, 75, 255)
    TweenService:Create(stroke, TweenInfo.new(0.2), {Color = target}):Play()
    status.Text = purple and "Accent changed to teal" or "Accent changed to purple"
end)

makeButton("Show Demo Message", 137, function()
    status.Text = "XAN HUB interface is running locally."
end)

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -28, 0, 24)
footer.Position = UDim2.fromOffset(14, 197)
footer.BackgroundTransparency = 1
footer.Text = "Client-side UI demo • No game advantages"
footer.TextColor3 = Color3.fromRGB(135, 125, 150)
footer.Font = Enum.Font.Gotham
footer.TextSize = 10
footer.Parent = main

print("XAN HUB loaded: safe local UI demo.")
