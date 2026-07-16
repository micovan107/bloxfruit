-- [[ NGUYỄN TIẾN NAM - AUTO CHEST PRO V2 (LOADER) ]]
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

-- Dọn dẹp GUI cũ nếu có trùng lặp
local oldGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("NamChestFarmGUI")
if oldGui then oldGui:Destroy() end

getgenv().AutoChest = false

local function playSound(soundId)
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://"..soundId
        sound.Parent = SoundService
        sound:Play()
        sound.Ended:Connect(function() sound:Destroy() end)
    end)
end

-- Tải ngầm phần lõi trước khi mở UI (Thay link Github chứa phần Lõi của ông ở đây)
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/micovan107/bloxfruit/refs/heads/main/autofam.lua"))()
end)

-- Khởi tạo ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NamChestFarmGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Bảng điều khiển chính
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 290, 0, 240)
MainFrame.Position = UDim2.new(0.5, -145, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local FrameStroke = Instance.new("UIStroke", MainFrame)
FrameStroke.Thickness = 2.5
FrameStroke.Color = Color3.fromRGB(255, 170, 0)

-- Tiêu đề
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = "NAM CHEST EXPLOIT PRO V2"
Title.TextColor3 = Color3.fromRGB(255, 170, 0)
Title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Title.BackgroundTransparency = 0.5
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 14
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

-- Nút Bật/Tắt Auto Chest chính
local ToggleChestBtn = Instance.new("TextButton")
ToggleChestBtn.Size = UDim2.new(0.86, 0, 0, 42)
ToggleChestBtn.Position = UDim2.new(0.07, 0, 0.23, 0)
ToggleChestBtn.Text = "AUTO CHEST: OFF"
ToggleChestBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
ToggleChestBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleChestBtn.Font = Enum.Font.GothamBold
ToggleChestBtn.TextSize = 13
ToggleChestBtn.Parent = MainFrame
Instance.new("UICorner", ToggleChestBtn).CornerRadius = UDim.new(0, 8)

----------------------------------------------------
-- CÁC NÚT BỔ SUNG CHỨC NĂNG (HÀNG NGANG CHUYÊN NGHIỆP)
----------------------------------------------------

-- Nút Tắt/Xóa GUI nhanh
local DestroyGuiBtn = Instance.new("TextButton")
DestroyGuiBtn.Size = UDim2.new(0.41, 0, 0, 32)
DestroyGuiBtn.Position = UDim2.new(0.07, 0, 0.45, 0)
DestroyGuiBtn.Text = "XÓA GIAO DIỆN"
DestroyGuiBtn.BackgroundColor3 = Color3.fromRGB(50, 15, 15)
DestroyGuiBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
DestroyGuiBtn.Font = Enum.Font.GothamBold
DestroyGuiBtn.TextSize = 11
DestroyGuiBtn.Parent = MainFrame
Instance.new("UICorner", DestroyGuiBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", DestroyGuiBtn).Color = Color3.fromRGB(150, 40, 40)

-- Nút Copy Link Lazi giao lưu
local CopyLaziBtn = Instance.new("TextButton")
CopyLaziBtn.Size = UDim2.new(0.41, 0, 0, 32)
CopyLaziBtn.Position = UDim2.new(0.52, 0, 0.45, 0)
CopyLaziBtn.Text = "COPY LINK LAZI"
CopyLaziBtn.BackgroundColor3 = Color3.fromRGB(15, 35, 50)
CopyLaziBtn.TextColor3 = Color3.fromRGB(100, 200, 255)
CopyLaziBtn.Font = Enum.Font.GothamBold
CopyLaziBtn.TextSize = 11
CopyLaziBtn.Parent = MainFrame
Instance.new("UICorner", CopyLaziBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", CopyLaziBtn).Color = Color3.fromRGB(40, 100, 150)

-- Bảng Log thông báo hệ thống
local LogLabel = Instance.new("TextLabel")
LogLabel.Size = UDim2.new(0.86, 0, 0, 52)
LogLabel.Position = UDim2.new(0.07, 0, 0.63, 0)
LogLabel.Text = "[HỆ THỐNG]\nSẵn sàng hoạt động."
LogLabel.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
LogLabel.TextColor3 = Color3.fromRGB(255, 170, 0)
LogLabel.Font = Enum.Font.Code
LogLabel.TextSize = 10
LogLabel.TextWrapped = true
LogLabel.Parent = MainFrame
Instance.new("UICorner", LogLabel).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", LogLabel).Color = Color3.fromRGB(50, 50, 60)

-- Tác giả watermark dưới cùng
local Watermark = Instance.new("TextLabel")
Watermark.Size = UDim2.new(1, 0, 0, 20)
Watermark.Position = UDim2.new(0, 0, 1, -22)
Watermark.Text = "Tác giả: Nguyễn Tiến Nam | lazi.vn"
Watermark.TextColor3 = Color3.fromRGB(130, 130, 130)
Watermark.BackgroundTransparency = 1
Watermark.Font = Enum.Font.GothamMedium
Watermark.TextSize = 10
Watermark.Parent = MainFrame

----------------------------------------------------
-- SỰ KIỆN TƯƠNG TÁC (EVENTS)
----------------------------------------------------

-- Sự kiện bật tắt Auto Chest
ToggleChestBtn.MouseButton1Click:Connect(function()
    getgenv().AutoChest = not getgenv().AutoChest
    pcall(function() playSound("12221967") end)
    
    if getgenv().AutoChest then
        ToggleChestBtn.Text = "AUTO CHEST: ON"
        ToggleChestBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 90)
        LogLabel.Text = "[HỆ THỐNG]\nBắt đầu chiến dịch cướp rương..."
        
        -- Gọi vòng lặp từ phần lõi đã được load trước đó
        if _G.StartChestFarmLoop then
            _G.StartChestFarmLoop(LogLabel)
        else
            LogLabel.Text = "[LỖI]\nKhông tìm thấy file lõi thực thi!"
        end
    else
        ToggleChestBtn.Text = "AUTO CHEST: OFF"
        ToggleChestBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        LogLabel.Text = "[HỆ THỐNG]\nĐã dừng auto."
    end
end)

-- Sự kiện Copy link Lazi
CopyLaziBtn.MouseButton1Click:Connect(function()
    pcall(function() playSound("12221967") end)
    local copyFunc = setclipboard or toclipboard
    if copyFunc then
        copyFunc("https://lazi.vn/user/tien-nam.nguyen20")
        LogLabel.Text = "[HỆ THỐNG]\nĐã copy link Lazi cá nhân!"
    else
        LogLabel.Text = "[HỆ THỐNG]\nExecutor không hỗ trợ sao chép."
    end
end)

-- Sự kiện Xóa GUI an toàn
DestroyGuiBtn.MouseButton1Click:Connect(function()
    pcall(function() playSound("12221967") end)
    getgenv().AutoChest = false -- Tự động tắt farm để tránh lỗi camera/vật lý khi xóa UI
    task.wait(0.1)
    ScreenGui:Destroy()
end)
