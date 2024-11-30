#============================================================
#    Http Util
#============================================================
# - author: zhangxuetu
# - datetime: 2024-11-26 19:02:06
# - version: 4.3.0.stable
#============================================================
class_name HttpUtil


static var _http_request_map := {}


static func get_http_request(id = "") -> HTTPRequest:
	if not _http_request_map.has(id):
		var http_request = HTTPRequest.new()
		http_request.name = "http_util"
		Engine.get_main_loop().current_scene.add_child(http_request)
		_http_request_map[id] = http_request
	return _http_request_map[id]


static func request(url: String, callback: Callable):
	var hr = get_http_request(url)
	hr.request_completed.connect(callback, Object.CONNECT_ONE_SHOT)
	hr.request(url)
