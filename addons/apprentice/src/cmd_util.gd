#============================================================
#    Cmd Util
#============================================================
# - author: zhangxuetu
# - datetime: 2024-11-30 14:47:07
# - version: 4.3.0.stable
#============================================================
class_name CMDUtil


## 执行CMD命令
static func execute(params: Array, output: Array = []) -> int:
	var p = ["/C"]
	p.append_array(params)
	return OS.execute("CMD.exe", p, output)


## 名称区分大小写
static func find_running_program(program_name_or_id) -> Array[Dictionary]:
	var output = []
	const CMD_CODE = 'wmic process where "%s" get name,processid,executablepath /format:csv'
	if program_name_or_id is String:
		execute([CMD_CODE % ('name like "%' + program_name_or_id + '%"')], output)
	elif program_name_or_id is int:
		execute([CMD_CODE % 'processid="' + program_name_or_id + '"'], output)
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
	execute([code], output)
	var result : String = str(output[0]).strip_edges()
	var items = result.split("\r\n")
	print(items)
	return items.size() > 2 # 只能有一个这样


## 这个线程的程序是否正在执行
static func is_running(pid: int) -> bool:
	return not find_running_program(pid).is_empty()
