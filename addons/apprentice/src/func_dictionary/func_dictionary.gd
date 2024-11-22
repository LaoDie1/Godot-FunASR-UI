#============================================================
#    Func Dict
#============================================================
# - author: zhangxuetu
# - datetime: 2024-05-24 09:48:17
# - version: 4.3.0.dev6
#============================================================
## 方法字典数据
##
##通过调用方法的方式创建字典对象。在运行之后会对原始的脚本代码进行重写。
##[br]
##[br]每个继承这个方法的类，都需要重写 [method instance] 方法，重写的方法需要是以下格式
##[codeblock]
##static func instance() -> CLASS_NAME:
##    return __instance__(CLASS_NAME)
##[/codeblock]
##其中 [code]CLASS_NAME[/code] 为继承的类的类名
##[br]
##[br][b]注意：因为会重写方法，所以在实例化的时候对 [method __instance__] 的第二个参数设置排除重写的法[/b]
class_name FuncDictionary


const METHOD_TEMPLATE = """
func {name}(value):
	__data__["{name}"] = value
	return self
"""

const CLASS_TEMPLATE = """## Custom Script
extends {class_name}

{method_code}

"""

static var __template_script_dict__ : Dictionary = {}
## 根据目标脚本创建方法字典，
static func __instance__(script: GDScript, exclude_method_name_list: Array = []):
	if not __template_script_dict__.has(script):
		# 符合条件的数据
		var method_data_list = []
		var global_name = script.get_global_name()
		if global_name != "":
			for data in script.get_script_method_list():
				if (
					not data["name"] in exclude_method_name_list
					and data["return"]["type"] == TYPE_OBJECT 
					and data["flags"] == METHOD_FLAG_NORMAL
					and data["args"].size() == 1
				):
					if data["return"]["class_name"] == global_name:
						method_data_list.append(data)
			
			# 重写，重新生成新的脚本
			var new_script : GDScript = GDScript.new()
			var method_code : String = ""
			for data in method_data_list:
				method_code += METHOD_TEMPLATE.format({
					"name": data["name"],
				})
			new_script.source_code = CLASS_TEMPLATE.format({
				"class_name": global_name,
				"method_code": method_code,
			})
			new_script.reload()
			__template_script_dict__[script] = new_script
		else:
			__template_script_dict__[script] = null
	
	if __template_script_dict__[script]:
		var s : GDScript = __template_script_dict__[script]
		return s.new()
	return null


static func __instance_from_dict__(data: Dictionary):
	var object = instance()
	object.__data__ = data.duplicate()
	return object



#===============================================


var __data__ : Dictionary = {}

## 获取 [Dictionary] 数据
func get_dict() -> Dictionary:
	return __data__

## 实例化当前类对象
static func instance():
	assert(false, "需要重写")

static func instance_from_dict(data: Dictionary):
	return __instance_from_dict__(data)
