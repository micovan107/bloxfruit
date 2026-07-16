-- [[ NGUYỄN TIẾN NAM - LOADER V32 PRO ]]
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

-- Reset GUI cũ nếu có trùng lặp
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

-- Khởi tạo giao diện chính
local KeyScreenGui = Instance.new("ScreenGui")
KeyScreenGui.Name = "NamKeySystemGUI"
KeyScreenGui.ResetOnSpawn = false
KeyScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Khung nền (Cân đối chiều cao 240 vừa vặn cho 2 nút chức năng)
local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(0, 310, 0, 240)
KeyFrame.Position = UDim2.new(0.5, -155, 0.5, -120)
KeyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
KeyFrame.BorderSizePixel = 0
KeyFrame.Active = true
KeyFrame.Draggable = true
KeyFrame.Parent = KeyScreenGui

Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 12)
local KeyStroke = Instance.new("UIStroke", KeyFrame)
KeyStroke.Thickness = 2.5
KeyStroke.Color = Color3.fromRGB(0, 200, 255)

-- Tiêu đề
local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, 0, 0, 40)
KeyTitle.Position = UDim2.new(0, 0, 0, 0)
KeyTitle.Text = "NGUYỄN TIẾN NAM - LOGIN"
KeyTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
KeyTitle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
KeyTitle.BackgroundTransparency = 0.5
KeyTitle.Font = Enum.Font.GothamBlack
KeyTitle.TextSize = 15
KeyTitle.Parent = KeyFrame
Instance.new("UICorner", KeyTitle).CornerRadius = UDim.new(0, 12)

-- Ô nhập Key
local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0.85, 0, 0, 35)
KeyInput.Position = UDim2.new(0.075, 0, 0.25, 0)
KeyInput.PlaceholderText = "Nhập Key vào đây..."
KeyInput.Text = ""
KeyInput.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.Font = Enum.Font.GothamMedium
KeyInput.TextSize = 13
KeyInput.Parent = KeyFrame
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", KeyInput).Color = Color3.fromRGB(50, 50, 60)

-- Nút GET KEY
local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(0.4, 0, 0, 35)
GetKeyBtn.Position = UDim2.new(0.075, 0, 0.45, 0)
GetKeyBtn.Text = "GET KEY"
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 0)
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.TextSize = 12
GetKeyBtn.Parent = KeyFrame
Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", GetKeyBtn).Color = Color3.fromRGB(255, 255, 0)

-- Nút XÁC NHẬN
local CheckKeyBtn = Instance.new("TextButton")
CheckKeyBtn.Size = UDim2.new(0.4, 0, 0, 35)
CheckKeyBtn.Position = UDim2.new(0.525, 0, 0.45, 0)
CheckKeyBtn.Text = "XÁC NHẬN"
CheckKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
CheckKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckKeyBtn.Font = Enum.Font.GothamBold
CheckKeyBtn.TextSize = 12
CheckKeyBtn.Parent = KeyFrame
Instance.new("UICorner", CheckKeyBtn).CornerRadius = UDim.new(0, 8)

----------------------------------------------------
-- CÁC NÚT CHỨC NĂNG LÕI (SẼ HIỆN KHI NHẬP ĐÚNG KEY)
----------------------------------------------------

-- Khung chứa các nút tính năng (Mặc định ẩn)
local FeatureFrame = Instance.new("Frame")
FeatureFrame.Size = UDim2.new(0.85, 0, 0, 100)
FeatureFrame.Position = UDim2.new(0.075, 0, 0.30, 0)
FeatureFrame.BackgroundTransparency = 1
FeatureFrame.Visible = false
FeatureFrame.Parent = KeyFrame

local UIListLayout = Instance.new("UIListLayout", FeatureFrame)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)

-- 1. Nút Chạy Auto Farm Level
local AutoFarmBtn = Instance.new("TextButton")
AutoFarmBtn.Size = UDim2.new(1, 0, 0, 38)
AutoFarmBtn.Text = "KÍCH HOẠT FARM LEVEL"
AutoFarmBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
AutoFarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoFarmBtn.Font = Enum.Font.GothamBold
AutoFarmBtn.TextSize = 12
AutoFarmBtn.Parent = FeatureFrame
Instance.new("UICorner", AutoFarmBtn).CornerRadius = UDim.new(0, 8)
local StrokeFarm = Instance.new("UIStroke", AutoFarmBtn)
StrokeFarm.Color = Color3.fromRGB(0, 150, 255)
StrokeFarm.Thickness = 1.5

-- 2. Nút Chạy Auto Farm Rương
local AutoRuongBtn = Instance.new("TextButton")
AutoRuongBtn.Size = UDim2.new(1, 0, 0, 38)
AutoRuongBtn.Text = "KÍCH HOẠT FARM RƯƠNG"
AutoRuongBtn.BackgroundColor3 = Color3.fromRGB(180, 110, 0)
AutoRuongBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoRuongBtn.Font = Enum.Font.GothamBold
AutoRuongBtn.TextSize = 12
AutoRuongBtn.Parent = FeatureFrame
Instance.new("UICorner", AutoRuongBtn).CornerRadius = UDim.new(0, 8)
local StrokeRuong = Instance.new("UIStroke", AutoRuongBtn)
StrokeRuong.Color = Color3.fromRGB(255, 170, 0)
StrokeRuong.Thickness = 1.5

-- Dòng chữ bản quyền nhỏ dưới đáy bảng
local Watermark = Instance.new("TextLabel")
Watermark.Size = UDim2.new(1, 0, 0, 20)
Watermark.Position = UDim2.new(0, 0, 1, -22)
Watermark.Text = "Tác giả: Nguyễn Tiến Nam | lazi.vn"
Watermark.TextColor3 = Color3.fromRGB(100, 100, 100)
Watermark.BackgroundTransparency = 1
Watermark.Font = Enum.Font.GothamMedium
Watermark.TextSize = 10
Watermark.Parent = KeyFrame

----------------------------------------------------
-- SỰ KIỆN TƯƠNG TÁC (EVENTS)
----------------------------------------------------

local copyFunc = setclipboard or toclipboard

-- Sự kiện Get Key
GetKeyBtn.MouseButton1Click:Connect(function()
    pcall(function() playSound("12221967") end)
    if copyFunc then
        copyFunc("https://lazi.vn/user/tien-nam.nguyen20")
        KeyInput.PlaceholderText = "Đã copy link Lazi!"
        KeyInput.Text = ""
    else
        KeyInput.PlaceholderText = "Executor không hỗ trợ!"
    end
end)

-- Sự kiện Xác nhận Key
CheckKeyBtn.MouseButton1Click:Connect(function()
    pcall(function() playSound("12221967") end)
    if KeyInput.Text == "nam792009" then
        KeyTitle.Text = "ĐĂNG NHẬP THÀNH CÔNG!"
        KeyTitle.TextColor3 = Color3.fromRGB(0, 255, 100)
        
        -- Ẩn phần nhập Key & Hiện các nút chức năng chính
        KeyInput.Visible = false
        GetKeyBtn.Visible = false
        CheckKeyBtn.Visible = false
        FeatureFrame.Visible = true
    else
        KeyTitle.Text = "SAI KEY RỒI!"
        KeyTitle.TextColor3 = Color3.fromRGB(255, 0, 0)
        KeyInput.Text = ""
        task.wait(1)
        KeyTitle.Text = "NGUYỄN TIẾN NAM - LOGIN"
        KeyTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
    end
end)

-- Kích hoạt Farm Level (Tải file autofam.lua)
AutoFarmBtn.MouseButton1Click:Connect(function()
    pcall(function() playSound("12221967") end)
    AutoFarmBtn.Text = "ĐANG KÍCH HOẠT FARM LEVEL..."
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/micovan107/bloxfruit/refs/heads/main/autofam.lua"))()
    end)
    task.wait(0.5)
    AutoFarmBtn.Text = "FARM LEVEL [ĐANG CHẠY]"
end)

-- Kích hoạt Farm Rương (Tải file autoruong.lua)
AutoRuongBtn.MouseButton1Click:Connect(function()
    pcall(function() playSound("12221967") end)
    AutoRuongBtn.Text = "ĐANG KÍCH HOẠT FARM RƯƠNG..."
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/micovan107/bloxfruit/refs/heads/main/autoruong.lua"))()
    end)
    task.wait(0.5)
    AutoRuongBtn.Text = "FARM RƯƠNG [ĐANG CHẠY]"
end)
