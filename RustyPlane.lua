if game.PlaceId == 84726337419858 then
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Rusty Plane Automation Script (Made By RyGuy)",
   Icon = 0,
   LoadingTitle = "Rayfield Interface Suite",
   LoadingSubtitle = "by RyGuy",
   ShowText = "Rayfield",
   Theme = "Default",
   ToggleUIKeybind = "K",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "RyGuy Hub"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"Hello"}
   }
})

-- ── SERVICES ────────────────────────────────────────────────────────────────
local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ── MAIN TAB ────────────────────────────────────────────────────────────────
local MainTab = Window:CreateTab("Home🏠", nil)
local Section = MainTab:CreateSection("Main")

-- ── INFINITE JUMP ────────────────────────────────────────────────────────────
local Button = MainTab:CreateButton({
   Name = "Infinite Jump",
   Callback = function()
      _G.infinjump = not _G.infinjump

      if _G.infinJumpStarted == nil then
         _G.infinJumpStarted = true

         game.StarterGui:SetCore("SendNotification", {
            Title = "RyGuy Hub";
            Text = "Infinite Jump Activated!";
            Duration = 5;
         })

         local m = LocalPlayer:GetMouse()
         m.KeyDown:connect(function(k)
            if _G.infinjump then
               if k:byte() == 32 then
                  local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                  humanoid:ChangeState("Jumping")
                  wait()
                  humanoid:ChangeState("Seated")
               end
            end
         end)
      end
   end,
})

-- ── WALKSPEED ────────────────────────────────────────────────────────────────
local Slider = MainTab:CreateSlider({
   Name = "Walkspeed",
   Range = {0, 200},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "Slider1",
   Callback = function(Value)
      LocalPlayer.Character.Humanoid.WalkSpeed = Value
   end,
})

-- ── TELEPORT ─────────────────────────────────────────────────────────────────
local COCKPIT_PART_NAME = "Cockpit"
local BACK_PART_NAME    = "BackOfPlane"

local function findPart(name)
   for _, v in ipairs(workspace:GetDescendants()) do
      if v.Name == name and v:IsA("BasePart") then
         return v
      end
   end
   return nil
end

local function teleportTo(part)
   local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
   local rootPart  = character:FindFirstChild("HumanoidRootPart")
   if rootPart and part then
      rootPart.CFrame = part.CFrame * CFrame.new(0, 3, 0)
   else
      game.StarterGui:SetCore("SendNotification", {
         Title = "Teleport Failed";
         Text = "Could not find target. Check part name.";
         Duration = 4;
      })
   end
end

local Dropdown = MainTab:CreateDropdown({
   Name = "Teleport",
   Options = {"Cockpit", "Back Of Plane"},
   CurrentOption = {"Cockpit"},
   MultipleOptions = false,
   Flag = "Dropdown1",
   Callback = function(Options)
      local selection = Options[1]
      if selection == "Cockpit" then
         teleportTo(findPart(COCKPIT_PART_NAME))
         game.StarterGui:SetCore("SendNotification", {
            Title = "Teleport"; Text = "Teleported to Cockpit."; Duration = 3;
         })
      elseif selection == "Back Of Plane" then
         teleportTo(findPart(BACK_PART_NAME))
         game.StarterGui:SetCore("SendNotification", {
            Title = "Teleport"; Text = "Teleported to Back of Plane."; Duration = 3;
         })
      end
   end,
})

-- ── AUTO FUEL TAB ─────────────────────────────────────────────────────────────
local AutoFuelTab = Maintab:CreateButton("Fuel ⛽", nil)
local FuelSection = AutoFuelTab:CreateSection("Auto Refuel")

_G.autoFuelActive  = false
local fuelLoopRunning = false

local GAS_CAN_PROMPT_NAME  = "Grab Gas Can"
local ADD_FUEL_PROMPT_NAME = "Add Fuel"

local function findPrompt(name)
   for _, v in ipairs(workspace:GetDescendants()) do
      if v:IsA("ProximityPrompt") and v.ActionText == name then
         return v
      end
   end
   return nil
end

local function promptPosition(prompt)
   local part = prompt.Parent
   if part and part:IsA("BasePart") then
      return part.Position
   end
   return nil
end

local function distanceTo(pos)
   local character = LocalPlayer.Character
   local root = character and character:FindFirstChild("HumanoidRootPart")
   if root and pos then
      return (root.Position - pos).Magnitude
   end
   return math.huge
end

local function walkTo(position, timeout)
   local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
   local humanoid  = character:FindFirstChildOfClass("Humanoid")
   local root      = character:FindFirstChild("HumanoidRootPart")
   if not humanoid or not root then return end

   humanoid:MoveTo(position)

   local timer   = 0
   local arrived = false
   local conn
   conn = humanoid.MoveToFinished:Connect(function()
      arrived = true
      conn:Disconnect()
   end)

   while not arrived and timer < (timeout or 10) do
      task.wait(0.1)
      timer += 0.1
   end

   if not arrived then conn:Disconnect() end
end

local function afkFuelLoop()
   if fuelLoopRunning then return end
   fuelLoopRunning = true

   while _G.autoFuelActive do
      local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
      local humanoid  = character:FindFirstChildOfClass("Humanoid")

      if humanoid and humanoid.Health <= 0 then
         task.wait(3)
         continue
      end

      -- STEP 1: grab a gas can
      local grabPrompt = findPrompt(GAS_CAN_PROMPT_NAME)
      if grabPrompt then
         local pos = promptPosition(grabPrompt)
         if pos then
            if distanceTo(pos) > 5 then
               walkTo(pos + Vector3.new(0, 0, 2), 8)
               task.wait(0.2)
            end
            fireproximityprompt(grabPrompt)
            task.wait(1.2)
         end
      end

      -- STEP 2: walk to fuel port and pour
      local addPrompt = findPrompt(ADD_FUEL_PROMPT_NAME)
      if addPrompt then
         local pos = promptPosition(addPrompt)
         if pos then
            if distanceTo(pos) > 5 then
               walkTo(pos + Vector3.new(0, 0, 2), 10)
               task.wait(0.2)
            end
            fireproximityprompt(addPrompt)
            task.wait(1.5)
         end
      else
         task.wait(2)
      end

      task.wait(0.8)
   end

   fuelLoopRunning = false
end

local FuelToggle = AutoFuelTab:CreateToggle({
   Name = "Auto Refuel (AFK)",
   CurrentValue = false,
   Flag = "AutoFuelToggle",
   Callback = function(Value)
      _G.autoFuelActive = Value
      if Value then
         game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Fuel"; Text = "AFK refuel running. Do nothing."; Duration = 4;
         })
         task.spawn(afkFuelLoop)
      else
         game.StarterGui:SetCore("SendNotification", {
            Title = "Auto Fuel"; Text = "Auto refuel stopped."; Duration = 3;
         })
      end
   end,
})

end
