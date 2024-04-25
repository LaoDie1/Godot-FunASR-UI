#============================================================
#    Queue File Tree
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-24 23:08:13
# - version: 4.3.0.dev5
#============================================================
class_name FileQueue
extends Tree


const ICON_SIZE = 32

var root : TreeItem
var _files : Dictionary = {}


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
			match id:
				0: # 复制文件名
					var file_path : String = item.get_metadata(0)
					var file_name : String = file_path.get_file()
					DisplayServer.clipboard_set(file_name)
					print("已复制文件名：", file_name)
					
				1: # 删除
					root.remove_child(item)
					_files.erase(item.get_metadata(0))
					if get_selected() == null:
						select(0)
	)
	
	# 加载历史文件
	for file in Config.get_value(ConfigKey.files):
		if FileAccess.file_exists(file):
			add_file(file)
	select(0)


func _exit_tree() -> void:
	Config.set_value(ConfigKey.files, get_files())



#============================================================
#  自定义
#============================================================
func add_file(file_path: String):
	file_path = file_path.replace("\\", "/")
	if _files.has(file_path):
		return
	
	var item = create_item(root)
	_update_item(item, file_path)
	item.add_button(0, Icons.get_icon("ActionCopy"))
	item.set_button_tooltip_text(0, 0, "复制文件名")
	item.add_button(0, Icons.get_icon("Remove"))
	item.set_button_tooltip_text(0, 1, "移除文件")
	_files[file_path] = item


func _update_item(item: TreeItem, file_path: String):
	item.set_text(0, file_path.get_file())
	item.set_metadata(0, file_path)
	item.set_tooltip_text(0, file_path)
	
	var icon : Texture2D
	var type : String = file_path.get_extension().to_lower()
	match type:
		"mp3", "wav", "ogg", "flac", "aac", "wma", "ape":
			icon = Icons.get_icon("AudioStreamMP3")
		"mp4", "flv", "webm", "avi", "mov", "mkv", "ogv", "rmvb":
			icon = Icons.get_icon("VideoStreamTheora")
			#icon = Icons.get_icon("VideoStreamPlayer")
		_:
			icon = Icons.get_icon(type)
	item.set_icon(0, icon)
	item.set_icon_max_width(0, ICON_SIZE)


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

## 弹出一个文件
func pop_file() -> String:
	var item = root.get_child(0)
	var file_path = item.get_metadata(0)
	root.remove_child(item)
	_files.erase(file_path)
	return file_path

