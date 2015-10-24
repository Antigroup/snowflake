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
    if SnowflakeChatPreferences == nil then
        SnowflakeChatPreferences = {}
        SnowflakeChatPreferences._all = 'YELL'
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
    print('Global channel preference: '..SnowflakeChatPreferences._all)
    for k,v in pairs(SnowflakeMessageTable) do
        if SnowflakeChatPreferences[k] == nil then
            print(k..': '..v)
        else
            print(k..' ('..SnowflakeChatPreferences[k]..'): '..v)
        end
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
    print('Snowflake: /snowflake setchannel <channel> [name]')
    print('Snowflake: Set the channel to use for message, globally or for player named <name>. ')
    print('Snowflake: <channel> can be one of {SAY, EMOTE, YELL, PARTY, GUILD, RAID, RAID_WARNING, INSTANCE_CHAT, BATTLEGROUND, NIL}. NIL removes preferences for specific players.')
    print('Snowflake: /snowflake list')
    print('Snowflake: List all names with their associated messages.')
end

function Snowflake:test(args)
    self:UnitKilled(args)
end

function Snowflake:setchannel(args)
    channel, name = args:match('^(%S*)%s*(.-)$')
    
    if channel ~= nil then
        if channel == 'SAY' or channel == 'EMOTE' or channel == 'YELL' or channel == 'PARTY' or channel == 'GUILD' or channel == 'RAID' or channel == 'RAID_WARNING' or channel == 'INSTANCE_CHAT' or channel == 'BATTLEGROUND' or channel == 'NIL' then
            if channel ~= 'NIL' then
                if name == '' or name == nil then
                    SnowflakeChatPreferences._all = channel
                    print('Snowflake: Set global channel preference to '..channel..'.')
                else
                    SnowflakeChatPreferences[name] = channel
                    print('Snowflake: Set channel preference for '..name..' to '..channel)
                end
            else
                SnowflakeChatPreferences[name] = nil
                print('Snowflake: Removed channel preference for '..name)
            end
        end
    end
end

function Snowflake:UnitKilled(name)
    if SnowflakeMessageTable[name] ~= nil  then
        channel = SnowflakeChatPreferences._all
        if SnowflakeChatPreferences[name] ~= nil then
            channel = SnowflakeChatPreferences[name]
        end
        
        SendChatMessage(SnowflakeMessageTable[name], channel, self.language, nil)
    end
end

Snowflake:Startup()