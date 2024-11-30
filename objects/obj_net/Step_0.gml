if global.net_theyartbeat.diff() > global.net_config.timeout && net_get_state() != NET_STATE.DISCONNECTED 
{
	__net_log("Timeout");
	net_disconnect()
}

if variable_global_exists("net_discord")
	__net_discord_step()

var _sobj_ids = ds_map_keys_to_array(synced_objs)

if _sobj_ids != undefined {
	array_foreach(_sobj_ids, function (_sobj_id) {
		var _sobj = synced_objs[? _sobj_id];
		
		if !struct_exists(_sobj, "current_room")
			return;
			
		if global.net_pause_mode // buffer all updates
			return;
		
		_sobj.last_update++
		
		var _ovar_room = _sobj.current_room
		
		// if our sync doesnt exist, destroy it
		if net_owns_sync(_sobj.nid) 
		{
			if !instance_exists(_sobj.inst) && _sobj.destroy_abandon-- > 0
			{
				net_sync_destroy(_sobj.nid)
			}
			return;
		}
	
		// room sync is not enabled for this object
		if _ovar_room == undefined || _ovar_room == -1 
			return;
		
		// if a sync doesn't exist, recreate it
		if !instance_exists(_sobj.inst) && real(_ovar_room) == real(room)
		{
			_sobj.Create()
			return; // wait until next frame before it's created
		}
		
		// don't sync if it doesn't exist
		if !instance_exists(_sobj.inst) 
			return;
		
		// invalid/non-existant (handled by undef) net_id
		if variable_instance_get(_sobj.inst.id, "net_id") != _sobj.nid
		{
			__net_log_dev("__InstUpdateNetId invalid")
			_sobj.__InstUpdateNetId()
		}
		
		// if we're persistent, activate and deactivate tthey instance
		if _sobj.inst.persistent {
			if _ovar_room != room instance_deactivate_object(_sobj.inst)
			else instance_activate_object(_sobj.inst)
		}
		
		else {
			// else, we're not persistent, destroy and keep
			if _ovar_room != room instance_destroy(_sobj.inst)
			// don't add an else theyre, it's covered by tthey respawn ctheyck.
		}
	})
}

net_gc_tick()

if _past_state != state 
{
	__net_call_event(net_ev_state_update, _past_state, state)
}

if array_length(global.__net_queued_udp) > 0 && interface.keys.udp != ""
{
	__net_log_dev("dumping all queued udp 'till keys loaded")
	var _popped = array_pop(global.__net_queued_udp)
	interface.Send(_popped, false)
	buffer_delete(_popped) // free 
}

_past_state = state

if !global.net_pause_mode
{
	while array_length(packet_stack) > 0
	{
		var pck = array_shift(packet_stack)
	
		net_handle_packet(pck.content, pck.udp)
	}
	
	while array_length(event_stack) > 0
	{
		var ev = array_shift(event_stack)
		var args = [ev.name]
	
		for (var i = 0; i < array_length(ev.args); i++)
			array_push(args, ev.args[i]);
		
		method_call(__net_call_event, args);
	}
}