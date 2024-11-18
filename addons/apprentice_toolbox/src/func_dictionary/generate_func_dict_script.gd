#============================================================
#    生成方法字典脚本
#============================================================
# - author: zhangxuetu
# - datetime: 2024-05-24 11:11:50
# - version: 4.3.0.dev6
#============================================================
## 快速生成 [FuncDictionary] 类脚本，调用 [method execute] 创建
@tool
class_name GenerateFuncDictionaryScript
extends EditorScript


const CLASS_TEMPLATE = """# {class_name}
class_name {class_name}
extends FuncDictionary


static func instance() -> {class_name}:
	return __instance__({class_name})

static func instance_from_dict(data: Dictionary) -> {class_name}:
	return __instance_from_dict__(data)

{method_code}

"""

const METHOD_TEMPLATE = """
func {name}(value) -> {class_name}:
	return self

func get_{name}(default = null):
	return __data__.get("{name}", default)
"""


static func execute(_class_name: String, key_name_list: Array, save_path: String):
	# [ 开始生成 ]
	var method_code = ""
	for method_name in key_name_list:
		method_code += METHOD_TEMPLATE.format({
			"class_name": _class_name,
			"name": method_name,
		})
	
	var script_code = CLASS_TEMPLATE.format({
		"class_name": _class_name,
		"method_code": method_code,
	})
	var script = GDScript.new()
	script.source_code = script_code
	
	# 保存脚本
	FileUtil.save_resource(script, save_path)
	print_debug("已保存：", save_path)
	
