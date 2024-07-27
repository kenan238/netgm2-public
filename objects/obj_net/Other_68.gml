var _type = async_load[? "type"]

var _is_udp = async_load[? "id"] == interface.udp;
var _buf = async_load[? "buffer"]

switch (_type) 
{
	case network_type_non_blocking_connect:
		event_user(!async_load[? "succeeded"])
		break;
	case network_type_data:
		//__net_log("InvokeReceive (...), sending socket is: " + string(async_load[? "id"]) + " UDP = " + string(interface.udp) + " | TCP = " + string(interface.tcp))
		if async_load[? "id"] != interface.udp && async_load[? "id"] != interface.tcp
			break;
		interface.InvokeReceive(_buf, _is_udp)
		
		//buffer_delete(_buf)
		break;
}