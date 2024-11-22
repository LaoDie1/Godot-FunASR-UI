#============================================================
#    Data Util
#============================================================
# - datetime: 2022-12-21 21:19:10
#============================================================
## 数据工具
##
##用作全局获取数据使用
class_name DataUtil

static var _data : Dictionary = {}

##  获取场景树 [SceneTree] 对象的 meta 数据作为单例数据，如果返回的数据为 [code]null[/code]
## 则会在下次继续调用这个 default 回调方法，直到返回的数据不为 [code]null[/code] 为止 
##[br]
##[br][code]key[/code]  数据key
##[br][code]default[/code]  如果没有这个key，则默认返回的数据
##[br][code]ignore_null[/code]  忽略 null 值。如果为 true，则在默认值为 null 的时候不记录到元数据，直到有数据为止
static func singleton(key: StringName, default: Callable, ignore_null: bool = true):
	if _data.has(key) and _data.get(key) != null:
		return _data.get(key)
	else:
		var value = default.call()
		if ignore_null:
			if value != null:
				_data[key] = value
		else:
			_data[key] = value
		return value


## 是否有这个 key 的据
static func has_singleton(key: StringName) -> bool:
	return _data.has(key)

##  移除数据
static func remove_singleton(key: StringName) -> bool:
	return _data.erase(key)

## 获取 Autoload 节点
static func get_auotload(name: String) -> Node:
	return Engine.get_main_loop().root.get_node_or_null(name)


## 移除所有meta数据
static func clear_all_singleton() -> void:
	for key in Engine.get_meta_list():
		_data.erase(key)


##  获取 Dictionary 数据
static func singleton_dict(key: StringName, default: Dictionary = {}) -> Dictionary:
	return _data.get_or_add(key, default)


##  获取 Array 数据
static func singleton_array(key: StringName, default: Array = []) -> Array:
	if Engine.has_meta(key):
		return Engine.get_meta(key)
	else:
		Engine.set_meta(key, default)
		return default


## 获取目标的默认数据，以目标对象作为基础存储数据
static func singleton_from_object(object: Object, key: StringName, default: Callable ):
	if object.has_meta(key):
		return object.get_meta(key)
	else:
		var data = default.call()
		object.set_meta(key, data)
		return data


## 获取标 [Dictionary] 类型数据 
static func singleton_dict_from_object(object: Object, key: StringName, default: Dictionary = {}) -> Dictionary:
	return singleton_from_object(object, key, func(): return default)


## 获取类型化数组
##[br]
##[br][code]_class[/code]  数据的类型。比如 [code]"Dictionary", Node, Sprite2D[/code] 等类名（基础数据类型需要加双引号），
##或者自定义类名 Player，或者字符串形式的类名，或者 TYPE_INT, TYPE_DICTIONARY
##[br][code]default[/code]  默认有哪些数据
static func get_type_array(_class, default : Array = []) -> Array:
	# 返回类型化数组
	var data := ObjectUtil.get_class_info(_class)
	return Array(default, data["type"], data["class_name"], data["script"] )


## 转为类型化数组
static func to_type_array(array: Array, _class) -> Array:
	return get_type_array(_class, array)


## 数组转为字典
##[br]
##[br]示例，将节点列表转为，以 node.name 为 key 的字典
##[codeblock]
##var dict_data = DataUtil.array_to_dictionary( 
##    node_list, 
##    func(node): return node.name, # key 键
##    func(node): return node 
##) 
##[/codeblock]
static func array_to_dictionary(
	list: Array, 
	get_key: Callable = func(item): return item, 
	get_value: Callable = func(item): return null 
) -> Dictionary:
	var data = {}
	var key
	var value
	for i in list:
		key = get_key.call(i)
		value = get_value.call(i)
		data[key] = value
	return data


## 引用数据
class RefObjectData:
	
	var value
	
	func _init(value) -> void:
		self.value = value
	
	func _to_string():
		return str(value)
	
	func get_value():
		return value
	
	func queue_free() -> void:
		if value is Object:
			ObjectUtil.queue_free(value)
	


## 获取引用数据。
##[br]
##[br][b]Note:[/b] 主要用在匿名函数里，以处理基本数据类型的值。因为匿名函数之外的基本数据类型的值
##在匿名函数修改不会发生改变。
static func get_ref_data(default, dependent: Object = null) -> RefObjectData:
	var r_data = RefObjectData.new(default)
	if dependent != null and dependent is Node:
		dependent.tree_exited.connect(Engine.get_main_loop().queue_delete.bind(r_data))
	return r_data


## 获取字典的值，如果没有，则获取并设置默认值
##[br]
##[br][code]dict[/code]  获取的字典
##[br][code]key[/code]  key 键
##[br][code]not_exists_set[/code]  没有则返回值设置这个值。这个回调方法返回要设置的数据
static func get_value_or_set(dict: Dictionary, key, not_exists_set: Callable = Callable()):
	if dict.has(key) and not typeof(dict[key]) == TYPE_NIL:
		return dict[key]
	else:
		if not_exists_set.is_valid():
			dict[key] = not_exists_set.call()
			return dict[key]

static func get_value(dict: Dictionary, key, default = null):
	return dict.get(key, default)


## 生成id
static func generate_id(data_list: Array) -> StringName:
	var list = []
	for i in data_list:
		list.append(hash(i))
	return ",".join(list).sha1_text()


## 如果不为空值结果值
class NotNullValueChain:
	
	func _init(value):
		set_meta("value", value)
	
	func get_value(default = null):
		return get_meta("value", default)
	
	func or_else(object, else_object: Callable) -> NotNullValueChain:
		return NotNullValueChain.new( object if object else else_object.call() )
	
	## 返回结果不为空时，这个方法需要一个参数接收值
	func if_not_null(else_object: Callable, default = null) -> NotNullValueChain:
		var value = get_value()
		return NotNullValueChain.new( else_object.call(value) if value else default )


##  如果对象不为 null 则调用。
## 可以链式调用逐步执行功能
##[codeblock]
##func get_data(object: Object):
##    return DataUtil.if_not_null(object, func():
##        return object.get_script()
##    ).or_else(func():
##        print("")
##    )
##[/codeblock]
static func if_not_null(object, else_object: Callable) -> NotNullValueChain:
	return NotNullValueChain.new((
		else_object.call() if object != null else object
	))


## 获取正则
static func get_regex(pattern: String) -> RegEx:
	var re = RegEx.new()
	re.compile(pattern)
	return re


##  合并数据
##[br]
##[br][code]merge_to[/code]  合并到的目标
##[br][code]data[/code]  要追加合并的数据
##[br][return]return[/return]  返回合并后的数据
static func merge(merge_to, data):
	if merge_to is Dictionary:
		if data is Dictionary:
			merge_to.merge(data, true)
		else:
			for item in data:
				merge_to[item] = null
	elif merge_to is Array:
		if data is Array:
			merge_to.append_array(data)
		elif data is Dictionary:
			merge_to.append_array(data.keys())
		else:
			merge_to.append(data)
	else:
		merge_to += data
	return merge_to


## 获取一个唯一的数字 ID，从 0 始
static func get_id() -> int:
	const KEY = "DataUtil_get_id"
	if Engine.has_meta(KEY):
		var id = Engine.get_meta(KEY)
		id += 1
		Engine.set_meta(KEY, id)
		return id
	else:
		var id = 0
		Engine.set_meta(KEY, id)
		return id


## 列表转为集合hash值，这样即便列表顺序不一致他的值也是相同的
static func as_set_hash(list: Array) -> int:
	var tmp = list.map(func(item): return hash(item))
	tmp.sort()
	return tmp.hash()


## 去除重复
static func remove_duplicates(list: Array) -> Array:
	var dict = {}
	for i in list:
		dict[i] = null
	return dict.keys()


## 格式化 _to_string 的字符串
static func format_to_string(node: Node, _class_name: StringName = &"") -> String:
	if _class_name == &"":
		_class_name = str(node.get_script().resource_path) \
			.get_basename() \
			.get_file() \
			.capitalize() \
			.replace(" ", "")
	return "%s:<%s#%s>" % [node.name, _class_name, node.get_instance_id()]

## 数据是否为 null
static func is_null(data) -> bool:
	return typeof(data) == TYPE_NIL

## 数据是否不为 null
static func not_null(data) -> bool:
	return typeof(data) != TYPE_NIL

## 值是否为数字
static func is_number(value) -> bool:
	return typeof(value) in [TYPE_FLOAT, TYPE_INT]

static func get_as_float(data: Dictionary, key, default: float = 0) -> float:
	return float(data.get(key, default))

static func get_as_int(data: Dictionary, key, default: int = 0) -> int:
	return int(data.get(key, default))

static func get_as_str(data: Dictionary, key, default: String = "") -> String:
	return str(data.get(key, default))

static func get_as_bool(data: Dictionary, key, default: bool = false) -> bool:
	return bool(data.get(key, default))

static func erase(key, data: Dictionary) -> bool:
	return data.erase(key)


static func offset(value, offset_value):
	return value + offset_value

static func offset_array(list: Array, value) -> Array:
	var arr = list.duplicate()
	offset_origin_array(arr, value)
	return arr

## 偏移整个数组，他会修改原数组，而非产生新的数组
static func offset_origin_array(list: Array, value):
	if value:
		for idx in list.size():
			list[idx] += value
	return list

static func append(data, value):
	if data is Dictionary:
		data[value] = null
	else:
		data += value

static func duplicates(value, deep: bool = false):
	if value is Dictionary or value is Array or value is Object:
		return value.duplicate(deep)
	else:
		return value

static func equals(a, b) -> bool:
	return typeof(a) == typeof(b) and a == b
