#============================================================
#    Icons
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-24 18:29:16
# - version: 4.3.0.dev5
#============================================================
class_name Icons


const ICONS = preload("icons.tres")
const LIGHT_ICONS = preload("res://src/global/light_icons.tres")


static func get_icon(name: StringName, theme_type: StringName = &"EditorIcons") -> Texture2D:
	if Global.get_theme_type() == "light":
		if LIGHT_ICONS.has_icon(name, theme_type):
			return LIGHT_ICONS.get_icon(name, theme_type)
	return ICONS.get_icon(name, theme_type)
