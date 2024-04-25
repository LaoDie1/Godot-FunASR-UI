#============================================================
#    Config Window
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-25 14:11:25
# - version: 4.3.0.dev5
#============================================================
extends Window


#============================================================
#  内置
#============================================================
func _init() -> void:
	close_requested.connect(hide)

func _enter_tree() -> void:
	size = Config.get_value(ConfigKey.Misc.config_window_size)

func _exit_tree() -> void:
	Config.set_value(ConfigKey.Misc.config_window_size, size)
