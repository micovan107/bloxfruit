-- [[ NGUYỄN TIẾN NAM - LOADER V32 PRO ]]

local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

local oldKeyGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("NamKeySystemGUI")
if oldKeyGui then oldKeyGui:Destroy() end

local function playSound(soundId)
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://"..soundId
        sound.Parent = SoundService
        sound:Play()
        sound.Ended:Connect(function() sound:Destroy() end)
    end)
end

local KeyScreenGui = Instance.new("ScreenGui")
KeyScreenGui.Name = "NamKeySystemGUI"
KeyScreenGui.ResetOnSpawn = false
KeyScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(0, 300, 0, 180)
KeyFrame.Position = UDim2.new(0.5, -150, 0.5, -90)
KeyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
KeyFrame.BorderSizePixel = 0
KeyFrame.Active = true
KeyFrame.Draggable = true
KeyFrame.Parent = KeyScreenGui

Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 12)
local KeyStroke = Instance.new("UIStroke", KeyFrame)
KeyStroke.Thickness = 2.5
KeyStroke.Color = Color3.fromRGB(0, 200, 255)

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, 0, 0, 40)
KeyTitle.Position = UDim2.new(0, 0, 0, 0)
KeyTitle.Text = "NGUYỄN TIẾN NAM - LOGIN"
KeyTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
KeyTitle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
KeyTitle.BackgroundTransparency = 0.5
KeyTitle.Font = Enum.Font.GothamBlack
KeyTitle.TextSize = 16
KeyTitle.Parent = KeyFrame
Instance.new("UICorner", KeyTitle).CornerRadius = UDim.new(0, 12)

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0.8, 0, 0, 35)
KeyInput.Position = UDim2.new(0.1, 0, 0.35, 0)
KeyInput.PlaceholderText = "Nhập Key vào đây..."
KeyInput.Text = ""
KeyInput.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.Font = Enum.Font.GothamMedium
KeyInput.TextSize = 14
KeyInput.Parent = KeyFrame
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", KeyInput).Color = Color3.fromRGB(50, 50, 60)

local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(0.38, 0, 0, 35)
GetKeyBtn.Position = UDim2.new(0.1, 0, 0.65, 0)
GetKeyBtn.Text = "GET KEY"
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 0)
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.TextSize = 14
GetKeyBtn.Parent = KeyFrame
Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", GetKeyBtn).Color = Color3.fromRGB(255, 255, 0)

local CheckKeyBtn = Instance.new("TextButton")
CheckKeyBtn.Size = UDim2.new(0.38, 0, 0, 35)
CheckKeyBtn.Position = UDim2.new(0.52, 0, 0.65, 0)
CheckKeyBtn.Text = "XÁC NHẬN"
CheckKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
CheckKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckKeyBtn.Font = Enum.Font.GothamBold
CheckKeyBtn.TextSize = 14
CheckKeyBtn.Parent = KeyFrame
Instance.new("UICorner", CheckKeyBtn).CornerRadius = UDim.new(0, 8)

GetKeyBtn.MouseButton1Click:Connect(function()
    pcall(function() playSound("12221967") end)
    local copyFunc = setclipboard or toclipboard
    if copyFunc then
        copyFunc("https://lazi.vn/user/tien-nam.nguyen20")
        KeyInput.PlaceholderText = "Đã copy link Lazi!"
        KeyInput.Text = ""
    else
        KeyInput.PlaceholderText = "Executor không hỗ trợ!"
    end
end)

CheckKeyBtn.MouseButton1Click:Connect(function()
    pcall(function() playSound("12221967") end)
    if KeyInput.Text == "nam792009" then
        KeyTitle.Text = "KEY HỢP LỆ!"
        KeyTitle.TextColor3 = Color3.fromRGB(0, 255, 100)
        task.wait(0.5)
        KeyScreenGui:Destroy() 
        
        -- 🔥 THAY LINK RAW GITHUB CỦA ÔNG VÀO ĐÂY 🔥
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/micovan107/bloxfruit/refs/heads/main/autofam.lua"))()
        end)
    else
        KeyTitle.Text = "SAI KEY RỒI!"
        KeyTitle.TextColor3 = Color3.fromRGB(255, 0, 0)
        KeyInput.Text = ""
        task.wait(1)
        KeyTitle.Text = "NGUYỄN TIẾN NAM - LOGIN"
        KeyTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
    end
end)
