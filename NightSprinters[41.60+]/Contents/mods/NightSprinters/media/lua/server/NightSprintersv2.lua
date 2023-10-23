--Cool little thing I saw Xeph's mod use to ensure zombies have the correct speed value for each client
--Essentially, makes the zombie update every 5 seconds no matter what
local updateInterval = 500;

local Speed;
local Cognition;

local function getFields(zombie)
	for i = 0, getNumClassFields(zombie) - 1 do
		local javaField = getClassField(zombie, i)
		if luautils.stringEnds(tostring(javaField), '.' .. "speedType") then
			Speed = javaField;
		end
		if luautils.stringEnds(tostring(javaField), '.' .. "cognition") then
			Cognition = javaField;
		end
	end
end

local function updateHealth(zombie)
	local toughness = getSandboxOptions():getOptionByName("ZombieLore.Toughness"):getValue();
	local ZomHealth = 0.0;
	if toughness == 1 then
		zomHealth = 3.5 + 0.1*ZombRandBetween(0,3);
	elseif toughness == 2 then
		zomHealth = 1.8 + 0.1*ZombRandBetween(0,3);
	elseif toughness ==3 then
		zomHealth = 0.5 + 0.1*ZombRandBetween(0,3);
	else
		zomHealth = 0.1*ZombRandBetween(5,35) + 0.1*ZombRandBetween(0,3);
	end
	zombie:setHealth(zomHealth);
end

local function updateCognition(zombie)
	if(getSandboxOptions():getOptionByName("ZombieLore.Cognition"):getValue() ~=1) then
		local zombCog = getClassFieldVal(zombie,Cognition)
		while(zombCog ==1) do
			zombie:DoZombieStats();
			zombCog = getClassFieldVal(zombie,Cognition)
			--print(Cognition)
		end
	end
end

local function updateZombie(zombie)
	zombie:makeInactive(true);
	zombie:makeInactive(false);
	if(getSandboxOptions():getOptionByName("NightSprinters.enhancedZombies"):getValue()) then
		updateHealth(zombie);
		updateCognition(zombie);
	end
	local vMod = zombie:getModData();
	vMod.Speed = getSandboxOptions():getOptionByName("ZombieLore.Speed"):getValue();
	vMod.Ticks = 0;
end

--Changes the zombie's speed based off it's current speed and the speed lore value in the sandbox
--Called on: Client and SinglePlayer
local function ZombieChange(zombie)
	local vMod = zombie:getModData();
	vMod.Ticks = vMod.Ticks or 0;
	vMod.Speed = vMod.Speed or -1;
	local speedLore = getSandboxOptions():getOptionByName("ZombieLore.Speed"):getValue();
	-- is update needed?             if so is it single player?             -- or maybe it's a client with zombie ownership within range
	if vMod.Speed ~= speedLore and ((not isClient() and not isServer()) or (isClient() and not zombie:isRemoteZombie())) then
		updateZombie(zombie);
	--   Has 5 seconds past since last update?            (I know I can just use an or statement with the top if statement, but it's getting hard to read up there)
	elseif vMod.Ticks >= updateInterval then
		updateZombie(zombie);
	else
		vMod.Ticks = vMod.Ticks + 1;
	end
end

function NSdisable()
	Events.OnZombieUpdate.Remove(ZombieChange);
end

function NSenable()
	Events.OnZombieUpdate.Add(ZombieChange);
end



--For right now this is pointless, but there are some things that I might need to do that will use this, so I'm keeping it here since it doesn't affect much
--Called on: Client and SinglePlayer
local function gameStart()
	getFields(IsoZombie.new(nil));
	if not BLTRandomZombies then
		Events.OnZombieUpdate.Add(ZombieChange);
	end
end

Events.OnGameStart.Add(gameStart);

