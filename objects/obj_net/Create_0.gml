randomize()

enum NET_STATE 
{
	CONNECTING,
	CONNECTED,
	REGISTERED,
	DISCONNECTED,
}

state = NET_STATE.CONNECTING
_past_state = state

enum PACKET_TYPE 
{
	REGISTER, // sent by client
	HELLO, // by server
	LEAVE, // sent by client
	
	OTHER_REGISTERED, // broadcasted by server
	OTHER_LEFT, // broadcasted by server
	
      SYNC_CREATE, // client
      SYNC_UPDATE, // client
      SYNC_DESTROY, // client
      SYNC_SIGNAL, // client
      SYNC_TRANSFER, // client

      OTHER_SYNC_CREATE, // server
      OTHER_SYNC_UPDATE, // client
      OTHER_SYNC_DESTROY, // client
      OTHER_SYNC_SIGNAL, // server
      OTHER_SYNC_TRANSFER, // server
	
	CHAT_SEND, // client
	OTHER_CHAT_SEND, // server
	
	P2P_SEND, // client
	OTHER_P2P_SEND, // server
	
	HEARTBEAT, // client & server
	
	RPC_CALL, // client & server
	
	GAMESTATE_UPDATE, // server
	GAMESTATE_UPDATE_PARTIAL, // client & server
	
	PLAYER_PROPS_UPDATE, // client & server
	
	PLAY_SOUND, // client & server
	
	SPAWN_BASIC, // client & server
	
	ADMINISTRATIVE_CMD, // client
	
	GET_RESOURCES, // client & server
	REQUEST_DOWNLOAD, // client
	FILE_CHUNK, // server
	
	STREAM_REGISTER, // client & server
	STREAM_DATA, // client & server
	STREAM_DESTROY, // client & server
	
	STREAM_LISTEN, // client
	STREAM_STOP_LISTEN, // client
	
	DESTROY_BASIC, // client & server
}

enum POWER_TYPES {
	BANNED,
	NORMAL,
    MODERATOR,
    ADMIN,
    OWNER,
    KENAN
}

net_id = noone
global.net_id = function () { return obj_net.net_id; }
global.net_heartbeat = {
	last: current_time,
	ping: 0,
	diff: function() {
		return current_time - global.net_heartbeat.last
	}
}

players = []
synced_objs = ds_map_create()
other_packet_handlers = ds_map_create()
chat = []

server_name = ""
rpcs = ds_map_create()

packet_parser = new NetPacketParser()

identity = {
	accId: noone,
	token: "",
	powlvl: POWER_TYPES.NORMAL,
}
resources = []
streams = []

gamestate = new NetGameState()

network_set_config(network_config_use_non_blocking_socket, true)
interface = new NetInterface(global.remote_address.ip, global.remote_address.port)
interface.on_receive = function(_buf, _is_udp)
{
	var _json;
	
	try
	{
		_json = buffer_read(_buf, buffer_string)
	}
	catch (e)
	{
		buffer_seek(_buf, buffer_seek_start, 0)
		_json = buffer_read(_buf, buffer_text)
	}
	
	var _packets = packet_parser.Parse(_is_udp, _json);
	
	for (var i = 0; i < array_length(_packets); i++) {
		var _pack = _packets[i];
		if struct_exists(_pack, "key")
			continue; // we should NEVER receive a key thats an incoming "server" message
		net_handle_packet(_pack, _is_udp)
	}
}

//net_voice_set_recorder(0)
//net_voice_init("obj_net_synced")

net_web_get_version(function(_status, _resp) {
	if !_status || _resp == 404
	{
		__net_log("[VersionCheck] Failed to check version")
		return;
	}
	
	var _ver = _resp.version;
	
	if net_version != _ver {
		repeat 100
			__net_log("[VersionCheck] !!!NEED TO UPDATE, latest is: " + string(_ver) + ", current version is: " + string(net_version))
		return;
	}
	
	__net_log("[VersionCheck] Up to date!")
})

packet_stack = []
event_stack = []