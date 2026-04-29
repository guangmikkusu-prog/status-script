--[[
    [TITLE]: Status Script Final Edition
    [DESCRIPTION]: 日英切替・全裏機能解説・Noclipスタック防止・TPジャンプ・重力ハック
    [AUTHOR]: User
    [VERSION]: 2.0.0
]]

-- 🌌 ステータススクリプト【究極最終版：日英切替・全裏設定解説・完全統合】

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- 二重起動防止
if CoreGui:FindFirstChild("Status_Final_Infinity_Edition") then
	CoreGui:FindFirstChild("Status_Final_Infinity_Edition"):Destroy()
end

local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "Status_Final_Infinity_Edition"

-- テーマ
local THEME_BG = Color3.fromRGB(5, 5, 20)
local THEME_ACCENT = Color3.fromRGB(0, 150, 255)
local THEME_TEXT = Color3.fromRGB(180, 220, 255)

-- 🌌 宇宙オーラSボタン (ドラッグ可能)
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0,90,0,90); openBtn.Position = UDim2.new(0.05,0,0.4,0)
openBtn.Text = "S"; openBtn.TextScaled = true; openBtn.Font = Enum.Font.GothamBlack
openBtn.BackgroundColor3 = THEME_BG; openBtn.TextColor3 = THEME_TEXT; openBtn.Draggable = true
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1,0)
local sStroke = Instance.new("UIStroke", openBtn); sStroke.Color = THEME_ACCENT; sStroke.Thickness = 4

-- メインGUI
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0.5, 0, 0.65, 0); main.Position = UDim2.new(0.25, 0, 0.15, 0)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 40); main.Visible = false; main.Active = true; main.Draggable = true
Instance.new("UIStroke", main).Color = THEME_ACCENT

openBtn.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)

-- 📖 説明用GUI (スクロール可能)
local helpFrame = Instance.new("Frame", gui)
helpFrame.Size = UDim2.new(0.45, 0, 0.65, 0); helpFrame.Position = UDim2.new(0.27, 0, 0.18, 0)
helpFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 25); helpFrame.Visible = false; helpFrame.Active = true; helpFrame.Draggable = true
Instance.new("UIStroke", helpFrame).Color = Color3.fromRGB(255, 200, 0)

local helpScroll = Instance.new("ScrollingFrame", helpFrame)
helpScroll.Size = UDim2.new(0.95, 0, 0.95, 0); helpScroll.Position = UDim2.new(0.025, 0, 0.025, 0)
helpScroll.BackgroundTransparency = 1; helpScroll.CanvasSize = UDim2.new(0, 0, 2.8, 0); helpScroll.ScrollBarThickness = 6

local helpLabel = Instance.new("TextLabel", helpScroll)
helpLabel.Size = UDim2.new(1, 0, 1, 0); helpLabel.BackgroundTransparency = 1; helpLabel.TextColor3 = Color3.new(1, 1, 1)
helpLabel.TextScaled = true; helpLabel.Font = Enum.Font.SourceSansBold; helpLabel.TextXAlignment = Enum.TextXAlignment.Left; helpLabel.TextYAlignment = Enum.TextYAlignment.Top

-- サブボタン
local function createStyledBtn(text)
	local b = Instance.new("TextButton", gui)
	b.Size = UDim2.new(0, 70, 0, 35); b.BackgroundColor3 = THEME_BG; b.TextColor3 = THEME_TEXT
	b.Text = text; b.Font = Enum.Font.GothamBlack; b.Visible = false; b.Draggable = true
	Instance.new("UICorner", b).CornerRadius = UDim.new(0.2,0); Instance.new("UIStroke", b).Color = THEME_ACCENT
	return b
end
local copyBtn = createStyledBtn("COPY"); local tpToBtn = createStyledBtn("TP")

--=====================
-- 状態管理
--=====================
local states = {
	tp = false, normalSpeed = false, jump = false, tpJump = false,
	noclip = false, infjump = false, autoPlatform = false,
	gravity = false, showExtraBtns = false, isEnglish = false, updateLang = {}
}
local defaultWS, defaultJP = 16, 50
local savedPos, respawnPos = nil, nil
local hasJumped = false

--=====================
-- UI構築 (日英対応)
--=====================
local function createBox(y, jpText, enText)
	local box = Instance.new("TextBox", main)
	box.Size = UDim2.new(0.6,0,0.05,0); box.Position = UDim2.new(0.2,0,y,0)
	box.PlaceholderText = jpText; box.TextScaled = true; box.BackgroundColor3 = Color3.fromRGB(45,45,60); box.TextColor3 = Color3.new(1,1,1)
	table.insert(states.updateLang, function() box.PlaceholderText = states.isEnglish and enText or jpText end)
	return box
end

local function createToggle(y, jpLabel, enLabel, key)
	local btn = Instance.new("TextButton", main)
	btn.Size = UDim2.new(0.6,0,0.05,0); btn.Position = UDim2.new(0.2,0,y,0)
	local function updateDisplay()
		local label = states.isEnglish and enLabel or jpLabel
		btn.Text = label.." : "..(states[key] and "ON" or "OFF")
		btn.BackgroundColor3 = states[key] and Color3.fromRGB(0,170,0) or Color3.fromRGB(150,0,0)
	end
	updateDisplay(); btn.TextScaled = true; btn.TextColor3 = Color3.new(1,1,1)
	btn.MouseButton1Click:Connect(function()
		states[key] = not states[key]
		updateDisplay()
		if key == "noclip" and not states[key] and player.Character then
			for _, v in pairs(player.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = (v.Name ~= "HumanoidRootPart") end end
			local hum = player.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
		end
		if key == "showExtraBtns" then
			copyBtn.Visible = states[key]; tpToBtn.Visible = states[key]
			copyBtn.Position = openBtn.Position + UDim2.new(0, 100, 0, 0); tpToBtn.Position = openBtn.Position + UDim2.new(0, 100, 0, 45)
		end
	end)
	table.insert(states.updateLang, updateDisplay)
end

-- 🌐 日英切替ボタン (右上)
local langBtn = Instance.new("TextButton", main)
langBtn.Size = UDim2.new(0.15, 0, 0.05, 0); langBtn.Position = UDim2.new(0.82, 0, 0.02, 0)
langBtn.Text = "JP/EN"; langBtn.TextScaled = true; langBtn.BackgroundColor3 = THEME_BG; langBtn.TextColor3 = THEME_ACCENT
Instance.new("UICorner", langBtn); Instance.new("UIStroke", langBtn).Color = THEME_ACCENT
langBtn.MouseButton1Click:Connect(function() states.isEnglish = not states.isEnglish; for _, fn in pairs(states.updateLang) do fn() end end)

-- 📖 説明ボタン (右下)
local helpBtn = Instance.new("TextButton", main)
helpBtn.Size = UDim2.new(0.15, 0, 0.05, 0); helpBtn.Position = UDim2.new(0.82, 0, 0.92, 0)
helpBtn.TextScaled = true; helpBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50); helpBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", helpBtn); Instance.new("UIStroke", helpBtn).Color = Color3.fromRGB(255, 200, 0)

local function updateHelpText()
	helpBtn.Text = states.isEnglish and "HELP" or "説明"
	if states.isEnglish then
		helpLabel.Text = [[【HOW TO OPERATE】
1. Input values into text boxes.
2. Click Toggle buttons to turn ON/OFF.
3. Use 'S' button to open/close GUI.
4. Language button (Top-Right) toggles JP/EN.

【FEATURES & SECRETS】
- TP Speed: Teleports towards MoveDirection. (Secret: Uses CFrame to bypass speed checks).
- WalkSpeed/Jump: Overrides default limits.
- TP Jump: High-power vertical teleport jump.
- Gravity: Change physics gravity. (Secret: 0.015 multiplier for smooth floating).
- Auto Platform: Neon floor on falling. (Secret: task.wait(2) auto-destroys for zero lag).
- Noclip: Pass through all walls. (Secret: Every frame CanCollide = false to beat engine recovery).
- Inf Jump: Multi-jump. (Secret: Directly changes state to Jumping on request).
- Respawn: Saves CFrame. (Secret: Persists after character reset).
- Anti-Stuck: Turning Noclip OFF triggers 'GettingUp' to prevent wall-stuck.]]
	else
		helpLabel.Text = [[【操作方法】
1. 各テキストボックスに数値を入力します。
2. 切替ボタンをクリックしてON/OFFを切り替えます。
3. 「S」ボタンでGUIの開閉が可能です。
4. 右上のボタンで日本語と英語を切り替えられます。

【機能と裏設定・仕組み】
- TPスピード: 移動方向にテレポート移動。(裏: CFrame演算により速度監視を回避)。
- 通常速度/ジャンプ: ゲーム側の制限を無視。
- TPジャンプ: 垂直方向への超高出力テレポートジャンプ。
- 重力ハック: 重力加速度を書き換え。(裏: 0.015係数でふわふわした操作感を実現)。
- 自動足場: 落下中のみ床を生成。(裏: 2秒後にDestroy()し、サーバー負荷をゼロに)。
- Noclip: すべての壁を透過。(裏: 毎フレームCanCollideをOFFにし物理エンジンの自動復元を制圧)。
- 無限ジャンプ: 空中で何度でも跳べる。(裏: JumpRequest時に強制的に状態を書き換え)。
- リス地設定: 現在位置を保存。(裏: キャラ更新後もCFrameを維持)。
- アンチスタック: NoclipをOFFにした瞬間「起き上がり」状態を強制し、壁埋まりを防止。]]
	end
end
table.insert(states.updateLang, updateHelpText); updateHelpText()
helpBtn.MouseButton1Click:Connect(function() helpFrame.Visible = not helpFrame.Visible end)

-- 配置
local tpIn = createBox(0.01, "TP距離", "TP Dist"); createToggle(0.07, "TPスピード", "TP Speed", "tp")
local wsIn = createBox(0.14, "通常スピード値", "WalkSpeed Val"); createToggle(0.20, "通常スピード", "Speed Hack", "normalSpeed")
local jpIn = createBox(0.27, "通常ジャンプ値", "Jump Val"); createToggle(0.33, "通常ジャンプ", "Jump Hack", "jump")
local tpjIn = createBox(0.40, "TPジャンプ値", "TP Jump Val"); createToggle(0.46, "TPジャンプ", "TP Jump", "tpJump")
local gravIn = createBox(0.53, "重力値", "Gravity Val"); createToggle(0.59, "重力ハック", "Gravity Hack", "gravity")
createToggle(0.66, "自動足場(J後)", "Auto Platform", "autoPlatform")
createToggle(0.73, "Noclip", "Noclip", "noclip"); createToggle(0.80, "無限ジャンプ", "Infinite Jump", "infjump")
local setRespawn = Instance.new("TextButton", main); setRespawn.Size = UDim2.new(0.6,0,0.06,0); setRespawn.Position = UDim2.new(0.2,0,0.87,0)
setRespawn.TextScaled = true; setRespawn.BackgroundColor3 = Color3.fromRGB(60,60,80); setRespawn.TextColor3 = Color3.new(1,1,1)
Instance.new("UIStroke", setRespawn).Color = THEME_ACCENT
local function updateRespawnText() setRespawn.Text = states.isEnglish and "Set Respawn" or "ここをリス地にする" end
table.insert(states.updateLang, updateRespawnText); updateRespawnText()
createToggle(0.93, "座標ボタン表示", "Show Coord Btns", "showExtraBtns")

--=====================
-- ロジック
--=====================
setRespawn.MouseButton1Click:Connect(function()
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		respawnPos = player.Character.HumanoidRootPart.CFrame
		setRespawn.Text = states.isEnglish and "Done" or "完了"; task.wait(0.5); updateRespawnText()
	end
end)
player.CharacterAdded:Connect(function(char) if respawnPos then task.wait(0.1); char:WaitForChild("HumanoidRootPart").CFrame = respawnPos end end)
copyBtn.MouseButton1Click:Connect(function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then savedPos = player.Character.HumanoidRootPart.CFrame end end)
tpToBtn.MouseButton1Click:Connect(function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and savedPos then player.Character.HumanoidRootPart.CFrame = savedPos end end)

RunService.Stepped:Connect(function()
	local char = player.Character; if not char then return end
	local hum, root = char:FindFirstChildOfClass("Humanoid"), char:FindFirstChild("HumanoidRootPart")
	if not hum or not root then return end
	if states.normalSpeed then hum.WalkSpeed = tonumber(wsIn.Text) or defaultWS else hum.WalkSpeed = defaultWS end
	if states.jump then hum.UseJumpPower = true; hum.JumpPower = tonumber(jpIn.Text) or defaultJP else hum.JumpPower = defaultJP end
	if states.gravity then
		local offset = (196.2 - (tonumber(gravIn.Text) or 196.2)) * 0.015
		if hum:GetState() == Enum.HumanoidStateType.Freefall or hum:GetState() == Enum.HumanoidStateType.Jumping then root.Velocity += Vector3.new(0, offset, 0) end
	end
	if states.tp and hum.MoveDirection.Magnitude > 0 then root.CFrame += hum.MoveDirection.Unit * ((tonumber(tpIn.Text) or 10)/10) end
	if states.noclip then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
	if hum:GetState() == Enum.HumanoidStateType.Jumping then hasJumped = true end
	if states.autoPlatform and hasJumped and root.Velocity.Y < -5 then
		local p = Instance.new("Part", workspace); p.Size = Vector3.new(8,0.2,8); p.Position = root.Position - Vector3.new(0,3.2,0); p.Anchored = true; p.BrickColor = BrickColor.new("Cyan"); p.Material = Enum.Material.Neon
		task.spawn(function() task.wait(2); p:Destroy() end); hasJumped = false
	end
end)

UIS.JumpRequest:Connect(function()
	local char = player.Character; if not char or not char:FindFirstChild("Humanoid") then return end
	if states.infjump then char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
	if states.tpJump and char:FindFirstChild("HumanoidRootPart") and tonumber(tpjIn.Text) then
		char.HumanoidRootPart.Velocity = Vector3.new(char.HumanoidRootPart.Velocity.X, tonumber(tpjIn.Text), char.HumanoidRootPart.Velocity.Z)
	end
end)
-- ==========================================================
-- 🔑 オートセーブ完全修正版 (Delta用)
-- ==========================================================

local SAVE_FILE = "StatusKey_Save.txt"
local GIST_URL = "https://gist.githubusercontent.com/guangmikkusu-prog/b2f286e93801333b9e6a2aa942899e82/raw/STATUSSCRIPT_TEST"
local KEY_SITE_URL = "https://gist.github.com/guangmikkusu-prog/b2f286e93801333b9e6a2aa942899e82"
local targetKey = ""

-- 🌐 サーバーからキーを取得
task.spawn(function()
    local success, result = pcall(function()
        return game:HttpGet(GIST_URL)
    end)
    if success then 
        targetKey = result:gsub("%s+", "") 
    end
end)

-- 🔓 システム解除
local function unlockSystem()
    if gui:FindFirstChild("KeySystemFrame") then
        gui.KeySystemFrame:Destroy()
    end
    openBtn.Visible = true
    main.Visible = true
end

-- 💾 【修正】オートログイン判定
task.spawn(function()
    -- キーが届くまで最大5秒待つ
    local timer = 0
    while targetKey == "" and timer < 5 do
        task.wait(0.5)
        timer = timer + 0.5
    end

    -[span_0](start_span)- ファイルが存在するか確認 (isfile)[span_0](end_span)
    if isfile and isfile(SAVE_FILE) then
        local success, saved = pcall(function() return readfile(SAVE_FILE) end)
        if success then
            local cleanSaved = saved:gsub("%s+", "")
            -- 保存されたキーが最新キーか「ruruSCPdelta」なら解除
            if cleanSaved == "ruruSCPdelta" or (targetKey ~= "" and cleanSaved == targetKey) then
                unlockSystem()
            end
        end
    end
end)

-- [中略：GUI作成部分は前と同じなので省略されますが、一番下のボタン処理だけ書き換えます]

-- (中略した後の) 認証ボタンのクリックイベント部分を以下に差し替え
submit.MouseButton1Click:Connect(function()
    local input = keyInput.Text:gsub("%s+", "")
    if input == "ruruSCPdelta" or (targetKey ~= "" and input == targetKey) then
        -[span_1](start_span)- 💾 【修正】ファイルに書き込む (writefile)[span_1](end_span)
        if writefile then
            pcall(function()
                writefile(SAVE_FILE, input)
            end)
        end
        unlockSystem()
    else
        submit.Text = "INVALID"
        task.wait(1)
        submit.Text = "OK"
    end
end)
