#============================================================
#    File List Panel
#============================================================
# - author: zhangxuetu
# - datetime: 2024-05-01 22:47:44
# - version: 4.2.2.stable
#============================================================
class_name FileListPanel
extends Control


signal added(path: String, item: TreeItem)
signal selected_path(path: String)


const META_KEY_PATH = "__path"

@export var current_dir: String:
	set(v):
		if current_dir != v:
			current_dir = v
			reload()


@onready var tree: Tree = %Tree
@onready var root : TreeItem = tree.create_item()
@onready var dir_dialog: FileDialog = %DirDialog


var data : Dictionary = {}


#============================================================
#  自定义
#============================================================
func add_path(path: String) -> bool:
	if not data.has(path):
		var item = tree.create_item(root)
		item.set_text(0, path.get_file())
		data[path] = item
		item.set_meta(META_KEY_PATH, path)
		added.emit(path, item)
		return true
	return false

func remove_path(path: String) -> bool:
	if data.has(path):
		var item = data[path]
		data.erase(path)
		root.remove_child(item)
		return true
	return false

func get_path_list():
	return data.keys()

func get_selected_path() -> String:
	var item = tree.get_selected()
	if item:
		return item.get_meta(META_KEY_PATH, "")
	return ""

func select_path(path: String):
	var item = data.get(path)
	if item is TreeItem:
		item.set_selectable(0, true)

func deselect_all():
	tree.deselect_all()


func reload():
	tree.clear()
	data.clear()
	root = tree.create_item()
	if current_dir != "":
		var files = FileUtil.scan_directory(current_dir)
		for file in files:
			add_path(file)


#============================================================
#  连接信号
#============================================================
func _on_dir_dialog_dir_selected(dir: String) -> void:
	self.current_dir = dir

func _on_button_pressed() -> void:
	dir_dialog.popup_centered()


func _on_tree_item_selected() -> void:
	var item = tree.get_selected()
	selected_path.emit( item.get_meta(META_KEY_PATH, "") )
