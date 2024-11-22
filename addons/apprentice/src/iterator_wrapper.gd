#============================================================
#    Iterator Wrapper
#============================================================
# - author: zhangxuetu
# - datetime: 2024-05-21 10:40:08
# - version: 4.3.0.dev6
#============================================================
## 迭代数据包装器
##
##对可迭代数据的统一处理，封装方法。
class_name IteratorWrapper


#============================================================
#  当前类
#============================================================
var _value

func _init() -> void:
	assert(false, "请使用 instance 方法进行创建，而不是直接使用 new")

func append(value):
	_value += value

func remove(value):
	_value -= value

func erase(value):
	_value.erase(value)

func has(value) -> bool:
	return _value.has(value)

func contains(value) -> bool:
	return has(value)

func append_iterator(values):
	for item in values:
		append(item)

func get_value():
	return _value

func hash():
	return hash(_value)

func get_array() -> Array:
	return _value

func size() -> int:
	return _value.size()

func front():
	return _value[0]

func back():
	return _value[size()-1]

func pick_random():
	return get_array().pick_random()


#============================================================
#  迭代器类型
#============================================================
## 实例化迭代包装器
static func instance(value) -> IteratorWrapper:
	var _executor : IteratorWrapper
	match typeof(value):
		TYPE_DICTIONARY:
			_executor = IteratorWrapperDictionary.new()
		TYPE_ARRAY, TYPE_PACKED_BYTE_ARRAY, TYPE_PACKED_INT32_ARRAY, TYPE_PACKED_INT64_ARRAY, TYPE_PACKED_FLOAT32_ARRAY, TYPE_PACKED_FLOAT64_ARRAY, TYPE_PACKED_STRING_ARRAY, TYPE_PACKED_VECTOR2_ARRAY, TYPE_PACKED_VECTOR3_ARRAY, TYPE_PACKED_COLOR_ARRAY:
			_executor = IteratorWrapperArray.new()
		TYPE_STRING, TYPE_STRING_NAME:
			_executor = IteratorWrapperString.new()
		_:
			_executor = IteratorWrapper.new()
	_executor._value = value
	return _executor


## 迭代字典
class IteratorWrapperDictionary extends IteratorWrapper:
	func _init() -> void:
		pass
	
	func append(value):
		_value[value] = null
	
	func remove(value):
		erase(value)
	
	func get_array() -> Array:
		return _value.keys()
	
	func front():
		return get_array().front()
	
	func back():
		return get_array().back()


## 迭代数组
class IteratorWrapperArray extends IteratorWrapper:
	func _init() -> void:
		pass
	
	func append(value):
		_value.append(value)
	
	func remove(idx: int):
		_value.remove_at(idx)
	
	func erase(value):
		Array(_value).erase(value)


## 迭代字符串
class IteratorWrapperString extends IteratorWrapper:
	func _init() -> void:
		pass
	
	func remove(value: int):
		_value = _value.substr(0, value) + _value.substr(value + 1)
	
	func size() -> int:
		return _value.length()
	
	func has(value) -> bool:
		return _value.find(value) > -1
	
	func get_array():
		return str(_value).split("")
	
	func front() -> String:
		return _value[0]
	
	func back() -> String:
		return _value[size() - 1]
	
	func pick_random() -> String:
		return _value[randi() % size()]
	
