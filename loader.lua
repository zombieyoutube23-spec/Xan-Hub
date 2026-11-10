-- XAN HUB - functional client UI
-- Player browsing/selection and local chat notifications only.
-- This client loader does not control other players, reveal hidden roles,
-- or modify server-authoritative game state.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
if not player then
    warn("XAN HUB: LocalPlayer unavailable.")
    return
end

local playerGui = player:WaitForChild("PlayerGui")
local previous = playerGui:FindFirstChild("XAN_HUB")
if previous then previous:Destroy() end

local C = {
    bg = Color3.fromRGB(17, 17, 25),
    panel = Color3.fromRGB(27, 24, 38),
    button = Color3.fromRGB(43, 35, 59),
    text = Color3.fromRGB(240, 235, 250),
    muted = Color3.fromRGB(157, 148, 174),
    purple = Color3.fromRGB(151, 92, 255),
    teal = Color3.fromRGB(49, 205, 181),
}
local accent = C.purple
local selectedPlayer = nil
local currentPage = "Home"

local gui = Instance.new("ScreenGui")
gui.Name = "XAN_HUB"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "Window"
main.Size = UDim2.fromOffset(460, 340)
main.Position = UDim2.new(0.5, -230, 0.5, -170)
main.BackgroundColor3 = C.bg
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)
local outline = Instance.new("UIStroke", main)
outline.Color = accent
outline.Thickness = 1.5

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 48)
top.BackgroundColor3 = C.panel
top.BorderSizePixel = 0
top.Parent = main
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(16, 0)
title.Size = UDim2.new(1, -120, 1, 0)
title.Font = Enum.Font.GothamBold
title.Text = "XAN HUB"
title.TextColor3 = C.text
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local function topButton(label, x, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(30, 28)
    b.Position = UDim2.new(1, x, 0, 10)
    b.BackgroundColor3 = color
    b.BorderSizePixel = 0
    b.Text = label
    b.TextColor3 = C.text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    b.Parent = top
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    return b
end
local minimize = topButton("–", -76, C.button)
local close = topButton("×", -40, Color3.fromRGB(91, 42, 58))
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Drag window with mouse or touch.
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
nav.Size = UDim2.new(0, 116, 1, -72)
nav.BackgroundColor3 = C.panel
nav.BorderSizePixel = 0
nav.Parent = main
Instance.new("UICorner", nav).CornerRadius = UDim.new(0, 10)

local contentFrame = Instance.new("Frame")
contentFrame.Position = UDim2.fromOffset(140, 60)
contentFrame.Size = UDim2.new(1, -152, 1, -72)
contentFrame.BackgroundColor3 = C.panel
contentFrame.BorderSizePixel = 0
contentFrame.ClipsDescendants = true
contentFrame.Parent = main
Instance.new("UICorner", contentFrame).CornerRadius = UDim.new(0, 10)

local pageTitle = Instance.new("TextLabel")
pageTitle.Position = UDim2.fromOffset(14, 10)
pageTitle.Size = UDim2.new(1, -28, 0, 25)
pageTitle.BackgroundTransparency = 1
pageTitle.Font = Enum.Font.GothamBold
pageTitle.Text = "Home"
pageTitle.TextColor3 = C.text
pageTitle.TextSize = 16
pageTitle.TextXAlignment = Enum.TextXAlignment.Left
pageTitle.Parent = contentFrame

local pageBody = Instance.new("TextLabel")
pageBody.Position = UDim2.fromOffset(14, 43)
pageBody.Size = UDim2.new(1, -28, 0, 46)
pageBody.BackgroundTransparency = 1
pageBody.Font = Enum.Font.Gotham
pageBody.Text = "Welcome, " .. player.DisplayName .. "! XAN HUB is ready."
pageBody.TextColor3 = C.muted
pageBody.TextSize = 12
pageBody.TextWrapped = true
pageBody.TextXAlignment = Enum.TextXAlignment.Left
pageBody.TextYAlignment = Enum.TextYAlignment.Top
pageBody.Parent = contentFrame

local dynamic = Instance.new("Frame")
dynamic.Name = "DynamicControls"
dynamic.Position = UDim2.fromOffset(10, 94)
dynamic.Size = UDim2.new(1, -20, 1, -104)
dynamic.BackgroundTransparency = 1
dynamic.Parent = contentFrame

local function clearDynamic()
    for _, child in ipairs(dynamic:GetChildren()) do child:Destroy() end
end

local function makeAction(label, y, callback)
    local b = Instance.new("TextButton")
    b.Position = UDim2.fromOffset(4, y)
    b.Size = UDim2.new(1, -8, 0, 34)
    b.BackgroundColor3 = C.button
    b.BorderSizePixel = 0
    b.Text = label
    b.TextColor3 = C.text
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 12
    b.Parent = dynamic
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(callback)
    return b
end

local function localChatNotice(message)
    local channels = TextChatService:FindFirstChild("TextChannels")
    local general = channels and channels:FindFirstChild("RBXGeneral")
    if general and general.DisplaySystemMessage then
        local ok = pcall(function()
            general:DisplaySystemMessage("[XAN HUB] " .. message)
        end)
        if ok then return true end
    end
    local ok = pcall(function()
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = "[XAN HUB] " .. message,
            Color = accent,
            Font = Enum.Font.Gotham,
            TextSize = 16,
        })
    end)
    return ok
end

local function showHome()
    currentPage = "Home"
    pageTitle.Text = "Home"
    pageBody.Text = "Welcome, " .. player.DisplayName .. "!\nChoose a section from the left."
    clearDynamic()
    makeAction("Post XAN HUB test notification to my chat", 4, function()
        local ok = localChatNotice("Chat notification test successful.")
        pageBody.Text = ok and "Notification posted to your client chat." or "Chat system unavailable in this experience."
    end)
    makeAction("Refresh player count", 46, function()
        pageBody.Text = "Players in this server: " .. tostring(#Players:GetPlayers())
    end)
end

local function showPlayers()
    currentPage = "Players"
    pageTitle.Text = "Players"
    clearDynamic()

    local selectedLabel = Instance.new("TextLabel")
    selectedLabel.Size = UDim2.new(1, -8, 0, 26)
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.Font = Enum.Font.GothamSemibold
    selectedLabel.TextSize = 11
    selectedLabel.TextColor3 = C.muted
    selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    selectedLabel.Parent = dynamic

    local function updateSelectedLabel()
        selectedLabel.Text = selectedPlayer and ("Selected: " .. selectedPlayer.DisplayName .. "  (@" .. selectedPlayer.Name .. ")") or "Selected: nobody"
    end
    updateSelectedLabel()

    local scroll = Instance.new("ScrollingFrame")
    scroll.Position = UDim2.fromOffset(0, 30)
    scroll.Size = UDim2.new(1, -4, 1, -68)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.CanvasSize = UDim2.new()
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = dynamic
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 5)
    layout.SortOrder = Enum.SortOrder.Name

    local function populate()
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local roster = Players:GetPlayers()
        table.sort(roster, function(a, b) return a.Name:lower() < b.Name:lower() end)
        for _, target in ipairs(roster) do
            local row = Instance.new("TextButton")
            row.Name = target.Name
            row.Size = UDim2.new(1, -6, 0, 30)
            row.BackgroundColor3 = (selectedPlayer == target) and accent or C.button
            row.BorderSizePixel = 0
            row.Text = target.DisplayName .. "  (@" .. target.Name .. ")"
            row.TextColor3 = C.text
            row.Font = Enum.Font.Gotham
            row.TextSize = 11
            row.Parent = scroll
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)
            row.MouseButton1Click:Connect(function()
                selectedPlayer = target
                updateSelectedLabel()
                for _, other in ipairs(scroll:GetChildren()) do
                    if other:IsA("TextButton") then
                        other.BackgroundColor3 = (other == row) and accent or C.button
                    end
                end
            end)
        end
        if #roster == 0 then
            local empty = Instance.new("TextLabel")
            empty.Size = UDim2.new(1, -6, 0, 28)
            empty.BackgroundTransparency = 1
            empty.Text = "No players found."
            empty.TextColor3 = C.muted
            empty.Font = Enum.Font.Gotham
            empty.TextSize = 11
            empty.Parent = scroll
        end
    end
    populate()

    local refresh = Instance.new("TextButton")
    refresh.Position = UDim2.new(0, 0, 1, -32)
    refresh.Size = UDim2.new(0.48, -2, 0, 30)
    refresh.BackgroundColor3 = C.button
    refresh.BorderSizePixel = 0
    refresh.Text = "Refresh list"
    refresh.TextColor3 = C.text
    refresh.Font = Enum.Font.GothamSemibold
    refresh.TextSize = 11
    refresh.Parent = dynamic
    Instance.new("UICorner", refresh).CornerRadius = UDim.new(0, 7)
    refresh.MouseButton1Click:Connect(populate)

    local notify = Instance.new("TextButton")
    notify.Position = UDim2.new(0.52, 2, 1, -32)
    notify.Size = UDim2.new(0.48, -2, 0, 30)
    notify.BackgroundColor3 = C.button
    notify.BorderSizePixel = 0
    notify.Text = "Chat notice"
    notify.TextColor3 = C.text
    notify.Font = Enum.Font.GothamSemibold
    notify.TextSize = 11
    notify.Parent = dynamic
    Instance.new("UICorner", notify).CornerRadius = UDim.new(0, 7)
    notify.MouseButton1Click:Connect(function()
        if selectedPlayer and selectedPlayer.Parent == Players then
            local ok = localChatNotice("Selected player: " .. selectedPlayer.DisplayName .. " (@" .. selectedPlayer.Name .. ").")
            pageBody.Text = ok and "Selection notice posted to your client chat." or "Chat system unavailable."
        else
            selectedPlayer = nil
            updateSelectedLabel()
            pageBody.Text = "Select a player first."
        end
    end)
end

local function showSettings()
    currentPage = "Settings"
    pageTitle.Text = "Settings"
    pageBody.Text = "Change the hub accent color."
    clearDynamic()
    makeAction("Switch purple / teal accent", 4, function()
        accent = (accent == C.purple) and C.teal or C.purple
        TweenService:Create(outline, TweenInfo.new(0.18), {Color = accent}):Play()
        pageBody.Text = accent == C.teal and "Accent changed to teal." or "Accent changed to purple."
    end)
end

local function showAbout()
    currentPage = "About"
    pageTitle.Text = "About"
    pageBody.Text = "XAN HUB client interface. Player selection and chat notices run locally. Server-side admin actions require an authorised server component in an experience you control."
    clearDynamic()
end

local function navButton(label, y, callback)
    local b = Instance.new("TextButton")
    b.Position = UDim2.fromOffset(8, y)
    b.Size = UDim2.new(1, -16, 0, 34)
    b.BackgroundColor3 = C.button
    b.BorderSizePixel = 0
    b.Text = label
    b.TextColor3 = C.text
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 12
    b.Parent = nav
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    b.MouseButton1Click:Connect(callback)
end

navButton("Home", 10, showHome)
navButton("Players", 52, showPlayers)
navButton("Settings", 94, showSettings)
navButton("About", 136, showAbout)

Players.PlayerAdded:Connect(function()
    if currentPage == "Players" then task.defer(showPlayers) end
end)
Players.PlayerRemoving:Connect(function(leaving)
    if selectedPlayer == leaving then selectedPlayer = nil end
    if currentPage == "Players" then task.defer(showPlayers) end
end)

local minimized = false
minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    nav.Visible = not minimized
    contentFrame.Visible = not minimized
    main:TweenSize(minimized and UDim2.fromOffset(220, 48) or UDim2.fromOffset(460, 340),
        Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.18, true)
    minimize.Text = minimized and "+" or "–"
end)

showHome()
print("XAN HUB loaded: player selector and local chat notifications ready.")
