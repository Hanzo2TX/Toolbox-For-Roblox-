local T=getgenv().Toolbox
if not T or not T.RegisterCategories then return end
local W=workspace
local R=game:GetService("ReplicatedStorage")
local P=game:GetService("Players").LocalPlayer
local TS=game:GetService("TweenService")
local RS=game:GetService("RunService")
local function ch() return P.Character or P.CharacterAdded:Wait() end
local function root() return ch():WaitForChild("HumanoidRootPart") end
local function get(o,...) for _,k in ipairs({...}) do o=o and o:FindFirstChild(k) end return o end
local function tp(o,t) if not o then return end root().CFrame=typeof(o)=="CFrame" and o or (o:IsA("Model") and o:GetPivot() or o.CFrame) if t then task.wait(t) end end
local function pp(o) if o and o:IsA("ProximityPrompt") and o.Enabled then pcall(function() fireproximityprompt(o) end) end end
local function use(o) local q=o and (o:IsA("ProximityPrompt") and o or o:FindFirstChildWhichIsA("ProximityPrompt",true)) if q and q.Parent then if q.Parent:IsA("BasePart") then tp(q.Parent.CFrame,.3) end pp(q) end end
local function equip(n) local c=ch() local tool=c:FindFirstChild(n) or get(P,"Backpack",n) if tool and tool.Parent~=c then local h=c:FindFirstChildOfClass("Humanoid") if h then h:EquipTool(tool) end end return tool end
local function invoke(tree,args) local f=get(R,"Packages","Packet","PacketFunction") if f then return f:InvokeServer(0,{__args=args or {},__tree=tree,__callType=0}) end end
local function btn(n,f,t) return {label=n,type=t or "action",enabled=false,has_shortcut=false,callback=f} end
local categories={}
local function cat(n,v) categories[#categories+1]={name=n,items=v} end
local active=false
local serial=0
local motion=nil
local stepping=nil
local float=nil
local original={}
local function stop()
 active=false serial+=1
 if motion then motion:Cancel() motion=nil end
 if stepping then stepping:Disconnect() stepping=nil end
 for part,value in pairs(original) do if part.Parent then part.CanCollide=value end end
 original={}
 if float then float:Destroy() float=nil end
end
local function grin()
 local maze=get(W,"Section1","Maze")
 local mode=W:GetAttribute("GamemodeMode")
 return maze and (maze:FindFirstChild(mode=="Normal" and "GrinDemon" or "GrinDemonNM") or maze:FindFirstChild("GrinDemon") or maze:FindFirstChild("GrinDemonNM"))
end
local function attack()
 stop() active=true
 local token=serial local c=ch() local r=root()
 float=Instance.new("Part") float.Name="ToolboxTorchFloat" float.Size=Vector3.new(3,.2,3) float.Anchored=true float.Transparency=1 float.CanCollide=true float.Parent=W
 stepping=RS.Stepped:Connect(function()
  if not active or serial~=token or not r.Parent then return end
  float.CFrame=r.CFrame*CFrame.new(0,-3.1,0)
  for _,v in ipairs(c:GetDescendants()) do if v:IsA("BasePart") then if original[v]==nil then original[v]=v.CanCollide end v.CanCollide=false end end
 end)
 task.spawn(function()
  local lastThrow,lastSwitch=0,0
  while active and serial==token and r.Parent do
   local monster=grin()
   local target=monster and (monster:FindFirstChild("HumanoidRootPart") or monster.PrimaryPart or monster:FindFirstChildWhichIsA("BasePart"))
   if target then
    local center=target.Position
    local offset=Vector3.new(r.Position.X-center.X,0,r.Position.Z-center.Z)
    local away=offset.Magnitude>.1 and offset.Unit or Vector3.new(0,0,1)
    local desired=center+away*35+Vector3.new(0,5,0)
    local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances={c,monster,float}
    local function blocked(pos) return W:Raycast(pos,center-pos,params)~=nil end
    if blocked(r.Position+Vector3.new(0,2,0)) and os.clock()-lastSwitch>1.5 then
     for _,dir in ipairs({-away,Vector3.new(-away.Z,0,away.X),Vector3.new(away.Z,0,-away.X)}) do
      local pos=center+dir*35+Vector3.new(0,5,0)
      if not blocked(pos) then if motion then motion:Cancel() end tp(CFrame.lookAt(pos,center)) desired=pos lastSwitch=os.clock() break end
     end
    end
    if motion then motion:Cancel() end
    local distance=(r.Position-desired).Magnitude
    if distance>2 then motion=TS:Create(r,TweenInfo.new(math.clamp(distance/65,.08,.6),Enum.EasingStyle.Linear),{CFrame=CFrame.lookAt(desired,center)}) motion:Play() end
    local torch
    for _,folder in ipairs({c,P:FindFirstChildOfClass("Backpack")}) do
     if folder then for _,v in ipairs(folder:GetChildren()) do
      if v:IsA("Tool") and v:FindFirstChild("RemoteEvent") and (v.Name:lower():find("torch") or v.Name:lower():find("fire")) then torch=v break end
     end end
     if torch then break end
    end
    if torch then
     if torch.Parent~=c then equip(torch.Name) end
     if torch.Parent==c and not blocked(r.Position+Vector3.new(0,2,0)) and os.clock()-lastThrow>1.2 then
      pcall(function() torch.RemoteEvent:FireServer(CFrame.lookAt(r.Position+Vector3.new(0,2,0),center)) end)
      lastThrow=os.clock()
     end
    end
   end
   task.wait(.15)
  end
 end)
end

cat("Gozu & Mezu",{btn("Auto Complete",function() tp(CFrame.new(-582,38,417)) end)})
cat("Heart",{
 btn("Talk",function() tp(CFrame.new(-138,45,79)) end),
 btn("Auto Hearts",function()
  local puzzle=get(W,"Section1","Puzzle")
  local hearts=get(puzzle,"Hearts")
  if hearts then for _,v in ipairs(hearts:GetChildren()) do local q=v:FindFirstChild("ProximityPrompt") if q and q.Enabled then tp(v:FindFirstChild("Heart") or v,.3) pp(q) end end end
  local spins=get(puzzle,"SpinModel")
  if spins then for _,v in ipairs(spins:GetChildren()) do local heart=get(v,"BeatingHeart","Heart") local q=get(heart,"ProximityPrompt") if q and q.Enabled then equip("Heart") use(q) end end end
 end),
 btn("Auto Run",function() tp(CFrame.new(-101,42,-395),.3) local doors=get(W,"Section1","Maze","Doors2") if doors then for _,v in ipairs(doors:GetChildren()) do local main=v:FindFirstChild("MAIN") if main and (main.Position-root().Position).Magnitude<30 then use(main) break end end end end)
})
cat("Maze",{
 btn("Auto Craft Torch",function()
  local maze=get(W,"Section1","Maze") local holes=get(maze,"Holes")
  if holes then for _,v in ipairs(holes:GetChildren()) do use(v) local count=0 local bp=P:FindFirstChildOfClass("Backpack") if bp then for _,item in ipairs(bp:GetChildren()) do if item.Name=="Stick" or item.Name=="Cloth" then count+=1 end end end if count>=3 then break end end end
  tp(CFrame.new(-78,4,-442),.5)
  local tables=get(maze,"Crafting","Tables")
  if tables then for _,v in ipairs(tables:GetChildren()) do local part=v:FindFirstChild("RootPart") if part and (part.Position-root().Position).Magnitude<30 then use(part) pcall(function() invoke({"CraftingService","Interact"},{}) end) local frame=get(P,"PlayerGui","Crafting","Frame") if frame then frame.Visible=false end break end end end
 end),
 btn("Get Fire",function()
  local flames=get(W,"Section1","Maze","Crafting","ArmFlames") local monster=grin() local mroot=monster and monster:FindFirstChild("HumanoidRootPart")
  if flames then for _,v in ipairs(flames:GetChildren()) do local fire=v:FindFirstChild("UndyingFlame") if fire and (not mroot or (fire.Position-mroot.Position).Magnitude>=20) then local q=fire:FindFirstChild("ProximityPrompt") if q and q.Enabled then use(q) break end end end end
 end),
 btn("Auto Throw Torch",function(state) if state then attack() else stop() end end,"toggle"),
 btn("Escape",function() tp(CFrame.new(-74,5.2,-880)) end)
})
cat("Bell",{
 btn("Enter Zone",function() tp(CFrame.new(-325.5,15,-1114)) end),
 btn("Kill All Flys",function()
  local flies=get(W,"Section2","FlyNoobs","Flies") if not flies then return end
  for _=1,2 do for _,area in ipairs(flies:GetChildren()) do for _,v in ipairs(area:GetChildren()) do
   local hitbox=v:FindFirstChild("FlyHitbox") local eyes=v:FindFirstChild("eyes")
   if hitbox and (not eyes or eyes.Transparency~=1) then local sword=equip("Bone Sword") if sword then tp(hitbox,.2) sword:Activate() task.wait(3) end end
  end end end
 end),
 btn("Auto Bell",function()
  local bells=get(W,"Section2","Bells") if not bells then return end
  for _,bell in ipairs(bells:GetChildren()) do
   local base=get(bell,"2","Base") local minions=bell:FindFirstChild("HandMinions")
   if base and minions then
    local q=base:FindFirstChild("ProximityPrompt") local hit=minions:FindFirstChild("Hitbox1")
    if q and hit then
     local start=os.clock()
     while bell.Parent and (minions:GetAttribute("Health") or 0)>0 and os.clock()-start<60 do
      if minions:GetAttribute("CanDamage") then local sword=equip("Bone Sword") if sword then tp(hit,.2) sword:Activate() end
      else use(q) end
      task.wait(.3)
     end
    end
   end
  end
 end),
 btn("Teleport To Door",function()
  local doors=get(W,"Section2","PuzzleDoor","Doors") if doors then for _,v in ipairs(doors:GetChildren()) do local combos=get(v,"Shapes","Combos") local gui=get(combos,"SurfaceGui") if combos and combos.Position.Y>=0 and gui and #gui:GetChildren()>0 then tp(combos,.3) break end end end
 end),
 btn("Auto Complete Puzzle",function()
  local doors=get(W,"Section2","PuzzleDoor","Doors") if not doors then return end
  for _,v in ipairs(doors:GetChildren()) do local combos=get(v,"Shapes","Combos") local gui=get(combos,"SurfaceGui") if combos and combos.Position.Y>=0 and gui and #gui:GetChildren()>0 then
   local names={} for _,child in ipairs(gui:GetChildren()) do names[#names+1]=child.Name end
   tp(combos,.3) use(get(v,"DoorDetector","ProximityPrompt")) pcall(function() invoke({"DoorPuzzleService","Clicked"},{names}) end) break
  end end
 end),
 btn("Auto Run",function() tp(CFrame.new(-3888,-55,-2289)) end)
})
cat("Enzukai",{
 btn("Enter Zone",function() for _,name in ipairs({"Trigger","Trigger2"}) do tp(get(W,"Section2.5","MindGame","Intro",name),.3) end end),
 btn("Auto Complete",function() local boats=get(W,"Section2.5","MindGame","Boats") if not boats then return end for _,v in ipairs(boats:GetChildren()) do local assigned=v:FindFirstChild("AssignedPlayer") if assigned and assigned.Value==P then local gamePart=v:FindFirstChild("EnzukaiGame") local q=get(gamePart,"RootPart","PromptAttachment","ProximityPrompt") local start=os.clock() while q and q.Parent and gamePart.Parent and os.clock()-start<90 do pp(q) task.wait(.1) end break end end end)
})
cat("Father",{
 btn("Disable Isamu",function() local hit=get(W,"Section3","IsamuAI","Hitbox") if hit then hit.CanTouch=false end end),
 btn("Teleport To Safe Spot",function() tp(CFrame.new(1136,30,-2400)) end)
})
cat("Train",{btn("Enter Zone",function() tp(get(W,"Section3.5","GhostTrain","TrainTrigger")) end)})
cat("Larves",{btn("Auto Complete",function()
 local givers=get(W,"Section4","HotPotato","Givers")
 if givers then for _,v in ipairs(givers:GetChildren()) do local q=get(v,"RootPart","ProximityPrompt") if q and q.Enabled then use(q) break end end end
 use(get(W,"Section4","DogWall","RootPart","ProximityPrompt"))
end)})
cat("Mud",{btn("Auto Complete",function() tp(get(W,"Section4.5","TeleportToSection5")) end)})
cat("Yurei",{
 btn("Teleport To House",function() local houses=get(W,"Section5","ISPY","Houses") if houses then for _,v in ipairs(houses:GetChildren()) do local q=get(v,"Player","HumanoidRootPart","ProximityPrompt") if q and q.Enabled then use(q) break end end end end),
 btn("Auto Click Items",function()
  local houses=get(W,"Section5","ISPY","Houses") local text=get(P,"PlayerGui","Section5","TextLabel") if not houses or not text then return end
  local aliases={TeddyBear="Teddy Bear",TraditionalLantern="Traditional Lantern",JapaneseStoneLantern="Japanese Stone Lantern",RubberDuck="Rubber Duck",WorkingLantern="Working Lantern",SunSymbol="Sun Symbol",KintoruHead="Kintoru Head",MailBox="Mail Box",RiceBarrel="Rice Barrel"}
  local clicked={}
  for _,v in ipairs(houses:GetChildren()) do local part=get(v,"Player","HumanoidRootPart") local items=v:FindFirstChild("Items") if part and items and (part.Position-root().Position).Magnitude<=50 then
   for _,item in ipairs(items:GetChildren()) do if not clicked[item.Name] and (text.Text:find(item.Name,1,true) or text.Text:find(aliases[item.Name] or " ",1,true)) then
    clicked[item.Name]=true pcall(function() invoke({"IspyService","Clicked"},{item.Name}) end) task.wait(.3)
   end end
  end end
 end)
})
local function clearMap() local build=get(W,"Section5","Boss","Build") if build then for _,v in ipairs(build:GetChildren()) do if v.Name=="c01-15k" or v.Name=="InvisWall" then v:Destroy() end end end end
local bossOn=false
local bossSerial=0
cat("Boss",{
 btn("Auto Complete",function(state)
  bossOn=state bossSerial+=1 local token=bossSerial
  if not state then return end
  task.spawn(function()
   while bossOn and bossSerial==token do
    local fight=get(P,"PlayerGui","BossFight") local monsters=get(W,"Section5","Boss","MonsterFolder")
    local yurei=monsters and (monsters:FindFirstChild("Yurei") or monsters:FindFirstChild("YureiNM"))
    local body=yurei and yurei:FindFirstChild("Body")
    if fight and fight.Enabled and body then
     local sword=equip("Katana")
     if sword then tp(body.CFrame*CFrame.new(0,-40,0),.15) sword:Activate() end
    end
    task.wait(.2)
   end
  end)
 end,"toggle"),
 btn("Clear Map",clearMap),
 btn("Teleport To Safe Spot",function() clearMap() tp(CFrame.new(3078,17,-540)) end),
 btn("Get Katanas",function() clearMap() local folder=get(W,"Section5","Boss","Katanas") if folder then local count=0 for _,v in ipairs(folder:GetChildren()) do if count>=5 then break end if v:IsA("BasePart") and v.Transparency==0 then tp(v.CFrame*CFrame.new(15,0,0),.3) use(v) count+=1 end end end tp(CFrame.new(3078,17,-540)) end)
})
cat("Hell",{btn("Auto Run",function() tp(CFrame.new(-1697,246,7806)) end)})
T:RegisterCategories(categories)
T:Refresh()
