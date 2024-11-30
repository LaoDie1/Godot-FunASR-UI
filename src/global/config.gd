#============================================================
#    Config
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-25 11:15:57
# - version: 4.3.0.dev5
#============================================================
class_name Config


static var default_value: Dictionary = {
	"/Project/font_size": 16,
	"/Project/recognition_mode": "offline",
	"/Project/split_text": "，。？！,?.",
	
	"/Execute/host": "127.0.0.1",
	"/Execute/port": "10095",
	
	"/File/save_to_directory": OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS),
	"/File/file_name_format": "{name}.txt",
	
	"/Misc/files": [],
	"/Misc/left_split_width": 0,
	"/Misc/file_view": 0,
}

class Project:
	static var recognition_mode: BindPropertyItem
	static var theme: BindPropertyItem
	static var font_size: BindPropertyItem
	static var text_show_mode: BindPropertyItem

## 执行功能
class Execute:
	static var python_execute_path: BindPropertyItem # Python 所在路径
	static var host: BindPropertyItem
	static var port: BindPropertyItem
	static var ffmpeg_path: BindPropertyItem # FFMpeg 执行文件所在路径

class File:
	static var save_to_directory: BindPropertyItem # 保存到这个目录
	static var file_name_format: BindPropertyItem # 文件名格式

## 杂项
class Misc:
	static var files: BindPropertyItem  #所有添加准备识别的文件
	static var window_position: BindPropertyItem
	static var window_size: BindPropertyItem
	static var window_mode: BindPropertyItem
	static var left_split_width: BindPropertyItem
	static var config_window_size: BindPropertyItem
	static var config_window_left_split_width: BindPropertyItem
	static var highlight_text: BindPropertyItem
	static var split_text: BindPropertyItem
	static var file_view: BindPropertyItem
