-- 🌌 ステータススクリプト【究極最終版：Noclipスタック防止・全機能統合】
-[span_0](start_span)- Source:[span_0](end_span)

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-[span_1](start_span)- 二重起動防止[span_1](end_span)
if CoreGui:FindFirstChild("Status_Final_Infinity_Edition") then
	CoreGui:FindFirstChild("Status_Final_Infinity_Edition"):Destroy()
end

local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "Status_Final_Infinity_Edition"

-[span_2](start_span)- テーマ設定[span_2](end_span)
local THEME_BG = Color3.fromRGB(5, 5, 20)
local THEME_ACCENT = Color3.fromRGB(0, 150, 255)
local THEME_TEXT = Color3.fromRGB(180, 220, 255)

-[span_3](start_span)- 🌌 宇宙オーラSボタン (メインGUI開閉用)[span_3](end_span)
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0,90,0,90)
openBtn.Position = UDim2.new(0.05,0,0.4,0)
openBtn.Text = "S"
openBtn.TextScaled = true
openBtn.Font = Enum.Font.GothamBlack
openBtn.BackgroundColor3 = THEME_BG
openBtn.TextColor3 = THEME_TEXT
openBtn.Draggable = true
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1,0)
local sStroke = Instance.new("UIStroke", openBtn)
sStroke.Color = THEME_ACCENT
sStroke.Thickness = 4

-[span_4](start_span)- メインGUIパネル[span_4](end_span)
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0.5,0,0.5,0)
main.Position = UDim2.new(0.25,0,0.25,0)
main.BackgroundColor3 = Color3.fromRGB(25,25,40)
main.Visible = false
main.Active = true
main.Draggable = true
Instance.new("UIStroke", main).Color = THEME_ACCENT

openBtn.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)

-[span_5](start_span)- サブボタン作成関数[span_5](end_span)
local function createStyledBtn(text)
	local b = Instance.new("TextButton", gui)
	b.Size = UDim2.new(0, 70, 0, 35)
	b.BackgroundColor3 = THEME_BG
	b.TextColor3 = THEME_TEXT
	b.Text = text
	b.Font = Enum.Font.GothamBlack
	b.Visible = false
	b.Draggable = true
	Instance.new("UICorner", b).CornerRadius = UDim.new(0.2,0)
	Instance.new("UIStroke", b).Color = THEME_ACCENT
	return b
end

[span_6](start_span)local copyBtn = createStyledBtn("COPY") --[span_6](end_span)
[span_7](start_span)local tpToBtn = createStyledBtn("TP")   --[span_7](end_span)

--=====================
-[span_8](start_span)- 状態管理[span_8](end_span)
--=====================
local states = {
	tp = false, normalSpeed = false, jump = false, tpJump = false,
	noclip = false, infjump = false, autoPlatform = false,
	gravity = false, showExtraBtns = false
}
local defaultWS, defaultJP = 16, 50
local savedPos, respawnPos = nil, nil
local hasJumped = false

--=====================
-[span_9](start_span)- UI構築用関数[span_9](end_span)
--=====================
local function createBox(y, text)
	local box = Instance.new("TextBox", main)
	box.Size = UDim2.new(0.6,0,0.06,0)
	box.Position = UDim2.new(0.2,0,y,0)
	box.PlaceholderText = text
	box.TextScaled = true
	box.BackgroundColor3 = Color3.fromRGB(45,45,60)
	box.TextColor3 = Color3.new(1,1,1)
	return box
end

[span_10](start_span)local function createToggle(y, label, key) --[span_10](end_span)
	local btn = Instance.new("TextButton", main)
	btn.Size = UDim2.new(0.6,0,0.06,0)
	btn.Position = UDim2.new(0.2,0,y,0)
	btn.Text = label.." : OFF"
	btn.TextScaled = true
	btn.BackgroundColor3 = Color3.fromRGB(150,0,0)
	btn.TextColor3 = Color3.new(1,1,1)
	
	btn.MouseButton1Click:Connect(function()
		states[key] = not states[key]
		btn.Text = label.." : "..(states[key] and "ON" or "OFF")
		btn.BackgroundColor3 = states[key] and Color3.fromRGB(0,170,0) or Color3.fromRGB(150,0,0)
		
		-[span_11](start_span)- Noclipオフ時のスタック回避復元[span_11](end_span)
		if key == "noclip" and not states[key] then
			if player.Character then
				for _, v in pairs(player.Character:GetDescendants()) do
					if v:IsA("BasePart") then
						v.CanCollide = (v.Name ~= "HumanoidRootPart")
					end
				end
				local hum = player.Character:FindFirstChildOfClass("Humanoid")
				if hum then 
					hum:ChangeState(Enum.HumanoidStateType.GettingUp)
				end
			end
		end

		[span_12](start_span)if key == "showExtraBtns" then --[span_12](end_span)
			copyBtn.Visible = states[key]
			tpToBtn.Visible = states[key]
			copyBtn.Position = openBtn.Position + UDim2.new(0, 100, 0, 0)
			tpToBtn.Position = openBtn.Position + UDim2.new(0, 100, 0, 45)
		end
	end)
end

-[span_13](start_span)- UI配置[span_13](end_span)
local tpIn = createBox(0.01, "TP距離")
createToggle(0.07, "TPスピード", "tp")
local wsIn = createBox(0.14, "通常スピード値")
createToggle(0.20, "通常スピード", "normalSpeed")
local jpIn = createBox(0.27, "通常ジャンプ値")
createToggle(0.33, "通常ジャンプ", "jump")
local tpjIn = createBox(0.40, "TPジャンプ値")
createToggle(0.46, "TPジャンプ", "tpJump")
local gravIn = createBox(0.53, "重力(大=速落/小=浮く)")
createToggle(0.59, "重力ハック", "gravity")
createToggle(0.66, "自動足場(J後)", "autoPlatform")
createToggle(0.73, "Noclip", "noclip")
createToggle(0.80, "無限ジャンプ", "infjump")

local setRespawn = Instance.new("TextButton", main)
setRespawn.Size = UDim2.new(0.6,0,0.06,0)
setRespawn.Position = UDim2.new(0.2,0,0.87,0)
setRespawn.Text = "ここをリス地にする"
setRespawn.TextScaled = true
setRespawn.BackgroundColor3 = Color3.fromRGB(60,60,80)
setRespawn.TextColor3 = Color3.new(1,1,1)
Instance.new("UIStroke", setRespawn).Color = THEME_ACCENT
createToggle(0.93, "座標ボタン表示", "showExtraBtns")

--=====================
-[span_14](start_span)- メインロジック[span_14](end_span)
--=====================
player.CharacterAdded:Connect(function(char)
	if respawnPos then 
		task.wait(0.1)
		char:WaitForChild("HumanoidRootPart").CFrame = respawnPos 
	end
end)

setRespawn.MouseButton1Click:Connect(function()
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		respawnPos = player.Character.HumanoidRootPart.CFrame
		setRespawn.Text = "完了"
		task.wait(0.5)
		setRespawn.Text = "ここをリス地にする"
	end
end)

copyBtn.MouseButton1Click:Connect(function() 
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then 
		savedPos = player.Character.HumanoidRootPart.CFrame 
	end 
end)

tpToBtn.MouseButton1Click:Connect(function() 
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and savedPos then 
		player.Character.HumanoidRootPart.CFrame = savedPos 
	end 
end)

-[span_15](start_span)- フレーム更新ループ[span_15](end_span)
RunService.Stepped:Connect(function()
	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	if not hum or not root then return end

	-[span_16](start_span)- スピード・通常ジャンプ設定[span_16](end_span)
	if states.normalSpeed then 
		hum.WalkSpeed = tonumber(wsIn.Text) or defaultWS 
	else 
		hum.WalkSpeed = defaultWS 
	end
	
	if states.jump then 
		hum.UseJumpPower = true
		hum.JumpPower = tonumber(jpIn.Text) or defaultJP 
	else 
		hum.JumpPower = defaultJP 
	end

	-[span_17](start_span)- 重力修正[span_17](end_span)
	if states.gravity then
		local offset = (196.2 - (tonumber(gravIn.Text) or 196.2)) * 0.015
		if hum:GetState() == Enum.HumanoidStateType.Freefall or hum:GetState() == Enum.HumanoidStateType.Jumping then
			root.Velocity += Vector3.new(0, offset, 0)
		end
	end

	-[span_18](start_span)- TP移動[span_18](end_span)
	if states.tp and hum.MoveDirection.Magnitude > 0 then 
		root.CFrame += hum.MoveDirection.Unit * ((tonumber(tpIn.Text) or 10)/10) 
	end

	-[span_19](start_span)- Noclip (ONの時は衝突判定を無効化)[span_19](end_span)
	if states.noclip then
		for _, v in pairs(char:GetDescendants()) do
			if v:IsA("BasePart") then v.CanCollide = false end
		end
	end

	-[span_20](start_span)- 足場ロジック[span_20](end_span)
	if hum:GetState() == Enum.HumanoidStateType.Jumping then hasJumped = true end
	if states.autoPlatform and hasJumped and root.Velocity.Y < -5 then
		local p = Instance.new("Part", workspace)
		p.Size = Vector3.new(8,0.2,8)
		p.Position = root.Position - Vector3.new(0,3.2,0)
		p.Anchored = true
		p.BrickColor = BrickColor.new("Cyan")
		p.Material = Enum.Material.Neon
		task.spawn(function() task.wait(2) p:Destroy() end)
		hasJumped = false
	end
end)

-[span_21](start_span)- ジャンプリクエスト時の処理[span_21](end_span)
UIS.JumpRequest:Connect(function()
	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	if not hum or not root then return end

	-[span_22](start_span)- 無限ジャンプ[span_22](end_span)
	if states.infjump then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end

	-[span_23](start_span)- TPジャンプ[span_23](end_span)
	if states.tpJump then
		local jVal = tonumber(tpjIn.Text)
		if jVal then
			root.Velocity = Vector3.new(root.Velocity.X, jVal, root.Velocity.Z)
		end
	end
end)
