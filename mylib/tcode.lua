
local tcode = {}

local qrep = {["\\"]="\\\\", ['"']='\\"',['\n']='\\n',['\t']='\\t'}
local function encodeString(s)
	return tostring(s):gsub('["\\\n\t]',qrep)
end

function tcode:encode(t_msg)
	if t_msg == nil then
		return "null"
	end

  	local vtype = type(t_msg)
	-- Handle strings
	if vtype == 'string' then    
		return '"' .. encodeString(t_msg) .. '"'	    -- Need to handle encoding in string
	end
  	-- Handle booleans
  	if vtype == 'number' or vtype == 'boolean' then
    	return base.tostring(t_msg)
  	end
  	-- Handle tables
  	if vtype == 'table' then
	    local rval = {}
	    -- Consider arrays separately
	    local bArray, maxCount = isArray(t_msg)
	    if bArray then
	      	for i = 1, maxCount do
	        	table.insert(rval, encode(t_msg[i]))
	      	end
	    else	-- An object, not an array
	      	for i,j in base.pairs(t_msg) do
	        	if isEncodable(i) and isEncodable(j) then
	          		table.insert(rval, '"' .. encodeString(i) .. '":' .. encode(j))
	        	end
	      	end
	    end
	    if bArray then
	      	return '[' .. table.concat(rval, ',') ..']'
	    else
	      	return '{' .. table.concat(rval, ',') .. '}'
	    end
  	end
	assert(false,'encode attempt to encode unsupported type ' .. vtype .. ':' .. tostring(t_msg))
end

function tcode:decode(s_msg)
	local t_msg = {}
	print("s_msg:", s_msg)
	local s_msg = tostring(s_msg)
	local idx_id1, idx_id2 = string.find(s_msg, "$|")
	print("idx_id1:", idx_id1, "idx_id2:", idx_id2)
	if idx_id1 and idx_id2 then
		t_msg.user_id = tonumber(string.sub(s_msg, 1, idx_id1 -1))
		t_msg.msg_type = tonumber(string.sub(s_msg, idx_id2 + 1, idx_id2 + 2))
	end
	t_msg.msg_data = {}
	return t_msg
end

return tcode