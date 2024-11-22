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
	ProperyItem = "item",
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
@onready var h_split_container: HSplitContainer = %HSplitContainer

var type_to_item : Dictionary = {}
var left_dict : Dictionary = {}
var hide_propertys : Array = [
	"/Global/files",
	"/Misc/left_split_width",
	"/Misc/config_window_size",
]
var list_items := {}

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
	
	item_list.clear()
	for bind_item:BindPropertyItem in Config.propertys:
		if hide_propertys.has(bind_item.get_name()) or bind_item.get_name().begins_with("/Misc"):
			continue
		var items = bind_item.get_name().split("/")
		var type = items[1]
		if not list_items.has(type):
			var list : Array[BindPropertyItem] = []
			list_items[type] = list
			var index = item_list.item_count
			item_list.set_meta("_%d" % index, list)
			item_list.add_item(type)
		list_items[type].append(bind_item)
	
	ConfigKey.Misc.config_window_left_split_width.bind_property(h_split_container, "split_offset", true)



#============================================================
#  自定义
#============================================================
func get_property(item: TreeItem):
	return item.get_metadata(MetaIndex.Property)

func get_value(item: TreeItem):
	return item.get_text(1)

func set_value(item: TreeItem, value, alter_config: bool):
	if item == null:
		return
	var property_path := str(get_property(item))
	var v = value
	
	# 相同则不修改
	var last_value = item.get_metadata(1)
	if typeof(last_value) == typeof(v) and last_value == v:
		return
	
	if property_path == ConfigKey.Global.recognition_mode.get_name():
		item.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
		item.set_text(MetaIndex.Data, ",".join(Config.ExecuteMode.values()))
		item.set_range(MetaIndex.Data, int(value))
		
	elif property_path == ConfigKey.Global.font_size.get_name():
		item.set_cell_mode(MetaIndex.Data, TreeItem.CELL_MODE_RANGE)
		item.set_range_config(1, 1, Config.MAX_FONT_SIZE, 1)
		if v is float or v is int:
			item.set_range(MetaIndex.Data, v)
		
	else:
		item.set_text(MetaIndex.Data, str(v))
	
	# 修改值
	item.set_metadata(MetaIndex.Data, value)
	if alter_config:
		Config.get_bind_property(property_path).update(v)


#============================================================
#  连接信号
#============================================================
func _on_item_list_item_selected(index: int) -> void:
	item_tree.clear()
	root = item_tree.create_item()
	
	var bind_propertys : Array[BindPropertyItem] = item_list.get_meta("_%d" % index)
	for bind_property in bind_propertys:
		var item = item_tree.create_item(root)
		var items = bind_property.get_name().split("/")
		item.set_metadata(MetaIndex.Property, bind_property.get_name())
		item.set_text(MetaIndex.Property, str(items[2]).capitalize())
		item.set_editable(MetaIndex.Data, true)
		
		# 添加额外按钮
		if bind_property in [
			ConfigKey.Execute.python_execute_path, 
		]:
			item.add_button(MetaIndex.Data, Icons.get_icon("FileBrowse"))
			item.set_meta(MetaIndex.ButtonType, TreeButtonType.LoadFile)
			
		elif bind_property in [
			ConfigKey.File.save_to_directory
		]:
			item.add_button(MetaIndex.Data, Icons.get_icon("FolderBrowse"))
			item.set_meta(MetaIndex.ButtonType, TreeButtonType.LoadPath)
		
		set_value(item, bind_property.get_value(), false)


func _on_menu_menu_pressed(idx: int, menu_path: StringName) -> void:
	match menu_path:
		"/文件/打开配置文件目录":
			OS.shell_open(Config.data_file_path.get_base_dir())


func _on_item_tree_item_edited() -> void:
	var item = item_tree.get_edited()
	var key = item.get_metadata(MetaIndex.Property)
	if key in [
		ConfigKey.Global.recognition_mode.get_name(),
		ConfigKey.Global.font_size.get_name(),
	]:
		set_value(item, item.get_range(MetaIndex.Data), true)
	else:
		set_value(item, item.get_text(MetaIndex.Data), true)


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
	set_value(_last_item, path, true)


func _on_select_dir_dialog_dir_selected(dir: String) -> void:
	set_value(_last_item, dir, true)


func _on_close_button_pressed() -> void:
	var parent = get_parent()
	while parent != null and not parent is Window:
		parent = parent.get_parent()
	if parent:
		parent.visible = false
	


func _on_h_split_container_dragged(offset: int) -> void:
	ConfigKey.Misc.config_window_left_split_width.update(offset)
