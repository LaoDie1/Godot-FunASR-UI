#============================================================
#    Custom Menu
#============================================================
# - author: zhangxuetu
# - datetime: 2024-11-30 21:12:16
# - version: 4.3.0.stable
#============================================================
## 自定义菜单
extends RefCounted


const CUSTOM_MENU_PATH = "res://addons/apprentice/@custom_menu"

var root_menu: PopupMenu
var id_to_menu_item : Dictionary = {}


func enter() -> void:
	# 创建目录
	if not DirAccess.get_files_at(CUSTOM_MENU_PATH).is_empty():
		await Engine.get_main_loop().process_frame
		await Engine.get_main_loop().create_timer(0.1).timeout
		var panel = EditorInterface.get_base_control()
		var base_container = panel.get_child(0)
		var editor_tile_bar = base_container.get_child(0)
		var editor_menu_bar = editor_tile_bar.get_child(0) as MenuBar
		root_menu = PopupMenu.new()
		root_menu.name = "自定义"
		root_menu.id_pressed.connect(_id_pressed)
		editor_menu_bar.add_child(root_menu)
		
		# 扫描自定义菜单
		for file in DirAccess.get_files_at(CUSTOM_MENU_PATH):
			if file.get_extension() == "gd":
				var script = load(CUSTOM_MENU_PATH.path_join(file)) as GDScript
				if script.get_base_script() == AbstractCustomMenu:
					var item := script.new() as AbstractCustomMenu
					if item._get_menu_name() != "":
						var id : int = root_menu.item_count
						root_menu.add_item(item._get_menu_name(), id)
						if item._get_shortcut():
							root_menu.set_item_shortcut(id, item._get_shortcut(), true)
						id_to_menu_item[id] = item
						item._enter()
					else:
						push_error(file, " 没有设置菜单名")
				else:
					push_error(file, " 文件不是 AbstractCustomMenu 类型的类")
	else:
		print("%s 目录下创建 AbstractCustomMenu 类脚本，将会自动添加自定义菜单" % CUSTOM_MENU_PATH )


func exit() -> void:
	for item: AbstractCustomMenu in id_to_menu_item.values():
		item._exit()
	root_menu.queue_free()


func _id_pressed(id):
	if id_to_menu_item.has(id):
		var item := id_to_menu_item[id] as AbstractCustomMenu
		item._execute()
	else:
		push_error("没有实现这个功能: ", id)
