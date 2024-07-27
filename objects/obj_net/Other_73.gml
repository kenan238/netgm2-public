if state != NET_STATE.REGISTERED
	exit;

var _as_buf = async_load[? "buffer_id"];
var _data = buffer_create(async_load[? "data_len"], buffer_fixed, 1)
if _as_buf == _data {
	buffer_delete(_data);
	exit;
}
buffer_copy(_as_buf, 0, async_load[? "data_len"], _data, 0)

//var _buf_copy = buffer_create(buffer_get_size(_as_buf), buffer_fixed, 1)
//buffer_copy(_as_buf, 0, buffer_get_size(_as_buf), _buf_copy, 0)

__net_voice_send_data(_data)

buffer_delete(_data)