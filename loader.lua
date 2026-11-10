-- XAN HUB - client-side interface
-- UI utilities only. This loader does not change server state, reveal hidden roles,
-- grant gameplay advantages, or force actions on other players.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
if not player then
    warn("XAN HUB: LocalPlayer is unavailable.")
    return
end

local playerGui = player:WaitForChild("PlayerGui")
local existing = playerGui:FindFirstChild("XAN_HUB")
if existing then existing:Destroy() end

local COLORS = {
    background = Color3.fromRGB(17, 17, 25),
    panel = Color3.fromRGB(27, 24, 38),
    panelHover = Color3.fromRGB(43, 35, 59),
    text = Color3.fromRGB(240, 235, 250),
    muted = Color3.fromRGB(157, 148, 174),
    purple = Color3.fromRGB(151, 92, 255),
    teal = Color3.fromRGB(49, 205, 181),
    red = Color3.fromRGB(235, 91, 112),
}
local accent = COLORS.purple

local gui = Instance.new("ScreenGui")
gui.Name = "XAN_HUB"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "Window"
main.Size = UDim2.fromOffset(440, 310)
main.Position = UDim2.new(0.5, -220, 0.5, -155)
main.BackgroundColor3 = COLORS.background
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)
local outline = Instance.new("UIStroke")
outline.Color = accent
outline.Thickness = 1.5
outline.Parent = main

local top = Instance.new("Frame")
top.Name = "TitleBar"
top.Size = UDim2.new(1, 0, 0, 48)
top.BackgroundColor3 = COLORS.panel
top.BorderSizePixel = 0
top.Parent = main
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(16, 0)
title.Size = UDim2.new(1, -130, 1, 0)
title.Font = Enum.Font.GothamBold
title.Text = "XAN HUB"
title.TextColor3 = COLORS.text
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local function smallButton(label, x, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(30, 28)
    b.Position = UDim2.new(1, x, 0, 10)
    b.BackgroundColor3 = color
    b.BorderSizePixel = 0
    b.Text = label
    b.TextColor3 = COLORS.text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    b.Parent = top
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    return b
end

local minimize = smallButton("–", -76, COLORS.panelHover)
local close = smallButton("×", -40, Color3.fromRGB(91, 42, 58))
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Drag the window from its title bar.
local dragging, dragInput, dragStart, startPosition
top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
top.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end
end)

local nav = Instance.new("Frame")
nav.Position = UDim2.fromOffset(12, 60)
nav.Size = UDim2.new(0, 112, 1, -72)
nav.BackgroundColor3 = COLORS.panel
nav.BorderSizePixel = 0
nav.Parent = main
Instance.new("UICorner", nav).CornerRadius = UDim.new(0, 10)

local content = Instance.new("Frame")
content.Position = UDim2.fromOffset(136, 60)
content.Size = UDim2.new(1, -148, 1, -72)
content.BackgroundColor3 = COLORS.panel
content.BorderSizePixel = 0
content.Parent = main
Instance.new("UICorner", content).CornerRadius = UDim.new(0, 10)

local pageTitle = Instance.new("TextLabel")
pageTitle.Position = UDim2.fromOffset(14, 10)
pageTitle.Size = UDim2.new(1, -28, 0, 25)
pageTitle.BackgroundTransparency = 1
pageTitle.Font = Enum.Font.GothamBold
pageTitle.Text = "Home"
pageTitle.TextColor3 = COLORS.text
pageTitle.TextSize = 16
pageTitle.TextXAlignment = Enum.TextXAlignment.Left
pageTitle.Parent = content

local pageBody = Instance.new("TextLabel")
pageBody.Position = UDim2.fromOffset(14, 43)
pageBody.Size = UDim2.new(1, -28, 0, 54)
pageBody.BackgroundTransparency = 1
pageBody.Font = Enum.Font.Gotham
pageBody.Text = "Welcome, " .. player.DisplayName .. "!\nXAN HUB is ready."
pageBody.TextColor3 = COLORS.muted
pageBody.TextSize = 12
pageBody.TextWrapped = true
pageBody.TextXAlignment = Enum.TextXAlignment.Left
pageBody.TextYAlignment = Enum.TextYAlignment.Top
pageBody.Parent = content

local function actionButton(text, y, callback)
    local b = Instance.new("TextButton")
    b.Position = UDim2.fromOffset(14, y)
    b.Size = UDim2.new(1, -28, 0, 34)
    b.BackgroundColor3 = COLORS.panelHover
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = COLORS.text
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 12
    b.Parent = content
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(callback)
    return b
end

local pages = {}
local function setPage(name, body)
    pageTitle.Text = name
    pageBody.Text = body
    for _, child in ipairs(content:GetChildren()) do
        if child ~= pageTitle and child ~= pageBody and child.Name == "PageControl" then
            child:Destroy()
        end
    end
end

local function navButton(label, y, callback)
    local b = Instance.new("TextButton")
    b.Name = "Nav_" .. label
    b.Position = UDim2.fromOffset(8, y)
    b.Size = UDim2.new(1, -16, 0, 34)
    b.BackgroundColor3 = COLORS.panelHover
    b.BorderSizePixel = 0
    b.Text = label
    b.TextColor3 = COLORS.text
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 12
    b.Parent = nav
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    b.MouseButton1Click:Connect(callback)
end

navButton("Home", 10, function()
    setPage("Home", "Welcome, " .. player.DisplayName .. "!\nXAN HUB is ready.")
    actionButton("Show notification", 112, function()
        pageBody.Text = "XAN HUB is running. Have a good game!"
    end).Name = "PageControl"
end)

navButton("Players", 52, function()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        table.insert(names, p.DisplayName .. "  (@" .. p.Name .. ")")
    end
    table.sort(names)
    local list = #names > 0 and table.concat(names, "\n") or "No players found."
    setPage("Players", "Players currently visible to this client:\n" .. list)
end)

navButton("Settings", 94, function()
    setPage("Settings", "Customize the hub accent color.")
    local b = actionButton("Switch purple / teal accent", 112, function()
        accent = (accent == COLORS.purple) and COLORS.teal or COLORS.purple
        TweenService:Create(outline, TweenInfo.new(0.18), {Color = accent}):Play()
        pageBody.Text = accent == COLORS.teal and "Accent: teal" or "Accent: purple"
    end)
    b.Name = "PageControl"
end)

navButton("About", 136, function()
    setPage("About", "XAN HUB interface build.\nClient-side UI only; no hidden-role access or server control.")
end)

local minimized = false
minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    nav.Visible = not minimized
    content.Visible = not minimized
    main:TweenSize(minimized and UDim2.fromOffset(220, 48) or UDim2.fromOffset(440, 310),
        Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.18, true)
    minimize.Text = minimized and "+" or "–"
end)

print("XAN HUB loaded.")
