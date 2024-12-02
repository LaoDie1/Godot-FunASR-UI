#============================================================
#    System Util
#============================================================
# - author: zhangxuetu
# - datetime: 2024-12-01 15:35:25
# - version: 4.3.0.stable
#============================================================
## 系统工具
class_name SystemUtil

enum ThemeType {
	DARK,
	LIGHT,
}

## 获取主题类型
static func get_theme_type() -> ThemeType:
	if DisplayServer.is_dark_mode_supported():
		return ThemeType.LIGHT if not DisplayServer.is_dark_mode() else ThemeType.DARK
	return ThemeType.DARK


## 执行CMD命令
static func execute_command(params: Array, output: Array = []) -> int:
	var p = ["/C"]
	p.append_array(params)
	return OS.execute("CMD.exe", p, output)

## 名称区分大小写
static func find_running_program(program_name_or_id) -> Array[Dictionary]:
	var output = []
	const CMD_CODE = 'wmic process where "%s" get name,processid,executablepath /format:csv'
	if program_name_or_id is String:
		execute_command([CMD_CODE % ('name like "%' + program_name_or_id + '%"')], output)
	elif program_name_or_id is int:
		execute_command([CMD_CODE % 'processid="' + program_name_or_id + '"'], output)
	var result: String = str(output[0]).strip_edges().replace("\\", "/")
	# 转换为字典格式数据
	var lines = result.split("\r\n")
	if lines.size() == 1:
		return []
	var list : Array[Dictionary] = []
	var keys = lines[0].replace("\r", "").split(",")
	for idx in range(1, lines.size()):
		var items = lines[idx].replace("\r", "").split(",")
		var data = {}
		for kid in keys.size():
			data[keys[kid]] = items[kid]
		list.append(data)
	return list


## 是否有这个相同的程序正在运行
static func current_is_running() -> bool:
	var path = OS.get_executable_path().replace("/", "\\\\")
	var code = 'wmic process where "executablepath LIKE \'%' + path + '%\'" get name,processid,executablepath /format:csv'
	var output = []
	execute_command([code], output)
	var result : String = str(output[0]).strip_edges()
	var items = result.split("\r\n")
	print(items)
	return items.size() > 2 # 只能有一个这样


## 这个线程的程序是否正在执行
static func is_running(pid: int) -> bool:
	return not find_running_program(pid).is_empty()

static var _confirmation_dialog_list : Array[ConfirmationDialog] = []
## 弹出确认框
static func popup_confirmation_dialog(message: String, callback: Callable, title:="请确认...", rect:=Rect2()):
	if _confirmation_dialog_list.is_empty():
		var dialog := ConfirmationDialog.new()
		dialog.visibility_changed.connect(
			func():
				# 隐藏后断开所有连接
				if not dialog.visible:
					for item in dialog.confirmed.get_connections():
						dialog.confirmed.disconnect(item["callable"])
				_confirmation_dialog_list.append(dialog)
		, Object.CONNECT_DEFERRED)
		_confirmation_dialog_list.append(dialog)
		Engine.get_main_loop().current_scene.add_child(dialog)
	var confir_dialog := _confirmation_dialog_list.pop_back() as ConfirmationDialog
	if rect == Rect2():
		confir_dialog.popup_centered()
	else:
		confir_dialog.popup(rect)
	confir_dialog.title = title
	confir_dialog.dialog_text = message
	confir_dialog.confirmed.connect(callback, Object.CONNECT_ONE_SHOT)
