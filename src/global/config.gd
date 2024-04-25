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


var data_file_path : String = OS.get_data_dir().path_join("Godot/FunASR/config.gcd")
var hot_word_path : String = OS.get_data_dir().path_join("Godot/FunASR/hotword.txt")
var data_file : DataFile = DataFile.instance(
	data_file_path, 
	DataFile.STRING, 
	{
		ConfigKey.font_size: 15,
		ConfigKey.files: [],
	}
)
var propertys : Array
var default_value: Dictionary:
	get:
		return {
			ConfigKey.font_size: 16,
			ConfigKey.files: [],
			ConfigKey.Misc.left_split_width: 0,
			ConfigKey.Misc.window_position: Vector2(),
			ConfigKey.Misc.window_size: Vector2(),
			ConfigKey.Execute.host: "127.0.0.1",
			ConfigKey.Execute.port: "10095",
			ConfigKey.recognition_mode: "offline",
			ConfigKey.File.save_to_directory: OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS),
		}



#============================================================
#  内置
#============================================================
func _init() -> void:
	propertys = ScriptUtil.init_class_static_value(ConfigKey, true)
	
	# hot word 文件
	FileUtil.make_dir_if_not_exists(hot_word_path.get_base_dir())
	if not FileAccess.file_exists(hot_word_path):
		FileUtil.write_as_string(hot_word_path, "")


func _enter_tree() -> void:
	if has_value(ConfigKey.Misc.window_position):
		Engine.get_main_loop().root.position = get_value(ConfigKey.Misc.window_position)
		Engine.get_main_loop().root.size = get_value(ConfigKey.Misc.window_size)


func _exit_tree() -> void:
	set_value(ConfigKey.Misc.window_position, Engine.get_main_loop().root.position)
	set_value(ConfigKey.Misc.window_size, Engine.get_main_loop().root.size)
	data_file.save()


#============================================================
#  自定义
#============================================================
func has_value(key: String) -> bool:
	return data_file.has_value(key)

func get_value(key: String, default = null):
	var value = data_file.get_value(key)
	if value == null:
		value = get_default_value(key)
		if value == null:
			return default
	return value

func set_value(key: String, value: Variant) -> void:
	data_file.set_value(key, value)

func get_default_value(key: String):
	if default_value.has(key):
		return default_value[key]
	else:
		match key:
			ConfigKey.Misc.config_window_size:
				return Engine.get_main_loop().root.size * 0.5
		return null
