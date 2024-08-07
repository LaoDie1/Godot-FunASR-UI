#============================================================
#    Text Container
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-24 22:41:27
# - version: 4.3.0.dev5
#============================================================
class_name TextContainer
extends MarginContainer


static var text_regex : RegEx:
	get:
		if text_regex == null:
			text_regex = RegEx.new()
			text_regex.compile("demo: (?<demo>.*?) timestamp:(?<timestamp>.*)")
		return text_regex
static var paragraph_regex : RegEx: # 段落
	get:
		if paragraph_regex == null:
			paragraph_regex = RegEx.new()
			paragraph_regex.compile("(.*?)[，。？！,\\?\\.x]")
		return paragraph_regex


@onready var text_edit: CodeEdit = %TextEdit
@onready var prompt_label_anim_player: AnimationPlayer = %PromptLabelAnimPlayer
@onready var show_mode_container: HBoxContainer = %ShowModeContainer
@onready var font_size_label: Label = %FontSizeLabel
@onready var font_size_slider: HSlider = %FontSizeSlider


var button_group : ButtonGroup


#============================================================
#  内置
#============================================================
func _ready() -> void:
	button_group = ButtonGroup.new()
	for child in show_mode_container.get_children():
		if child is BaseButton:
			child.button_group = button_group
	button_group.pressed.connect(
		func(button: Button):
			print("切换显示模式：", button.text)
			set_text(get_origin_text())
	)
	button_group.get_buttons()[0].button_pressed = true
	
	set_text_font_size(Config.get_value(ConfigKey.Global.font_size))
	font_size_slider.max_value = Config.MAX_FONT_SIZE


#============================================================
#  自定义
#============================================================
func play_animation(anim_name: String):
	prompt_label_anim_player.play(anim_name)

func stop_animation():
	prompt_label_anim_player.stop()


## 处理结果
func handle_result(text: String):
	var lines = text.split("\n")
	# 识别结果行
	var line: String
	for idx in lines.size():
		var tmp = lines[idx]
		if str(lines[idx]).strip_edges(true, false).begins_with("pid"):
			line = lines[idx]
			break
	# 设置文字
	set_text( line )


func get_origin_text() -> String:
	return text_edit.get_meta("text", "")

func get_text() -> String:
	return text_edit.text.strip_edges(false, true)

func set_text(text: String) -> void:
	text_edit.set_meta("text", text)
	text_edit.text = ""
	if text == "":
		return
	
	var result = text_regex.search(text)
	if result == null:
		printerr("没有识别到内容")
		return
	
	var demo_str = result.get_string("demo")
	var timestamp_str = result.get_string("timestamp")
	
	var mode : String = button_group.get_pressed_button().text
	match mode:
		"文本":
			text_edit.text = demo_str 
		
		"段落":
			var paragraphs = paragraph_regex.search_all(demo_str)
			#text_edit.text = "\n".join(paragraphs.map(func(item): return item.get_string().left(-1) )) + "\n"
			print("  | 段落数：", paragraphs.size())
			
			text_edit.text = "\n".join(paragraphs.map(func(item): return item.get_string() ))
		
		"时间":
			var paragraphs = paragraph_regex.search_all(demo_str)
			var timestamp : Array = JSON.parse_string(timestamp_str)
			#timestamp.push_front([0, timestamp[0][0]])
			paragraphs = paragraphs.map(func(item: RegExMatch): return item.get_string())
			print("  | 段落数：", paragraphs.size())
			print("  | 时间戳数：", paragraphs.size())
			
			var time = ""
			text = ""
			for i in paragraphs.size():
				text += "%s   %s\n" % [
					str(timestamp[i]), #to_time(timestamp[i][0]), 
					paragraphs[i].left(-1)
				]
			text_edit.text = text
		
		"字幕":
			# SRT 文字格式
			var paragraphs = paragraph_regex.search_all(demo_str)
			var timestamp : Array = Array(JSON.parse_string(timestamp_str))
			#timestamp.push_front([0, timestamp[0][0]])
			paragraphs = paragraphs.map(func(item: RegExMatch): return item.get_string())
			print("  | 段落数：", paragraphs.size())
			print("  | 时间戳数：", paragraphs.size())
			
			var time = ""
			text = ""
			for i in paragraphs.size():
				text += "%d\n%s\n%s\n\n" % [
					i, 
					"%s --> %s" % [to_time(timestamp[i][0]), to_time(timestamp[i][1])] , 
					paragraphs[i].left(-1)
				]
			text_edit.text = text
			
		
		_:
			printerr("其他类型")


func to_time(value: int) -> String:
	var millisecond = value
	var seconds = value / 100.0
	var minute = int(seconds) / 60
	var hour = minute / 60
	minute = minute % 60
	seconds = int(seconds) % 60
	millisecond = value % 100
	return "%02d:%02d:%02d,%03d" % [ hour, minute, seconds, millisecond ]

func set_text_font_size(value: float):
	font_size_label.text = str(value)
	text_edit.add_theme_font_size_override("font_size", value)
	if font_size_slider.value != value:
		font_size_slider.value = value
	Config.set_value(ConfigKey.Global.font_size, value)


#============================================================
#  连接信号
#============================================================
func _on_line_edit_text_submitted(new_text: String) -> void:
	var line = text_edit.get_caret_line()
	var column = text_edit.get_caret_column()
	text_edit.set_search_flags(TextEdit.SEARCH_BACKWARDS)
	text_edit.set_search_text(new_text)
	text_edit.queue_redraw()
