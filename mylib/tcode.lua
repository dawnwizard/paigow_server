
local tcode = {}

local encodeString
local isArray
local isEncodable

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
    	return tostring(t_msg)
  	end
  	-- Handle tables
  	if vtype == 'table' then
	    local rval = {}
	    -- Consider arrays separately
	    local bArray, maxCount = isArray(t_msg)
	    if bArray then
	      	for i = 1, maxCount do
	        	table.insert(rval, self:encode(t_msg[i]))
	      	end
	    else	-- An object, not an array
	      	for i,j in pairs(t_msg) do
	        	if isEncodable(i) and isEncodable(j) then
	          		table.insert(rval, '"' .. encodeString(i) .. '":' .. self:encode(j))
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


-- *****************************************************************
local qrep = {["\\"]="\\\\", ['"']='\\"',['\n']='\\n',['\t']='\\t'}
encodeString = function(str)
	return tostring(str):gsub('["\\\n\t]', qrep)
end

isArray = function(t)
  -- Next we count all the elements, ensuring that any non-indexed elements are not-encodable 
  -- (with the possible exception of 'n')
  local maxIndex = 0
  for k,v in pairs(t) do
    if (type(k)=='number' and math.floor(k)==k and 1<=k) then	-- k,v is an indexed pair
      if (not isEncodable(v)) then return false end	-- All array elements must be encodable
      maxIndex = math.max(maxIndex,k)
    else
      if (k=='n') then
        if v ~= table.getn(t) then return false end  -- False if n does not hold the number of elements
      else -- Else of (k=='n')
        if isEncodable(v) then return false end
      end  -- End of (k~='n')
    end -- End of k,v not an indexed pair
  end  -- End of loop across all pairs
  return true, maxIndex
end

--- Determines whether the given Lua object / table / variable can be JSON encoded. The only
-- types that are JSON encodable are: string, boolean, number, nil, table and json.null.
-- In this implementation, all other types are ignored.
-- @param o The object to examine.
-- @return boolean True if the object should be JSON encoded, false if it should be ignored.
isEncodable = function(o)
  local t = type(o)
  return (t=='string' or t=='boolean' or t=='number' or t=='nil' or t=='table') or (t=='function' and o==null) 
end

return tcode