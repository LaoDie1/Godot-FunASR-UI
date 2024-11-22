#============================================================
#    Config
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

var property_data := {}
var propertys : Array[BindPropertyItem] = []


func get_bind_property(path: String) -> BindPropertyItem:
	for p in propertys:
		if p.get_name() == path:
			return p
	return null


#============================================================
#  内置
#============================================================
func _init() -> void:
	# 基础数据设置
	if FileUtil.file_exists(data_file_path):
		property_data = FileUtil.read_as_var(data_file_path)
	var default_value: Dictionary = {
		"/Global/font_size": 16,
		"/Global/files": [],
		"/Global/recognition_mode": "offline",
		"/Global/split_text": "，。？！,?.",
		
		"/Misc/left_split_width": 0,
		
		"/Execute/host": "127.0.0.1",
		"/Execute/port": "10095",
		
		"/File/save_to_directory": OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS),
		"/File/file_name_format": "{name}.txt",
	}
	ScriptUtil.init_class_static_value(
		ConfigKey, 
		func(script, path:String, property):
			var property_path := path.path_join(property)
			# 修改数据
			var value
			if property_data.has(property_path):
				value = property_data.get(property_path)
			if not value:
				value = default_value.get(property_path)
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


func _enter_tree() -> void:
	ConfigKey.Misc.window_size.bind_property(Engine.get_main_loop().root, "size", true)
	ConfigKey.Misc.window_position.bind_property(Engine.get_main_loop().root, "position", true)
	if ConfigKey.Misc.window_mode.get_value(Window.MODE_WINDOWED) != Window.MODE_WINDOWED:
		ConfigKey.Misc.window_mode.bind_property(Engine.get_main_loop().root, "mode", true)
	
	Engine.get_main_loop().root.size_changed.connect(
		func():
			if Engine.get_main_loop().root.mode == Window.MODE_WINDOWED:
				ConfigKey.Misc.window_size.update(Engine.get_main_loop().root.size)
				ConfigKey.Misc.window_position.update(Engine.get_main_loop().root.position)
	)
	
	NodeUtil.create_timer(3 * 60, null, self.save_config_data, true, false)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_config_data()


func save_config_data():
	ConfigKey.Misc.window_mode.update(Engine.get_main_loop().root.mode)
	ConfigKey.Misc.window_position.update(Engine.get_main_loop().root.position)
	
	FileUtil.write_as_var(data_file_path, property_data)
	print("-- 已保存设置数据")
	print(property_data)
