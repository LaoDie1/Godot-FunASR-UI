#============================================================
#    Plugin
#============================================================
# - datetime: 2022-08-28 23:28:30
#============================================================
@tool
extends EditorPlugin


const TOOL_NAME_CHECK_DIFF = "Check Plugin-in Difference"
const TOOL_NAME_DOWNLOAD = "Download Plug-in"
const TOOL_NAME_UPLOAD = "Upload Plug-in"


func _enter_tree() -> void:
	# 总仓库路径
	var root_path := OS.get_data_dir().path_join("godot-init-plugin/apprentice")
	# 检查差异
	add_tool_menu_item(TOOL_NAME_CHECK_DIFF, func():
		var from = root_path
		var to = "res://addons/apprentice/"
		
		# 当前仓库不存在的
		var list = []
		check_diff(from, to, list)
		print("当前插件目录中的差异")
		for data in list:
			print("  ", data["status"], "：", data["from"])
		
		# 总仓库不存在的
		list = []
		check_diff(to, from, list)
		print("根插件目录中的差异")
		for data in list:
			print("  ", data["status"], "：", data["from"])
	)
	# 上传
	add_tool_menu_item(TOOL_NAME_UPLOAD, func():
		var current_path = str(get_script().resource_path).get_base_dir()
		print("<从 %s 上传到 %s>" % [current_path, root_path])
		copy_directory_and_file(current_path, root_path)
		print_debug("<完成>")
	)
	# 下载
	add_tool_menu_item(TOOL_NAME_DOWNLOAD, func():
		if DirAccess.dir_exists_absolute(root_path) and DirAccess.get_directories_at(root_path).is_empty():
			push_error("还没有默认插件，先点击 ", TOOL_NAME_UPLOAD, " 之后，更新代码时进行下载")
			return
		var current_path = str(get_script().resource_path).get_base_dir()
		print("<从 %s 下载到 %s>" % [root_path, current_path])
		copy_directory_and_file(root_path, current_path)
		EditorUtil.scan_files()
		print_debug("<完成>")
	)
	


func _exit_tree() -> void:
	remove_tool_menu_item(TOOL_NAME_DOWNLOAD)
	remove_tool_menu_item(TOOL_NAME_UPLOAD)
	remove_tool_menu_item(TOOL_NAME_CHECK_DIFF)


static func check_diff(from_path: String, to_path: String, list:Array) -> void:
	if DirAccess.dir_exists_absolute(from_path):
		for dir in DirAccess.get_directories_at(from_path):
			check_diff(from_path.path_join(dir), to_path.path_join(dir), list)
		# 当前文件替换到另一个目录里
		var files = DirAccess.get_files_at(from_path)
		for file in files:
			if FileAccess.get_md5(from_path.path_join(file)) != FileAccess.get_md5(to_path.path_join(file)):
				# 不同的文件则进行替换
				list.append({
					"from": from_path.path_join(file), 
					"to": to_path.path_join(file),
					"status": "差异" if FileAccess.get_md5(to_path.path_join(file)) != "" else "不存在"
				})


## 复制目录和文件
static func copy_directory_and_file(from_path: String, to_path: String):
	FileUtil.make_dir_if_not_exists(to_path)
	if DirAccess.dir_exists_absolute(from_path):
		for dir in DirAccess.get_directories_at(from_path):
			FileUtil.make_dir_if_not_exists(to_path.path_join(dir))
			copy_directory_and_file(from_path.path_join(dir), to_path.path_join(dir))
		# 当前文件替换到另一个目录里
		var files = DirAccess.get_files_at(from_path)
		for file in files:
			if FileAccess.get_md5(from_path.path_join(file)) != FileAccess.get_md5(to_path.path_join(file)):
				# 不同的文件则进行替换
				DirAccess.copy_absolute(from_path.path_join(file), to_path.path_join(file))
				print("  ✔ 更新：", to_path.path_join(file))
		# 删除另一个目录里不存在的文件
		for file in DirAccess.get_files_at(to_path):
			if not files.has(file):
				OS.move_to_trash(to_path.path_join(file))
				print("  ✘ 删除：", to_path.path_join(file))
