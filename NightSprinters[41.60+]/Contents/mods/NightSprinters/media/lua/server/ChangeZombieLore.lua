--Used in the change zombie lore thingy. True = follows the modified settings, false = normal settings
local currentState;

--TODO: see if SandboxVars is a better way to go. I don't think it is updated properly, but might be worth it for the increase in preformance
--gets the starting time for when zombies will follow the modified speed value
--Called on: Everything
local function getStartTime()
	local gametime = GameTime:getInstance();
	local month = gametime:getMonth();
	if month>=2 and month<=4 then
		return getSandboxOptions():getOptionByName("NightSprinters.startSpring"):getValue();
	elseif month>=5 and month<=7 then
		return getSandboxOptions():getOptionByName("NightSprinters.startSummer"):getValue();
	elseif month>=8 and month<=10 then
		return getSandboxOptions():getOptionByName("NightSprinters.startAutumn"):getValue();
	end
	return getSandboxOptions():getOptionByName("NightSprinters.startWinter"):getValue();
end

--TODO: see if SandboxVars is a better way to go. I don't think it is updated properly, but might be worth it for the increase in preformance
--gets the ending time for when zombies will stop following the modified speed value
--Called on: Everything
local function getEndTime()
	local gametime = GameTime:getInstance();
	local month = gametime:getMonth();
	if month>=2 and month<=4 then
		return getSandboxOptions():getOptionByName("NightSprinters.endSpring"):getValue();
	elseif month>=5 and month<=7 then
		return getSandboxOptions():getOptionByName("NightSprinters.endSummer"):getValue();
	elseif month>=8 and month<=10 then
		return getSandboxOptions():getOptionByName("NightSprinters.endAutumn"):getValue();
	end
	return getSandboxOptions():getOptionByName("NightSprinters.endWinter"):getValue();
end

--Essentially, I used to use this when I still used mod options, now that I don't I need to update every thing
--Called on: Servers and singleplayer
local function nsupdateSettings()
	local globalData = getGameTime():getModData();
	
	if globalData.NSSETTINGS then
		getSandboxOptions():set("NightSprinters.startSummer",globalData.NSSETTINGS.startSummer - 1);
		getSandboxOptions():set("NightSprinters.endSummer",globalData.NSSETTINGS.endSummer - 1);
		getSandboxOptions():set("NightSprinters.startAutumn",globalData.NSSETTINGS.startAutumn - 1);
		getSandboxOptions():set("NightSprinters.endAutumn",globalData.NSSETTINGS.endAutumn - 1);
		getSandboxOptions():set("NightSprinters.startWinter",globalData.NSSETTINGS.startWinter - 1);
		getSandboxOptions():set("NightSprinters.endWinter",globalData.NSSETTINGS.endWinter - 1);
		getSandboxOptions():set("NightSprinters.startSpring",globalData.NSSETTINGS.startSpring - 1);
		getSandboxOptions():set("NightSprinters.endSpring",globalData.NSSETTINGS.endSpring - 1);

		getSandboxOptions():set("NightSprinters.rainSprinters",globalData.NSSETTINGS.rainSprinters);
		getSandboxOptions():set("NightSprinters.normalZombies",globalData.NSSETTINGS.normalSpeed);
		getSandboxOptions():set("NightSprinters.modifiedZombies",globalData.NSSETTINGS.modifiedSpeed);
	
		globalData.NSSETTINGS = nil;
	end	
end

--Changes the settings when the state switches... this could be optimized, but it's called so infrequently that it doesn't really matter
local function switchSettings(modified)
	if modified then
		getSandboxOptions():set("ZombieLore.Speed",getSandboxOptions():getOptionByName("NightSprinters.modifiedZombies"):getValue());
		if getSandboxOptions():getOptionByName("NightSprinters.enhancedZombies"):getValue() then
			if(getSandboxOptions():getOptionByName("NightSprinters.ZombiesCognition"):getValue()) then
				getSandboxOptions():set("ZombieLore.Cognition",1);
			end
			getSandboxOptions():set("ZombieLore.Toughness",getSandboxOptions():getOptionByName("NightSprinters.modifiedZombiesToughness"):getValue());
			getSandboxOptions():set("ZombieLore.Hearing",getSandboxOptions():getOptionByName("NightSprinters.modifiedZombiesHearing"):getValue());
			getSandboxOptions():set("ZombieLore.Sight",getSandboxOptions():getOptionByName("NightSprinters.modifiedZombiesSight"):getValue());
			getSandboxOptions():set("ZombieLore.Memory",getSandboxOptions():getOptionByName("NightSprinters.modifiedZombiesMemory"):getValue());
		end
	else
		getSandboxOptions():set("ZombieLore.Speed",getSandboxOptions():getOptionByName("NightSprinters.normalZombies"):getValue());
		if getSandboxOptions():getOptionByName("NightSprinters.enhancedZombies"):getValue() then
			if(getSandboxOptions():getOptionByName("NightSprinters.ZombiesCognition"):getValue()) then
				getSandboxOptions():set("ZombieLore.Cognition",4);
			end
			getSandboxOptions():set("ZombieLore.Toughness",getSandboxOptions():getOptionByName("NightSprinters.normalZombiesToughness"):getValue());
			getSandboxOptions():set("ZombieLore.Hearing",getSandboxOptions():getOptionByName("NightSprinters.normalZombiesHearing"):getValue());
			getSandboxOptions():set("ZombieLore.Sight",getSandboxOptions():getOptionByName("NightSprinters.normalZombiesSight"):getValue());
			getSandboxOptions():set("ZombieLore.Memory",getSandboxOptions():getOptionByName("NightSprinters.normalZombiesMemory"):getValue());
		end
	end
end

--Handles any compatibility that needs to be added, at the moment, only RandomZombies is implemented
local function handleCompatibility(newState)
	if BLTRandomZombies then
		if newState and BLTRandomZombies.disable then
  			BLTRandomZombies.disable();
			NSenable();
			--print("RANDOM DISABLED - NS ENABLED")
		elseif not newState and BLTRandomZombies.enable then
			BLTRandomZombies.enable();
			NSdisable();
			--print("RANDOM ENABLED - NS DISABLED")
		end
	end
end

--This method is crucial as it is in charge of changing the lore speed given the time and settings
--Called on: Everything
local function changeLore()
	local gTime = getGameTime();
	local hour = gTime:getTimeOfDay();
	local startTime = getStartTime();
	local endTime = getEndTime();
	local rain = RainManager:getRainIntensity();
	local rainThreshold = 0; --getSandboxOptions():getOptionByName("NightSprinters.RainThreshold"):getValue();
	--local oldState = getSandboxOptions():getOptionByName("ZombieLore.Speed"):getValue();
	local newState;

	if (hour >= startTime and hour < endTime) or (rain>rainThreshold and getSandboxOptions():getOptionByName("NightSprinters.rainSprinters"):getValue()) then
		--newSpeed = getSandboxOptions():getOptionByName("NightSprinters.modifiedZombies"):getValue()
		newState = true;
	elseif (hour>=startTime or hour<endTime) and startTime>endTime then
		--newSpeed = getSandboxOptions():getOptionByName("NightSprinters.modifiedZombies"):getValue()
		newState = true;
	else
		--newSpeed = getSandboxOptions():getOptionByName("NightSprinters.normalZombies"):getValue()
		newState = false;
	end

	if newState ~= currentState then
		--getSandboxOptions():set("ZombieLore.Speed",newSpeed);
		switchSettings(newState);
		currentState = newState;
		handleCompatibility(newState);
	end
	
	--Shouldn't really go here, but I am a bit rushed atm
	nsupdateSettings()
end



--handles event types for each type of game instance: server, singleplayer, and client in that order(Not really needed anymore honestly)
--Called on: Everything
local function handleEvents()
	Events.EveryTenMinutes.Add(changeLore);
	changeLore();
	if BLTRandomZombies then
		BLTRandomZombies.disable();
		NSdisable();
	end
end


Events.OnGameStart.Add(handleEvents);
Events.OnServerStarted.Add(handleEvents);