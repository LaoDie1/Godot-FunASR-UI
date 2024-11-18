#============================================================
#    Property Item
#============================================================
# - author: zhangxuetu
# - datetime: 2024-06-12 13:24:41
# - version: 4.3.0.beta1
#============================================================
class_name PropertyItem
extends RefCounted


var _property_management: PropertyManagement
var _property: String


## 初始化目标的 PropertyItem 属性项
static func init_propertys(
	target: Object, 
	property_management: PropertyManagement, 
	exclude_propertys:Array[String] = []
) -> Array:
	var list = []
	var script := target.get_script() as GDScript
	for data in script.get_script_property_list():
		if data["class_name"] == &"PropertyItem" and not data["name"] in exclude_propertys:
			var item = PropertyItem.new(property_management, data["name"])
			list.append({
				property = data["name"],
				item = item,
			})
			target.set(data["name"], item)
	return list


func _init(property_management: PropertyManagement, property:String) -> void:
	_property_management = property_management
	_property = property

func set_value(value):
	_property_management.set_value(_property, value)

func get_value(default = null):
	return _property_management.get_value(_property, default)

func get_as_bool(default: bool = false) -> bool:
	return _property_management.get_as_bool(_property, default)

func get_as_float(default: float = 0.0) -> float:
	return _property_management.get_as_float(_property, default)

func get_as_int(default: int = 0) -> int:
	return _property_management.get_as_int(_property, default)

func get_as_string(default: String = "") -> String:
	return _property_management.get_as_string(_property, default)

func get_as_array(default: Array = []) -> Array:
	return _property_management.get_as_array(_property, default)

func get_as_dictionary(default: Dictionary = {}) -> Dictionary:
	return _property_management.get_as_dictionary(_property, default)
