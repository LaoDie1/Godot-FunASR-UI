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


## 进行语音识别
func execute(file_path: String, mode: String, callback: Callable) -> Error:
	if not FileAccess.file_exists(file_path):
		return ERR_FILE_BAD_PATH
	stop()
	thread = Thread.new()
	thread.start( __execute.bind(file_path, mode, callback) )
	return OK

func is_running() -> bool:
	return thread != null

## 停止
func stop():
	if thread != null:
		thread.wait_to_finish()
		thread = null

func __execute(file_path: String, mode: String, callback: Callable):
	var time = Time.get_ticks_msec()
	
	# python 客户端发送音视频文件
	const FUNASR_WSS_CLIENT_PATH = "res://src/assets/funasr_wss_client.py"
	var script_path = FileUtil.get_real_path(FUNASR_WSS_CLIENT_PATH)
	if not FileUtil.file_exists(script_path):
		# 运行在已经导出的文件上了
		script_path = FileUtil.get_project_real_path().path_join("funasr_wss_client.py")
	if not FileUtil.file_exists(script_path):
		FileUtil.copy_file(FUNASR_WSS_CLIENT_PATH, script_path)
	
	# 执行过程
	var error : int 
	var output = []
	var python_path = Config.Execute.python_execute_path.get_value("")
	if FileAccess.file_exists(python_path) and FileAccess.file_exists(script_path):
		# 视频大小超过 500MB 时使用 ffmpeg 将视频转换为 mp3 格式再进行识别
		# 这样可以大大缩短识别文字的耗费时间
		var ffmpeg_path = Config.Execute.ffmpeg_path.get_value("")
		if FileUtil.file_exists(ffmpeg_path):
			if FileQueue.get_file_type(file_path) == FileQueue.VIDEO and FileUtil.get_file_size(file_path, FileUtil.SizeFlag.MB) > 500:
				var mp3_path : String = file_path.get_basename() + "_new.mp3"
				if not FileUtil.file_exists(mp3_path):
					print("开始转换为 mp3 类型文件")
					Main.show_prompt.call_deferred("使用 ffmpeg 将文件为 mp3 发送数据，这样识别快很多")
					print("执行命令：", " ".join([ffmpeg_path, '-i', '"%s"'%file_path, '"%s"'%mp3_path ]))
					var e = OS.execute(ffmpeg_path, ['-i', '"%s"'%file_path, '"%s"'%mp3_path])
					prints(e, error_string(e) )
					if FileUtil.file_exists(mp3_path):
						print("转换 mp3 完成")
						file_path = mp3_path
					else:
						print("转换 mp3 失败")
		# 语音转文字
		var host : String = Config.Execute.host.get_value("")
		var port : int = int(Config.Execute.port.get_value(0))
		var output_dir = OS.get_cache_dir().path_join("funasr_last_result")
		var result_file_path = output_dir.path_join("text.0_0")
		if FileUtil.file_exists(result_file_path):
			FileUtil.delete(result_file_path)
		var params = [
			'"%s"' % script_path,
			"--host", host,
			"--port", port,
			#"--mode", mode, 
			"--mode", "offline", 
			"--audio_in", '"%s"' % file_path,
			"--output_dir", '"%s"' % output_dir
		]
		print("开始语音识别：", python_path, " ", " ".join(params))
		Main.show_prompt.call_deferred("开始语音识别")
		error = OS.execute(python_path, params, output, true)
		output[0] = FileUtil.read_as_string(result_file_path)
		print("识别结束，文字内容暂存到：", result_file_path)
		print("  --- 用时：", (Time.get_ticks_msec() - time) / 1000.0, "s")
		print()
	else:
		output = [""]
		error = ERR_FILE_BAD_PATH
	
	# 结束回调
	callback.call_deferred({
		"error": error,
		"text": output[0],
		"used_time": Time.get_ticks_msec() - time
	})
	stop.call_deferred()
