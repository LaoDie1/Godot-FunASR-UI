#============================================================
#    Abstract Custom Menu
#============================================================
# - author: zhangxuetu
# - datetime: 2024-11-30 20:54:57
# - version: 4.3.0.stable
#============================================================
class_name AbstractCustomMenu
extends RefCounted


func _enter():
	pass

func _exit():
	pass


## 菜单名称
func _get_menu_name():
	return ""

## 快捷键
func _get_shortcut() -> Shortcut:
	return null

## 实现功能
func _execute():
	pass
