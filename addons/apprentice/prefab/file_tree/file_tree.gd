#============================================================
#    File Tree
#============================================================
# - author: zhangxuetu
# - datetime: 2024-05-01 23:12:48
# - version: 4.2.2.stable
#============================================================
class_name FileTree
extends Tree


signal added_item(type: String, path: String, item: TreeItem)
signal selected_path(type: String, path: String)


const META_KEY_PATH = "__path"
const META_KEY_TYPE = "__type"


@export var show_file_type : Array[String] = []
@export var folder_icon: Texture2D
@export var file_icon: Texture2D


var root : TreeItem


func _init() -> void:
	hide_root = true
	added_item.connect(
		func(type, path, item: TreeItem):
			if type == "dir":
				item.set_icon(0, folder_icon)
				item.set_icon_modulate(0, Color.DARK_ORANGE)
			else:
				item.set_icon(0, file_icon)
	)
	item_collapsed.connect(
		func(item: TreeItem):
			# 点击展开后才开始显示其中的子节点
			if not item.collapsed:
				for child in item.get_children():
					if child.get_meta(META_KEY_TYPE) == "dir":
						self.__scan.call_deferred(child.get_meta(META_KEY_PATH), child)
	)
	item_selected.connect(
		func():
			var item = get_selected()
			if item:
				var type = item.get_meta(META_KEY_TYPE)
				var path = item.get_meta(META_KEY_PATH)
				selected_path.emit(type, path)
	)


func scan_dir(dir: String):
	clear()
	root = create_item()
	root.set_text(0, dir)
	root.collapsed = false
	root.set_meta(META_KEY_PATH, dir)
	__scan(dir, root)
	item_collapsed.emit(root)


func __scan(parent_dir: String, parent: TreeItem):
	# 如果 unfolded 为 true，则是展开的，继续向下级添加
	if parent.get_child_count() != 0:
		return
	
	var path: String
	var item : TreeItem
	
	# 目录
	for dir in DirAccess.get_directories_at(parent_dir):
		item = create_item(parent)
		item.collapsed = true
		path = parent_dir.path_join(dir)
		item.set_text(0, dir)
		item.set_meta(META_KEY_PATH, path)
		item.set_meta(META_KEY_TYPE, "dir")
		added_item.emit("dir", path, item)
	
	# 文件
	for file in DirAccess.get_files_at(parent_dir):
		if show_file_type.is_empty() or file.get_extension().to_lower() in show_file_type:
			item = create_item(parent)
			path = parent_dir.path_join(file)
			item.set_text(0, file)
			item.set_meta(META_KEY_PATH, path)
			item.set_meta(META_KEY_TYPE, "file")
			added_item.emit("file", path, item)


#func select_path(path: String):
	#var last_item : TreeItem = root
	#var tmp_path : String
	#while last_item != null:
		#if last_item.get_meta(META_KEY_PATH) == path or last_item.get_meta(META_KEY_PATH) == path.rstrip("/").rstrip("\\"):
			#break
		#var current = last_item
		#last_item = null
		#for child in current.get_children():
			#tmp_path = child.get_meta(META_KEY_PATH)
			#if path.begins_with(tmp_path):
				#last_item = child
				#if tmp_path == path:
					#break
				#child.collapsed = false
				#item_collapsed.emit(child)
				#if child.get_child_count() == 0:
					#__scan(tmp_path, child)
				#break
	#
	#if last_item:
		#last_item.select(0)
	

