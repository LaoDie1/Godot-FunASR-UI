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
	Config.Misc.config_window_size.bind_property(self, "size", true)

func _exit_tree() -> void:
	Config.Misc.config_window_size.update(self.size)
