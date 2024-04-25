#============================================================
#    Speech Recognition
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-24 22:26:46
# - version: 4.3.0.dev5
#============================================================
## 语音识别
extends Node


var thread : Thread


## 是否正在执行语音识别
func is_executing() -> bool:
	return thread != null


## 进行语音识别
func execute(path: String, mode: String, callback: Callable) -> Error:
	if is_executing():
		return FAILED
	if not FileAccess.file_exists(path):
		return ERR_FILE_BAD_PATH
	thread = Thread.new()
	thread.start( __execute.bind(path, mode, callback) )
	return OK


func __execute(path: String, mode: String, callback: Callable):
	var time = Time.get_ticks_msec()
	var output = []
	var python_path : String = Config.get_value(ConfigKey.Execute.python_execute_path)
	var script_path : String  = Config.get_value(ConfigKey.Execute.py_script_path)
	var error : int 
	if FileAccess.file_exists(python_path) and FileAccess.file_exists(script_path):
		var host : String = Config.get_value(ConfigKey.Execute.host)
		var port : int = int(Config.get_value(ConfigKey.Execute.port))
		error = OS.execute(python_path, [
			script_path,
			"--host", host,
			"--port", port,
			"--mode", mode, 
			"--audio_in", path,
		], output, true)
		
		print("=".repeat(50))
		print(output[0])
		print("  --- 用时：", (Time.get_ticks_msec() - time) / 1000.0, "s")
		print()
	else:
		output = [""]
		error = ERR_FILE_BAD_PATH
	
	__finish.call_deferred()
	callback.call_deferred({
		"error": error,
		"result": output[0],
		"used_time": Time.get_ticks_msec() - time
	})


func __finish():
	thread.wait_to_finish()
	thread = null

