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

local MainTab = Window:CreateTab("Home🏠", nil)
local Section = MainTab:CreateSection("Main")

-- Teleport helper: finds a part by name in workspace recursively
local function findPart(name)
   for _, v in ipairs(workspace:GetDescendants()) do
      if v.Name == name and v:IsA("BasePart") then
         return v
      end
   end
   return nil
end

local function teleportTo(part)
   local player = game.Players.LocalPlayer
   local character = player.Character or player.CharacterAdded:Wait()
   local rootPart = character:FindFirstChild("HumanoidRootPart")
   if rootPart and part then
      -- Offset slightly above the target part so we don't clip into it
      rootPart.CFrame = part.CFrame * CFrame.new(0, 3, 0)
   else
      game.StarterGui:SetCore("SendNotification", {
         Title = "Teleport Failed";
         Text = "Could not find target. Check part name.";
         Duration = 4;
      })
   end
end

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

         local plr = game:GetService('Players').LocalPlayer
         local m = plr:GetMouse()
         m.KeyDown:connect(function(k)
            if _G.infinjump then
               if k:byte() == 32 then
                  local humanoid = game:GetService('Players').LocalPlayer.Character:FindFirstChildOfClass('Humanoid')
                  humanoid:ChangeState('Jumping')
                  wait()
                  humanoid:ChangeState('Seated')
               end
            end
         end)
      end
   end,
})

local Slider = MainTab:CreateSlider({
   Name = "Walkspeed",
   Range = {0, 200},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "Slider1",
   Callback = function(Value)
      game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
   end,
})

-- PART NAMES — change these if the actual part names in the game differ
-- Use a workspace explorer (e.g. Ctrl+Shift+F in your executor) to confirm exact names
local COCKPIT_PART_NAME = "Cockpit"       -- adjust to actual cockpit seat/part name
local BACK_PART_NAME    = "BackOfPlane"   -- adjust to actual back-of-plane part name

local Dropdown = MainTab:CreateDropdown({
   Name = "Teleport",
   Options = {"Cockpit", "Back Of Plane"},
   CurrentOption = {"Cockpit"},
   MultipleOptions = false,
   Flag = "Dropdown1",
   Callback = function(Options)
      local selection = Options[1]

      if selection == "Cockpit" then
         local part = findPart(COCKPIT_PART_NAME)
         teleportTo(part)
         game.StarterGui:SetCore("SendNotification", {
            Title = "Teleport";
            Text = "Teleported to Cockpit.";
            Duration = 3;
         })

      elseif selection == "Back Of Plane" then
         local part = findPart(BACK_PART_NAME)
         teleportTo(part)
         game.StarterGui:SetCore("SendNotification", {
            Title = "Teleport";
            Text = "Teleported to Back of Plane.";
            Duration = 3;
         })
      end
   end,
})

end
