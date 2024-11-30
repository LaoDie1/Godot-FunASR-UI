#============================================================
#    Sync File
#============================================================
# - author: zhangxuetu
# - datetime: 2024-11-30 21:11:28
# - version: 4.3.0.stable
#============================================================
## 同步文件
extends RefCounted


const TOOL_NAME_CHECK_DIFF = "Check Plugin-in Difference"
const TOOL_NAME_DOWNLOAD = "Download Plug-in"
const TOOL_NAME_UPLOAD = "Upload Plug-in"

const Status = {
	DIFF = &"内容有差异",
	NOT_EXISTS_FILE = &"不存在文件",
	NOT_EXISTS_DIRECTORY = &"不存在目录",
}

# 总仓库路径
var root_path := OS.get_data_dir().path_join("godot-init-plugin/apprentice")
var current_path : String = "res://addons/apprentice"
var plugin: EditorPlugin


func enter() -> void:
	plugin.add_tool_menu_item(TOOL_NAME_CHECK_DIFF, check_diff) # 检查差异
	plugin.add_tool_menu_item(TOOL_NAME_UPLOAD, upload) # 上传
	plugin.add_tool_menu_item(TOOL_NAME_DOWNLOAD, download) # 下载


func exit() -> void:
	plugin.remove_tool_menu_item(TOOL_NAME_DOWNLOAD)
	plugin.remove_tool_menu_item(TOOL_NAME_UPLOAD)
	plugin.remove_tool_menu_item(TOOL_NAME_CHECK_DIFF)


func check_diff():
	print("=".repeat(80))
	var list : Array[Dictionary] 
	var diff_status : bool = false
	# 当前插件不存在的
	list = _check_diff(root_path, current_path)
	if not list.is_empty():
		diff_status = true
		prints("当前插件", current_path, "与以下文件的区别：")
		for data in list:
			prints("   %-7s %s" % [data["status"], data["from"]])
	# 总插件不存在的
	list = _check_diff(current_path, root_path)
	if not list.is_empty():
		diff_status = true
		prints("总插件", root_path, "与以下文件的区别：")
		for data in list:
			prints("   %-7s %s" % [data["status"], data["from"]])
	if not diff_status:
		print("  没有差异")
	print("=".repeat(80))


func upload():
	var list : Array[Dictionary] = _check_diff(root_path, current_path)
	if not list.is_empty():
		print("修改 %s 目录的文件" % root_path)
		for item in list:
			match item["status"]:
				Status.DIFF:
					FileUtil.copy_file(item["to"], item["from"])
					print(" ✔ 更新 ", item["from"])
				Status.NOT_EXISTS_FILE, Status.NOT_EXISTS_DIRECTORY:
					FileUtil.remove(item["from"])
					print(" ✘ 移除 ", item["from"])
		
		list = _check_diff(current_path, root_path)
		for item in list:
			if item["status"] in [Status.NOT_EXISTS_FILE, Status.NOT_EXISTS_DIRECTORY]:
				FileUtil.copy_directory_and_file(item["from"], item["to"])
				print(" ✔ 新增 ", item["to"])
			
	else:
		print("没有差异文件")
	print()


func download():
	var list : Array[Dictionary] = _check_diff(current_path, root_path)
	if not list.is_empty():
		print("修改 %s 目录的文件" % current_path)
		for item in list:
			match item["status"]:
				Status.DIFF:
					FileUtil.copy_file(item["to"], item["from"])
					print(" ✔ 更新 ", item["from"])
				Status.NOT_EXISTS_FILE, Status.NOT_EXISTS_DIRECTORY:
					FileUtil.remove(item["from"])
					print(" ✘ 移除 ", item["from"])
		list = _check_diff(root_path, current_path)
		for item in list:
			if item["status"] in [Status.NOT_EXISTS_FILE, Status.NOT_EXISTS_DIRECTORY]:
				FileUtil.copy_directory_and_file(item["from"], item["to"])
				print(" ✔ 新增 ", item["to"])
		EditorInterface.get_resource_filesystem().scan()
		EditorInterface.get_resource_filesystem().scan_sources()
	else:
		print("没有差异文件")
	print()


static func _check_diff(from_path: String, to_path: String, list:Array[Dictionary]=[]) -> Array:
	if DirAccess.dir_exists_absolute(from_path):
		for dir in DirAccess.get_directories_at(from_path):
			if DirAccess.dir_exists_absolute(to_path.path_join(dir)):
				_check_diff(from_path.path_join(dir), to_path.path_join(dir), list)
			else:
				list.append({
					"from": from_path.path_join(dir),
					"to": to_path.path_join(dir),
					"status": Status.NOT_EXISTS_DIRECTORY,
				})
		# 当前文件替换到另一个目录里
		var files : PackedStringArray = DirAccess.get_files_at(from_path)
		var from_file_path : String = ""
		var to_file_path : String = ""
		for file in files:
			from_file_path = from_path.path_join(file)
			to_file_path = to_path.path_join(file)
			if FileAccess.get_md5(from_file_path) != FileAccess.get_md5(to_file_path):
				# 不同的文件则进行替换
				list.append({
					"from": from_file_path, 
					"to": to_file_path,
					"status": Status.DIFF if FileAccess.get_md5(to_file_path) != "" else Status.NOT_EXISTS_FILE
				})
	return list
