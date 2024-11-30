#============================================================
#    New Script
#============================================================
# - author: zhangxuetu
# - datetime: 2024-11-30 21:19:21
# - version: 4.3.0.stable
#============================================================
extends AbstractCustomMenu


func _get_menu_name():
	return "下载到当前插件"

func _execute():
	ApprenticePlugin.instance.SyncFile.download()
