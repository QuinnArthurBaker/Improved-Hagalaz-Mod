local HagalazMod = RegisterMod("Improved Hagalaz",1)

-- Main function; gets called after the player uses a hagalaz rune as defined in the AddCallback function below
-- This function will kill all host variants and fireplaces, as well as open secret room e

function HagalazMod:hagalazAction(_HagalazMod)

	-- -- Entity Destruction
	-- get the table of entities in the current room
	entitytable = Isaac.GetRoomEntities()
	-- iterate through the table of entities (probably a better way to do this)
	for key,value in pairs(entitytable) do 
		-- for each entity, if its a host, red host, mobile host, mobile red host, or a fireplace, kill it. Killing a fireplace extinguishes it.
		if(value.Type==EntityType.ENTITY_FIREPLACE or value.Type==EntityType.ENTITY_STONEHEAD or value.Type==EntityType.ENTITY_STONEY or value.Type==EntityType.ENTITY_BRIMSTONE_HEAD or value.Type==EntityType.ENTITY_CONSTANT_STONE_SHOOTER or value.Type==EntityType.ENTITY_GAPING_MAW or value.Type==EntityType.ENTITY_BROKEN_GAPING_MAW)
		then
			value:Kill()
		end

	end

	-- -- Door Opening
	-- get the current room
	curRoom = Game():GetRoom()
	-- if the current room is a secret room, open all the doors (supersecret rooms will already have all the doors opened, because you would have to open the only door into it to enter it in the first place)
	if(curRoom:GetType()==RoomType.ROOM_SECRET)
	then
		-- for each possible door (can be simplified because secret rooms can only have 4 doors), open it if the door exists.
		for i=0,DoorSlot.NUM_DOOR_SLOTS-1 do
			checkDoor = curRoom:GetDoor(i)
			if(checkDoor~=nil)
			then
				checkDoor:TryBlowOpen(true)
			end
		end
	end

	-- if the current room can have a secret room border it (not error rooms, boss rooms, devil/angel rooms, the bossrush room, black market and dungeons(crawlspaces?), and the ultra greed room(?))
	if(curRoom:GetType()~=RoomType.ROOM_ERROR and curRoom:GetType()~=RoomType.ROOM_BOSS and curRoom:GetType()~=RoomType.ROOM_DEVIL and curRoom:GetType()~=RoomType.ROOM_ANGEL and curRoom:GetType()~=RoomType.ROOM_BOSSRUSH and curRoom:GetType()~=RoomType.ROOM_BLACK_MARKET and curRoom:GetType()~=RoomType.ROOM_DUNGEON and curRoom:GetType()~=RoomType.ROOM_GREED_EXIT)
	then
		-- set a flag for random door opening later on 
		flagDoorOpened = false
		-- for each possible door (this imitates iterating through the values of the DoorSlot enumeration)
		for i=0,DoorSlot.NUM_DOOR_SLOTS-1 do
			-- generate a random value between 0 and 7 (inclusive)
			checkVal = math.random(0,7)
			-- get the door corresponding to the value (even if it doesn't exist)
			checkDoor = curRoom:GetDoor(i)
			-- if checkDoor is a door that exists in the room and it leads to a secret or super secret room or an isaac's bedroom, explode the door open
			if(checkDoor~=nil and (checkDoor.TargetRoomType==RoomType.ROOM_SECRET or checkDoor.TargetRoomType==RoomType.ROOM_SUPERSECRET))
			then
				checkDoor:TryBlowOpen(true)

			-- if the room is an isaacs room, open it fully
			elseif(checkDoor~=nil and (checkDoor.TargetRoomType==RoomType.ROOM_ISAACS))
			then
				checkDoor:TryBlowOpen(true)
				checkDoor:TryBlowOpen(true)
			
			--  otherwise, if the door exists, check if the random value checkVal above was a 0. If it was, and another non-secret room door hasn't been opened yet, blow open this door. This allows for up to one non-secret room door to be opened with each hagalaz rune
			elseif(checkDoor~=nil and checkVal==0 and flagDoorOpened==false)
			then
					checkDoor:TryBlowOpen(true)
					-- set the flag to ensure only one non-secret room door is opened per rune
					flagDoorOpened = true
			end

		end
	end

end

-- attach the hagalazAction function to the callback when a card is used, specifically a hagalaz rune

HagalazMod:AddCallback(ModCallbacks.MC_USE_CARD, HagalazMod.hagalazAction, Card.RUNE_HAGALAZ)