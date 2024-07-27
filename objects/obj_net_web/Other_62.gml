if async_load[? "id"] != undefined {
	if global.__net_ignore_http
	{
		global.__net_ignore_http = false
		exit;
	}
	if async_load[? "status"] == 0 {
		var _res = async_load[? "result"]
		global.__net_resp_callback(true, str_at(_res, 0) == "{" ? json_parse(_res) : _res);
	}
	else {
		__net_log("Couldn't contact NetGM2 apis at " + net_web_endpoint)
		global.__net_resp_callback(false, {});
	}
}