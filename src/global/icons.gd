#============================================================
#    Icons
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-24 18:29:16
# - version: 4.3.0.dev5
#============================================================
class_name Icons


const ICONS = preload("icons.tres")
const IMAGES = "res://src/global/icons/imgs/"

static var _dict : Dictionary = {}


static func get_icon(name: StringName, theme_type: StringName = &"EditorIcons") -> Texture2D:
	if not _dict.has(name):
		var path = IMAGES.path_join(name + ".png")
		if FileAccess.file_exists(path):
			_dict[name] = load(path)
		elif ICONS.has_icon(name, theme_type):
			_dict[name] = ICONS.get_icon(name, theme_type)
		else:
			_dict[name] = ICONS.get_icon("File", "EditorIcons")
	return _dict[name]
