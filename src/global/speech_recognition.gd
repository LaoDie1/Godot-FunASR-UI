#============================================================
#    Speech Recognition
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-24 22:26:46
# - version: 4.3.0.dev5
#============================================================
## 语音识别
extends Node


var thread : Thread = Thread.new()


## 是否正在执行语音识别
func is_executing() -> bool:
	return thread.is_alive()


## 进行语音识别
func execute(path: String, mode: String, callback: Callable) -> Error:
	if is_executing():
		return FAILED
	if not FileAccess.file_exists(path):
		return ERR_FILE_BAD_PATH
	if thread.is_started():
		thread.wait_to_finish()
	thread.start( __execute.bind(path, mode, callback) )
	return OK


## 停止
func stop():
	if thread.is_alive():
		thread.wait_to_finish()


func __execute(path: String, mode: String, callback: Callable):
	var time = Time.get_ticks_msec()
	var output = []
	var python_path = ConfigKey.Execute.python_execute_path.get_value("")
	const FUNASR_WSS_CLIENT_PATH = "res://src/assets/funasr_wss_client.py"
	var script_path = FileUtil.get_real_path(FUNASR_WSS_CLIENT_PATH)
	if not FileUtil.file_exists(script_path):
		# 运行在已经导出的文件上了
		script_path = FileUtil.get_project_real_path().path_join("funasr_wss_client.py")
		if not FileUtil.file_exists(script_path):
			FileUtil.copy_file(FUNASR_WSS_CLIENT_PATH, script_path)
		
	var error : int 
	if FileAccess.file_exists(python_path) and FileAccess.file_exists(script_path):
		var host : String = ConfigKey.Execute.host.get_value("")
		var port : int = int(ConfigKey.Execute.port.get_value(0))
		var output_dir = OS.get_cache_dir().path_join("funasr_last_result")
		var params = [
			script_path,
			"--host", host,
			"--port", port,
			"--mode", mode, 
			"--audio_in", path,
			"--output_dir", output_dir
		]
		print("开始语音识别：", python_path, " ", " ".join(params))
		error = OS.execute(python_path, params, output, true)
		var result_file_path = output_dir.path_join("text.0_0")
		output[0] = FileUtil.read_as_string(result_file_path)
		print("识别结束，文字内容暂存到：", result_file_path)
		print("  --- 用时：", (Time.get_ticks_msec() - time) / 1000.0, "s")
		print()
	else:
		output = [""]
		error = ERR_FILE_BAD_PATH
	
	__finish.call_deferred()
	callback.call_deferred({
		"error": error,
		"text": output[0],
		"used_time": Time.get_ticks_msec() - time
	})


func __finish():
	if thread.is_alive():
		thread.wait_to_finish()
