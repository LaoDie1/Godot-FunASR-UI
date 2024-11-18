#============================================================
#    Example
#============================================================
# - author: zhangxuetu
# - datetime: 2024-05-24 12:57:41
# - version: 4.3.0.dev6
#============================================================
# 快速创建 FuncDictionary 类编辑器脚本示例，运行这个脚本即可自动创建方法字典脚本
@tool
extends EditorScript


func _run():
	var _class_name = "DataClass"
	var key_name_list = [
		"name", "type",
	]
	var save_path : String = get_script().resource_path \
		.get_base_dir() \
		.path_join(_class_name.to_snake_case() + ".gd")
	GenerateFuncDictionaryScript.execute(_class_name, key_name_list, save_path)
	


