-- Auto Sit Script for Musical Chairs
-- Created for Delta Executor

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Buat GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "AutoChairGUI"
gui.ResetOnSpawn = false

-- Frame utama
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 280, 0, 120)
frame.Position = UDim2.new(0.5, -140, 0.85, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 12)

-- Tombol Teleport Sekali
local teleportBtn = Instance.new("TextButton", frame)
teleportBtn.Size = UDim2.new(0, 120, 0, 40)
teleportBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
teleportBtn.Text = "🎯 Teleport"
teleportBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportBtn.Font = Enum.Font.SourceSansBold
teleportBtn.TextSize = 18

local btnCorner = Instance.new("UICorner", teleportBtn)
btnCorner.CornerRadius = UDim.new(0, 8)

-- Tombol Auto Teleport (Toggle)
local autoBtn = Instance.new("TextButton", frame)
autoBtn.Size = UDim2.new(0, 120, 0, 40)
autoBtn.Position = UDim2.new(0.55, 0, 0.15, 0)
autoBtn.Text = "⏳ Auto: OFF"
autoBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.Font = Enum.Font.SourceSansBold
autoBtn.TextSize = 18

local autoCorner = Instance.new("UICorner", autoBtn)
autoCorner.CornerRadius = UDim.new(0, 8)

-- Label status
local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0.7, 0)
statusLabel.Text = "Status: Siap"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 14
statusLabel.BackgroundTransparency = 1

-- Fungsi mencari kursi terdekat
local function findNearestChair()
    local character = player.Character
    if not character then return nil end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local chairs = {}
    -- Cari semua objek yang mengandung kata "chair" atau "seat"
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local name = obj.Name:lower()
            if name:find("chair") or name:find("seat") then
                -- Jika model, cari primary part atau part pertama
                local pos = obj:IsA("Model") and obj.PrimaryPart and obj.PrimaryPart.Position or 
                           (obj:IsA("BasePart") and obj.Position)
                if pos then
                    table.insert(chairs, {obj = obj, pos = pos})
                end
            end
        end
    end
    
    -- Cari yang terdekat
    local nearest = nil
    local nearestDist = math.huge
    local charPos = hrp.Position
    
    for _, chair in pairs(chairs) do
        local dist = (chair.pos - charPos).Magnitude
        if dist < nearestDist then
            nearestDist = dist
            nearest = chair
        end
    end
    
    return nearest
end

-- Fungsi teleport ke kursi
local function teleportToChair()
    local chair = findNearestChair()
    if not chair then
        statusLabel.Text = "⚠️ Tidak ada kursi ditemukan!"
        return false
    end
    
    local character = player.Character
    if not character then return false end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    -- Teleport ke posisi kursi + sedikit di atas
    local targetPos = chair.pos + Vector3.new(0, 2.5, 0)
    hrp.CFrame = CFrame.new(targetPos)
    
    statusLabel.Text = "✅ Teleport ke: " .. chair.obj.Name
    return true
end

-- Variabel auto mode
local autoMode = false
local autoLoop = nil

-- Fungsi toggle auto
local function toggleAuto()
    autoMode = not autoMode
    
    if autoMode then
        autoBtn.Text = "⏳ Auto: ON"
        autoBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
        statusLabel.Text = "🔄 Auto aktif - mencari kursi..."
        
        -- Loop auto teleport
        autoLoop = game:GetService("RunService").Heartbeat:Connect(function()
            -- Cek apakah pemain sedang berdiri (Humanoid.MoveDirection ~= Vector3.zero)
            -- Ini menandakan musik masih berjalan
            local char = player.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum and hum.MoveDirection.Magnitude < 0.5 then
                    -- Pemain diam, kemungkinan musik berhenti
                    teleportToChair()
                    task.wait(0.5) -- Jeda sebentar agar tidak spam
                end
            end
        end)
    else
        autoBtn.Text = "⏳ Auto: OFF"
        autoBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        statusLabel.Text = "⏹ Auto dimatikan"
        if autoLoop then
            autoLoop:Disconnect()
            autoLoop = nil
        end
    end
end

-- Event tombol
teleportBtn.MouseButton1Click:Connect(function()
    teleportToChair()
end)

autoBtn.MouseButton1Click:Connect(function()
    toggleAuto()
end)

-- Hotkey T untuk teleport cepat
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.T then
        teleportToChair()
    end
end)

statusLabel.Text = "✅ Script siap! Tekan T atau klik Teleport"
print("[Auto Chair] Script berhasil dijalankan!")