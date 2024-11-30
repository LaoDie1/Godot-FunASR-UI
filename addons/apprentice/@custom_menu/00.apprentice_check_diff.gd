#============================================================
#    New Script
#============================================================
# - author: zhangxuetu
# - datetime: 2024-11-30 21:19:21
# - version: 4.3.0.stable
#============================================================
extends AbstractCustomMenu


func _get_menu_name():
	return "检查差异"

func _execute():
	ApprenticePlugin.instance.SyncFile.check_diff()
