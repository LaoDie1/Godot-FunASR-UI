#============================================================
#    Config Key
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-25 11:15:57
# - version: 4.3.0.dev5
#============================================================
class_name ConfigKey


class Global:
	static var font_size: BindPropertyItem
	static var files: BindPropertyItem
	static var recognition_mode: BindPropertyItem
	static var text_show_mode: BindPropertyItem
	static var highlight_text: BindPropertyItem
	static var split_text: BindPropertyItem


class File:
	static var save_to_directory: BindPropertyItem # 保存到这个目录
	static var file_name_format: BindPropertyItem # 文件名格式


## 执行功能
class Execute:
	static var python_execute_path: BindPropertyItem # Python 所在路径
	static var py_script_path: BindPropertyItem # funasr_wss_client 执行脚本所在路径
	static var host: BindPropertyItem
	static var port: BindPropertyItem


## 杂项
class Misc:
	static var window_position: BindPropertyItem
	static var window_size: BindPropertyItem
	static var window_mode: BindPropertyItem
	static var left_split_width: BindPropertyItem
	static var config_window_size: BindPropertyItem
	static var config_window_left_split_width: BindPropertyItem
