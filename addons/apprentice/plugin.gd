#============================================================
#    Plugin
#============================================================
# - datetime: 2022-08-28 23:28:30
#============================================================
@tool
class_name ApprenticePlugin
extends EditorPlugin


static var instance: ApprenticePlugin

var SyncFile = preload("res://addons/apprentice/@plugin_func/sync_file.gd").new()
var CustomMenu = preload("res://addons/apprentice/@plugin_func/custom_menu.gd").new()


func _enter_tree() -> void:
	instance = self
	SyncFile.plugin = self
	SyncFile.enter()
	CustomMenu.enter()


func _exit_tree() -> void:
	SyncFile.exit()
	CustomMenu.exit()
