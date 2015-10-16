local Snowflake = CreateFrame('FRAME', 'Snowflake')

function Snowflake:COMBAT_LOG_EVENT_UNFILTERED(timestamp, eventtype, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, ...)
	if eventtype == 'UNIT_DIED' and (bit.band(dstFlags,0x00000400) > 0) then
		if SnowflakeMessageTable[dstName] ~= nil  then
			SendChatMessage(SnowflakeMessageTable[dstName], 'YELL', self.language, nil)
		end
	end
end

function Snowflake:Startup()
	print('Snowflake: Starting')
	
	SLASH_SNOWFLAKE1 = '/snowflake'
	SlashCmdList["SNOWFLAKE"] = function (msg, editbox) self:SlashHandler(msg, editbox) end
	
    self.language = GetDefaultLanguage()
	self:SetScript('OnEvent', function(self,event, ...) self[event](self, ...) end)
	self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	self:RegisterEvent('ADDON_LOADED')
end

function Snowflake:ADDON_LOADED(arg1)
	if SnowflakeMessageTable == nil then
		SnowflakeMessageTable = {}
	end
end

function Snowflake:SlashHandler(msg, editbox)
	local command, name, message = msg:match("^(%S*)%s*(%S*)%s*(.-)$")
	
    if command == 'help' or command == '' then
        print('Snowflake: Commands')
        print('Snowflake: /snowflake add <name> <message>')
        print('Snowflake: Adds an entry to yell <message> when raid member named <name> dies. Also used to change message for existing entries.')
        print('Snowflake: /snowflake remove <name>')
        print('Snowflake: Remove entry for player named <name>.')
        print('Snowflake: /snowflake list')
        print('Snowflake: List all names with their associated messages.')
    end
    
	if command == 'list' then
		for k,v in pairs(SnowflakeMessageTable) do
			print(k..': '..v)
		end
		return nil
	end
	
    if command == 'remove' then
        SnowflakeMessageTable[name] = nil
        print('Snowflake: Removed Entry for '..name)
    end
    
    if command == 'add' then
        SnowflakeMessageTable[name] = message
        print('Snowflake: Added '..name..' with message "'..message..'".')
    end
end

Snowflake:Startup()