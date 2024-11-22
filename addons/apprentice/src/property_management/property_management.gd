#============================================================
#    Property Management
#============================================================
# - datetime: 2022-11-23 19:35:39
#============================================================
## 属性管理
class_name PropertyManagement
extends MyNode


##  数据发生改变。新增和移除属性时都会发出这个信号。新增时 previous 值为 [code]null[/code]，
##移除时 current 值为 [code]null[/code]。
##[br]- [code]property[/code]  属性名
##[br]- [code]previous[/code]  改变前的数据值
##[br]- [code]current[/code]  当前的数据值
signal property_changed(property, previous, current)
## 新添加属性
signal newly_added_property(property, value)
## 移除了属性
signal removed_property(property, value)


# 属性对应的值
var _property_to_value_map : Dictionary = {}


#============================================================
#  内置
#============================================================
func _get(property):
	return _property_to_value_map.get(property)

func _set(property, value):
	_property_to_value_map[property] = value
	return true


#============================================================
#  SetGet
#============================================================
##  获取所有数据，属性对应的值
func get_property_map() -> Dictionary:
	return _property_to_value_map

func get_property_list() -> Array:
	return _property_to_value_map.keys()

##  设置属性值
##[br]
##[br][code]force_change[/code]  强制进行修改
##[br][code]emit_chang_signal[/code]  是否发出数据发生改变的信号
func set_value(property, value, force_change: bool = false, emit_chang_signal: bool = true):
	if _property_to_value_map.has(property):
		var _tmp_value = _property_to_value_map[property]
		if typeof(_tmp_value) != typeof(value) or _tmp_value != value or force_change:
			_property_to_value_map[property] = value
			if emit_chang_signal:
				self.property_changed.emit(property, _tmp_value, value)
	else:
		_property_to_value_map[property] = value
		self.newly_added_property.emit(property, value)
		if emit_chang_signal:
			self.property_changed.emit(property, null, value)

##  获取属性值
##[br]
##[br][code]default[/code]  如果没有这个属性时返回的默认值
func get_value(property, default = null):
	return _property_to_value_map.get(property, default)

##  是否存在有这个属性
func has_property(property) -> bool:
	return _property_to_value_map.has(property)

##  添加数据。如果是数字则会追加数值，其他则会覆盖掉之前的数据
func add_value(property, value):
	if value is float or value is int:
		set_value(property, _property_to_value_map.get(property, 0) + value )
	else:
		set_value(property, value, true)

##  减去数据。数值类型的数据则会减少这个值
func sub_value(property, value):
	if value is float or value is int:
		set_value(property, _property_to_value_map.get(property, 0) - value )

## 设置多个属性数据
func set_values(data: Dictionary):
	for property in data:
		set_value(property, data[property])

## 与运算属性
func and_value(property, value):
	if value is int:
		set_value(property, get_as_int(property) & value)
	elif value is bool:
		set_value(property, get_as_bool(property) and value)
	else:
		set_value(property, value)

## 或运算属性
func or_value(property, value):
	if value is int:
		set_value(property, get_as_int(property) | value)
	elif value is bool:
		set_value(property, get_as_bool(property) or value)
	else:
		set_value(property, value)

func add_values(data: Dictionary, ignore_not_exists_property: bool = true):
	for property in data:
		if ignore_not_exists_property or has_property(property):
			add_value(property, data[property])

func sub_values(data: Dictionary, ignore_not_exists_property: bool = true):
	for property in data:
		if ignore_not_exists_property or has_property(property):
			sub_value(property, data[property])

##  移除数据
func remove(property):
	if _property_to_value_map.has(property):
		var value = _property_to_value_map[property]
		self.removed_property.emit(property, value)
		self.property_changed.emit(property, value, null)
		_property_to_value_map.erase(property)

## 取出属性。如果是数值，则最多取出不超过剩余的量的值
func take_value(property, value, default = null):
	if has_property(property):
		var v = get_value(property)
		# 如果值为数字，则减去取出的值
		if (
			(value is float or value is int) 
			and (v is float or v is int)
		):
			if v < value:
				value = v 
			sub_value(property, value)
			return value
		
		# 如果不是数字，则直接取出数据，并设置这个属性为 null
		else:
			set_value(property, null)
			return v
	return default

## 属性值与判断值相同
func property_equals(property, compare_value) -> bool:
	var a = get_value(property)
	var b = compare_value
	return typeof(a) == typeof(b) and a == b 


#============================================================
#  获取并转换类型
#============================================================
## 获取数据并转为 [bool] 类型
func get_as_bool(property, default : bool = false) -> bool:
	return bool(_property_to_value_map.get(property, default))

## 获取数据并转为 [int] 类型
func get_as_int(property, default : int = 0) -> int:
	return int(_property_to_value_map.get(property, default))

## 获取数据并转为 [float] 类型
func get_as_float(property, default : float = 0.0) -> float:
	return float(_property_to_value_map.get(property, default))

## 获取数据并转为 [String] 类型
func get_as_string(property, default: String = "") -> String:
	return str(_property_to_value_map.get(property, default))

## 获取数据并转为 [Array] 类型
func get_as_array(property, default: Array = []) -> Array:
	return Array(_property_to_value_map.get(property, default))

## 获取数据并转为 [Dictionary] 类型
func get_as_dictionary(property, default: Dictionary = {}) -> Dictionary:
	return Dictionary(_property_to_value_map.get(property, default))

## 获取这些属性的总值
func get_total(propertys: Array) -> float: 
	var total : float = 0
	for property in propertys:
		total += get_as_float(property)
	return total
