
local tcode = {}

tcode.decode = function ( s_msg )
	local t_msg = {}
	t_msg.user_id = 10000
	t_msg.msg_type = 1
	t_msg.msg_data = {}
	return t_msg
end

return tcode