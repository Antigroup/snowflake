local Snowflake = CreateFrame('FRAME', 'Snowflake')

function Snowflake:COMBAT_LOG_EVENT_UNFILTERED(timestamp, eventtype, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, ...)
	if eventtype == 'UNIT_DIED' and (bit.band(dstFlags,0x00000400) > 0) then
		self:UnitKilled(dstName)
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
	local command, args = msg:match("^(%S*)%s*(.-)$")
	
    if command == '' or command == nil then
        self:help(args)
    else
        if self[command] ~= nil then
            self[command](self, args)
        else
            print('Snowflake: unrecognized command "'..command..'". /snowflake help will list all commands.')
        end
    end
end

function Snowflake:list(args)
    for k,v in pairs(SnowflakeMessageTable) do
        print(k..': '..v)
    end
end

function Snowflake:remove(args)
    name = args
    
    SnowflakeMessageTable[name] = nil
    print('Snowflake: Removed Entry for '..name)
end

function Snowflake:add(args)
    name, message = args:match('^(%S*)%s*(.-)$')

    SnowflakeMessageTable[name] = message
    print('Snowflake: Added '..name..' with message "'..message..'".')
end

function Snowflake:help(args)
    print('Snowflake: Commands')
    print('Snowflake: /snowflake help')
    print('Snowflake: Display this message.')
    print('Snowflake: /snowflake add <name> <message>')
    print('Snowflake: Adds an entry to yell <message> when raid member named <name> dies. Also used to change message for existing entries.')
    print('Snowflake: /snowflake remove <name>')
    print('Snowflake: Remove entry for player named <name>.')
    print('Snowflake: /snowflake list')
    print('Snowflake: List all names with their associated messages.')
end

function Snowflake:test(args)
    self:UnitKilled(args)
end

function Snowflake:UnitKilled(name)
    if SnowflakeMessageTable[name] ~= nil  then
        SendChatMessage(SnowflakeMessageTable[name], 'YELL', self.language, nil)
    end
end

Snowflake:Startup()