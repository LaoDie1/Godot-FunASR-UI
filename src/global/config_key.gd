#============================================================
#    Config Key
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-25 11:15:57
# - version: 4.3.0.dev5
#============================================================
class_name ConfigKey


static var font_size
static var files
static var recognition_mode


class File:
	static var save_to_directory # 保存到这个目录
	static var file_name_format # 文件名格式


## 执行功能
class Execute:
	static var python_execute_path # Python 所在路径
	static var py_script_path # funasr_wss_client 执行脚本所在路径
	static var host
	static var port


## 杂项
class Misc:
	static var window_position
	static var window_size
	static var left_split_width
	static var config_window_size
