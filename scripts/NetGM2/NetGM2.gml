// NetGM2 by kenan238 (https://kenanyazbeck.com)
// THIS CODE HAS BEEN PROCESSED, ALTERED, AND OBFUSCATED
/*
   NetGM2 © 2023-2024 by kenan238 is licensed under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International. 
   To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-nd/4.0/
*/
   

//   
         
      
          
 
  

   

   
       
   
         
    
     
//      
    
      
        
      
  
   
      
//    
        
         
  
     
//      
       

      
  
          

        
 
     function net_set_name(_name) {
global.net_name = _name
    }
       
  function net_set_password(_passwd) {
global.net_password = _passwd
       }
  
    function net_heartbeat() {
 net_send_json({ type: PACKET_TYPE.HEARTBEAT });
     }
  
      function net_multiclient() {
    
          
          
      
    
   
//  

          
         
 
   
   
//   
//        
    
      
 
  
//      
//     

         

        global.net_multiclient = MultiClientGetID();
  }
        
        function net_static_id_reset()
   {
if !instance_exists(obj_net)
        return;
 
    global.__net_static_id_handle = 0
__net_log("Static id reset")
     }
        
     function net_get_static_id(_room, inst_id)
      {
     var info = room_get_info(_room, false, true)
 var i_insts = info.instances
     
array_sort(i_insts, function (a, b)
 {
      return real(a.id) - real(b.id)
        })
 
  return array_find_index(i_insts, method({ inst_id }, 
 
//  
  
        
          
 
    
          
  
        
//      
          
    
         
function (e)
{
      return e.id == inst_id
 })
       );
    }

       function net_ping(_ip, _port) {
     network_set_config(network_config_connect_timeout, 3000)
     var _sock = network_create_socket(network_socket_tcp)
  var _stat = network_connect_raw(_sock, _ip, _port)
           
     network_destroy(_sock)
return _stat >= 0;
      
// 
       
//     
    
        

    

  
// 
     
       
      }
 
        function net_set_pause_mode(_t)
{
        if !variable_global_exists("net_pause_mode")
   return;

   global.net_pause_mode = _t;
  __net_log_dev("net_pause_mode " + string(global.net_pause_mode))
   }

function net_init() {
 if net_key == "unset" 
   
  {

  
  
    
        
     
//    
   
     
        
       
   
       
//    
     
          
       
//         
      
   
       
  
__net_log("[FATAL] net_key macro is not set! Can't initialize!")
      return;
 }
   
net_debug_init();
      
   __net_log("Booted up in " + working_directory)
       global.net_props = {};
      global.net_last_props = {};
       global.net_event_listeners = ds_map_create();
      global.net_kick_reason = "no reason";
     global.net_chat_cmds = ds_map_create();
   global.net_audio_queue_buf = ds_map_create();
       global.net_voice_active = false;
     global.net_pause_mode = false;
  global.__net_ignore_http = false;
      global.__net_queued_udp = [];
        net_chat_add_cmd("kick", function(_cmd) {
     __net_log("Kick: " + string(_cmd))
       if is_numeric(_cmd[1])
     return;
net_administrative_command("kick", { who: real(_cmd[1]) })
          

//    
      
    
//         
   
      
 
    
         
       
  
//           
//          
//      
    })
       net_file_init();
    net_set_config({
        timeout: 40_000,
        uses_accounts: false,
   })
 net_gc_init();
  
        }
  
  function net_get_server_name() {
      if !instance_exists(obj_net)
   return undefined;
 
   return obj_net.server_name;
   }
// 
       
//  
    
     
       function net_set_config(_config) {
       global.net_config = {
        timeout: net_val_or_def(_config, "timeout", 40_000),
         
          
     
          
//         
    
          
        onstart: net_val_or_def(_config, "onstart", function() {}),
   p2p_handler: net_val_or_def(_config, "p2p_handler", function() {}),
    uses_accounts: net_val_or_def(_config, "uses_accounts", false),
        
     uses_files: net_val_or_def(_config, "uses_files", false),
      }
 }
         
   
//        
 
  
      
  

  
//  
//   

       
//           
        
 
         
        
 function net_get_id() {
      if !instance_exists(obj_net)
 return noone;

     return obj_net.net_id;
   }
    
     function net_iam(whom)
   {
    return net_get_id() == whom
        }
     
     function net_heis(nid)
       {
      var sobj = net_sync_get(nid)

      
      
     
      
//        
   
   
    
      
        
   
   
 
     
 
//           
 


 
         
     
 
  if sobj == noone
        return -1
       
     return sobj.owner_id
       }
   
      function net_disconnect(_early) {
    _early ??= false;
      with (obj_net) {
       if !_early net_send_json({ type: PACKET_TYPE.LEAVE })
    interface.Kill()
        state = NET_STATE.DISCONNECTED;
        
 array_foreach(ds_map_keys_to_array(synced_objs) ?? [], function (_o) {
      synced_objs[? _o].Destroy();
        });
  
  __net_log("Goodbye!");
__net_call_event(net_ev_leave, global.net_kick_reason);
instance_destroy();
 }
    }
     
    
        
       
     
 
       

       
          
  
     
 
       
      
    

      
          

    
         
       function net_get_state() {
     if instance_exists(obj_net) return obj_net.state;
     
       return NET_STATE.DISCONNECTED;
        }
        
       function net_connect(_ip, _port) {
 if !os_is_network_connected()
     {
        __net_log("[Fail] Not connected!");
       return false;
 }
     
    global.remote_address = { ip: _ip, port: _port }
       global.__net_queued_udp = []
var _inst = instance_create_depth(0, 0, 0, obj_net)
  
    with _inst {
        interface.ip = global.remote_address.ip
     interface.port = global.remote_address.port
    
        
    
//      
          
 
  
          
      
   
 
//       
    
         
         

  
     
    
    
       
         
    
      
      
 
        
    
        
        
    
       interface.Connect()
       }
     return true;
 }
 
     function net_send_json(_data) {
        net_send_string(json_stringify(_data))
    }
        
        function net_send_json_udp(_data) {
 net_send_string_udp(json_stringify(_data))
}
   
      function net_send_json_ext(_data, _reliable) {
     if _reliable net_send_json(_data)
    else net_send_json_udp(_data)
   }

  function net_send_string(_data) {
var _buf = buffer_create(string_length(_data)+1, buffer_fixed, 1)
buffer_seek(_buf, buffer_seek_start, 0)
     buffer_write(_buf, buffer_string, _data)
       with obj_net
    interface.Send(_buf, true)
        buffer_delete(_buf)
       }
   
function net_send_string_udp(_data) {
        var _buf = buffer_create(string_length(_data)+1, buffer_fixed, 1)
  buffer_seek(_buf, buffer_seek_start, 0)
          
        
       
 

//           
   
//  
  
         
     
        
//       
//      
//      
        
       
//  
          
          
//           
     buffer_write(_buf, buffer_string, _data)
    var interface_out = false
        with obj_net
   interface_out = interface.Send(_buf, false)
      if interface_out 
    buffer_delete(_buf)
 }
  
        function net_add_custom_packet(_type, _callback) {
        ds_map_add(obj_net.other_packet_handlers, _type, _callback)
}
 
      function __net_debug_tip_by_kick_reason(_reason) {
   switch (_reason) {
      case "is_acc":
   __net_log("Tip: The server kicked you because it uses an account system. Set 'uses_accounts' to true when calling net_set_config");
 break;
   case "invalid_acc":
     __net_log("Tip: The server kicked you because you wrote an invalid password or username");
      break;
        case "security_violation":

 
   
//  
   
     game_end()
  break;
     }
  
      
  
       
//     
//    
//           
   

       

// 
          

    
          
//           
          
 
//     
   
 }
      
  function __net_create_socks(_protocol, _protocol2, _port) {
            var socket = network_create_socket_ext(_protocol, _port)
      var socket2 = network_create_socket_ext(_protocol2, _port + 2)
    while (socket < 0 && socket2 < 0 && _port < 65535)
        {
            _port++
        socket = network_create_socket_ext(_protocol, _port)
               socket2 = network_create_socket_ext(_protocol2, _port + 2)
           }
       if (socket < 0 || socket2 < 0 || _port > 65535)
           {
             __net_log("Cannot find a clear port!")
                game_end()
              return noone;
     }
          global.__net_last_safe_port = _port
     return [socket, socket2];
   }
     
  function net_handle_packet(_packet, _udp) {
    if struct_exists(_packet, "__k")
         
      
        
        
//   
  
       
       
         
    
    
   
 
      
  
     
          
       
//         
         
   
    
    
 
        

 {
  __net_log_dev("Received self packet")
      return;
 }
   
if ds_map_exists(other_packet_handlers, _packet.type)
     other_packet_handlers[? _packet.type](_packet);
     
var do_pause_mode = method({ _packet, _udp }, function ()
      {
   if global.net_pause_mode
       {
 array_push(obj_net.packet_stack, 
{
        content: _packet,
 udp: _udp
        })
        return true;
}
     
      return false;
        })
  
     switch (_packet.type) 
       
//       
        
    
         
       
  
  
          
//          
       

    
 
//       
//      
//    
      {
  
        




    case PACKET_TYPE.HELLO:
    
 net_id = _packet.net_id
        
    if global.net_config.uses_accounts {
obj_net.identity = {
  accId: _packet.accId,
  token: _packet.token,
 powlvl: _packet.powlvl,
        }
 }
   
      
      array_foreach(_packet.players, function (_pstruct) 
     
  
 
    

          
//          
//          
      
          
          
// 
       
       
        
       
        
   
    
   
//         
       
      {
  var _plyr = new NetPlayer(noone, noone).FillFromStruct(_pstruct)
    
        
  
       array_push(players, _plyr)
      })
    
     
       array_foreach(_packet.objects, function (_ostruct) 
      {
     var _nid = _ostruct.nid;
     var _obj = _ostruct.obj;
 var _oid = _ostruct.oid;
 var _owner = _ostruct.owner;
       var _room = _ostruct.rom;
   var _ci = _ostruct.ci;
     
      var _sobj = new NetSync(_nid, _obj).Assign(_owner, _oid);
        
    _sobj.current_room = _room;
      if _ci != -4
    
//          
      
      
  
        
          
   
  
//     
       


     
          
     
 
  {
   _sobj.custom_instance.has = true
      _sobj.custom_instance.is = _ci
}
  ds_map_add(synced_objs, _nid, _sobj);
      })

 state = NET_STATE.REGISTERED
     
   
   net_heartbeat()
       
      
       server_name = _packet.svName;
   
if global.net_config.uses_files
      net_file_request_resources()
//           
//           
//        
 
 
        
     
     
   
        
//      
    
     __net_call_event(net_ev_join)
        
    interface.keys.udp = _packet.uk
interface.keys.tcp = _packet.tk
       
      __net_log_dev("interface keys = " + string(interface.keys))
break;
     
        case PACKET_TYPE.OTHER_LEFT:
      var _lid = _packet.lid;
//       
     
//     
        
//   
//  
     
 
        
        

//          
       

         
    
          
  
 
        

         

       
       
        if obj_net.net_id != _lid
{
      __net_call_event(net_ev_player_left, _lid)
  var _idx = net_player_find_idx_by_id(_lid);
 
  if _idx == noone
    break;
      
       array_delete(players, _idx, 1);
     }
else
  {
     state = NET_STATE.DISCONNECTED
     global.net_kick_reason = _packet.why;
 __net_log("Got disconnected: " + global.net_kick_reason);
        __net_debug_tip_by_kick_reason(global.net_kick_reason)
 instance_destroy(obj_net)
}
      break;
     
 case PACKET_TYPE.OTHER_REGISTERED:
       
    var _plyr = new NetPlayer(noone, noone).FillFromStruct(_packet)
      if net_player_get(_plyr.pid) != noone
 {
 
//      
    
 

 
      
 
          
   
__net_log("dupe player register detected within other_registered")
break;
        }
      
        array_push(players, _plyr)
 
  __net_call_event(net_ev_player_join, _plyr.pid)
break;
        /* */
 
//    

      
       
          
//     
//   
    
         
       
        
// 
 
  
      
          
   
         

     
  
      
//         
     
   

        





      case PACKET_TYPE.OTHER_SYNC_CREATE:
 var _nid = _packet.nid;
    var _obj = _packet.obj;
    var _oid = _packet.oid;
   var _owner = _packet.owner;
    var _room = _packet.room;
       var _ci = _packet.ci;
       var _tag = -1;
    
if struct_exists(_packet, "tag")
_tag = _packet.tag;

if _tag != -1 {
      
if _oid == obj_net.net_id && _owner == NET_SYNC_OWNER.PLAYER { 
        var _sobj = synced_objs[? _tag];
   
   if _sobj == undefined
 break;
        
 
_sobj.is_queued = false;
     _sobj.nid = _nid;

       
   _sobj.__InstUpdateNetId();
//      
     
//       
 
        
         
        
    
//           
         
        
//          
  

   
  ds_map_delete(synced_objs, _tag);
        ds_map_add(synced_objs, _nid, _sobj);
   
     _sobj.on_instant_networked(_sobj);
  break;
   }
  }
     
      var _sobj = new NetSync(_nid, _obj, _room).Assign(_owner, _oid);
 if _ci != noone
        {
        
     
 
          
     
        
         
          
    
  
      
          
         
   
    
         
  
 
  
   
// 

     
  
    _sobj.custom_instance.has = true;
  _sobj.custom_instance.is = _ci;
  }
    _sobj.Create(); 
ds_map_add(synced_objs, _nid, _sobj);
break;
      
   case PACKET_TYPE.OTHER_SYNC_UPDATE:
   var _nid = _packet.nid;
     
    if net_owns_sync(_nid) {
       return;
    }
      if !ds_map_exists(obj_net.synced_objs, _nid) {
    return;
}
     

     var _vars = _packet.vars;
 var _sobj = synced_objs[? _nid];
    
if _sobj == undefined
     break;
      
        
  
         
     
        
       
      
//   
  
  
     
        
      
  

 

     
         
          
         
        
    



      
    
  
   
if _sobj.current_room != _packet.room
       __net_call_event(net_ev_other_roomchange, _sobj.owner_id, _sobj.current_room, _packet.room)
     
      _sobj.current_room = _packet.room;
        
       _sobj.on_preupdate(_sobj, _vars)
     
     
      var _varnames = struct_get_names(_vars);
        for (var i = 0; i < array_length(_varnames); i++) {
     var _varname = _varnames[i];
        var _value = struct_get(_vars, _varname)
        
       synced_objs[? _nid].__VarSet(_varname, _value);
   }
    break;
        
        case PACKET_TYPE.OTHER_SYNC_DESTROY:
       var _sobj = synced_objs[? _packet.nid];
        if _sobj == undefined return;
_sobj.Destroy();
       
       ds_map_delete(synced_objs, _sobj.nid)
      break;
    
  case PACKET_TYPE.OTHER_SYNC_SIGNAL:
       var _from = _packet.src;
       var _data = _packet.dat;
   
 
       
   
      
 
          
    
//  
  
       
     
var _for = _packet.nid;
   
     var _sobj = synced_objs[? _for];
    if _sobj == undefined return;
  
    _sobj.__CallSignalExternal(_from, _data)
   break;
        
  case PACKET_TYPE.OTHER_SYNC_TRANSFER:
    var _for = _packet.nid;
      
 var _sobj = synced_objs[? _for];
         

          
 
    

//       
    
     
      
       
         
//     
         

         
   
// 
     
   
       
          
          
//          
        
  if _sobj == undefined
    break;
        
      _sobj.owner = _packet.typ
        _sobj.owner_id = _packet.id
     break;
        
   /* */
    
      




  case PACKET_TYPE.OTHER_CHAT_SEND:
  var _msg = _packet.content;
   var _id = _packet.cid;
   net_chat_add_msg(_msg, _id)
       break;
 /* */
     
    




case PACKET_TYPE.OTHER_P2P_SEND:
if do_pause_mode()
     break;
     
 var _from_id = _packet.from;
 
      
      
        
     
//      
      
var _data = _packet.data;
    
if struct_exists(_packet, "rmw") 
{
   var _room = _packet.rm;
if real(_room) != real(room)
        return;

//        
       
     
    }
       
  global.net_config.p2p_handler(_from_id, _data);
     __net_call_event(net_ev_p2p, _from_id, _data)
   

   
          
       
       
        
         
       
     
//          
          
     
       
//      
     
    
  
          
          
    
       
      break;
        /* */
        
     




      case PACKET_TYPE.HEARTBEAT:
        global.net_heartbeat.ping = current_time - global.net_heartbeat.last;
      global.net_heartbeat.last = current_time;
  net_heartbeat()
break;
       /* */
 
     




   case PACKET_TYPE.RPC_CALL:
        if do_pause_mode()
        break;

     var _name = _packet.fn;
    var _args = _packet.args;
 __net_rpc_call_self(_name, _args);
     break;
/* */
  
     
         
//           
   
//  
      
        
     
//        
    
   
         
   
      
        
   
        
   
      
      
         
   
        
//   
    
// 

    
// 
    




     case PACKET_TYPE.GAMESTATE_UPDATE:
       var _data = _packet.dat;
        gamestate.__Set(_data);
   break;
       
 case PACKET_TYPE.GAMESTATE_UPDATE_PARTIAL:
       var _diff = _packet.dif;
     gamestate.__Process(_diff);
   break;
      /* */
  
     




     case PACKET_TYPE.PLAYER_PROPS_UPDATE:
      var _oid = _packet.oid;
     var _diff = _packet.dif;
    
  var idx = net_player_find_idx_by_id(_oid)
   if idx == noone
  break;
      players[idx].__UpdateProps(_diff);
    break;
   /* */
 
     




      case PACKET_TYPE.PLAY_SOUND:
    var _dat = _packet.dat;
  if !struct_exists(_dat, "sound") 
    {
      

    __net_log("Server tried to play sound without sound");
    return;
 
       
   
      
     
     

 
 

          
//    

//         
  
//  
       }
   
        net_play_sound(_dat);
       break;
       /* */
       
 




      case PACKET_TYPE.SPAWN_BASIC:
    if do_pause_mode()
break;
        
 if net_get_id() == _packet.mkr
   break;
 
        __net_spawn_basic_other(_packet.obj, _packet.x, _packet.y, _packet.vars, _packet.lay, _packet.mkr, _packet.rm)
     break;
        
        
          
// 
 
          

   
//    
   
  
   
     case PACKET_TYPE.DESTROY_BASIC:
  if do_pause_mode()
break;
 
   var inst = _packet.i
var asset = _packet.a
       var from = _packet.fr
   
if !instance_exists(inst)
      break;
        var orgAsset = object_get_name(inst.object_index)
 if orgAsset != asset
      
       {
         
     
        
     
//   
  
 
   __net_log("Asset mismatch destroy basic: " + string(orgAsset) + " but got " + asset)
   break;
}
       
     __net_call_event(net_ev_destroy_basic, inst, from, asset)
         
         
         

         
 
//      
//      
     
//   
      
   instance_destroy(inst)
 break;
    /* */
   
        




 case PACKET_TYPE.GET_RESOURCES:
  if !struct_exists(_packet, "res")
     break;
resources = __net_file_fix_res_struct(_packet.res);
    
   var _todown = net_file_to_download()
         
//    
        
   
          
   
          
       
//         
      
   
   
   
        
          
     
     
   
//       
 
//     
 
    
      
         
   
       
//   
     __net_log_verbose("Got resources: " + string(resources) + ", and downloading: " + string(_todown))
   var _downed = net_file_downloaded();
       
 __net_log_verbose("With " + string(_downed) + " already downloaded")
    for (var i = 0; i < array_length(_todown); i++) {
   net_file_download(_todown[i].name);
    }
      break;

    case PACKET_TYPE.FILE_CHUNK:
 var _data = _packet.data;
var _is_end = _packet.fin;
var _name = _packet.name;
    
__net_log_verbose("Got file chunk for " + string(_name) + (_is_end ? "" : " and it's still gonna download more"));
  
var _buf = buffer_base64_decode(_data)
net_file_write(_name, _buf)
        
       if !_is_end
   net_file_download(_name)
       break;
    /* */
      
  




        case PACKET_TYPE.STREAM_REGISTER:
 var _nid = _packet.nid;
        var _oid = _packet.oid;
     
   
  
          
     

          
//           

  
//        
    
// 
//           
 
//         
   
  
//   
   
 
//         
          
       
  
       
        
   
       
   var _stream = new NetStream(_oid, _nid);
       array_push(streams, _stream);
  __net_call_event(net_ev_stream_created, _stream);
    break;
  
        case PACKET_TYPE.STREAM_DATA:
 var _nid = _packet.nid;
     var _oid = _packet.oid;
       var _data = buffer_base64_decode(_packet.dat);
     var _data_cpy = buffer_create(buff_sz(_data), buffer_fixed, 1)
       buffer_copy(_data, 0, buff_sz(_data), _data_cpy, 0)
      
        var _stream = net_stream_get(_oid, _nid);
        if _stream == noone
     {
       __net_log("Cannot write to non-existant stream!")
    return;
   }
   
     _stream.__AppendData(_data_cpy)
 buffer_delete(_data_cpy)
     __net_call_event(net_ev_stream_data, _stream, _data)
 break;
  
      case PACKET_TYPE.STREAM_DESTROY:
        var _nid = _packet.nid;
  var _oid = _packet.oid;
       
         
  
          
     
          
 
       
          
     
     
  
    array_delete(obj_net.streams, net_stream_get_index(_oid, _nid), 1)
     __net_call_event(net_ev_stream_destroyed, _nid, _oid)
     break;
   
      /* */
   
      default:
    __net_log("Unknown packet " + string(_packet.type))
break;

     
//        

          
      
   
      
   
   
          
//    
          
     
  
        
    
         
  

    
        }
        }      
 
  function net_administrative_command(_command, _params) {
     net_send_json({
    type: PACKET_TYPE.ADMINISTRATIVE_CMD,
  cmd: _command,
   params: _params
    });
 }        
    
   
        
 function net_chat_add_msg(_msg, _id) {
        array_push(obj_net.chat, {
    content: _msg,
 cid: _id
       });
       
    
     
     
       
//      
  
   __net_call_event(net_ev_chat, _msg, _id)
}

 function net_chat_add_cmd(_cmd, _callback) {
  global.net_chat_cmds[? _cmd] = _callback;
   }
    
//      
     
 

   
   
      
   
          
          
//  
// 
     
       
       
          
         
//      
         
//           
        
     
      
 
//        
          
// 
       
//          
        
     function net_chat_send(_msg, _reliably = true) {
if (str_at(_msg, 1) == "/") {
 
     var _splitted = string_split(_msg, " ")
var _cmd = string_copy(_splitted[0], 2, string_length(_splitted[0]));
     
  _splitted[0] = _cmd;
  
       if !ds_map_exists(global.net_chat_cmds, _cmd)
      return;
   
   global.net_chat_cmds[? _cmd](_splitted);
  return;
 }
  
        net_send_json_ext({
      type: PACKET_TYPE.CHAT_SEND,
   msg: _msg
     }, _reliably)
     }
       
  function net_chat_get() {
 return obj_net.chat;
       }
  
  #macro net_dev_enabled /*true*/false
  
function net_debug_init() {
    global.net_debug_logger = show_debug_message;
     
 
  

        
          
 
          
   
  
       
         
    
          
     
         
      
      
  
        
         
    
          
   
 
    
  
//           
     
      global.net_debug_logger_v = show_debug_message;
  global.net_debug_logger_dev = function() {};
 
 if net_dev_enabled
        net_debug_set_dev_logger(show_debug_message)
       }
        
 function __net_log(_message) {
  global.net_debug_logger("[NetGM2 - LOG] " + _message);
    }
     
   function __net_log_verbose(_message) {
   global.net_debug_logger_v("[NetGM2 - VERBOSE] " + _message);
      }
    
      function __net_log_dev(_message) {
        if !net_dev_enabled
        return;
  
 global.net_debug_logger_dev("[NetGM2 - DEV] " + _message);
}
   
        function net_debug_set_logger(_callback) {
global.net_debug_logger = _callback;
 }
     
  function net_debug_set_verbose_logger(_callback) {
       global.net_debug_logger_v = _callback;
    }
//    

      
     

          
      
//         
// 
 
     function net_debug_set_dev_logger(_callback) {
      if !net_dev_enabled
  return;
        
        global.net_debug_logger_dev = _callback;
   }    

//  
    
   
   
      
//   
//           
//          
       
//         
 
      
  
          
      
      function net_discord_init() 
   {
          global.net_discord = {
      app_id: "1174766512767250524",
custom_presence: false,
   user: {
    user_id: noone,
        username: "",
            avatar: "",
        loaded: np_initdiscord(global.net_config.discord.app_id, false, "0"),
        }
      }
 }

 function __net_discord_async_social()
   
       
     
    {
           switch async_load[? "event_type"]
       {
//    

//   
   
//  
//           
       
     
            case "DiscordReady":
       global.__net_discord.user = {
         user_id: async_load[? "user_id"],
      username: async_load[? "username"],
    avatar: async_load[? "avatar"],
        }
      break;
    case "DiscordError":
 
//          
        __net_log("Net Discord RPC Error: " + (async_load[? "error_message"] ?? "Could not fetch error message") + " with code of " + (async_load[? "error_code"] ?? "Couldn't fetch error code"))
    break;
       
       
   
      
         
       
         case "DiscordJoinRequest":
         var _uid = async_load[? "user_id"];
       __net_log("Replying to join request from: " + _uid)
        np_respond(_uid, DISCORD_REPLY_NO)
           break;
     }
   
    
       
// 
 
    
//          
      
 
     
          
        
   

   
     
   
          

//      
//      
          
   }
      
        function __net_discord_step()
       {
    np_update()
  if !global.net_config.discord.custom_presence {
 var _state = "No state.";
     var _details = "";
   var _img_key = "";
       var _small_img_key = "net_bp_sm";
       switch (net_get_state()) {
    case NET_STATE.CONNECTING:
      _state = "Joining";
      _details = "Connecting to the game...";
_img_key = "net_bp_offline";
       break;
case NET_STATE.CONNECTED:
     _state = "Joined";
_details = "Loading in...";
 _img_key = "net_bp_loading";
       break;
  case NET_STATE.DISCONNECTED:
       
          
        
    
   
    
        
    
// 
//       
    
// 
      

  
    _state = "Not playing";
  _details = "Not doing much.";
    _img_key = "net_bp_offline";
   break;
case NET_STATE.REGISTERED:
    _state = "In-game";
      _details = "Playing on server " + obj_net.server_name;
     _img_key = "net_bp_ingame";
        break;
   }
 np_setpresence(_state, _details, _img_key, _small_img_key);
}
 }
    
         
       
         
   
  
//      
      #macro net_ev_state_update "on_state_change"
 
     #macro net_ev_join "on_us_join"
     #macro net_ev_leave "on_us_leave"
        #macro net_ev_leave_late "on_us_leave_late_post"
 #macro net_ev_player_join "on_player_join"
   
//          
  

     
  
//     
      
       
        
      
       
//         
#macro net_ev_player_left "on_player_leave"

 #macro net_ev_chat "on_chat_message_sent"
  #macro net_ev_gstate_update "on_game_state_update"
    #macro net_ev_player_props_update "on_player_props_modified"
      #macro net_ev_rpc_call "on_remote_procedure_call"
#macro net_ev_sound_played "on_other_sound_player"
    
    #macro net_ev_stream_created "on_other_register_new_stream"
      #macro net_ev_stream_destroyed "on_other_destroy_existing_stream"
 #macro net_ev_stream_data "on_other_stream_append_data"
       
      #macro net_ev_holepunch_finish "on_holepuncher_work_state_finished"
     
         
     
         
//          
 
 
   
     

  

         
         

     
    
   
     
  
          
       
      
//   

  
 #macro net_ev_holepunch_failed "on_holepuncher_work_state_unsuccessful"
        
    #macro net_ev_destroy_basic "on_other_destroy_basic_unsafe"
    #macro net_ev_p2p "on_other_sent_p2p_message"
      
        #macro net_ev_packet "on_self_send_packet_anytype"
    
      #macro net_ev_other_roomchange "on_other_changed_croom_sync"
     
    function net_add_event_listener(_ev_name, _callback) {
    if !ds_map_exists(global.net_event_listeners, _ev_name) {
      global.net_event_listeners[? _ev_name] = [];
     }
     array_push(global.net_event_listeners[? _ev_name], _callback)
 }
  
  function __net_call_event(_ev_name) {
    
       
       var _args = [];
     for (var i = 1; i < argument_count; i++) 
   {
      array_push(_args, argument[i]);
     }
      
   
          
//   
      
      
         
  
   
       
      
    
  
         
          
        
   
         
//      
          
      
    
        
var _callbacks = global.net_event_listeners[? _ev_name];
  
  for (var i = 0; i < array_length(_callbacks); i++) {
    var _callback = _callbacks[i];
   
  method_call(_callback, _args)
       }
    }      
   
     #macro net_res_folder game_save_id + "NetGm2Resources" + "\\"
#macro net_res_mask game_save_id + "NetGm2Resources/*.bin"
     
      function net_file_request_resources() {
    net_send_json({
type: PACKET_TYPE.GET_RESOURCES,
    })
    }
 
//      
//    
        
         
        
    
// 
     
         
         
          
         
      
        
          
   function __net_file_fix_res_struct(_res) {
   var _final = []

      for (var i = 0; i < array_length(_res); i++) {
array_push(_final, {
     name: _res[i].n,
       hash: _res[i].h,
});
       }

return _final;
  }

 function net_file_has(_file) {
        return array_contains(array_map(obj_net.resources, 
//         
          

//  
      
 
  
     
// 
    
// 

 
      
  
      
 
      
  

 
//    
        function (_x, _i) {
  return _x.name;
      }), _file);
   }
     
     function net_file_download(_file) {
        if !net_file_has(_file)
  {
     __net_log("Cannot download file that doesn't exist!");
   return;
 }
 
 net_send_json({
      type: PACKET_TYPE.REQUEST_DOWNLOAD,
     fil: _file
       })
}
 
   function net_file_get_hash(_file) {
    var _buf = buffer_load(_file)
    buffer_seek(_buf, buffer_seek_end, 0)
    
        
//       

          
       
       
          
  
     
     
        
//          
   
        var _byte = buffer_peek(_buf, buffer_tell(_buf)-1, buffer_u8)
     while (_byte == 0x0 || _byte == undefined) {
  var _tell = buffer_tell(_buf);
       _byte = buffer_peek(_buf, _tell, buffer_u8)
        buffer_seek(_buf, buffer_seek_start, _tell - 1)
     }
     
    var _trimmed = buffer_create(1, buffer_grow, 1)
   buffer_copy(_buf, 0, buffer_tell(_buf) + 1, _trimmed, 0)
     buffer_delete(_buf)
      
       return buffer_md5(_trimmed, 0, buffer_get_size(_trimmed))
 }
         
     
    
     
 
          
        
        
          
       
//   
  
//           
      
  
 
      function net_file_downloaded() {
        var _files = []
   for (var _file = file_find_first(net_res_mask, 0); _file != ""; _file = file_find_next())
{
        var _fname = string_replace(_file, ".bin", "");
  if net_file_has(_fname) 
   {
  array_push(_files, {
        name: _fname,
       hash: md5_file(net_res_folder + _file)
 })
     }
        }
        return _files;
      
        

 
      

        
//    
  
  
     
    
          
 
   
      
      
         
         
     
       
}
 
function net_file_to_download() {
      
  var _downed = net_file_downloaded()
for (var i = 0; i < array_length(obj_net.resources); i++) {
       var _res = obj_net.resources[0];
for (var j = 0; j < array_length(_downed); j++) {
        var _fl = _downed[i];
   if _res.name == _fl.name && _res.hash != _fl.hash {

 __net_log_verbose("Deleted " + _res.name + ".bin due to invalid hashes")
    file_delete(net_res_folder + _res.name + ".bin")
 }
}
        }
  
      var _todown = net_file_downloaded();
      return net_array_except(obj_net.resources, _todown);
     }
       
//   
  
          
        
   
 
  
          
   

  
 
     
        
       
   
    
        
          

          
 
  
     
       
        function net_file_write(_name, _buffer) {
  if !directory_exists(net_res_folder)
    {
     __net_log("Did not properly init")
     return;
        }

       var _path = net_res_folder + "/" + _name;
       var _fpath = _path + ".bin";
  
      var _file = file_bin_open(_fpath, 2)
  var _sz = file_bin_size(_file);
   
       
     file_bin_seek(_file, file_bin_size(_file))
 buffer_seek(_buffer, buffer_seek_start, 0)
     
        
      while (buffer_tell(_buffer) < buffer_get_size(_buffer)) {
        file_bin_write_byte(_file, buffer_read(_buffer, buffer_u8))
      }

    
     file_bin_close(_file);
}
        
//   
      


     
         
       
       

 

        
// 
//     
    
       
//          
       
          
// 
    
     
      function net_file_init() {
     directory_create(net_res_folder)
        }    
  
     
  
    enum NET_GSD_ACCESS 
  {
       SERVER,
        PLAYER
  }
     
       function NetGameState() constructor {
   self.state = {} 
  
      self.local = {}
      
    self.last = {}
  
  function __ApplyDiff(_sdiff) {
         
  
          
      
         
     
     
        
//     
// 

    
   
      
  
         
    
//   
   
     
   
  
      
     self.local = net_struct_apply_diff(net_struct_copy(self.local), _sdiff)
       }
       
   function __MakeDiff(_last) {
 return net_struct_diff(self.last, self.local);
     }
      
      function __Set(_to) {
  self.local = net_struct_copy(_to);
        self.state = net_struct_copy(self.local);
        }
  
    function BeginChange() {
self.local = net_struct_copy(self.state);
    self.last = net_struct_copy(self.local)
      }
 
 function Commit() {
        
    net_send_json({
    type: PACKET_TYPE.GAMESTATE_UPDATE_PARTIAL,
      dif: __MakeDiff(self.local)
})
   

        
    
//      
    
         
          
//         
      
//     
         
      
          

   
 
//        
        
  
//           
  }
   
      function __Process(_diff) {
        self.state = net_struct_apply_diff(net_struct_copy(self.state), _diff);
 __net_call_event(net_ev_gstate_update, self.state)
        self.local = net_struct_copy(self.state);
    }
      }
  
    function net_gamestate_begin_change() {
    with (obj_net) {
     gamestate.BeginChange();
}
 }
 
    function net_gamestate_commit() {
     with (obj_net) {
  gamestate.Commit();
      }
     }
      
        
      

      
   
       
        
//     
         
   
//           

   
function net_gc_init() {
      global.net_gc_queues = {
      buffers: [],
     buf_audio: [],
     };
   global.net_gc_deletions = [];
  }
       
     function net_gc_queue(_section, _obj, _life) {
array_push(global.net_gc_queues[$ _section], {
 obj: _obj,
     life: _life
     
  
      
//         
//           
    

      

     
         
        
       
   
    
//           
   
          

   

         
//        
     


 
//   
      
  });
     }
      
function net_gc_tick() {
       var _sections = struct_get_names(global.net_gc_queues)
    
      for (var i = 0; i < array_length(_sections); i++) {
        var _sec = _sections[i];
    var _queue = global.net_gc_queues[$ _sec];
     
  for (var j = 0; j < array_length(_queue); j++) {

  var _el = _queue[j];
      _el.life--;
    
       if _el.life <= 0 {
   __net_gc_clean(_sec, j)
        }
   }
   }
      __net_gc_dequeue()
    }
    
 function __net_gc_dequeue() {
      for (var i = 0; i < array_length(global.net_gc_deletions); i++) {
var _el = global.net_gc_deletions[i];
   array_delete(global.net_gc_queues[$ _el.sec], _el.ind, 1);
  }
    global.net_gc_deletions = [];
    
  
//      
   
//       
  
  
   
      

    
      
     
     
  
//          
//      
    
  }
       
 function __net_gc_clean(_section, _ind) {
switch (_section)
       {
   case "buffers":
        buffer_delete(global.net_gc_queues[$ _section][_ind].obj);
       break;
  case "buf_audio":
     audio_free_buffer_sound(global.net_gc_queues[$ _section][_ind].obj)
     break;
   }
     
 array_push(global.net_gc_deletions, {
     sec: _section,
   ind: _ind
});
}
   
//     

        
          
      
     
         
  
        
      function net_gc_workload() {
    var _total = 0;
      var _sections = struct_get_names(global.net_gc_queues)
  
        for (var i = 0; i < array_length(_sections); i++) {
        var _sec = _sections[i];
    var _queue = global.net_gc_queues[$ _sec];
     
  
       
  
        
      
        
       
         
    _total += array_length(_queue);
     }
     
return _total;
      }    
    
 function net_gui_debug() {
    
       
//    
       
       

 
   
   
          
//      
     
//         
          
       
      
       
     
         
       var _info = "NetGM2 debugging information"
     _info += "\nPing: " + string(global.net_heartbeat.ping - 2000);
     _info += "\nLast heartbeat: " + string(global.net_heartbeat.diff());
  _info += "\nGC workload: " + string(net_gc_workload());
    _info += "\nNetwork ID: " + string(global.net_id());
      _info += "\nNumber of server resources: " + string(array_length(net_file_downloaded()));
        _info += "\nNumber of hooked events: " + string(ds_map_size(global.net_event_listeners));
   _info += "\nNumber of chat messages: " + string(array_length(obj_net.chat));
       _info += "\nSynchronized objects: " + string(array_length(obj_net.synced_objs));
     _info += "\nNumber of players: " + string(array_length(obj_net.players));
    _info += "\nStream count: " + string(array_length(obj_net.streams));
 draw_set_alpha(1)
draw_set_halign(fa_left)
      draw_set_valign(fa_top)
draw_set_color(obj_net.state == NET_STATE.REGISTERED ? c_white : c_red)
draw_text(0, 0, _info)
    }

  function net_gui_chat()
       
//      
          
      
//         
//         
      
         
          
        
     
//  
 
//      
 

          
        
     
 
      
  {
       var _chat = ""
        var _messages = []
if array_length(net_chat_get()) > 18
      array_copy(_messages, 0, net_chat_get(), array_length(net_chat_get()) - 18, 18)
    else
   _messages = net_chat_get()
     
   array_foreach(_messages, function (_msg, _i)
 {
   var _cid = _msg.cid
    var _content = _msg.content
       var player_name = "server"
    if _cid != -1
 {
      var _plyr = net_player_get(_cid)
   player_name = _plyr == noone ? "unknown" : _plyr.name
   }
      
    draw_text(x, view_hport[0] - _i * string_height("a"), player_name + ": " + _content)
       })
      
      
//       
         
          
 
    
//           

     
 
        
//    
        

    
      
     
  
         
 
         
     

         

//    
      
    
//        
     }    
   
 enum NET_HOLEPUNCH_STATE {
        IDLE,
           TESTING,
        PUNCHING,
       DONE,
       FAILED
        }
       
       #macro net_holepunch_intermediate "https://kenanyazbeck.com/netgm2/"
 #macro net_holepunch_min_frames 30
        
      
       
  function NetInterface(_ip, _port) constructor 
    {
         var _socks = self.__CreateSockets();
     self.tcp = _socks[0];
    self.udp = _socks[1];
      self.ip = _ip
     self.port = _port
         
    self.keys = 
      {
             udp: "",
         tcp: "",
            }
           
 
 
       
//  
 
//         
  
   
         self.on_receive = function(_, _2)
         {
         }
           
      static Connect = function ()
    {
               with obj_net
     
    
   
   

      
//     
    
      
        
 
  
      
          
    
  
          {
                __net_log_dev("interface connect")
               network_connect_raw_async(interface.tcp, interface.ip, interface.port)
         }
           }
           
           static __CreateSockets = function (_port = 6245)
          {
               var socket = network_create_socket_ext(network_socket_tcp, _port)
                var socket2 = network_create_socket(network_socket_udp)
 
 while (socket < 0)
 socket = network_create_socket_ext(network_socket_tcp, _port++)
                
     while (socket < 0)
 socket2 = network_create_socket(network_socket_udp)
     
     
//        
        
   

      
        
      
      
   

           
   return [socket, socket2];
            }
    
    static __BufAppendKey = function (_obuf, _key)
         {
     _key = "{\"__k\":\"" + _key + "\"," 
       
     
           
           
         buffer_seek(_obuf, buffer_seek_start, 0)
   

         
     
     
//          
      
   
       
       
//    
//  
            var _buf = buffer_create(string_length(_key) + buffer_get_size(_obuf) - 2, buffer_fixed, 1)
                buffer_copy(_obuf, 0, buffer_get_size(_obuf), _buf, string_length(_key) - 1) 
            buffer_seek(_buf, buffer_seek_start, 0)
               buffer_write(_buf, buffer_text, _key) 
        return _buf;
      }
       
           static SendUDP = function (_obuf)
           {
              if self.keys.udp == ""
               {
                   __net_log_dev("queued udp packet due to invalid key")
   
     
//          
    
    
      
 
        
  
    
      
            array_push(global.__net_queued_udp, _obuf)
             return false;
                }
             _buf = self.__BufAppendKey(_obuf, self.keys.udp);
               network_send_udp_raw(self.udp, self.ip, self.port + 2, _buf, buffer_get_size(_buf))
             return true;
    }
        
    static SendTCP = function (_obuf)
          {
               _buf = self.__BufAppendKey(_obuf, self.keys.tcp);
         
//        
         network_send_raw(self.tcp, _buf, buffer_get_size(_buf))
         }
         

       
          
    
        
          
  
   
//        
  
      
//       
  
  
    
// 
  
//    
      
       
//   
    
      
      static Send = function (_buf, _reliably = true)
        {
                if _reliably self.SendTCP(_buf)
            else return self.SendUDP(_buf)
     }
        
        static InvokeReceive = function (_buf, _isudp)
            {
              with obj_net
               interface.on_receive(_buf, _isudp)
            }
      
         static Kill = function ()
            {
      network_destroy(self.tcp);
     network_destroy(self.udp);
       }
        }      
     

        
function net_p2p_send(_data, _to) {
        
      
  
     
  


   
       
    
  
      
       

  
// 
 
         
      
//    
     
        
   net_send_json({
    type: PACKET_TYPE.P2P_SEND,
   data: _data,
     to: _to,
  })
       }
    
        function net_p2p_send_room(_data) {
   net_send_json({
    type: PACKET_TYPE.P2P_SEND,
   data: _data,
  rmw: 1,
    to: room,
     })
    }

      function NetPacketParser() constructor {
  global.__net_pack_queued = ""
global.__net_debug_packet_queue = []
    

         
       
//           
     
//     
       
     
   
  
         
       
      
       
     
       

  
      static ReadChunk = function (_data, _index, _from, _until) {
 var _str = string_copy(_data, _index + 1, string_length(_data));
       var _accumulated = ""
   var _in_string = false
    var _depth = 0
    
   for (var i = 0; i < string_length(_str); i++) {
       var _c = str_at(_str, i + 1)
    if (_c == "\"")
        _in_string = !_in_string
        
   _accumulated += _c;
    
    if (_in_string)
continue;

  if (_c == _from) _depth++
        if (_c == _until) _depth--;
// 
      

     
  
 
  
    
      
//      

       

   
   
       
      
   
         
    
   
//     
        
     
    
      
 
  
       if (_c == _until && _depth == 0)
     return [_accumulated, i + _index, true];
      }
        
    return [_accumulated, string_length(_data), false];
      }
   
 static Parse = function(_udp, _packet) {
       if array_length(global.__net_debug_packet_queue) > 30
      array_delete(global.__net_debug_packet_queue, 0, 1)
     
      array_push(global.__net_debug_packet_queue, [_udp, _packet])
     
      if !_udp
        _packet = global.__net_pack_queued + _packet;
     
       var _packets = [];
      
     for (var i = 0; i < string_length(_packet); i++) {
       var _c = str_at(_packet, i + 1);
    
   if (_c == "{") {
     var _chunkres = self.ReadChunk(_packet, i, "{", "}");
     var _content = _chunkres[0];
   var _index = _chunkres[1];
   var _status = _chunkres[2];
       
//         
     
       
         
       
          
  
        
      

       
  
        
    
//   
         
      

//  
          
   
        if !_udp {
   if !_status && string_length(global.__net_pack_queued) > 0 && str_at(global.__net_pack_queued, 1) == "{"
{
global.__net_pack_queued = ""
       __net_log_dev("[PACKETPARSER] Special case 1")

      continue;
   }
      else if !_status {
     
 
      global.__net_pack_queued += _content;
     
 i = _index;
    continue;
  }
 
global.__net_pack_queued = ""
       }
 
  global.__net_pack_debug_lastcontent = _content
     
       
 
    
  
   
     
//     
     

   
      
 
   array_push(_packets, json_parse(_content));
   i = _index;
        }
    }
      
  return _packets;
      }
} 
      

      
  
        
    
       
  
    
     
 
    
//       
       
    
         
         

       
//   
      
       

        
       
  
    
 
  function NetPlayer(_pid, _name) constructor {
    self.pid = _pid;
self.name = _name;
    self.acc_id = noone;
self.props = {};
   self.powlvl = POWER_TYPES.NORMAL;
  
  function FillFromStruct(_struct) {
   self.pid = _struct.pid;
 self.name = _struct.name;
     if global.net_config.uses_accounts
       self.acc_id = _struct.accId
      
 self.props = _struct.props;
 self.powlvl = _struct.powlvl;
       return self;
      }
    
 function __UpdateProps(_diff) {
self.props = net_struct_apply_diff(net_struct_copy(self.props), _diff)
 __net_call_event(net_ev_player_props_update, self.props)
  }
   }
     
         
      

 
      
     
  
//      
//           
          
  
         
     
     
     
// 
       
          
        
          
//         
  
   
     
     
  
  
//      
   
      
        function net_player_find_idx_by_id(_id) {
      with (obj_net) {
      for (var i = 0; i < array_length(players); i++) {
  if (players[i].pid == _id) return i;
}
    return noone;
 }
    }
     
       function net_player_get(_id) {
var _idx = net_player_find_idx_by_id(_id)
        if _idx == noone return _idx
      
     return obj_net.players[_idx]
    }

 function net_commit_props() {
       var diff = net_struct_diff(global.net_last_props, global.net_props)
 
      if array_length(struct_get_names(diff)) == 0
      return;
     
     net_send_json({
type: PACKET_TYPE.PLAYER_PROPS_UPDATE,
    dif: diff
        });
  global.net_last_props = net_struct_copy(global.net_props);
      }

        
    
      
   
       
//     
       
//           
// 
//  
          
 
          
        
//        
    
    

      
      function net_get_players() {
       return obj_net.players;
       }      

function net_rpc_register(_name, _callback) {
with (obj_net) {
    ds_map_add(rpcs, _name, _callback)
     }
}

     function __net_rpc_call_self(_name, _arguments) {
       with (obj_net) {
var _args = _arguments; 
     var _iptr = 0;
  var _callback = rpcs[? _name];
        
     if _callback == undefined
       return show_error("Cannot call non-existant RPC " + string(_name), false);
//        

//          

          
          
   
      
    
 
    
     
          
     
       
      
   
       __net_call_event(net_ev_rpc_call, _callback, _args, _name);
      
 switch (array_length(_arguments)) {
case 0: _callback(); break;
       case 1: _callback(_args[_iptr++]); break;
case 2: _callback(_args[_iptr++], _args[_iptr++]); break;
       case 3: _callback(_args[_iptr++], _args[_iptr++], _args[_iptr++]); break;
        case 4: _callback(_args[_iptr++], _args[_iptr++], _args[_iptr++], _args[_iptr++]); break;
   case 5: _callback(_args[_iptr++], _args[_iptr++], _args[_iptr++], _args[_iptr++], _args[_iptr++]); break;
  case 6: _callback(_args[_iptr++], _args[_iptr++], _args[_iptr++], _args[_iptr++], _args[_iptr++], _args[_iptr++]); break;
      case 7: _callback(_args[_iptr++], _args[_iptr++], _args[_iptr++], _args[_iptr++], _args[_iptr++], _args[_iptr++], _args[_iptr++]); break;
       default:
    var _msg = "Too many arguments on RPC call " + _name + " (" + string(array_length(_arguments)) + ") tell me to add more";
  show_error(_msg, false);
  break;
//     
         
 
       
    
     
 
//           

          
      
     
 
    

          
    
     
        }

        
        }
  }
    
  function net_rpc_call(_name, _reliable) {
      _reliable = _reliable ?? true;
       var _args = [];
      if argument_count > 1 {
    for (var i = 1; i < argument_count; i++) {
        array_push(_args, argument[i]);
    }
       }
       
 var _packet = {
type: PACKET_TYPE.RPC_CALL,
      fn: _name,
 
//     
      
//    
// 
    
       
     


         
 
  
         
     
     
    
 
  
//   
       
       
      
         
        
 
          
};
 
  if array_length(_args) > 0 {
      struct_set(_packet, "args", _args);
  }
  
        var _send = _reliable ? net_send_json : net_send_json_udp;
  _send(_packet);
      }
       
        
     
        function net_play_sound(_snd, _reliable) {
    _reliable = _reliable ?? true;
     __net_call_event(net_ev_sound_played, _snd)
  audio_play_sound_ext(_snd)
     var _send = _reliable ? net_send_json : net_send_json_udp;
      _send({
       type: PACKET_TYPE.PLAY_SOUND,
       dat: _snd
    })
 }     
    
     
      #macro net_spwn_all
         
 
       
        
 
 
//         
        
// 
      
    
     
// 
      
//      
//         
         
      
    
          
      
     function net_spawn_basic(_obj, _x, _y, _vars, _layer = "Instances", _reliable = true) {
 var _send = _reliable ? net_send_json : net_send_json_udp;
 _send({
type: PACKET_TYPE.SPAWN_BASIC,
 obj: object_get_name(_obj),
 x: _x,
 y: _y,
     vars: _vars,
  lay: _layer,
      rm: real(room),
     });
 
       var _inst = instance_create_layer(_x, _y, _layer, _obj)
  with (_inst)
        net_creator_id = obj_net.net_id;
     
       return _inst;
       }
     
         
//        
//       
        
          
       
         
  
// 
  
       
   
 
 function __net_spawn_basic_other(_obj, _x, _y, _vars, _layer, _creator, rm) {
       if rm != real(room)
    return;
      
        _obj = asset_get_index(_obj) 
    var _inst = instance_create_layer(_x, _y, _layer, _obj)
  _inst.net_creator_id = obj_net.net_id;
        
   if !instance_exists(_inst)
 {
     __net_log_dev("spawnbasic premature death")
   return;
   }
//          

        
//       
// 
   
  
//    
     
     
       
// 
          
//       
          
         

     

//     
          

        
 var _names = struct_get_names(_vars);
        for (var i = 0; i < array_length(_names); i++) {
      var _name = _names[i];
       
        if _inst == undefined || _name == undefined || _vars[$ _name] == undefined
break
 
variable_instance_set(_inst, _name, _vars[$ _name])
   }
   
 return _inst;
     }
  
 function net_destroy_basic(_inst, _reliable = true)
        {
     var _send = _reliable ? net_send_json : net_send_json_udp;
  _send({
   type: PACKET_TYPE.DESTROY_BASIC,
     i: _inst,
       a: object_get_name(_inst.object_index)
     })
    
          
          
         


//   
          
//  
      
       
    
     
        
      }      
  
  
   
        
  
        

   
       
        
 
      


          
 
        
      
      
       
//         
  
//           
//   
        
   
// 

       




    function __net_steam_prepare_buf(buf, ptype)
  {
           buffer_resize(buf, buffer_get_size(buf) + 1) 
     buffer_seek(buf, buffer_seek_start, buffer_get_size(buf) - 1)
     buffer_write(buf, buffer_u8, ptype) 
        }
     
        function __net_steam_process_buf(buf)
      {
     var ptype = buffer_peek(buf, buffer_get_size(buf) - 1, buffer_u8)
           buffer_resize(buf, buffer_get_size(buf) - 1) 
           return ptype
        }
      

    
         
         
  
    
    
 
         
          
          
   
     
   
       
//         
       
//        
    
  
//      
//           
 
   /* */
        





function net_steamhost_init(_server_endpoint, lobby_type = steam_lobby_type_public)
   {
           __net_log("[STEAM] If this errors, you don't have NetGM2, this is an extension of NetGM2, install the core first.")
         
    instance_destroy(obj_net_steamhost)
       instance_create_depth(0, 0, 99, obj_net_steamhost)
    
     
      steam_net_set_auto_accept_p2p_sessions(false);
            
            __net_log("[STEAM] first boot")
           
           with obj_net_steamhost
            {
        server_endpoint = _server_endpoint
          sockets = ds_map_create()
               users = ds_map_create()
              __net_log("[STEAM] created sockets")
        lobby = steam_lobby_create(lobby_type, 300)
              steam_lobby_set_type(lobby_type)
            steam_lobby_set_joinable(true)
         


         
//      
      
  
   
             steam_lobby_set_data("LobbyName", "NetGM2 Steam Lobby");
             lb_type = lobby_type
     
                if lobby == ""
          {
                repeat 20 __net_log("[STEAM] ERROR! failed to create lobby.")
                instance_destroy()
                   return;
       
              }
          
    
 
      

 
         
        
          
         
          
//        
//     
       
    
         
     
   
   
 
      

//        
          
  

//       
  
        steam_lobby_activate_invite_overlay()
   
             __net_log("[STEAM] done setting up steam and making a lobby")
    }
   }
     
function __net_steamhost_step()
{
          while steam_net_packet_receive()
     {
             var packet = 
            {
                    size: steam_net_packet_get_size(),
                sender: steam_net_packet_get_sender_id(),
               data: undefined,
        }
        packet.data = buffer_create(packet.size, buffer_fixed, 1)
            steam_net_packet_get_data(packet.data)
         buffer_seek(packet.data, buffer_seek_start, 0)
            
            var ptype = __net_steam_process_buf(packet.data)
             
             __net_log_verbose("[STEAM] [GOT] Got packet from client where ptype is " + string(ptype))
   
 var socks = sockets[? packet.sender]
  
             switch ptype
         {

        
     
         
      
      
          
  
       
  
          
 
   
      
        
       
        
   
 
   
  

   
             case steam_net_packet_type_reliable: 
                     
                  network_send_raw(socks.tcp, packet.data, buffer_get_size(packet.data))
                    break
                  case steam_net_packet_type_unreliable: 
                
                        network_send_udp_raw(socks.udp, server_endpoint.ip, server_endpoint.port + 2, packet.data, buffer_get_size(packet.data))
                     break
      default:
     __net_log_verbose("[STEAM] [GOT] [FAIL] Unknown ptype " + string(ptype))
  break;
           }
        }
       }
        
      function __net_steamhost_steam_async()
    {
  static s_port = 25589
    if async_load[? "event_type"] == "lobby_created"
      {
            steam_lobby_set_type(lb_type)
            steam_lobby_set_joinable(true)
               __net_log("[STEAM] lobby id is " + string(steam_lobby_get_lobby_id()))
     
//          
 
 
   
        
      

         
  
       
   
         
//  
        
       
   
     
//       
        
 
          
   
       
    
         
 
   
     
  
               steam_lobby_set_data("LobbyName", "NetGM2 Steam Lobby");
      }
            if async_load[? "event_type"] == "lobby_chat_update"
     {
          var _identity = async_load[? "user_id"]
          __net_log("[STEAM] handling update request from " + string(_identity))
                var flags = async_load[? "change_flags"]
          
               if (flags == 2)
                {
                    var sock = sockets[? _identity]
                ds_map_delete(sockets, _identity)
                 ds_map_delete(users, sock.tcp)
                 ds_map_delete(users, sock.udp)
        network_destroy(sock.tcp)
     network_destroy(sock.udp)

                   __net_log("[STEAM] user disconnected & free'd")
                   return;
           }
             
                if (flags != 1)
         {
             __net_log("[STEAM] unhandled steam lobby_chat_update flag!")
                  return;
             }
            
          __net_log("[STEAM] user connecting")
       
        steam_net_accept_p2p_session(_identity)
  
   if ds_map_exists(sockets, _identity)
        
 

// 
//     
   
        
    
    
  
         
         
         
         

         
         
{
   __net_log("[STEAM] dupe connect (keeping same sockets)")
return;
  }

           var _sock = network_create_socket_ext(network_socket_tcp, s_port)
                var _sock_udp = network_create_socket_ext(network_socket_udp, s_port + 1)
   s_port += 3
     
          sockets[? _identity] = 
              {
                   tcp: _sock,
              udp: _sock_udp,
          }
        users[? _sock] = _identity 
    
   
         
          
       
     
          users[? _sock_udp] = _identity 
              
                network_set_config(network_config_use_non_blocking_socket, true)
              
         network_connect_raw(_sock, server_endpoint.ip, server_endpoint.port)
              __net_log("[STEAM] created & connected socket for user")
//           
   
  
//    
          
   
 


       
        
        }
      }
    
    function __net_steamhost_network_async()
    {
          var type = async_load[? "type"]
 
        var receiving_sock = async_load[? "id"];
         var buf = async_load[? "buffer"]
        
      switch (type) {
         
     
  
//           
        
          
   
// 
 
    
//      
//      

       

  
       
//        
   
          
   
      

     
//         
         
        

//  
                case network_type_non_blocking_connect:
                if !async_load[? "succeeded"]
                  {
                      repeat 20 __net_log("[STEAM] ERROR! Failed to connect to server endpoint!")
                    }
              break
        case network_type_data:
                var target_user = users[? receiving_sock]
      
      if target_user == undefined
               break
      
   var socks = target_user == undefined ? undefined : sockets[? target_user]

if socks == undefined
   break
  
        var _usock = socks.udp;
             var _tsock = socks.tcp;
       
       if receiving_sock != _tsock && receiving_sock != _usock
     {
       __net_log_dev("untraced message")
break;
}
       
           var is_udp = receiving_sock == _usock
              
            var ptype = is_udp ? steam_net_packet_type_unreliable : steam_net_packet_type_reliable
 

          

     
   
         
    
          __net_steam_prepare_buf(buf, ptype)
                steam_net_packet_set_type(ptype)
           
              __net_log_verbose("[STEAM] [SEND] Sending server packet to client " + string(ptype))
               
          
            
             steam_net_packet_send(target_user, buf, buffer_get_size(buf))
        
     
     
        
  
 
         
  
//   
//       
         
     
        
//  
  
              break;
            }
        }
       
       function __net_steamhost_destroy()
{
           __net_log("[STEAM] destroy()")
         var size = ds_map_size(sockets)
     var key = ds_map_find_first(sockets)
         for (var i = 0; i < size; i++)
          {
        __net_log("[STEAM] cleanup socket for " + string(key))
           network_destroy(sockets[? key].tcp)
              network_destroy(sockets[? key].udp)
               key = ds_map_find_next(sockets, key)
 
        
       
   
        
      
     
      
 
//     
      
 
     
     
          
  
      
      
//       
       
        }
      
          steam_lobby_activate_invite_overlay()
      steam_lobby_set_type(steam_lobby_type_private)
          
         ds_map_destroy(sockets)
     ds_map_destroy(users)
       
            network_destroy(udp_socket)
    __net_log("[STEAM] cleanup finished")
      }
/* */
 
      




      function net_steamclient_init(lobby_id, tunnel_port)
       {
     instance_destroy(obj_net_steamclient)
         instance_create_depth(0, 0, 99, obj_net_steamclient)
        with obj_net_steamclient
      {
 
          
//      
         __net_log("[STEAMCLIENT] initialized")
                lobby = steam_lobby_join_id(lobby_id)
              
         
         
     
    
        
      
          

   
//  
        
//    
     
        
      
  
//          
     
        


 
     
       
//         
         
    
         
    

              cached_packets = []
           cached_early_tcp = []
        
           
               tunnel = network_create_server_raw(network_socket_tcp, tunnel_port, 2)
                tunnel_udp = network_create_socket_ext(network_socket_udp, tunnel_port + 2)
            tun_port = tunnel_port
           }
     
    net_add_event_listener(net_ev_packet, __net_steamclient_onpacket_send)
 }
  
function __net_steamclient_step()
   {
         if array_length(cached_packets) > 0 && lobby != undefined
      {
        __net_log_dev("[STEAMCLIENT] dumped cached packet")
              var _cached = array_pop(cached_packets)
               var buf = _cached[0]
              var ptype = _cached[1]
               __net_steam_prepare_buf(buf, ptype)
               steam_net_packet_set_type(ptype)
             steam_net_packet_send(steam_lobby_get_owner_id(), buf, buffer_get_size(buf))
        buffer_delete(buf)
         }
          
      if array_length(cached_early_tcp) > 0 && target_tcp != undefined
           {
            __net_log_dev("[STEAMCLIENT] dumped cached [EARLY TCP] packet")
          var _cached = array_pop(cached_early_tcp)
 
     
       
      
         
        
   
       
  
        
      
      
          
     
//  
//      
      
               network_send_raw(target_tcp, _cached, buffer_get_size(_cached))
             buffer_delete(_cached)
     }
          
     while steam_net_packet_receive()
        {
              var packet = 
              {
              size: steam_net_packet_get_size(),
                  sender: steam_net_packet_get_sender_id(),
            data: undefined,
           }
           packet.data = buffer_create(packet.size, buffer_fixed, 1)
         steam_net_packet_get_data(packet.data)
         buffer_seek(packet.data, buffer_seek_start, 0)
         
              var ptype = __net_steam_process_buf(packet.data)
  
          
          
         
        
         
            
              
                if packet.sender != steam_lobby_get_owner_id()
             {
//        
          
       
      
     
          
 
   
//  
    
    

       
  
 
  
         
   
          
      
     
       
   
        
//       
        
  
              __net_log("[STEAMCLIENT] hey! laugh at " + string(steam_lobby_get_owner_id()) + ", they're hacking lol")
                 continue
               }
              
             
                
              __net_log_verbose("[STEAMCLIENT] [GOT] Sending server packet to client")
       trace(buffer_prettyprint(packet.data))
            
            switch ptype
              {
               case steam_net_packet_type_reliable: 
                    if target_tcp == undefined || lobby == undefined || !obj_net_steamclient.active
                {
                          var b = buffer_create(packet.size, buffer_fixed, 1)
                          buffer_copy(packet.data, 0, packet.size, b, 0)
                           array_push(cached_early_tcp, b)
                        break
                     }
               
                network_send_raw(target_tcp, packet.data, buffer_get_size(packet.data))
                  break
                 case steam_net_packet_type_unreliable: 
                if client_port_udp == 0
                 {
                     __net_log_dev("[STEAMCLIENT] we have not yet figured out the client's udp port, we cannot relay packets")
                         return;
 
        
//      
        
    
    
                        }
                   network_send_udp_raw(tunnel_udp, "127.0.0.1", client_port_udp, packet.data, buffer_get_size(packet.data))
                       break
   default:
  __net_log_verbose("[STEAM] [GOT] [FAIL] Unknown ptype " + string(ptype))
       break;
      
//     
         
         
    
    
 
//          
 
        
       
          }
       }
       }

   function __net_steamclient_steam_async()
     {
       var type = async_load[? "event_type"]
       if (type == "lobby_joined")
         {
                var lobby_id = async_load[? "lobby_id"]
             var success = async_load[? "success"]
      
          
   
// 
  
          
//      
  
          
         
  
//           
     
//       
     
     
              var result = async_load[? "result"]
                if !success
         {
              __net_log("[STEAMCLIENT] failed to join lobby!")
        net_disconnect()
                return;
                }
            
              __net_log("[STEAMCLIENT] joined lobby! status = " + string(success) + " with result = " + string(result) + " for lobby_id = " + string(lobby_id))
          __net_log("[STEAMCLIENT] with name = " + string(steam_lobby_get_data("LobbyName")))
        __net_log("[STEAMCLIENT] with owner_id = " + string(steam_lobby_get_owner_id()))
             with obj_net_steamclient
               {
                   lobby = lobby_id
       alarm[0] = 60
         }
//  
   
     
     
  
          
 
    

   

//       
//   
          
        

          
          
 
  
  
 
    
            }
        }
     
   function __net_steamclient_onpacket_send(data, is_udp)
   {
        var buf = buffer_create(string_length(data), buffer_fixed, 1)
       buffer_seek(buf, buffer_seek_start, 0)
   buffer_write(buf, buffer_text, data)
   
    var ptype = is_udp ? steam_net_packet_type_unreliable : steam_net_packet_type_reliable
 
        if obj_net_steamclient.lobby == undefined
     {
  __net_log_verbose("[STEAMCLIENT] cached packet due to not having fully joined the lobby yet")
    var nbuf = buffer_create(buffer_get_size(buf), buffer_fixed, 1)
      buffer_copy(buf, 0, buffer_get_size(buf), nbuf, 0)
    array_push(obj_net_steamclient.cached_packets, [nbuf, ptype])
  buffer_delete(buf)
     return;
       }
     
     __net_steam_prepare_buf(buf, ptype)
 steam_net_packet_set_type(ptype)
  
     
   
      
//          
      
     
      
      

//  
      steam_net_packet_send(steam_lobby_get_owner_id(), buf, buffer_get_size(buf))
       buffer_delete(buf)
    }
   
      function __net_steamclient_network_async()
 {
    var type = async_load[? "type"]

           var sock_id = async_load[? "id"];
          var buf = async_load[? "buffer"]
          
//      
//          
          
        
         
     
         
       
// 
  
         
//    
       
  
        
       
        
       var is_udp = sock_id == tunnel_udp
          
           switch type
      {
          case network_type_data:
                    if client_port_udp == 0 && is_udp
              {
                   client_port_udp = async_load[? "port"]
                        __net_log("[STEAMCLIENT] figured out client's udp port = " + string(client_port_udp))
                   }
               if target_tcp == undefined && !is_udp
            {
                       target_tcp = sock_id;
                   __net_log("[STEAMCLIENT] figured out client's tcp socket")
            }
                   break;
      }
 
     
     
     
     
       
          

//           
       
      
 
  
  
   

     
     
        
   
//        
  }
       
    function __net_steamclient_destroy()
      {
         steam_lobby_leave()
     network_destroy(tunnel)
        network_destroy(tunnel_udp)
        }
     /* */    
     
  
 
   function net_stream_register(_id) {
      net_send_json({
  type: PACKET_TYPE.STREAM_REGISTER,
     id: _id
 })
}
  
function net_stream_destroy(_id) {
//         
        
         
        
        

//  
       net_send_json({
  type: PACKET_TYPE.STREAM_DESTROY,
id: _id
       })
}
    
    function net_stream_data(_id, _buffer, _reliable = true) {
//    
//     
//       
      
   
          

  
       
//      
//     
//       
         
     
    
    
        
          
//  
      
    

         
 
//      
     
          
  net_send_json_ext({
      type: PACKET_TYPE.STREAM_DATA,
   dat: buffer_base64_encode(_buffer, 0, buffer_get_size(_buffer)),
       id: _id
        }, _reliable);
     }
       
     function net_stream_get_index(_oid, _id) {
       for (var i = 0; i < array_length(obj_net.streams); i++) {
   var _stream = obj_net.streams[i];
       
    if _stream.oid == _oid && _stream.nid == _id
     return i;
}
  
  return noone;
        }
      
     function net_stream_get(_oid, _id) {
        var _ind = net_stream_get_index(_oid, _id)
 if _ind == noone return _ind;
    
   return obj_net.streams[_ind];
 }

        function NetStream(_oid, _id) constructor {
self.oid = _oid
         
      
      
          
//     
        

        self.nid = _id
      self.data_callback = noone
 
        function SetListener(_listener) {
      self.data_callback = _listener
      net_send_json({
        type: PACKET_TYPE.STREAM_LISTEN,
      

        
 
 
//   
//         
//   
      
  
//      
  
  
     
          

      
          
      
       
       
      
//      
//       
      
    
 
    

     
oid: self.oid,
nid: self.nid
})
      }
     
 function ResetListener() {
       self.data_callback = noone
       net_send_json({
 type: PACKET_TYPE.STREAM_STOP_LISTEN,
        oid: self.oid,
   nid: self.nid
     })
    }

      function __AppendData(_data) {
       if self.data_callback == noone return;

        self.data_callback(self, _data);
   }
     } 

       
      
 enum NET_SYNC_OWNER {
NOONE,
    SERVER,
     PLAYER
     }
 
  
   
  
// 
//  


   
//       
//  
        
         
 

   
         
          
    
        function NetSync(_id, _obj, _room) constructor 
     {
        self.nid = _id
        self.obj = _obj
  self.current_room = _room
    self.is_queued = false;
      self.inst = noone;
  
    self.vars = ds_map_create()
   self.past_var_syncs = ds_map_create()
   
    function __InstUpdateNetId() {
   with (self.inst) {
     net_id = other.nid
  }
  var _vars = ds_map_keys_to_array(self.vars)
  for (var i = 0; i < array_length(_vars); i++) {
      var _var = _vars[i];
      
//       
//    
//    
// 
     
  
          
          
//          
    
 
      
          
       
        
// 
         
  
    
variable_instance_set(self.inst, _var, self.vars[? _var])
   }
    }

function Create() {
     self.inst = instance_create_depth(0, 0, 0, asset_get_index(self.obj))
__InstUpdateNetId()
 }
  
 self.owner = NET_SYNC_OWNER.NOONE
 self.owner_id = -1;
    self.last_update = 0
   self.on_signal = function(_x, _y) {}
    
        __net_log_dev("New NetSync made")
  
        function Assign(_owner, _oid) {
      self.owner = _owner
        self.owner_id = _oid
      return self;
     
//    
//      
          
  }
  
       function __VarSet(_var, _val) {
   if instance_exists(self.inst)
          
   
 
 
    
     
   
  
         
       
         
   
//     
     
          
//  
      
    
//          
        
     
      
    
     
      

     

     
  variable_instance_set(self.inst, _var, _val)
       self.vars[? _var] = _val
       self.last_update = 0
  return self;
        }
 
function Destroy() {
       instance_destroy(self.inst)
     ds_map_delete(obj_net.synced_objs, self.nid)
      ds_map_destroy(self.vars)
   }
    
function __CallSignalExternal(_from, _data) {
      __net_log_verbose("Got signal from pid=" + string(_from))
     self.on_signal(_from, _data)
      }
}
        
    function net_sync_create(_obj) {
       net_send_json({
        type: PACKET_TYPE.SYNC_CREATE,
    obj: _obj,
      croom: real(room)
      })
       }
        
   
function net_sync_create_instant(_obj) {
       if obj_net.net_id == noone {
  
//     
      
      
       
//   
      
        
         
  
     
      __net_log("You're running net_sync_create_instant too early! Wait for it to connect at least!")
 return;
   }
      
var _tag = irandom(c_white);
        net_send_json({
        type: PACKET_TYPE.SYNC_CREATE,
       obj: _obj,
        croom: real(room),
tag: _tag
 })
  
//   
     
//  
     
          
     
   
 
    
          
          
         
   
//           
          
//        
          
       
    
      var _sobj = new NetSync(_tag, _obj, room).Assign(NET_SYNC_OWNER.PLAYER, obj_net.net_id);
     _sobj.is_queued = true;
 _sobj.Create();
     ds_map_add(obj_net.synced_objs, _tag, _sobj);
       }
 
        
      function net_sync_vars(_nid, _vars, _reliable) {
       if !ds_map_exists(obj_net.synced_objs, _nid)
   {
       __net_log("Not syncing something that doesn't exist: net_sync_sync_vars")
return;
      }
        
var _sobj = obj_net.synced_objs[? _nid];
 
    if _sobj.is_queued
     return; 
     
    
  
     var _queued_deletions = []
   
       
    
//    

          
    
       
  
 
   
//        
       
   
      
  for (var i = 0; i < array_length(_vars); i++) {
       var _var = _vars[i];
        
     if ds_map_exists(_sobj.past_var_syncs, _var.n) {
       var _svar = _sobj.past_var_syncs[? _var.n];

       if _svar == _var.v {
 
      array_push(_queued_deletions, i)
       }
 
// 
 
      
    
         
        else {
 _sobj.past_var_syncs[? _var.n] = _var.v;
 }
 }

   
//       
       
//           
     
      
          
 
          
// 
  
      
//        
       else {
    _sobj.past_var_syncs[? _var.n] = _var.v;
  }
      }
    
     for (var i = 0; i < array_length(_queued_deletions); i++) {
   _vars[_queued_deletions[i]] = "kill";
        }
  
        repeat 2 for (var i = 0; i < array_length(_vars); i++) {
   if _vars[i] == "kill"
   {
  array_delete(_vars, i, 1);

      
    
      
         
     
         
       
i = 0;
    }
        }

array_push(_vars, {
      n: "__net_crm",
   v: instance_exists(_sobj.inst) ? real(room) : noone,
        });
 
        
     
//        
       
       
         
        
  
       
    
  
        
          
// 
 
    
     
    var _opti_vars = {};
     for (var i = 0; i < array_length(_vars); i++) {
     var _vr = _vars[i];
     _opti_vars[$ _vr.n] = _vr.v;
    }
 
var _send = _reliable ? net_send_json : net_send_json_udp;
     _send({ 
   type: PACKET_TYPE.SYNC_UPDATE, 
    nid: _nid, vars: _opti_vars 
      });
  }

    
//    
    function net_sync_vars_simple(_nid, _vars, _reliable) 
        
       
      
       
     
    
   
      
       
  
      
//    
  
      
      {
  _reliable = _reliable ?? true;
       if !ds_map_exists(obj_net.synced_objs, _nid)
 {
      __net_log("Not syncing something that doesn't exist: net_sync_instance")
   return;
     }
  
 var _vars_s = [];
        for (var i = 0; i < array_length(_vars); i++) 
    {
      var _sobj_inst = obj_net.synced_objs[? _nid].inst;
        var _vname = _vars[i]
       var _val = variable_instance_get(_sobj_inst, _vars[i])
  
    
    
 
     
//          
// 
    
       
     
          
         
//   
         
 
          
    
          
          
//       
          
//   
     
  
 
   

   array_push(_vars_s, 
      { 
  n: _vname, 
v: _val
       });
   }
        net_sync_vars(_nid, _vars_s, _reliable)
        }
     
       function net_sync_destroy(_nid) {
   net_send_json({
type: PACKET_TYPE.SYNC_DESTROY,
        nid: _nid,
 })
       }
   
     function net_owns_sync_ext(_nid, _oid) {
       if ds_map_find_value(obj_net.synced_objs, _nid) == undefined
 return false;
   var _me = obj_net.synced_objs[? _nid]
     return _me.owner_id == _oid && _me.owner == NET_SYNC_OWNER.PLAYER;
      }
     
       function net_owns_sync(_nid) {
       return net_owns_sync_ext(_nid, net_get_id());
      
      
   
       
//    
   
  
 
        
         

//   
//    
   }

 function net_sync_owner(_nid) {
       if ds_map_find_value(obj_net.synced_objs, _nid) == undefined
  return noone;
       var _me = obj_net.synced_objs[? _nid]
   var _pidx = net_player_find_idx_by_id(_me.owner_id)
       if _pidx == noone return noone;
      var _player = obj_net.players[_pidx]
     
   return _player;
    }
   
  
 
      
         
//     
     

        
        
    
  
//  
     
       
        
        
//   
//  
         
  function net_sync_objs_of(_pid) {
       var _nids = ds_map_keys_to_array(obj_net.synced_objs);
    var _objs_of = [];

  for (var i = 0; i < array_length(_nids); i++) {
  var _nid = _nids[i];
       var _sobj = obj_net.synced_objs[? _nid];
 var _owner = net_sync_owner(_sobj.nid);
    if _owner == noone continue;
       if net_owns_sync_ext(_sobj.nid, _pid) {
     array_push(_objs_of, _sobj);
      }
}

return _objs_of;
  }
    
 function net_sync_get(_nid) {
if !instance_exists(obj_net)

     
  

       
 
//           
        
    
         
//       

       
  return noone;
      
if !ds_map_exists(obj_net.synced_objs, _nid)
   return noone;
  
  return obj_net.synced_objs[? _nid];
    }
   
       function net_sync_send_signal_from(_nid, _data, _reliable) {
  if net_owns_sync(_nid)
 return false;
    
    net_send_json_ext({
//  
     
//  
      
     
         

//   
        
          
  
          
   
 
          
     
   

   
   

     
       

      
          
    type: PACKET_TYPE.SYNC_SIGNAL,
  nid: _nid,
  dat: _data
    }, _reliable)
      
   return true;
       }
  
   function net_sync_set_signal_handler(_nid, _handler) {
     if !net_owns_sync(_nid)
   return false;
      
var _sobj = obj_net.synced_objs[? _nid];
_sobj.on_signal = _handler;

  __net_log_verbose("[Signal] Attached signal to nid=" + string(_nid))
 }
  
  function net_sync_transfer(_owner, _oid, _net_id)
      {
        if !net_owns_sync(_net_id)
      return false;
   
  net_send_json({
  type: PACKET_TYPE.SYNC_TRANSFER,
     typ: _owner,

     
     
          
     
        
       
 

         
//      
    
          
//           
         
       
     oid: _oid,
       nid: _net_id,
   })
 }     
   
       #macro str_at string_char_at
  #macro buff_sz buffer_get_size
     #macro is_connected os_is_network_connected()
      
     
  
   function buffer_prettyprint(_buf, _per_row = 20) {
      static _out = buffer_create(16, buffer_grow, 1);
          static _chars = buffer_create(16, buffer_grow, 1);
            buffer_seek(_out, buffer_seek_start, 0);
   
  
//     
    
//   
    buffer_seek(_chars, buffer_seek_start, 0);
           var _size = buffer_get_size(_buf);
      var _tell = buffer_tell(_buf);
      
     
      
          
          
   
    
      
   

       
         

        
     
         
        
   
          

 
  

//      
 
         
       
//  
        
          buffer_write(_out, buffer_text, "buffer(size: ");
           buffer_write(_out, buffer_text, string(_size));
           buffer_write(_out, buffer_text, ", tell: ");
        buffer_write(_out, buffer_text, string(_tell));
         buffer_write(_out, buffer_text, ", type: ");
        switch (buffer_get_type(_buf)) {
          case buffer_fixed:   buffer_write(_out, buffer_text, "buffer_fixed"  ); break;
            case buffer_grow:    buffer_write(_out, buffer_text, "buffer_grow"   ); break;
           case buffer_fast:    buffer_write(_out, buffer_text, "buffer_fast"   ); break;
             case buffer_wrap:    buffer_write(_out, buffer_text, "buffer_wrap"   ); break;
         case buffer_vbuffer: buffer_write(_out, buffer_text, "buffer_vbuffer"); break;
          default: buffer_write(_out, buffer_text, string(buffer_get_type(_buf))); break;
    }
        buffer_write(_out, buffer_text, "):");
         
      for (var i = 0; i < _size; i++) {
          if (i % _per_row == 0) { 
                 if (i > 0) { 
                        buffer_write(_out, buffer_text, " | ");
                  buffer_write(_chars, buffer_u8, 0);
                    buffer_seek(_chars, buffer_seek_start, 0);
                      buffer_write(_out, buffer_text, buffer_read(_chars, buffer_string));
                     buffer_seek(_chars, buffer_seek_start, 0);
                  }
               
               buffer_write(_out, buffer_u8, ord("\n"));
                   buffer_write(_out, buffer_text, string_format(i, 6, 0));
 

    
  
//        
         
 
               buffer_write(_out, buffer_text, " |");
         }
          buffer_write(_out, buffer_u8, i == _tell ? ord(">") : ord(" "));
          var _byte = buffer_peek(_buf, i, buffer_u8);
             
           
               if (_byte >= 32 && _byte < 128) {

// 

     
  
          
         
        

                  buffer_write(_chars, buffer_u8, _byte);
        } else {
                    buffer_write(_chars, buffer_text, "·");
             }
               
            
        var _hex = _byte >> 4;
                buffer_write(_out, buffer_u8, _hex >= 10 ? ord("A") - 10 + _hex : ord("0") + _hex);
           _hex = _byte & 15;
        
   
      
         
//   
       


      
//     
   

   
         buffer_write(_out, buffer_u8, _hex >= 10 ? ord("A") - 10 + _hex : ord("0") + _hex);
        }
         
            
      if (_size % _per_row != 0) {
               repeat (_per_row - (_size % _per_row)) {
                  buffer_write(_out, buffer_text, "   ");
              }
          }
         buffer_write(_out, buffer_text, " | ");
        buffer_write(_chars, buffer_u8, 0);
       buffer_seek(_chars, buffer_seek_start, 0);
        buffer_write(_out, buffer_text, buffer_read(_chars, buffer_string));
 
    
    
       

    

   
        
    
    
          buffer_write(_out, buffer_u8, 0);
          buffer_seek(_out, buffer_seek_start, 0);
          return buffer_read(_out, buffer_text);
 }
      
       function net_buffer_copy(_buf) {
var _nbuf = buffer_create(buff_sz(_buf), buffer_fixed, 1)
        buffer_seek(_nbuf, buffer_seek_start, 0)
    buffer_copy(_buf, 0, buff_sz(_buf), _nbuf, 0)
   return _nbuf;
   
}
          

  
      
//           
    
     
//           


 

      
       
//          
          
      
    
     function net_val_or_def(_struct, _name, _default) {
if struct_exists(_struct, _name) return struct_get(_struct, _name);
     
        return _default;
   }
   
 




   function net_minmax_arrs(_arr1, _arr2) {
 if array_length(_arr1) > array_length(_arr2) {
       return [_arr1, _arr2];
    }
        
  return [_arr2, _arr1];
  }
     
    
   
 
//   
// 
          
       
 
      
      
        
//          
   
function net_minmax_strs(_str1, _str2) {
       if string_length(_str1) > string_length(_str2) {
       return [_str1, _str2];
     }

return [_str2, _str1];
  }
        
  function net_array_merge(_a, _b) {
 
     }

function net_array_contains(_a, _b) {
//         
          
  
//        
        
//      
 for (var i = 0; i < array_length(_a); i++) {
       if is_struct(_a[i]) && is_struct(_b) {
 var _sa = json_stringify(_a[i]);
       var _sb = json_stringify(_b);
if _sa == _sb
       {
       
//      
          
       
   
        
 
      
          
  
 
  
      
          
    
//         
      
         
 
        
     
//         
     
//          
       return true;
  }
     }
   else {
        
      if _a[i] == _b
     return true;
 }
     }
    
     return false;
      }
      
      function net_array_except(_a, _b) {
 
       
   
     
        var _c = [];
  for (var i = 0; i < array_length(_a); i ++) {
if !net_array_contains(_b, _a[i])
     array_push(_c, _a[i])
 }
  
        
        
         
      
          
    
//       
        
         

          
   
//      
//    
          
       
          
     
         

         
       
        
//        
//        
         
 
        
   
//           
    return _c;
 }
      /* */
      
      




       function net_struct_copy(_a) {
   var _replica = {};
    var _names = struct_get_names(_a);
       
 for (var i = 0; i < array_length(_names); i++) {
       var _name = _names[i];
    var _value = _a[$ _name]
   if is_struct(_value) _replica[$ _name] = net_struct_copy(_value)
else _replica[$ _name] = _value
      }
     
 return _replica;
  }
  
     function net_struct_merge(_a, _b) {
        var _names_a = struct_get_names(_a)
      var _names_b = struct_get_names(_b)
 var _merged = {};
        
   for (var i = 0; i < array_length(_names_a); i++) {
 var _key = _names_a[i];
 var _val = _a[$ _key];
 var _val_b = _b[$ _key];
 
   if is_struct(_val) && is_struct(_val_b) {
//         
 
   
    
       

     
  
//       
   
 
   
    
    _merged[$ _key] = net_struct_merge(_val, _val_b)
        }
  else _merged[$ _key] = _val
        }
 
for (var i = 0; i < array_length(_names_b); i++) {
       var _key = _names_b[i];
       var _val = _b[$ _key];
    var _val_a = _a[$ _key];
      
     if is_struct(_val) && is_struct(_val_a) {
 _merged[$ _key] = net_struct_merge(_val, _val_a)
}
 
   
 
    
  
      
//       
 else _merged[$ _key] = _val
    }

       return _merged;
}
/* */
       
 
 
//  
     
   
      
 
          
     
//          
      




 function net_arr_diff_no_bidirectional(_a, _b) {
    var _pa = [];
     array_copy(_pa, 0, _a, 0, array_length(_a))
 
      
 
      var _diff = [];
        
for (var i = 0; i < array_length(_a); i++) {
//     
//         

      
     
       
    
         
//  
       
//          
        if !array_contains(_b, _a[i]) {
    
 array_push(_diff, { v: _a[i], __net_attr: "-" })
  }
      }

      for (var i = 0; i < array_length(_b); i++) {
if !array_contains(_a, _b[i]) array_push(_diff, _b[i])
       }

     return _diff;
      
 
       }
       /* */
      
       
      
//     
//    
    
        
      
        
//       
      
          
 
     
     
     
       
    
  
 
 

       




       function net_struct_diff(_old, _new) {
        var _diff = {};
 var _names_new = struct_get_names(_new);
  for (var i = 0; i < array_length(_names_new); i++) {
       var _name = _names_new[i];
var _nv = _new[$ _name]
var _ov = _old[$ _name]
      
        
 if is_struct(_new[$ _name]) && is_struct(_ov) {
    _diff[$ _name] = net_struct_diff(_old[$ _name] ?? {}, _new[$ _name])
      }
else if is_array(_nv) && is_array(_ov) {
       _diff[$ _name] = net_arr_diff_no_bidirectional(_ov, _nv)
}
    else if !is_array(_ov) && is_array(_nv) {
     _diff[$ _name] = { v: _nv, __net_attr: "!" }
       }
     else if _nv != _ov {

          
   
//         
  
      
//   
       
//       
    
   
     
      
          
 
      
        
 
        
     
     _diff[$ _name] = _new[$ _name];
     }
      }
   
  var _removed_names = net_arr_diff_no_bidirectional(struct_get_names(_old ?? {}), _names_new)
  for (var i = 0; i < array_length(_removed_names); i++) {
var _nm = _removed_names[i];
if is_struct(_nm) _nm = _nm.v;
 if !struct_exists(_diff, _nm) _diff[$ _nm + "net_attr_D"] = 0x0;
   }
    
     return _diff;
}
  
     function net_struct_apply_diff(_old, _diff) {
  var _dnames = struct_get_names(_diff);

   for (var i = 0; i < array_length(_dnames); i++) {
var _dname = _dnames[i];
      var _attr_pos = string_pos("net_attr_", _dname)
          
  
        
if _attr_pos != 0 {
       
        
      
         
    
       
        var _attr_head = _attr_pos + string_length("net_attr_")
       var _attr_type = str_at(_dname, _attr_head)
    if _attr_type == "D" {
      struct_remove(_old, string_replace(_dname, "net_attr_D", ""))
        }
     continue;
    
 }
//  
        
// 
    
    
       
  
     
          
       
   
      
          
     
//        

       
      

//       
       
        
          
          
     
       
var _value = _diff[$ _dname]
var _ovalue = _old[$ _dname]
  
       if is_struct(_value) {
       
        var _is_attr = struct_exists(_value, "__net_attr")
    if _is_attr {
        var _type = _value.__net_attr;
      if _type == "!" {
_old[$ _dname] = _value.v; 
     }
     }
 else {
    
    if is_struct(_ovalue) {
 var _nv = net_struct_apply_diff(net_struct_copy(_ovalue), net_struct_copy(_value))
      _old[$ _dname] = _nv
     }
       else {
_old[$ _dname] = _value; 
        }
  }

        

//         
         
         
  continue;
     }
        
 
   if is_array(_value) && is_array(_ovalue) {
    for (var j = 0; j < array_length(_value); j++) {
          
   
   
    
    
   
  
      
        
//  
      
   
      
         

        
 
       
       
  
   var _item = _value[j];
  
   if is_struct(_item) {
       
        var _is_attr = struct_exists(_item, "__net_attr")
     if _is_attr {
    var _type = _item.__net_attr;
      var _v = _item.v;
   if _type == "-" {
       array_delete(_old[$ _dname], array_find_index(_ovalue,
  method({ _v: _v }, function(_x) {
   return _v == _x;
    })),
    1);
   }
       }
 else array_push(_old[$ _dname], _item);
}
     else {
  array_push(_old[$ _dname], _item); 

   
     
     
//           

   
//       
        
       
          
        
       
 
        
// 
      
      
//         
    
     
     }
 }
 continue;
 }
        
    

        _old[$ _dname] = _value;
   }
   
return _old; 
        }
        /* */
   





      function net_str_mod_chr(_str, _pos, _chr) {
 return string_copy(_str, 1, _pos) + _chr + string_copy(_str, _pos + 2, string_length(_str))
 }
 
function net_str_diff_to_str(_diffs) {
  var _str = "";
 
          
      
       
          
      
       for (var i = 0; i < array_length(_diffs); i++) {
     var _diff = _diffs[i];
   var _ch = _diff.ch;
var _pos = _diff.pos;
 switch _diff.type {
 case "mod":
         
          
    
        
//      
  
  
       
     
          
          
//          
    
         
   
  
     
  
       
    
    _str += "." + string(_pos) + "," + _ch;
        break;
       case "add":
  _str += "+" + string(_pos) + "," + _ch;
        break;
    case "rm":
       _str += "-" + string(_pos) + "," + string(string_length(_ch)); 
        break;
        }
      }
       
return _str;
  }
   
    function net_str_diff_to_diff(_str) {
     var i = 0;
      var _diff = [];
    var _typemap = ds_map_create()
  ds_map_add(_typemap, "+", "add")
    ds_map_add(_typemap, "-", "rm")
   
 
    
        
        
        

  
    
       ds_map_add(_typemap, ".", "mod")
   while (i < string_length(_str)) {
      var _type = str_at(_str, i + 1);
i++;
       var _pos_str = "";
   
while string_digits(str_at(_str, i + 1)) == str_at(_str, i + 1) {
_pos_str += str_at(_str, i + 1)
       i++;
//         
    
     
         

     
          
       
     
          
//          
  
         
    

    
         
//    
        
        
       

//           
//         
        
}
   
   var _pos = real(_pos_str);
  var _ch = "";
    
        i++; 

 
    while str_at(_str, i + 1) != "." && str_at(_str, i + 1) != "+" && str_at(_str, i + 1) != "-" && i < string_length(_str) {
     _ch += str_at(_str, i + 1)
  i++;
   }
  
   

    array_push(_diff, {
 type: _typemap[? _type],
       ch: _ch,
 pos: _pos
   });
 }
   
   return _diff;
}
     /* */
    
     
        
    
         
        
      
    

 function uuid_generate() {
          var d = current_time + epoch() * 10000, uuid = array_create(32), i = 0, r;
        
          
//        
    
    
      
   
   
        
     
       
//         
//         
         
    
    for (i=0;i<array_length_1d(uuid);++i) {
           r = floor((d + random(1) * 16)) mod 16;
           
          if (i == 16)
             uuid[i] = dec_to_hex(r & $3|$8);
        else
                   uuid[i] = dec_to_hex(r);
    }
            
       uuid[12] = "4";
            
        return uuid_array_implode(uuid);
   }
 
        
          
//           

     
   
         
      
       
        function uuid_array_implode() {
            var s = "", i=0, sl = array_length_1d(argument0), a = argument0, sep = "-";
        
            repeat 8 s += a[i++];
       s += sep;
            
    repeat 4 s += a[i++];
      s += sep;
  
       
    
     
       
          
//         
    
  
   
        

  
         
    
        
 
          
//      
      
  
//    
//    

   

    
      
            
       repeat 4 s += a[i++];
      s += sep;
       
     repeat 4 s += a[i++];
            s += sep;
      
       repeat 12 s += a[i++];
        
      return s;
     }
   

function dec_to_hex()
  
   
 
    

   

   
      
        
        {
        var dec, hex, h, byte, hi, lo;
            dec = argument0;
      if (dec) hex = "" else hex="0";
//       
// 
       
         
   
//        
         
      
    
   
    
       
 
  
      
       
  
        
      

//     
      
  
    
      

          h = "0123456789ABCDEF";
         while (dec) {
                byte = dec & 255;
                hi = string_char_at(h, byte div 16 + 1);
          lo = string_char_at(h, byte mod 16 + 1);
                hex = iff(hi!="0", hi, "") + lo + hex;
            dec = dec >> 8;
         }
         return hex;
        }
    
   function iff(argument0, argument1, argument2)
       {
          if argument0 return argument1 
       return argument2
  }
       
        function epoch()
       {
           return round(date_second_span(date_create_datetime(2016,1,1,0,0,1), date_current_datetime()));
 }        
        
 #macro net_vc_stream 0xff
        
   function net_voice_start_stream(_picked) {
  
     
// 
     
   
//    
//      
 
         
//    
//         
//        
       

   
          
  
         
     
          
          
     
//   
          
        
     
       
  
         
        
     if net_stream_get(obj_net.net_id, net_vc_stream) != noone
{
     __net_log("There's already a stream at 0xff, cannot allocate a voice stream")
  return;
     }
     
if audio_get_recorder_count() == 0 {
  __net_log("NetGM2: Not enough audio recorders to start voice");
return;
  }
     
 net_voice_recorder = _picked
    __net_log("================AUDIO================")
   __net_log("Recorder count: " + string(audio_get_recorder_count()))
        var i = 0;
        repeat (audio_get_recorder_count()) 
  {
      __net_log("Recorder " + string(i) + ": " + json_encode(audio_get_recorder_info(i)))
 i++;
 }
      __net_log("Picked recorder " + string(net_voice_recorder))
  
    net_voice_record = audio_start_recording(net_voice_recorder)
      net_stream_register(net_vc_stream)
     }

      function __net_voice_send_data(_buf) {
      net_stream_data(net_vc_stream, _buf, false)

    
        
//      

 
    
    
         
   
       
//   
      
 
// 
    
}
      
 function __net_voice_get_prox_objs(_otherid) {
        var _prox_objs = array_filter(net_sync_objs_of(_otherid), function(_el, _idx) {
    return _el.obj == global.net_voice_proximity_obj;
        });
  
  return _prox_objs;
        }
 
  function net_voice_other_start(_otherid) {
 var _stream = net_stream_get(_otherid, net_vc_stream)
     if _stream == noone {
__net_log("Other's voice stream doesn't exist yet! Wait for it to exist and then call this")
//      
        
       
   
        

  
  
 
   
        
  
       
     
   
    
        return _stream;
 }
        global.net_audio_queue_buf[? string(_stream.oid) + "_" + string(_stream.nid)] = buffer_create(0, buffer_grow, 1);

      _stream.SetListener(function (_strm, _data) {
       var _queuebuf_id = string(_strm.oid) + "_" + string(_strm.nid);
        var _qbuf = global.net_audio_queue_buf[? _queuebuf_id];
    
     
 if (buffer_get_size(_qbuf) < 1000) {
     buffer_copy(_data, 0, buff_sz(_data), _qbuf, buff_sz(_qbuf))
        __net_log_verbose("Queueing audio chunk " + string(buff_sz(_data)) + " queue size=" + string(buff_sz(_qbuf)))
      return;
  }
        
__net_log_verbose("Playing back with " + string(buff_sz(_qbuf)) + " queued bytes")
         
          
 
       
        
        

    
          
        
  
     

//          
      
   
      
  

     
 var _qbuf_copy = net_buffer_copy(_qbuf)
  var _bufsnd = audio_create_buffer_sound(_qbuf_copy, buffer_s16, 16000, 0, buffer_get_size(_qbuf_copy), audio_mono)
 var _gain = 1;
    
if global.net_voice_proximity {
  var _prox_objs = __net_voice_get_prox_objs(_strm.oid)
 if array_length(_prox_objs) > 0
   {
     var _prox_obj = _prox_objs[0];

        var _our_prox_objs = __net_voice_get_prox_objs(net_get_id())
   if array_length(_our_prox_objs) > 0 {
 var _our_prox_obj = _our_prox_objs[0];

 var _dist = point_distance(_prox_obj.inst.x, _prox_obj.inst.y, _our_prox_obj.inst.x, _our_prox_obj.inst.y)
 var _reach = 1;
    _gain = _reach / _dist;
    if _dist == 0
  _gain = 1;
     }
         
//     
   
        }
    }
       
//      
  
      
   
 
//    
   
//          
          
//      
  
   
//           
       
audio_sound_gain(_bufsnd, _gain, 0)
       audio_play_sound(_bufsnd, 0, false)
      
 buffer_delete(_qbuf)

     net_gc_queue("buffers", _qbuf_copy, 60);
    net_gc_queue("buf_audio", _bufsnd, 20);
   
global.net_audio_queue_buf[? _qbuf] = buffer_create(0, buffer_grow, 1);
})
  }
    
     function net_voice_set_recorder(_recorder) {
      global.net_voice_recorder = _recorder
//    
     
       }
   
 
     

          
          
        
   function net_voice_init(_proximity) {
  global.net_voice_active = true;
   global.net_voice_proximity = _proximity != undefined
 if global.net_voice_proximity {
        global.net_voice_proximity_obj = _proximity
     }
  
         
 
   
         
   
       
    
    
        
//   
//       
      
  
       
      
   
 
        
   
with (obj_net) {
       net_add_event_listener(net_ev_join, function() {
        net_voice_start_stream(global.net_voice_recorder)
      })
      
      net_add_event_listener(net_ev_stream_created, function(_strm) {
     if _strm.nid == net_vc_stream {
      net_voice_other_start(_strm.oid)
     }
   })
     }
   }     
   
    #macro net_web_endpoint "https://kenanyazbeck.com"
   #macro net_version "1.0.0beta"

  
  function net_get_version() {
 return net_version;
   
     
        
   
  
       }
      
function net_web_get_version(_callback) {
       var _uri = net_web_endpoint + "/netgm2/version";
  
     
    
      
  
 
       
 
     
//   
 

         

  
 
    
//    
   
       with (obj_net_web) {
      __net_log_verbose("Requesting version from the server...")
     global.__net_resp_callback = _callback
api_req = http_get(_uri)
      }
 }       
   
   function net_get_ip_addr(_async_callback) {
     with (obj_net_web) {
      api_req = http_get("http://checkip.amazonaws.com/")
global.__net_resp_callback = _async_callback
     }
   }
