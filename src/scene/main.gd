#============================================================
#    Main
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-24 14:21:30
# - version: 4.3.0.dev5
#============================================================
class_name Main
extends Control


const SHOW_MODE_GROUP = preload("res://src/global/show_mode_group.tres")


@onready var menu: SimpleMenu = %Menu
@onready var current_path_label: Label = %CurrentPathLabel
@onready var start_button: Button = %StartButton
@onready var recognition_mode_button: OptionButton = %RecognitionModeButton
@onready var hot_word_container: MarginContainer = %HotWordContainer
@onready var text_container: TextContainer = %TextContainer
@onready var file_size_label: Label = %FileSizeLabel
@onready var left_split_container: HSplitContainer = %LeftSplitContainer
@onready var middle_split_container: HSplitContainer = %MiddleSplitContainer
@onready var config_window: Window = %ConfigWindow
@onready var auto_execute_timer: Timer = %AutoExecuteTimer
@onready var confirmation_dialog: ConfirmationDialog = %ConfirmationDialog
@onready var about_window = %AboutWindow
@onready var finish_audio_player: AudioStreamPlayer = %FinishAudioPlayer
@onready var error_audio_player: AudioStreamPlayer = %ErrorAudioPlayer
@onready var save_as_dialog: FileDialog = %SaveAsDialog
@onready var file_tree: FileTree = %FileTree
@onready var file_view_button: OptionButton = %FileViewButton
@onready var prompt_color: ColorRect = %PromptColor

static var prompt_animation_player: AnimationPlayer
static var prompt_label: Label

var auto_save_timer := NodeUtil.create_timer(0.5, self, Callable(), false, true)
var current_path: String:
	set(v):
		current_path = v
		current_path_label.text = current_path if current_path else "(无)"


#============================================================
#  内置
#============================================================
func _ready() -> void:
	prompt_label = %PromptLabel
	prompt_animation_player = %PromptAnimationPlayer
	menu.init_menu({
		"文件": [
			"另存为", "自动保存并移动源文件", "-",
			"设置"
		],
		"操作": [
			"运行语音识别", "自动执行并保存", "自动保存时跳过空白内容", "-", 
			"打开选中文件所在目录", "修正队列文件名", "清空队列文件"
		],
		"帮助": ["关于"],
	})
	menu.init_shortcut({
		"/文件/另存为": SimpleMenu.parse_shortcut("Ctrl+S"),
		"/文件/自动保存并移动源文件": SimpleMenu.parse_shortcut("Ctrl+Shift+S"),
		"/文件/设置": SimpleMenu.parse_shortcut("Ctrl+P"),
		"/操作/运行语音识别": SimpleMenu.parse_shortcut("Ctrl+E"),
	})
	menu.init_icon({
		"/文件/另存为": Icons.get_icon("Save"),
		"/文件/设置": Icons.get_icon("GDScript"),
		"/操作/运行语音识别": Icons.get_icon("Play"),
		"/操作/打开选中文件所在目录": Icons.get_icon("Load"),
		"/操作/自动执行并保存": Icons.get_icon("AutoPlay"),
		"/操作/修正队列文件名": Icons.get_icon("Rename"),
		"/操作/清空队列文件": Icons.get_icon("Clear"),
		"/帮助/关于": Icons.get_icon("Info"),
	})
	menu.set_menu_as_checkable("/操作/自动执行并保存", true)
	menu.set_menu_as_checkable("/操作/自动保存时跳过空白内容", true)
	menu.set_menu_checked("/操作/自动保存时跳过空白内容", true)
	
	# 识别模式
	recognition_mode_button.clear()
	for item in Global.ExecuteMode.values():
		recognition_mode_button.add_item(item)
	if Config.Project.recognition_mode.get_value():
		Config.Project.recognition_mode.bind_method(recognition_mode_button.select, true)
	Config.Misc.left_split_width.bind_property(left_split_container, "split_offset", true)
	Config.Misc.file_view.bind_method(
		func(v: int): 
			file_tree.show_type = v
			file_view_button.select.call_deferred(v), 
		true
	)
	for key:String in FileTree.ShowType.keys():
		file_view_button.add_item(key.capitalize())
	# 加载文件
	for file in Config.Misc.files.get_value([]):
		file_tree.add_item(file)
	# 更新主题
	FuncUtil.thread_execute(Config.Project.theme.bind_method.bind( 
		func(v): update_theme(), true)
	)
	DisplayServer.set_system_theme_change_callback(update_theme)
	#show_prompt("注意：识别的时间是预测的时间并不完全准确")
	show_prompt("加载主题...")
	# 处理拖拽文件
	Engine.get_main_loop().root.files_dropped.connect(
		func(files:Array):
			var status : bool = file_tree.is_empty()
			for file in files:
				if file.get_extension().to_lower() in [
					"aac", "aif", "aiff", "amr", "ape", "au", "awb", "caf", "dct", "dss", "dvf", "flac", "gsm", "iklax", "ivs", "m4a", "m4b", "m4p", "mmf", "mp3", "mpc", "msv", "ogg", "oga", "opus", "ra", "ram", "raw", "rf64", "sln", "tta", "voc", "vox", "wav", "wma", "wv",
					"mp4", "flv", "webm", "avi", "mov", "mkv", "ogv", "rmvb","3g2", "3gp", "3gp2", "3gpp", "amv", "asf", "avi", "avs", "bik", "bin", "bix", "bmk", "divx", "drc", "dv", "dvr - ms", "evo", "f4v", "flv", "gvi", "gxf", "iso", "m1v", "m2v", "m2t", "m2ts", "m4v", "mkv", "mov", "mp2", "mp2v", "mp4v", "mpe", "mpeg", "mpeg1", "mpeg2", "mpeg4", "mpg", "mpv2", "mts", "mtv", "mxf", "mxg", "nsv", "nuv", "ogg", "ogm", "ogv", "ps", "rec", "rm", "rmvb", "rpl", "thp", "tod", "ts", "tts", "txd", "vob", "vp3", "vp6", "vro", "webm", "wm", "wmv", "wtv", "xesc",
				]:
					if not file_tree.has_item(file):
						file_tree.add_item(file)
					else:
						print("已添加过：", file)
			if status:
				if file_tree.get_selected_file() == "":
					file_tree.select_item(files.front())
	)
	prompt_animation_player.play("RESET")
	update_selected_file_size()


## 开始执行语音识别
func execute(path: String):
	if not FileAccess.file_exists(path):
		auto_execute_timer.stop()
		error_audio_player.play()
		show_prompt("执行错误，不存在这个路径： <%s>" % path)
		return
	
	if SpeechRecognition.is_running():
		show_prompt("正在识别语音.")
		return
	
	current_path = path
	text_container.play_animation("run")
	text_container.set_text("")
	start_button.disabled = true
	print("识别文件：", path)
	SpeechRecognition.execute(path, recognition_mode_button.text, 
		func(output: Dictionary):
			var error : int = output.error
			var result: String = output.text
			text_container.play_animation("RESET")
			start_button.disabled = false
			if error == OK:
				text_container.set_text(result)
				
				if menu.get_menu_checked("/操作/自动执行并保存"):
					auto_save_timer.start(0.5)
					await auto_save_timer.timeout
					var success = auto_save()
					if not success:
						# 保存时出现错误，则停止
						auto_execute_timer.stop()
						menu.set_menu_checked("/操作/自动执行并保存", false)
						error_audio_player.play()
				
				finish_audio_player.play()
				
			else:
				show_prompt("执行时出现错误：%d %s" % [error, error_string(error)])
				error_audio_player.play()
	)


func auto_save() -> bool:
	if file_tree.get_selected_file() != "":
		
		# 移动原始文件
		var save_to_directory : String = Config.File.save_to_directory.get_value()
		if not DirAccess.dir_exists_absolute(save_to_directory):
			show_prompt("设置中的保存到的目录不存在，请重新设置！")
			return false
		
		var to_path : String = save_to_directory.path_join(current_path.get_file())
		var error : int = FileUtil.move_file(current_path, to_path)
		if error == OK:
			# 文件路径
			var file_name_format : String = Config.File.file_name_format.get_value("")
			var time : String = Time.get_datetime_string_from_system() \
				.replace("-", "") \
				.replace(":", "") \
				.replace("T", "")
			var file_name : String = file_name_format.format({
				"name": current_path.get_file().get_basename() + "_" + time,
			})
			var file_path : String = save_to_directory.path_join(file_name)
			# 保存文本
			FileUtil.write_as_string(file_path, text_container.get_text() )
			print("已保存：%s\n" % file_path)
			
			file_tree.remove_item(current_path)
			text_container.set_text("")
			current_path = ""
			if file_tree.get_selected() != null:
				file_tree.select(0)
			return true
		else:
			show_prompt("保存时出现失败：", [error, " ", error_string(error)])
			error_audio_player.play()
	else:
		show_prompt("没有选中文件")
	return false


## 提示信息
static func show_prompt(text: String, items: Array = [], connect_char: String = ""):
	prompt_label.text = text + connect_char.join(items)
	prompt_animation_player.play("prompt")


# 更正文件名
func _update_queue_files():
	if file_tree.is_empty():
		return
	
	print("开始更正文件列表：")
	var files : Array = file_tree.get_files()
	var error : int
	var file : String
	for idx in files.size():
		file = files[idx]
		var file_name : String = file.get_file()
		if file_name.contains(" "):
			var new_path : String = file.get_base_dir().path_join(
				file_name.replace(" ", "")
			) 
			error = DirAccess.rename_absolute(file, new_path)
			if error == OK:
				file_tree.update_file_name(file, new_path)
				print("  | ", file.get_file(), "  --->  ", new_path.get_file())
			else:
				error_audio_player.play()
				show_prompt("修正文件名时出现错误: ", [
					error, " (", error_string(error), ") ",
					" old: ", file,
					", new: ", new_path
				])
				return
	
	show_prompt("更正结束")

# 主题
func update_theme():
	if DisplayServer.is_dark_mode_supported():
		FileUtil
		var window : Window = get_viewport()
		var type = Global.get_theme_type()
		if type == "dark":
			window.theme = FileUtil.load_file("res://src/assets/dark_theme.tres")
			RenderingServer.set_default_clear_color(Color(0.2, 0.2, 0.2))
			prompt_color.color = Color.BLACK
		elif type == "light":
			window.theme = FileUtil.load_file("res://src/assets/light_theme.tres")
			RenderingServer.set_default_clear_color(Color(0.95, 0.95, 0.95))
			prompt_color.color = Color.WHITE
		else:
			push_error("错误的主题类型：", type)
		file_tree.reload()


func update_selected_file_size() -> void:
	var file = file_tree.get_selected_file()
	if file:
		current_path = file
		const byte_quantities: Array[float] = [
			1e3, # KB
			1e6, # MB
			1e9, # GB
		]
		var length : int = FileUtil.get_file_length(file)
		file_size_label.text = "%.2f MB" % (length / byte_quantities[1])
		file_size_label.tooltip_text = "字节长度：%d" % length
	else:
		file_size_label.text = "0 MB"
		file_size_label.tooltip_text = ""
		current_path = ""


## 执行识别选中的文件
func execute_selected_file() -> void:
	if not start_button.disabled:
		start_button.grab_focus()
		if not file_tree.is_empty():
			execute(file_tree.get_selected_file())
		else:
			show_prompt("没有选中执行的文件")


func save_to(path: String) -> void:
	FileUtil.write_as_string(path, text_container.get_text())


#============================================================
#  连接信号
#============================================================
func _on_menu_menu_pressed(idx: int, menu_path: StringName) -> void:
	match menu_path:
		"/文件/另存为":
			save_as_dialog.popup_centered()
		"/操作/运行语音识别":
			execute_selected_file()
		
		"/文件/设置":
			config_window.popup_centered()
		
		"/操作/修正队列文件名":
			confirmation_dialog.set_meta("callback", _update_queue_files)
			confirmation_dialog.dialog_text = "\n".join([
				"  警告\n",
				"· 将列表中文件名中的 [空格] 去除才能正确执行",
				"· 确定要更正列表中的文件名吗？",
				"· 此操作不能撤销！"
			])
			confirmation_dialog.popup_centered()
		
		"/文件/自动保存并移动源文件":
			auto_save()
		
		"/操作/打开选中文件所在目录":
			var file : String = file_tree.get_selected_file()
			if file:
				FileUtil.shell_open(file)
			else:
				show_prompt("没有选中文件")
			
		"/操作/清空队列文件":
			confirmation_dialog.dialog_text = "此操作会清空队列中的所有文件，是否继续操作？"
			confirmation_dialog.popup_centered()
			confirmation_dialog.set_meta("callback", func():
				file_tree.clear_files()
				update_selected_file_size()
			)
		
		"/帮助/关于":
			about_window.popup_centered()
		
		#_:
			#print("可能是未处理的菜单功能：", menu_path)

func _on_left_split_container_dragged(offset: int) -> void:
	Config.Misc.left_split_width.update(offset)


func _on_auto_execute_timer_timeout() -> void:
	if file_tree.is_empty():
		auto_execute_timer.stop()
		return
	if not start_button.disabled:
		execute_selected_file()

func _on_recognition_mode_button_item_selected(index: int) -> void:
	Config.Project.recognition_mode.update(index)


func _on_confirmation_dialog_confirmed() -> void:
	var callback : Callable = Callable(confirmation_dialog.get_meta("callback"))
	callback.call()


func _on_menu_menu_check_toggled(idx: int, menu_path: StringName, status: bool) -> void:
	match menu_path:
		"/操作/自动执行并保存":
			if status:
				auto_execute_timer.start()
			else:
				auto_execute_timer.stop()
		
		#_:
			#show_prompt("未实现功能：%s" % menu_path)

enum ButtonType {
	SHOW,
	REMOVE,
}

func _on_file_tree_added_item(path: String, item: TreeItem) -> void:
	var type = Global.get_file_type(path)
	if type == Global.SOUND:
		item.set_icon(0, Icons.get_icon("AudioStreamMP3"))
	elif type == Global.VIDEO:
		item.set_icon(0, Icons.get_icon("VideoStreamTheora"))
	file_tree.add_item_button(path, Icons.get_icon("Load"), ButtonType.SHOW)
	file_tree.add_item_button(path, Icons.get_icon("Remove"), ButtonType.REMOVE)


func _on_file_tree_button_pressed(path: String, button_type: int) -> void:
	match button_type:
		ButtonType.SHOW:
			FileUtil.shell_open(path)
		ButtonType.REMOVE:
			file_tree.remove_item(path)


func _on_file_tree_removed_file(path: String) -> void:
	Config.Misc.files.get_value([]).erase(path)


func _on_file_view_button_item_selected(index: int) -> void:
	file_tree.show_type = index
	Config.Misc.file_view.update(index)


func _on_file_tree_added_file(path: String) -> void:
	Config.Misc.files.update( file_tree.get_item_list() )
