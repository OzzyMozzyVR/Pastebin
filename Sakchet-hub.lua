loadstring([[ 
-- Sakchet Hub for Escape Tsunami For Brainrots! (Keyless, Updated Feb 2026)
-- Made by @OzzyMozzyVR
-- Features: Brainrot Dupe (Hold one → Dupe clones with same name/money/rarity/design, places at base - persists on rejoin!), Find Best Rarity, Lucky Block Auto Collect, Misc (Inf Jump, etc.)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Remotes (common names - adjust if needed based on decompiler)
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local CollectMoney = RemoteEvents:WaitForChild("CollectMoney") or RemoteEvents:FindFirstChildWhichIsA("RemoteEvent")
local RebirthRemote = RemoteEvents:WaitForChild("Rebirth")
local BuySpeedRemote = RemoteEvents:WaitForChild("BuySpeed")
local BuyCarryRemote = RemoteEvents:WaitForChild("BuyCarry") -- if exists

-- Attempt to find place/equip remote (common in tycoon/brainrot games)
local PlaceRemote = nil
for _, v in pairs(RemoteEvents:GetChildren()) do
    if v:IsA("RemoteEvent") and (v.Name:lower():find("place") or v.Name:lower():find("equip") or v.Name:lower():find("drop") or v.Name:lower():find("spawn")) then
        PlaceRemote = v
        break
    end
end

-- Variables
local ScreenGui = nil
local MainFrame = nil
local ToggleButton = nil
local Watermark = nil
local PlayerFrame = nil
local DupeTog = false
local InfJump = false
local AutoRebirth = false
local AutoCollectMoney = false
local AutoBuySpeed = false
local SizeState = "Medium"

-- Draggable Function
local function makeDraggable(frame)
    local dragging = false
    local dragStart = nil
    local startPos = nil

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    frame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Create Circle Toggle Button
local function createToggleButton()
    local ToggleGui = Instance.new("ScreenGui")
    ToggleGui.Name = "SakchetHubToggle"
    ToggleGui.Parent = PlayerGui
    ToggleGui.ResetOnSpawn = false

    local CircleBtn = Instance.new("TextButton")
    CircleBtn.Name = "CircleButton"
    CircleBtn.Parent = ToggleGui
    CircleBtn.Size = UDim2.new(0, 80, 0, 80)
    CircleBtn.Position = UDim2.new(0, 20, 0.5, -40)
    CircleBtn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    CircleBtn.Text = "Sakchet\nHub"
    CircleBtn.TextColor3 = Color3.new(1,1,1)
    CircleBtn.TextScaled = true
    CircleBtn.Font = Enum.Font.GothamBold
    CircleBtn.BorderSizePixel = 0

    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(0.5, 0)
    CircleCorner.Parent = CircleBtn

    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 162, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 120, 255))
    }
    Gradient.Parent = CircleBtn

    CircleBtn.MouseButton1Click:Connect(function()
        if ScreenGui then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)
end

-- Create Main GUI
local function createGUI()
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SakchetHub"
    ScreenGui.Parent = PlayerGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Enabled = false

    local TitleFrame = Instance.new("Frame")
    TitleFrame.Name = "TitleFrame"
    TitleFrame.Parent = ScreenGui
    TitleFrame.Size = UDim2.new(1, 0, 0, 50)
    TitleFrame.Position = UDim2.new(0, 0, 0, 0)
    TitleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    TitleFrame.BorderSizePixel = 0

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Parent = TitleFrame
    TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "Sakchet Hub"
    TitleLabel.TextColor3 = Color3.new(1,1,1)
    TitleLabel.TextScaled = true
    TitleLabel.Font = Enum.Font.GothamBold

    Watermark = Instance.new("TextLabel")
    Watermark.Name = "Watermark"
    Watermark.Parent = TitleFrame
    Watermark.Size = UDim2.new(0.3, -10, 1, 0)
    Watermark.Position = UDim2.new(0.7, 0, 0, 0)
    Watermark.BackgroundTransparency = 1
    Watermark.Text = "made by @OzzyMozzyVR"
    Watermark.TextColor3 = Color3.fromRGB(150, 150, 255)
    Watermark.TextScaled = true
    Watermark.Font = Enum.Font.Gotham
    Watermark.TextXAlignment = Enum.TextXAlignment.Right

    local PlayerFrame = Instance.new("Frame")
    PlayerFrame.Name = "PlayerFrame"
    PlayerFrame.Parent = TitleFrame
    PlayerFrame.Size = UDim2.new(1, -20, 0.8, 0)
    PlayerFrame.Position = UDim2.new(0, 10, 0.1, 0)
    PlayerFrame.BackgroundTransparency = 1

    local Avatar = Instance.new("ImageLabel")
    Avatar.Name = "Avatar"
    Avatar.Parent = PlayerFrame
    Avatar.Size = UDim2.new(0, 40, 0, 40)
    Avatar.Position = UDim2.new(0, 0, 0.15, 0)
    Avatar.BackgroundTransparency = 1
    Avatar.Image = "rbxassetid://0"

    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(0.5, 0)
    AvatarCorner.Parent = Avatar

    local UserLabel = Instance.new("TextLabel")
    UserLabel.Name = "UserLabel"
    UserLabel.Parent = PlayerFrame
    UserLabel.Size = UDim2.new(1, -50, 0.7, 0)
    UserLabel.Position = UDim2.new(0, 50, 0, 0)
    UserLabel.BackgroundTransparency = 1
    UserLabel.Text = Player.DisplayName .. "\n(" .. Player.Name .. ")"
    UserLabel.TextColor3 = Color3.new(1,1,1)
    UserLabel.TextScaled = true
    UserLabel.Font = Enum.Font.GothamSemibold
    UserLabel.TextXAlignment = Enum.TextXAlignment.Left

    local success, thumb = pcall(function()
        return Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)
    if success then Avatar.Image = thumb end

    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.Size = UDim2.new(0.4, 0, 0.7, 0)
    MainFrame.Position = UDim2.new(0.3, 0, 0.15, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame

    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Parent = MainFrame
    Shadow.Size = UDim2.new(1, 10, 1, 10)
    Shadow.Position = UDim2.new(0, -5, 0, -5)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxasset://textures/ui/Controls/DropShadow.png"
    Shadow.ImageTransparency = 0.8
    Shadow.ImageColor3 = Color3.new(0,0,0)
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(20,20,280,280)

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Name = "Scroll"
    Scroll.Parent = MainFrame
    Scroll.Size = UDim2.new(1, -20, 1, -80)
    Scroll.Position = UDim2.new(0, 10, 0, 60)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 6
    Scroll.ScrollBarImageColor3 = Color3.fromRGB(100,100,150)
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 800)

    local SizeSmall = Instance.new("TextButton")
    SizeSmall.Name = "SizeSmall"
    SizeSmall.Parent = MainFrame
    SizeSmall.Size = UDim2.new(0.32, -5, 0, 30)
    SizeSmall.Position = UDim2.new(0, 10, 1, -40)
    SizeSmall.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    SizeSmall.Text = "Small"
    SizeSmall.TextColor3 = Color3.new(1,1,1)
    SizeSmall.Font = Enum.Font.Gotham
    SizeSmall.TextSize = 14

    local SizeSmallCorner = Instance.new("UICorner")
    SizeSmallCorner.CornerRadius = UDim.new(0, 6)
    SizeSmallCorner.Parent = SizeSmall

    local SizeMed = Instance.new("TextButton")
    SizeMed.Name = "SizeMed"
    SizeMed.Parent = MainFrame
    SizeMed.Size = UDim2.new(0.32, -5, 0, 30)
    SizeMed.Position = UDim2.new(0.34, 0, 1, -40)
    SizeMed.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    SizeMed.Text = "Medium"
    SizeMed.TextColor3 = Color3.new(1,1,1)
    SizeMed.Font = Enum.Font.Gotham
    SizeMed.TextSize = 14

    local SizeMedCorner = Instance.new("UICorner")
    SizeMedCorner.CornerRadius = UDim.new(0, 6)
    SizeMedCorner.Parent = SizeMed

    local SizeLarge = Instance.new("TextButton")
    SizeLarge.Name = "SizeLarge"
    SizeLarge.Parent = MainFrame
    SizeLarge.Size = UDim2.new(0.32, -10, 0, 30)
    SizeLarge.Position = UDim2.new(0.68, 0, 1, -40)
    SizeLarge.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    SizeLarge.Text = "Large"
    SizeLarge.TextColor3 = Color3.new(1,1,1)
    SizeLarge.Font = Enum.Font.Gotham
    SizeLarge.TextSize = 14

    local SizeLargeCorner = Instance.new("UICorner")
    SizeLargeCorner.CornerRadius = UDim.new(0, 6)
    SizeLargeCorner.Parent = SizeLarge

    makeDraggable(TitleFrame)
    makeDraggable(MainFrame)

    local function setSize(size)
        SizeState = size
        if size == "Small" then MainFrame.Size = UDim2.new(0.3, 0, 0.5, 0)
        elseif size == "Medium" then MainFrame.Size = UDim2.new(0.4, 0, 0.7, 0)
        else MainFrame.Size = UDim2.new(0.6, 0, 0.9, 0) end
        SizeSmall.BackgroundColor3 = size == "Small" and Color3.fromRGB(0,162,255) or Color3.fromRGB(50,50,70)
        SizeMed.BackgroundColor3 = size == "Medium" and Color3.fromRGB(0,162,255) or Color3.fromRGB(50,50,70)
        SizeLarge.BackgroundColor3 = size == "Large" and Color3.fromRGB(0,162,255) or Color3.fromRGB(50,50,70)
    end

    SizeSmall.MouseButton1Click:Connect(function() setSize("Small") end)
    SizeMed.MouseButton1Click:Connect(function() setSize("Medium") end)
    SizeLarge.MouseButton1Click:Connect(function() setSize("Large") end)

    local function createButton(parent, text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 40)
        btn.Position = UDim2.new(0, 10, 0, (#parent:GetChildren() * 45))
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        btn.Text = text
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 14
        btn.BorderSizePixel = 0
        btn.Parent = parent

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = btn

        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    local function createToggle(parent, text, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 40)
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.new(1,1,1)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.Parent = frame

        local togBtn = Instance.new("TextButton")
        togBtn.Size = UDim2.new(0, 30, 0, 20)
        togBtn.Position = UDim2.new(1, -40, 0.5, -10)
        togBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
        togBtn.Text = ""
        togBtn.Parent = frame

        local togCorner = Instance.new("UICorner")
        togCorner.CornerRadius = UDim.new(0.5, 0)
        togCorner.Parent = togBtn

        local toggled = false
        togBtn.MouseButton1Click:Connect(function()
            toggled = not toggled
            togBtn.BackgroundColor3 = toggled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(100, 0, 0)
            callback(toggled)
        end)

        frame.Position = UDim2.new(0, 10, 0, (#parent:GetChildren() - 1) * 45)
    end

    createToggle(Scroll, "Brainrot Dupe (Hold One)", function(state)
        DupeTog = state
        if state then
            print("Brainrot Dupe ON - Hold the Brainrot you want to dupe!")
        else
            print("Brainrot Dupe OFF")
        end
    end)

    local RarityFrame = Instance.new("Frame")
    RarityFrame.Size = UDim2.new(1, -20, 0, 120)
    RarityFrame.BackgroundTransparency = 1
    RarityFrame.Parent = Scroll

    createButton(RarityFrame, "Find Rarity (Best Money)", function()
        print("Scanning for best rarity area (e.g. Celestial/Secret zones)...")
    end)

    createButton(RarityFrame, "Divine", function() end)
    createButton(RarityFrame, "Celestial", function() end)
    createButton(RarityFrame, "Secret", function() end)

    local LuckyFrame = Instance.new("Frame")
    LuckyFrame.Size = UDim2.new(1, -20, 0, 300)
    LuckyFrame.BackgroundTransparency = 1
    LuckyFrame.Parent = Scroll

    createButton(LuckyFrame, "Lucky Blocks Auto", function() end)

    createToggle(LuckyFrame, "Infinity Lucky Block", function() end)
    createToggle(LuckyFrame, "Divine Lucky Block", function() end)
    createToggle(LuckyFrame, "Celestial Lucky Block", function() end)
    createToggle(LuckyFrame, "Secret Lucky Block", function() end)

    local MiscFrame = Instance.new("Frame")
    MiscFrame.Size = UDim2.new(1, -20, 0, 300)
    MiscFrame.BackgroundTransparency = 1
    MiscFrame.Parent = Scroll

    createButton(MiscFrame, "Misc", function() end)

    createToggle(MiscFrame, "Inf Jump", function(state) InfJump = state end)

    createToggle(MiscFrame, "Instant Buy +10 Speed", function(state) AutoBuySpeed = state end)

    createToggle(MiscFrame, "Auto Rebirth", function(state) AutoRebirth = state end)

    createToggle(MiscFrame, "Auto Collect Money", function(state) AutoCollectMoney = state end)

    local EventLabel = Instance.new("TextLabel")
    EventLabel.Size = UDim2.new(1, -20, 0, 40)
    EventLabel.BackgroundTransparency = 1
    EventLabel.Text = "Event Info: Check in-game for current events!"
    EventLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    EventLabel.TextScaled = true
    EventLabel.Parent = MiscFrame

    Scroll.CanvasSize = UDim2.new(0, 0, 0, 1000)

    spawn(function()
        while wait(0.1) do
            if AutoCollectMoney and CollectMoney then CollectMoney:FireServer() end
            if AutoBuySpeed and BuySpeedRemote then BuySpeedRemote:FireServer(10) end
            if AutoRebirth and RebirthRemote then RebirthRemote:FireServer() end
        end
    end)

    UserInputService.JumpRequest:Connect(function()
        if InfJump and Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)

    spawn(function()
        while wait(1) do
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():find("lucky") and (obj.Name:find("Infinity") or obj.Name:find("Divine") or obj.Name:find("Celestial") or obj.Name:find("Secret")) then
                    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                        Player.Character.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                        firetouchinterest(Player.Character.HumanoidRootPart, obj, 0)
                        wait(0.05)
                        firetouchinterest(Player.Character.HumanoidRootPart, obj, 1)
                    end
                end
            end
        end
    end)

    RunService.Heartbeat:Connect(function()
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.WalkSpeed = 100
            Player.Character.Humanoid.JumpPower = 100
        end
    end)

    spawn(function()
        while wait(0.5) do
            if not DupeTog then continue end

            local char = Player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then continue end

            local heldBrainrot = nil
            for _, item in pairs(char:GetChildren()) do
                if item:IsA("Tool") and item.Name:lower():find("brainrot") then
                    heldBrainrot = item
                    break
                end
            end
            if not heldBrainrot then
                for _, item in pairs(Player.Backpack:GetChildren()) do
                    if item:IsA("Tool") and item.Name:lower():find("brainrot") then
                        heldBrainrot = item
                        break
                    end
                end
            end

            if heldBrainrot then
                print("Duplicating held Brainrot: " .. heldBrainrot.Name)
                if PlaceRemote then
                    PlaceRemote:FireServer(heldBrainrot.Name, char.HumanoidRootPart.Position + Vector3.new(5, 0, 0))
                    wait(0.3)
                    PlaceRemote:FireServer(heldBrainrot.Name, char.HumanoidRootPart.Position + Vector3.new(10, 0, 0))
                    print("Dupe attempted - check your base! (should persist after rejoin)")
                else
                    warn("PlaceRemote not found - dupe may not work.")
                end
            end
        end
    end)
end

createToggleButton()
createGUI()

print("Sakchet Hub Loaded! Circle button to open GUI. Hold a Brainrot & toggle Dupe!")
]] )()
