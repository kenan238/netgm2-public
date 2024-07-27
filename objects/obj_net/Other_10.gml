/// @description When initialized
state = NET_STATE.CONNECTED
__net_log("Connected!")
var _rpck = {
	type: PACKET_TYPE.REGISTER,
	name: global.net_name,
};

if global.net_config.uses_accounts
	_rpck.password = global.net_password

net_send_json(_rpck)