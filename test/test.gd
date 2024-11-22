extends Node2D

func _ready() -> void:
	var params = [
		r"C:\Users\z\Desktop\FunASR\funasr_wss_client.py",
		"--host", "127.0.0.1",
		"--port", "10095", 
		"--mode", "offline",
		"--audio_in", r"C:\Users\z\Videos\带货\地锅鸡\WCJG5171.MP4_new.mp3",
		"--output_dir", r"C:\Users\z\Desktop\FunASR\result"
	]
	print(" ".join(params))
	await Engine.get_main_loop().create_timer(0.5).timeout
	var output = []
	var error = OS.execute("C:/Users/z/AppData/Local/Programs/Python/Python311/python.exe", params, output)
	print(error_string(error))
	print(output)
