#============================================================
#    Config Setting Container
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-25 14:24:49
# - version: 4.3.0.dev5
#============================================================
extends MarginContainer


const MetaIndex = {
	Property = 0,
	Data = 1,
	ButtonType = "button_type",
}
enum TreeButtonType {
	LoadFile,
	LoadPath,
}

@onready var menu: SimpleMenu = %Menu
@onready var item_list: ItemList = %ItemList
@onready var item_tree: Tree = %ItemTree
@onready var root : TreeItem = item_tree.create_item()
@onready var select_file_dialog: FileDialog = %SelectFileDialog
@onready var select_dir_dialog: FileDialog = %SelectDirDialog

var type_to_item : Dictionary = {}
var left_dict : Dictionary = {}
var hide_propertys : Array = [
	"/Global/files"
]
var _last_item : TreeItem


#============================================================
#  内置
#============================================================
func _ready() -> void:
	menu.init_menu({
		"文件": [ "打开配置文件目录" ]
	})
	item_tree.set_column_title(0, "属性名")
	item_tree.set_column_title(1, "值")
	
	for property_path in Config.propertys:
		var items = property_path.split("/")
		if items[1] == "":
			items[1] = "global"
		if str(items[1]).to_lower() != "misc":
			get_item_paths(items[1]).append(property_path)
	
	item_list.select(0)
	_on_item_list_item_selected(0)



#============================================================
#  自定义
#============================================================
func get_item_paths(type: String) -> Array:
	if not left_dict.has(type):
		left_dict[type] = []
		item_list.add_item(type.capitalize())
		item_list.set_item_metadata(item_list.item_count-1, type)
	return left_dict[type]

func get_property(item: TreeItem):
	return item.get_metadata(MetaIndex.Property)

func get_value(item: TreeItem):
	return item.get_text(1)

func set_value(item: TreeItem, value, alter_config: bool = true):
	if item == null:
		return
	var key = get_property(item)
	var v = value
	#if key in [ConfigKey.Execute.host] or not value is String:
		#v = value
	#else:
		#v = str_to_var(value)
		#if v == null:
			#v = value
	
	# 相同则不修改
	var last_value = item.get_metadata(1)
	if typeof(last_value) == typeof(v) and last_value == v:
		return
	
	if key == ConfigKey.Global.recognition_mode:
		item.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
		item.set_text(MetaIndex.Data, ",".join(Config.ExecuteMode.values()))
		item.set_range(MetaIndex.Data, int(value))
		
	elif key == ConfigKey.Global.font_size:
		item.set_cell_mode(MetaIndex.Data, TreeItem.CELL_MODE_RANGE)
		item.set_range_config(1, 1, Config.MAX_FONT_SIZE, 1)
		item.set_range(MetaIndex.Data, v)
		
	else:
		item.set_text(MetaIndex.Data, str(v))
	
	# 修改值
	item.set_metadata(MetaIndex.Data, value)
	if alter_config:
		Config.set_value(key, v)


#============================================================
#  连接信号
#============================================================
func _on_item_list_item_selected(index: int) -> void:
	item_tree.clear()
	root = item_tree.create_item()
	
	var type = item_list.get_item_metadata(index)
	var keys = get_item_paths(type)
	keys.erase("files")
	for key in keys:
		if hide_propertys.has(key):
			continue
		var item = item_tree.create_item(root)
		var items = key.split("/")
		item.set_metadata(MetaIndex.Property, key)
		item.set_text(MetaIndex.Property, str(items[2]).capitalize())
		item.set_editable(MetaIndex.Data, true)
		
		# 添加额外按钮
		if key in [
			ConfigKey.Execute.python_execute_path, 
			ConfigKey.Execute.py_script_path, 
		]:
			item.add_button(MetaIndex.Data, Icons.get_icon("FileBrowse"))
			item.set_meta(MetaIndex.ButtonType, TreeButtonType.LoadFile)
			
		elif key in [
			ConfigKey.File.save_to_directory
		]:
			item.add_button(MetaIndex.Data, Icons.get_icon("FolderBrowse"))
			item.set_meta(MetaIndex.ButtonType, TreeButtonType.LoadPath)
		
		set_value(item, Config.get_value(key, ""), false)


func _on_menu_menu_pressed(idx: int, menu_path: StringName) -> void:
	match menu_path:
		"/文件/打开配置文件目录":
			OS.shell_open(Config.data_file_path.get_base_dir())


func _on_item_tree_item_edited() -> void:
	var item = item_tree.get_edited()
	var key = item.get_metadata(MetaIndex.Property)
	if key in [
		ConfigKey.Global.recognition_mode,
		ConfigKey.Global.font_size,
	]:
		set_value(item, item.get_range(MetaIndex.Data))
	else:
		set_value(item, item.get_text(MetaIndex.Data))


func _on_item_tree_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	var button_type = item.get_meta(MetaIndex.ButtonType)
	match button_type:
		TreeButtonType.LoadFile:
			var file_path = item.get_text(MetaIndex.Data)
			select_file_dialog.current_path = file_path
			select_file_dialog.popup_centered()
			_last_item = item
		
		TreeButtonType.LoadPath:
			var dir = item.get_text(MetaIndex.Data)
			select_dir_dialog.current_dir = dir
			select_dir_dialog.popup_centered()
			_last_item = item
		
		_:
			printerr("其他类型的按钮：", button_type)


func _on_select_file_dialog_file_selected(path: String) -> void:
	set_value(_last_item, path)


func _on_select_dir_dialog_dir_selected(dir: String) -> void:
	set_value(_last_item, dir)


func _on_close_button_pressed() -> void:
	var parent = get_parent()
	while parent != null and not parent is Window:
		parent = parent.get_parent()
	if parent:
		parent.visible = false
	

