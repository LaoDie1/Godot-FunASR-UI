#============================================================
#    File List
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-27 22:46:39
# - version: 4.3.0.dev5
#============================================================
class_name SimpleFileList
extends Tree


signal added_item(item: TreeItem)

@export var file_icon : Texture2D

var root : TreeItem
var _files : Dictionary = {}
var _button_id_to_callback : Dictionary = {}


#============================================================
#  内置
#============================================================
func _init() -> void:
	root = create_item()
	button_clicked.connect(
		func(item: TreeItem, column: int, id: int, mouse_button_index: int):
			var mouse_item = get_item_at_position(get_local_mouse_position())
			if mouse_button_index != MOUSE_BUTTON_LEFT or mouse_item != item:
				return
			
			var callback = _button_id_to_callback.get(id)
			if callback is Callable:
				callback.call(item)
	)


#============================================================
#  自定义
#============================================================
func bind_item_button(idx: int, callback: Callable):
	_button_id_to_callback[idx] = callback


func add_files(list: Array):
	for file in list:
		add_file(file)

func add_file(file_path: String):
	file_path = file_path.replace("\\", "/")
	if _files.has(file_path):
		return
	
	var item = create_item(root)
	_update_item(item, file_path)
	added_item.emit(item)
	_files[file_path] = item


## 选中文件
func select_file(file: String) -> int:
	for item in root.get_children():
		if item.get_metadata(0) == file:
			item.select(0)
			break
	return -1

func _update_item(item: TreeItem, file_path: String):
	item.set_text(0, file_path.get_file())
	item.set_metadata(0, file_path)
	item.set_tooltip_text(0, file_path)
	item.set_icon(0, file_icon)

func get_file_path(item: TreeItem):
	return item.get_metadata(0)

func select(idx: int):
	if idx < root.get_child_count():
		var item = root.get_child(idx)
		item.select(0)

func is_empty() -> bool:
	return root.get_child_count() == 0

func is_selected() -> bool:
	return get_selected() != null

func get_selected_file() -> String:
	var item = get_selected()
	if item:
		return item.get_metadata(0)
	return ""

func remove_file(file: String):
	var item = _files.get(file)
	if item:
		_files.erase(file)
		root.remove_child(item)

func update_file_name(file_or_idx, new_file_path: String):
	var id : int = -1
	if file_or_idx is String:
		for child in root.get_children():
			id += 1
			if child.get_metadata(0) == file_or_idx:
				file_or_idx = id
				break
	elif file_or_idx is int:
		id = file_or_idx
	else:
		assert(false, "错误数据类型")
	var item : TreeItem = root.get_child(id)
	_update_item(item, new_file_path)


func get_files() -> Array:
	return root.get_children().map(
		func(item: TreeItem): return item.get_metadata(0)
	)

func clear_files():
	clear()
	_files.clear()
	root = create_item()
