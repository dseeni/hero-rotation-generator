--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
-- HeroLib
local HL     = HeroLib
local Cache  = HeroCache
local Unit   = HL.Unit
local Player = Unit.Player
local Target = Unit.Target
local Pet    = Unit.Pet
local Spell  = HL.Spell
local Item   = HL.Item
-- HeroRotation
local HR     = HeroRotation

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
if not Spell.Monk then Spell.Monk = {} end
Spell.Monk.Windwalker = {
  ChiBurst                              = Spell(123986),
  SerenityBuff                          = Spell(152173),
  Serenity                              = Spell(152173),
  FistoftheWhiteTiger                   = Spell(),
  ChiWave                               = Spell(115098),
  WhirlingDragonPunch                   = Spell(152175),
  EnergizingElixir                      = Spell(115288),
  TigerPalm                             = Spell(100780),
  FistsofFury                           = Spell(113656),
  RushingJadeWind                       = Spell(116847),
  RushingJadeWindBuff                   = Spell(116847),
  RisingSunKick                         = Spell(107428),
  SpinningCraneKick                     = Spell(107270),
  FlyingSerpentKick                     = Spell(),
  BokProcBuff                           = Spell(),
  BlackoutKick                          = Spell(100784),
  InvokeXuentheWhiteTiger               = Spell(123904),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  ArcaneTorrent                         = Spell(50613),
  LightsJudgment                        = Spell(255647),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738),
  TouchofDeath                          = Spell(115080),
  StormEarthandFire                     = Spell(137639),
  SwiftRoundhouse                       = Spell(),
  SwiftRoundhouseBuff                   = Spell(),
  SpearHandStrike                       = Spell(116705),
  TouchofKarma                          = Spell(122470),
  GoodKarma                             = Spell(),
  StormEarthandFireBuff                 = Spell(137639)
};
local S = Spell.Monk.Windwalker;

-- Items
if not Item.Monk then Item.Monk = {} end
Item.Monk.Windwalker = {
  ProlongedPower                   = Item(142117),
  LustrousGoldenPlumage            = Item()
};
local I = Item.Monk.Windwalker;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Monk.Commons,
  Windwalker = HR.GUISettings.APL.Monk.Windwalker
};

-- Variables

local EnemyRanges = {8}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    HL.GetEnemies(i);
  end
end

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Aoe, Cd, Serenity, St
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- potion
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- chi_burst,if=(!talent.serenity.enabled|!talent.fist_of_the_white_tiger.enabled)
    if S.ChiBurst:IsCastableP() and ((not S.Serenity:IsAvailable() or not S.FistoftheWhiteTiger:IsAvailable())) then
      if HR.Cast(S.ChiBurst) then return ""; end
    end
    -- chi_wave
    if S.ChiWave:IsCastableP() then
      if HR.Cast(S.ChiWave) then return ""; end
    end
  end
  Aoe = function()
    -- whirling_dragon_punch
    if S.WhirlingDragonPunch:IsCastableP() then
      if HR.Cast(S.WhirlingDragonPunch) then return ""; end
    end
    -- energizing_elixir,if=!prev_gcd.1.tiger_palm&chi<=1&energy<50
    if S.EnergizingElixir:IsCastableP() and HR.CDsON() and (not Player:PrevGCDP(1, S.TigerPalm) and Player:Chi() <= 1 and Player:EnergyPredicted() < 50) then
      if HR.Cast(S.EnergizingElixir, Settings.Windwalker.OffGCDasOffGCD.EnergizingElixir) then return ""; end
    end
    -- fists_of_fury,if=energy.time_to_max>2.5
    if S.FistsofFury:IsCastableP() and (Player:EnergyTimeToMaxPredicted() > 2.5) then
      if HR.Cast(S.FistsofFury) then return ""; end
    end
    -- rushing_jade_wind,if=buff.rushing_jade_wind.down&energy.time_to_max>1
    if S.RushingJadeWind:IsCastableP() and (Player:BuffDownP(S.RushingJadeWindBuff) and Player:EnergyTimeToMaxPredicted() > 1) then
      if HR.Cast(S.RushingJadeWind) then return ""; end
    end
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=(talent.whirling_dragon_punch.enabled&cooldown.whirling_dragon_punch.remains<gcd)&cooldown.fists_of_fury.remains>3
    if S.RisingSunKick:IsCastableP() and (bool(min:debuff.mark_of_the_crane.remains)) and ((S.WhirlingDragonPunch:IsAvailable() and S.WhirlingDragonPunch:CooldownRemainsP() < Player:GCD()) and S.FistsofFury:CooldownRemainsP() > 3) then
      if HR.Cast(S.RisingSunKick) then return ""; end
    end
    -- spinning_crane_kick,if=!prev_gcd.1.spinning_crane_kick&(chi>2|cooldown.fists_of_fury.remains>4)
    if S.SpinningCraneKick:IsCastableP() and (not Player:PrevGCDP(1, S.SpinningCraneKick) and (Player:Chi() > 2 or S.FistsofFury:CooldownRemainsP() > 4)) then
      if HR.Cast(S.SpinningCraneKick) then return ""; end
    end
    -- chi_burst,if=chi<=3
    if S.ChiBurst:IsCastableP() and (Player:Chi() <= 3) then
      if HR.Cast(S.ChiBurst) then return ""; end
    end
    -- fist_of_the_white_tiger,if=chi.max-chi>=3&(energy>46|buff.rushing_jade_wind.down)
    if S.FistoftheWhiteTiger:IsCastableP() and (Player:ChiMax() - Player:Chi() >= 3 and (Player:EnergyPredicted() > 46 or Player:BuffDownP(S.RushingJadeWindBuff))) then
      if HR.Cast(S.FistoftheWhiteTiger) then return ""; end
    end
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&chi.max-chi>=2&(energy>56|buff.rushing_jade_wind.down)
    if S.TigerPalm:IsCastableP() and (bool(min:debuff.mark_of_the_crane.remains)) and (not Player:PrevGCDP(1, S.TigerPalm) and Player:ChiMax() - Player:Chi() >= 2 and (Player:EnergyPredicted() > 56 or Player:BuffDownP(S.RushingJadeWindBuff))) then
      if HR.Cast(S.TigerPalm) then return ""; end
    end
    -- chi_wave
    if S.ChiWave:IsCastableP() then
      if HR.Cast(S.ChiWave) then return ""; end
    end
    -- flying_serpent_kick,if=buff.bok_proc.down,interrupt=1
    if S.FlyingSerpentKick:IsCastableP() and (Player:BuffDownP(S.BokProcBuff)) then
      if HR.Cast(S.FlyingSerpentKick) then return ""; end
    end
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick
    if S.BlackoutKick:IsCastableP() and (bool(min:debuff.mark_of_the_crane.remains)) and (not Player:PrevGCDP(1, S.BlackoutKick)) then
      if HR.Cast(S.BlackoutKick) then return ""; end
    end
  end
  Cd = function()
    -- invoke_xuen_the_white_tiger
    if S.InvokeXuentheWhiteTiger:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.InvokeXuentheWhiteTiger, Settings.Windwalker.OffGCDasOffGCD.InvokeXuentheWhiteTiger) then return ""; end
    end
    -- use_item,name=lustrous_golden_plumage
    if I.LustrousGoldenPlumage:IsReady() then
      if HR.CastSuggested(I.LustrousGoldenPlumage) then return ""; end
    end
    -- blood_fury
    if S.BloodFury:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
    end
    -- berserking
    if S.Berserking:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
    end
    -- arcane_torrent,if=chi.max-chi>=1&energy.time_to_max>=0.5
    if S.ArcaneTorrent:IsCastableP() and HR.CDsON() and (Player:ChiMax() - Player:Chi() >= 1 and Player:EnergyTimeToMaxPredicted() >= 0.5) then
      if HR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
    end
    -- lights_judgment
    if S.LightsJudgment:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.LightsJudgment) then return ""; end
    end
    -- fireblood
    if S.Fireblood:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
    end
    -- ancestral_call
    if S.AncestralCall:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return ""; end
    end
    -- touch_of_death,if=target.time_to_die>9
    if S.TouchofDeath:IsCastableP() and HR.CDsON() and (Target:TimeToDie() > 9) then
      if HR.Cast(S.TouchofDeath) then return ""; end
    end
    -- storm_earth_and_fire,if=cooldown.storm_earth_and_fire.charges=2|(cooldown.fists_of_fury.remains<=6&chi>=3&cooldown.rising_sun_kick.remains<=1)|target.time_to_die<=15
    if S.StormEarthandFire:IsCastableP() and HR.CDsON() and (S.StormEarthandFire:ChargesP() == 2 or (S.FistsofFury:CooldownRemainsP() <= 6 and Player:Chi() >= 3 and S.RisingSunKick:CooldownRemainsP() <= 1) or Target:TimeToDie() <= 15) then
      if HR.Cast(S.StormEarthandFire, Settings.Windwalker.OffGCDasOffGCD.StormEarthandFire) then return ""; end
    end
    -- serenity,if=cooldown.rising_sun_kick.remains<=2|target.time_to_die<=12
    if S.Serenity:IsCastableP() and HR.CDsON() and (S.RisingSunKick:CooldownRemainsP() <= 2 or Target:TimeToDie() <= 12) then
      if HR.Cast(S.Serenity, Settings.Windwalker.OffGCDasOffGCD.Serenity) then return ""; end
    end
  end
  Serenity = function()
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains
    if S.RisingSunKick:IsCastableP() and (bool(min:debuff.mark_of_the_crane.remains)) then
      if HR.Cast(S.RisingSunKick) then return ""; end
    end
    -- fists_of_fury,if=(buff.bloodlust.up&prev_gcd.1.rising_sun_kick&!azerite.swift_roundhouse.enabled)|buff.serenity.remains<1|active_enemies>1
    if S.FistsofFury:IsCastableP() and ((Player:HasHeroism() and Player:PrevGCDP(1, S.RisingSunKick) and not S.SwiftRoundhouse:AzeriteEnabled()) or Player:BuffRemainsP(S.SerenityBuff) < 1 or Cache.EnemiesCount[8] > 1) then
      if HR.Cast(S.FistsofFury) then return ""; end
    end
    -- spinning_crane_kick,if=!prev_gcd.1.spinning_crane_kick&(active_enemies>=3|(active_enemies=2&prev_gcd.1.blackout_kick))
    if S.SpinningCraneKick:IsCastableP() and (not Player:PrevGCDP(1, S.SpinningCraneKick) and (Cache.EnemiesCount[8] >= 3 or (Cache.EnemiesCount[8] == 2 and Player:PrevGCDP(1, S.BlackoutKick)))) then
      if HR.Cast(S.SpinningCraneKick) then return ""; end
    end
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains
    if S.BlackoutKick:IsCastableP() and (bool(min:debuff.mark_of_the_crane.remains)) then
      if HR.Cast(S.BlackoutKick) then return ""; end
    end
  end
  St = function()
    -- cancel_buff,name=rushing_jade_wind,if=active_enemies=1&(!talent.serenity.enabled|cooldown.serenity.remains>3)
    if (Cache.EnemiesCount[8] == 1 and (not S.Serenity:IsAvailable() or S.Serenity:CooldownRemainsP() > 3)) then
      -- if HR.Cancel(S.RushingJadeWindBuff) then return ""; end
    end
    -- whirling_dragon_punch
    if S.WhirlingDragonPunch:IsCastableP() then
      if HR.Cast(S.WhirlingDragonPunch) then return ""; end
    end
    -- rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=(cooldown.fists_of_fury.remains>2|chi>=5|azerite.swift_roundhouse.rank>1)
    if S.RisingSunKick:IsCastableP() and (bool(min:debuff.mark_of_the_crane.remains)) and ((S.FistsofFury:CooldownRemainsP() > 2 or Player:Chi() >= 5 or S.SwiftRoundhouse:AzeriteRank() > 1)) then
      if HR.Cast(S.RisingSunKick) then return ""; end
    end
    -- rushing_jade_wind,if=buff.rushing_jade_wind.down&energy.time_to_max>1&active_enemies>1
    if S.RushingJadeWind:IsCastableP() and (Player:BuffDownP(S.RushingJadeWindBuff) and Player:EnergyTimeToMaxPredicted() > 1 and Cache.EnemiesCount[8] > 1) then
      if HR.Cast(S.RushingJadeWind) then return ""; end
    end
    -- fists_of_fury,if=energy.time_to_max>2.5&(azerite.swift_roundhouse.rank<2|(cooldown.whirling_dragon_punch.remains<10&talent.whirling_dragon_punch.enabled)|active_enemies>1)
    if S.FistsofFury:IsCastableP() and (Player:EnergyTimeToMaxPredicted() > 2.5 and (S.SwiftRoundhouse:AzeriteRank() < 2 or (S.WhirlingDragonPunch:CooldownRemainsP() < 10 and S.WhirlingDragonPunch:IsAvailable()) or Cache.EnemiesCount[8] > 1)) then
      if HR.Cast(S.FistsofFury) then return ""; end
    end
    -- fist_of_the_white_tiger,if=chi<=2&(buff.rushing_jade_wind.down|energy>46)
    if S.FistoftheWhiteTiger:IsCastableP() and (Player:Chi() <= 2 and (Player:BuffDownP(S.RushingJadeWindBuff) or Player:EnergyPredicted() > 46)) then
      if HR.Cast(S.FistoftheWhiteTiger) then return ""; end
    end
    -- energizing_elixir,if=chi<=3&energy<50
    if S.EnergizingElixir:IsCastableP() and HR.CDsON() and (Player:Chi() <= 3 and Player:EnergyPredicted() < 50) then
      if HR.Cast(S.EnergizingElixir, Settings.Windwalker.OffGCDasOffGCD.EnergizingElixir) then return ""; end
    end
    -- blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&(cooldown.rising_sun_kick.remains>2|chi>=3)&(cooldown.fists_of_fury.remains>2|chi>=4|(azerite.swift_roundhouse.rank>=2&active_enemies=1))&buff.swift_roundhouse.stack<2
    if S.BlackoutKick:IsCastableP() and (bool(min:debuff.mark_of_the_crane.remains)) and (not Player:PrevGCDP(1, S.BlackoutKick) and (S.RisingSunKick:CooldownRemainsP() > 2 or Player:Chi() >= 3) and (S.FistsofFury:CooldownRemainsP() > 2 or Player:Chi() >= 4 or (S.SwiftRoundhouse:AzeriteRank() >= 2 and Cache.EnemiesCount[8] == 1)) and Player:BuffStackP(S.SwiftRoundhouseBuff) < 2) then
      if HR.Cast(S.BlackoutKick) then return ""; end
    end
    -- chi_wave
    if S.ChiWave:IsCastableP() then
      if HR.Cast(S.ChiWave) then return ""; end
    end
    -- chi_burst,if=chi.max-chi>=1&active_enemies=1|chi.max-chi>=2
    if S.ChiBurst:IsCastableP() and (Player:ChiMax() - Player:Chi() >= 1 and Cache.EnemiesCount[8] == 1 or Player:ChiMax() - Player:Chi() >= 2) then
      if HR.Cast(S.ChiBurst) then return ""; end
    end
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&chi.max-chi>=2&(buff.rushing_jade_wind.down|energy>56)
    if S.TigerPalm:IsCastableP() and (bool(min:debuff.mark_of_the_crane.remains)) and (not Player:PrevGCDP(1, S.TigerPalm) and Player:ChiMax() - Player:Chi() >= 2 and (Player:BuffDownP(S.RushingJadeWindBuff) or Player:EnergyPredicted() > 56)) then
      if HR.Cast(S.TigerPalm) then return ""; end
    end
    -- flying_serpent_kick,if=prev_gcd.1.blackout_kick&chi>1&buff.swift_roundhouse.stack<2,interrupt=1
    if S.FlyingSerpentKick:IsCastableP() and (Player:PrevGCDP(1, S.BlackoutKick) and Player:Chi() > 1 and Player:BuffStackP(S.SwiftRoundhouseBuff) < 2) then
      if HR.Cast(S.FlyingSerpentKick) then return ""; end
    end
    -- fists_of_fury,if=energy.time_to_max>2.5&cooldown.rising_sun_kick.remains>2&buff.swift_roundhouse.stack=2
    if S.FistsofFury:IsCastableP() and (Player:EnergyTimeToMaxPredicted() > 2.5 and S.RisingSunKick:CooldownRemainsP() > 2 and Player:BuffStackP(S.SwiftRoundhouseBuff) == 2) then
      if HR.Cast(S.FistsofFury) then return ""; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- auto_attack
    -- spear_hand_strike,if=target.debuff.casting.react
    if S.SpearHandStrike:IsCastableP() and Target:IsInterruptible() and Settings.General.InterruptEnabled and (Target:IsCasting()) then
      if HR.CastAnnotated(S.SpearHandStrike, false, "Interrupt") then return ""; end
    end
    -- rushing_jade_wind,if=talent.serenity.enabled&cooldown.serenity.remains<3&energy.time_to_max>1&buff.rushing_jade_wind.down
    if S.RushingJadeWind:IsCastableP() and (S.Serenity:IsAvailable() and S.Serenity:CooldownRemainsP() < 3 and Player:EnergyTimeToMaxPredicted() > 1 and Player:BuffDownP(S.RushingJadeWindBuff)) then
      if HR.Cast(S.RushingJadeWind) then return ""; end
    end
    -- touch_of_karma,interval=90,pct_health=0.5,if=!talent.Good_Karma.enabled,interval=90,pct_health=0.5
    if S.TouchofKarma:IsCastableP() and (not S.GoodKarma:IsAvailable()) then
      if HR.Cast(S.TouchofKarma, Settings.Windwalker.OffGCDasOffGCD.TouchofKarma) then return ""; end
    end
    -- touch_of_karma,interval=90,pct_health=1,if=talent.Good_Karma.enabled,interval=90,pct_health=1
    if S.TouchofKarma:IsCastableP() and (S.GoodKarma:IsAvailable()) then
      if HR.Cast(S.TouchofKarma, Settings.Windwalker.OffGCDasOffGCD.TouchofKarma) then return ""; end
    end
    -- potion,if=buff.serenity.up|buff.storm_earth_and_fire.up|(!talent.serenity.enabled&trinket.proc.agility.react)|buff.bloodlust.react|target.time_to_die<=60
    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.SerenityBuff) or Player:BuffP(S.StormEarthandFireBuff) or (not S.Serenity:IsAvailable() and bool(trinket.proc.agility.react)) or Player:HasHeroism() or Target:TimeToDie() <= 60) then
      if HR.CastSuggested(I.ProlongedPower) then return ""; end
    end
    -- call_action_list,name=serenity,if=buff.serenity.up
    if (Player:BuffP(S.SerenityBuff)) then
      local ShouldReturn = Serenity(); if ShouldReturn then return ShouldReturn; end
    end
    -- fist_of_the_white_tiger,if=(energy.time_to_max<1|(talent.serenity.enabled&cooldown.serenity.remains<2))&chi.max-chi>=3
    if S.FistoftheWhiteTiger:IsCastableP() and ((Player:EnergyTimeToMaxPredicted() < 1 or (S.Serenity:IsAvailable() and S.Serenity:CooldownRemainsP() < 2)) and Player:ChiMax() - Player:Chi() >= 3) then
      if HR.Cast(S.FistoftheWhiteTiger) then return ""; end
    end
    -- tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=(energy.time_to_max<1|(talent.serenity.enabled&cooldown.serenity.remains<2))&chi.max-chi>=2&!prev_gcd.1.tiger_palm
    if S.TigerPalm:IsCastableP() and (bool(min:debuff.mark_of_the_crane.remains)) and ((Player:EnergyTimeToMaxPredicted() < 1 or (S.Serenity:IsAvailable() and S.Serenity:CooldownRemainsP() < 2)) and Player:ChiMax() - Player:Chi() >= 2 and not Player:PrevGCDP(1, S.TigerPalm)) then
      if HR.Cast(S.TigerPalm) then return ""; end
    end
    -- call_action_list,name=cd
    if (true) then
      local ShouldReturn = Cd(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=st,if=active_enemies<3|(active_enemies=3&azerite.swift_roundhouse.rank>2)
    if (Cache.EnemiesCount[8] < 3 or (Cache.EnemiesCount[8] == 3 and S.SwiftRoundhouse:AzeriteRank() > 2)) then
      local ShouldReturn = St(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=aoe,if=active_enemies>3|(active_enemies=3&azerite.swift_roundhouse.rank<=2)
    if (Cache.EnemiesCount[8] > 3 or (Cache.EnemiesCount[8] == 3 and S.SwiftRoundhouse:AzeriteRank() <= 2)) then
      local ShouldReturn = Aoe(); if ShouldReturn then return ShouldReturn; end
    end
  end
end

HR.SetAPL(269, APL)
