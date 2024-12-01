#============================================================
#    Global
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-24 22:22:09
# - version: 4.3.0.dev5
#============================================================
extends Node


const MAX_FONT_SIZE = 200
const ExecuteMode = {
	Pass2 = "2pass",
	Offline = "offline",
	Online = "online",
}

var data_file_path : String = OS.get_data_dir().path_join("Godot/FunASR/config.data")
var hot_word_path : String = OS.get_data_dir().path_join("Godot/FunASR/hotword.txt")

var init_data_hash : int = 0
var property_data := {}
var propertys : Array[BindPropertyItem] = []


func _init() -> void:
	# 基础数据设置
	if FileUtil.file_exists(data_file_path):
		property_data = FileUtil.read_as_var(data_file_path)
		init_data_hash = hash(property_data)
	ScriptUtil.init_class_static_value(
		Config, 
		func(script, path:String, property):
			if path == "":
				return
			var property_path := path.path_join(property)
			# 修改数据
			var value
			if property_data.has(property_path):
				value = property_data.get(property_path)
			if not value:
				value = Config.default_value.get(property_path)
			var bind_property := BindPropertyItem.new(property_path, value)
			# 绑定数据
			bind_property.bind_method(
				func(value):
					property_data[property_path] = value
			)
			
			script.set( property, bind_property )
			propertys.append(bind_property)
	)
	# hot word 文件
	FileUtil.make_dir_if_not_exists(hot_word_path.get_base_dir())
	if not FileAccess.file_exists(hot_word_path):
		FileUtil.write_as_string(hot_word_path, "")
	
	# 默认 FFMpeg 路径
	if Config.Execute.ffmpeg_path.get_value() == null:
		var ffmpeg_path = FileUtil.get_project_real_path().path_join("ffmpeg.exe")
		if not FileUtil.file_exists(ffmpeg_path):
			ffmpeg_path = FileUtil.find_program_path("ffmpeg")
		if ffmpeg_path:
				Config.Execute.ffmpeg_path.update(ffmpeg_path)
	# 默认 python 路径
	if Config.Execute.python_execute_path.get_value() == null:
		var python_path = FileUtil.find_program_path("python3")
		if not FileUtil.file_exists(python_path):
			python_path = FileUtil.find_program_path("python")
		if python_path:
			Config.Execute.python_execute_path.update(python_path)


func _ready() -> void:
	var window: Window = Engine.get_main_loop().root
	Config.Misc.window_size.bind_property(window, "size", true)
	Config.Misc.window_position.bind_property(window, "position", true)
	if Config.Misc.window_mode.get_value(Window.MODE_WINDOWED) != Window.MODE_WINDOWED:
		Config.Misc.window_mode.bind_property(window, "mode", true)
	NodeUtil.create_timer(3 * 60, null, self.save_config_data, true, false)
	window.size_changed.connect(
		func():
			if window.mode == Window.MODE_WINDOWED:
				Config.Misc.window_size.update(window.size)
				Config.Misc.window_position.update(window.position)
	)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_config_data()


func save_config_data():
	var window: Window = Engine.get_main_loop().root
	Config.Misc.window_mode.update(window.mode)
	if window.mode == Window.MODE_WINDOWED:
		Config.Misc.window_position.update(window.position)
	if init_data_hash != hash(property_data):
		FileUtil.write_as_var(data_file_path, property_data)
		print("-- 已保存设置数据")
		print(property_data)


func find_bind_property(path: String) -> BindPropertyItem:
	for p in propertys:
		if p.get_name() == path:
			return p
	return null

enum {
	ERROR = -1,
	SOUND,
	VIDEO,
}

static func get_file_type(file_path: String):
	var type = file_path.get_extension().to_lower()
	if type in ["aac", "aif", "aiff", "amr", "ape", "au", "awb", "caf", "dct", "dss", "dvf", "flac", "gsm", "iklax", "ivs", "m4a", "m4b", "m4p", "mmf", "mp3", "mpc", "msv", "ogg", "oga", "opus", "ra", "ram", "raw", "rf64", "sln", "tta", "voc", "vox", "wav", "wma", "wv"]:
		return SOUND
	elif type in ["mp4", "flv", "webm", "avi", "mov", "mkv", "ogv", "rmvb","3g2", "3gp", "3gp2", "3gpp", "amv", "asf", "avi", "avs", "bik", "bin", "bix", "bmk", "divx", "drc", "dv", "dvr - ms", "evo", "f4v", "flv", "gvi", "gxf", "iso", "m1v", "m2v", "m2t", "m2ts", "m4v", "mkv", "mov", "mp2", "mp2v", "mp4v", "mpe", "mpeg", "mpeg1", "mpeg2", "mpeg4", "mpg", "mpv2", "mts", "mtv", "mxf", "mxg", "nsv", "nuv", "ogg", "ogm", "ogv", "ps", "rec", "rm", "rmvb", "rpl", "thp", "tod", "ts", "tts", "txd", "vob", "vp3", "vp6", "vro", "webm", "wm", "wmv", "wtv", "xesc"]:
		return VIDEO
	else:
		return ERROR

func get_theme_type() -> String:
	var type
	if Config.Project.theme.get_number(0) == 0:
		type = "light" if not DisplayServer.is_dark_mode() else "dark"
	else:
		type = "light" if Config.Project.theme.get_number(0) == 1 else "dark"
	return type
