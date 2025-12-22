-- Fish It! Winter Cavern TP Hub | WindUI v1.8 (PERFECT FIXED!)
-- Fitur: Auto TP + Save Position + Auto Return saat cavern close (kalau timed)
-- Isi tab & section pasti muncul full!

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "Fish It Cavern TP ❄️",
    Folder = "FishIt",
    IconSize = 44,
    HideSearchBar = false,
    OpenButton = {
        Enabled = true  -- Biar bisa buka lagi di mobile setelah minimize/X
    }
})

Window:Open()

Window:Tag({
    Title = "version 1.0.0",
    Icon = "zap",
    Color = Color3.fromHex("#30FF6A")
})

-- Services
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Config (Koordinat Winter Cavern di Christmas Island - sisi kanan cave entrance)
-- Dari update Christmas 2025: Cave selalu accessible di Christmas Island, bukan timed.
-- Koordinat lama mungkin outdated, coba test & ganti manual kalau TP gak pas ke dalam cave.
local EVENT_POS = Vector3.new(577, -581, 8932)  -- Ganti kalau perlu
local autoTP = false
local tpDelay = 5
local savedPositions = {}
local selectedReturn = nil

-- Fungsi TP
local function tpTo(pos)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(pos)
        print("✅ TP Sukses!")
        return true
    end
    print("❌ HRP gak ketemu!")
    return false
end

-- Auto TP Loop (tanpa cek timed, karena Winter Cavern selalu open di event 2025)
task.spawn(function()
    while true do
        if autoTP then
            tpTo(EVENT_POS)
        end
        task.wait(tpDelay)
    end
end)

-- Tab Utama
local Tab = Window:Tab({
    Title = "Winter Cavern",
    Icon = "snowflake"
})

-- Section Status & Auto
local StatusSec = Tab:Section({
    Title = "Status & Auto TP"
})

StatusSec:Paragraph({
    Title = "🟢 Winter Cavern OPEN (Christmas Event)",
    Desc = "Cave di Christmas Island sisi kanan - selalu accessible."
})

StatusSec:Toggle({
    Title = "Auto TP ke Cavern",
    Desc = "Teleport Terus Menerus",
    Value = false,
    Callback = function(v)
        autoTP = v
        print("Auto TP: " .. (v and "ON" or "OFF"))
    end
})

StatusSec:Slider({
    Title = "Interval TP (detik)",
    Value = {Min = 3, Max = 30, Default = 5},
    Callback = function(v)
        tpDelay = v
    end
})

-- Section Save & Return
local SaveSec = Tab:Section({
    Title = "Save & Return Position"
})

SaveSec:Input({
    Title = "Save Position Saat Ini",
    Placeholder = "Nama spot (ex: Fisherman Island)",
    Callback = function(name)
        if name ~= "" then
            local pos = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position
            if pos then
                savedPositions[name] = pos
                print("💾 Saved: " .. name)
            end
        end
    end
})

local dropdown = SaveSec:Dropdown({
    Title = "Pilih Position Kembali",
    Values = {},  -- Auto update
    Callback = function(choice)
        selectedReturn = choice
        print("↩️ Return dipilih: " .. choice)
    end
})

-- Auto refresh dropdown
task.spawn(function()
    while true do
        local values = {}
        for name, _ in pairs(savedPositions) do
            table.insert(values, {Title = name})
        end
        dropdown:Refresh(values)
        task.wait(3)
    end
end)

SaveSec:Button({
    Title = "Teleport Kembali ke Saved Position Sebelumnya",
    Callback = function()
        if selectedReturn and savedPositions[selectedReturn] then
            tpTo(savedPositions[selectedReturn])
            print("↩️ Kembali ke " .. selectedReturn)
        else
            print("❌ Pilih position dulu di dropdown!")
        end
    end
})

-- Section Manual
local Manual