#============================================================
#    File Tree
#============================================================
# - author: zhangxuetu
# - datetime: 2024-11-30 16:33:28
# - version: 4.3.0.stable
#============================================================
## 文件树
##
##方便处理文件显示。以下为添加文件的图标和按钮功能：
##[codeblock]
### 文件按钮的类型
##enum ButtonType {
##    SHOW,
##    REMOVE,
##}
##
### 连接 added_item 信号，设置项目的图标和按钮
##func _on_file_tree_added_item(path: String, item: TreeItem) -> void:
##    item.set_icon(0, Icons.get_icon("AudioStreamMP3")) # 文件图标
##    file_tree.add_item_button(path, Icons.get_icon("Load"), ButtonType.SHOW) # 文件按钮
##    file_tree.add_item_button(path, Icons.get_icon("Remove"), ButtonType.REMOVE)
##
### 连接 button_pressed 实现上面添加的按钮的实际效果
##func _on_file_tree_button_pressed(path: String, button_type: int) -> void:
##    match button_type:
##        ButtonType.SHOW:
##            FileUtil.shell_open(path)
##        ButtonType.REMOVE:
##            file_tree.remove_item(path)
##[/codeblock]
class_name FileTree
extends Tree


## 这个文件是新添加的
signal added_file(path: String)
## 移除一个文件
signal removed_file(path: String)
## 新添加的 TreeItem，更改 [member show_type] 属性时将会重新添加 item 并发出这个信号
signal added_item(path: String, item: TreeItem)
## 移除一个 TreeItem
signal removed_item(path: String, item: TreeItem)
signal button_pressed(path: String, button_type: int)


enum ShowType {
	ONLY_NAME, ## 只有名称
	ONLY_PATH, ## 只有路径
	INFO, ## 详细信息
	TREE, ## 树形
}
const MetaKey = {
	PATH = "_path",
}

@export var show_type : ShowType = ShowType.ONLY_NAME:
	set(v):
		if show_type != v:
			show_type = v
			if show_type == ShowType.INFO:
				column_titles_visible = true
				columns = titles.size()
				for idx in titles.size():
					set_column_title(idx, str(titles[idx]).to_pascal_case())
					set_column_title_alignment(idx, HORIZONTAL_ALIGNMENT_LEFT)
				for idx in range(1, titles.size()):
					set_column_expand(idx, false)
				set_column_custom_minimum_width(1, 80)
				set_column_custom_minimum_width(2, 110)
				set_column_custom_minimum_width(3, 180)
			else:
				column_titles_visible = false
				columns = 1
			
			reload()
#@export var titles : PackedStringArray = []:
	#set(v):
		#if hash(titles) != hash(v):
			#titles = v
			#columns = titles.size()
			#for i in titles.size():
				#set_column_title(i, titles[i])

var titles = ["name", "type", "size", "time"]
var root : TreeItem
var path_to_item : Dictionary = {}
var files : Dictionary = {}


func _init() -> void:
	root = create_item()
	hide_root = true
	button_clicked.connect(
		func(item: TreeItem, column: int, button_type: int, mouse_button_index: int):
			if mouse_button_index == MOUSE_BUTTON_LEFT:
				var path = item.get_meta(MetaKey.PATH)
				self.button_pressed.emit(path, button_type)
	)
	set_column_custom_minimum_width(0, 150)


func reload():
	clear()
	path_to_item.clear()
	root = create_item()
	for file in files:
		add_item(file)

func has_item(path: String) -> bool:
	return files.has(path.replace("\\", "/"))

func add_item(path: String):
	path = path.replace("\\", "/")
	var item : TreeItem
	match show_type:
		ShowType.ONLY_NAME:
			item = root.create_child()
			item.set_text(0, path.get_file())
			item.set_meta(MetaKey.PATH, path)
			item.set_tooltip_text(0, path)
		ShowType.ONLY_PATH:
			item = root.create_child()
			item.set_text(0, path)
			item.set_meta(MetaKey.PATH, path)
			item.set_tooltip_text(0, path)
		ShowType.INFO:
			item = root.create_child()
			if path.get_extension() != "":
				item.set_text(0, path.get_basename().get_file())
			else:
				item.set_text(0, path.get_file())
			item.set_tooltip_text(0, path)
			item.set_text(1, path.get_extension().to_upper())
			var file_size = FileUtil.get_file_size(path, FileUtil.SizeFlag.KB)
			item.set_tooltip_text(2, "%s KB" % str(snappedf(file_size, 0.01)))
			if file_size < 1000:
				item.set_text(2, "%s KB" % str(snappedf(file_size, 0.01)))
			else:
				file_size /= 1024
				if file_size < 1000:
					item.set_text(2, "%s MB" % str(snappedf(file_size, 0.01)))
				else:
					file_size /= 1024
					item.set_text(2, "%s GB" % str(snappedf(file_size, 0.01)))
			var time = FileUtil.get_file_modified_time(path)
			item.set_text(3, Time.get_datetime_string_from_unix_time(time, true))
			item.set_meta(MetaKey.PATH, path)
		ShowType.TREE:
			var last_dir = ""
			var dirs = path.split("/")
			var parent_item : TreeItem
			for idx in dirs.size():
				var dir_name = dirs[idx]
				parent_item = get_item(last_dir)
				if parent_item == null:
					parent_item = root
				last_dir = last_dir.path_join(dir_name)
				if not path_to_item.has(last_dir):
					# 没有父节点
					item = parent_item.create_child()
					path_to_item[last_dir] = item
					item.set_text(0, dir_name)
					item.set_meta(MetaKey.PATH, last_dir)
					item.set_tooltip_text(0, last_dir)
	path_to_item[path] = item
	assert(item != null, "不能没有 item")
	if not files.has(path):
		files[path] = null
		self.added_file.emit(path)
	self.added_item.emit(path, item)


func get_item(path: String) -> TreeItem:
	return path_to_item.get(path)

func remove_item(path: String) -> void:
	var item = get_item(path)
	if item:
		self.removed_item.emit(path, item)
		item.get_parent().remove_child(item)
		path_to_item.erase(path)
		files.erase(path)
		self.removed_file.emit(path)

func get_view_colums_count() -> int:
	if show_type != ShowType.INFO:
		return 1
	else:
		return titles.size()

func select_item(path: String) -> void:
	var item = get_item(path)
	if item:
		item.select(0)

func is_empty() -> bool:
	return root.get_child_count() == 0

func clear_files():
	clear()
	root = create_item()
	path_to_item.clear()
	files.clear()

func update_file(file_path:String, new_path: String):
	var item = get_item(file_path)
	if item:
		remove_item(file_path)
		add_item(new_path)

func get_selected_file() -> String:
	var item = get_selected()
	if item:
		return item.get_meta(MetaKey.PATH)
	return ""

func add_item_button(path: String, texture: Texture2D, button_type:int) -> void:
	var item = get_item(path)
	columns = get_view_colums_count() + 1
	set_column_expand(columns-1, false)
	var idx = columns - 1
	item.add_button(idx, texture, button_type)

func remove_item_button(path: String, button_type: int):
	var item = get_item(path)
	item.erase_button(get_view_colums_count() + 1, button_type)

func get_item_list():
	return files.keys()
