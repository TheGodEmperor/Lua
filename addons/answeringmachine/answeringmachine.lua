

_addon.commands = {'answeringmachine','am'}
_addon.name = 'AnsweringMachine'
_addon.author = 'Byrth'
_addon.version = '1.1'


tell_table = {}
recording = {}

windower.register_event('addon command',function (...)
	term = table.concat({...}, ' ')
	local broken = split(term, ' ')
	if broken[1] ~= nil then
		if broken[1]:upper() == "CLEAR" then
			if broken[2] == nil then
				tell_table = {}
				recording = {}
				windower.add_to_chat(4,'Answering Machine>> Blanking the recordings')
			elseif tell_table[broken[2]:upper()]~=nil then
				windower.add_to_chat(4,'Answering Machine>> Deleting messages from '..uc_first(broken[2]))
				tell_table[broken[2]:upper()]=nil
				recording[broken[2]:upper()]=nil
			else
				windower.add_to_chat(5,'Cancel error: Could not find specified player in tell history')
			end
		end
		
		if broken[1]:upper() == "LIST" then
			for i,v in pairs(tell_table) do
				windower.add_to_chat(5,v..' messages from '..uc_first(i))
			end
		end

		if broken[1]:upper() == "PLAY" then
			if broken[2] ~= nil then
				if tell_table[broken[2]:upper()] ~= nil then
					local num = tell_table[broken[2]:upper()]
					if num == 1 then
						windower.add_to_chat(5,'1 message from '..uc_first(broken[2]))
					else
						windower.add_to_chat(5,num..' messages from '..uc_first(broken[2]))
					end
					for n = 1,num do
						local tablekey = recording[broken[2]:upper()]
						windower.add_to_chat(4,uc_first(broken[2])..'>> '..tablekey[n])
					end
				end
			else
				windower.add_to_chat(4,'Answering Machine>> Playing back all messages')
				for i,v in pairs(tell_table) do
					if v == 1 then
						windower.add_to_chat(5,'1 message from '..uc_first(i))
					else
						windower.add_to_chat(5,v..' messages from '..uc_first(i))
					end
					for n = 1,v do
						local tablekey = recording[i]
						windower.add_to_chat(4,uc_first(i)..'>> '..tablekey[n])
					end
				end
			end
		end
		
		if broken[1]:upper() == "HELP" then
			print('am clear <name> : Clears current messages, or only messages from <name> if provided')
			print('am help : Lists these commands!')
			print('am list : Lists the names of people who have sent you tells')
			print('am msg <message> : Sets your away message, which will be sent to non-GMs only once after plugin load or message clear')
			print('am play <name> : Plays current messages, or only messages from <name> if provided')
		end
		
		
		if broken[1]:upper() == "MSG" then
			table.remove(broken,1)
			if #broken ~= 0 then
				away_msg=table.concat(broken,' ')
				windower.add_to_chat(123,'AnsweringMachine: Message set to: '..away_msg)
			end
		end
	end
end)

windower.register_event('chat message',function(message,player,mode,isGM)
	if mode==3 then
		if not playertab then playertab = {} end
		if tell_table[player:upper()] then
			tell_table[player:upper()] = tell_table[player:upper()]+1
			recording[player:upper()][#recording[player:upper()]+1] = message
		else
			tell_table[player:upper()] = 1
			recording[player:upper()] = {message}
			if away_msg and not isGM then
				windower.send_command('@input /tell '..player..' '..away_msg)
			end
		end
	end
end)

function split(msg, match)
	local length = msg:len()
	local splitarr = {}
	local u = 1
	while u < length do
		local nextanch = msg:find(match,u)
		if nextanch ~= nil then
			splitarr[#splitarr+1] = msg:sub(u,nextanch-1)
			if nextanch~=length then
				u = nextanch+1
			else
				u = length
			end
		else
			splitarr[#splitarr+1] = msg:sub(u,length)
			u = length
		end
	end
	return splitarr
end

function uc_first(msg)
	local length = msg:len()
	local first_char = msg:sub(1,1)
	local rest = msg:sub(2,length)
	return first_char:upper()..rest:lower()
end
