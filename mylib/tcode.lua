
local tcode = {}

function tcode:decode( s_msg )
	local t_msg = {}
	local idx_id1, idx_id2 = string.find(s_msg,"$|")
	print("idx_id1:", idx_id1, "idx_id2:", idx_id2)
	if idx_id1 and idx_id2 then
		t_msg.user_id = tonumber(string.sub(s_msg, 1, idx_id1 -1))
		t_msg.msg_type = tonumber(string.sub(s_msg, idx_id2 + 1, idx_id2 + 2))
	end
	t_msg.msg_data = {}
	return t_msg
end

return tcode