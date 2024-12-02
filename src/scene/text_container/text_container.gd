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
			text_regex.compile("demo\t(?<demo>.*?)\t(?<timestamp>.*)")
		return text_regex
static var paragraph_regex : RegEx: # 段落
	get:
		if paragraph_regex == null:
			paragraph_regex = RegEx.new()
			paragraph_regex.compile("(.*?)[，。？！,\\?\\.]")
		return paragraph_regex


@onready var text_edit: CodeEdit = %TextEdit
@onready var prompt_label_anim_player: AnimationPlayer = %PromptLabelAnimPlayer
@onready var show_mode_container: HBoxContainer = %ShowModeContainer
@onready var font_size_label: Label = %FontSizeLabel
@onready var font_size_slider: HSlider = %FontSizeSlider
@onready var highlight_text: LineEdit = %HighlightText
@onready var split_text_line_edit: LineEdit = %SplitTextLineEdit
@onready var extra_node: HBoxContainer = %ExtraNode # 额外显示的节点
@onready var auto_wrap_button: CheckBox = %AutoWrapButton


var button_group : ButtonGroup


#============================================================
#  内置
#============================================================
func _ready() -> void:
	font_size_slider.max_value = Global.MAX_FONT_SIZE
	button_group = ButtonGroup.new()
	for child in show_mode_container.get_children():
		if child is BaseButton:
			child.button_group = button_group
	button_group.pressed.connect(
		func(button: Button):
			set_text(get_origin_text())
			Config.Project.text_show_mode.update(button.get_index())
			if extra_node.has_node(NodePath(button.name)):
				extra_node.show()
				extra_node.get_node(NodePath(button.name)).show()
			else:
				extra_node.hide()
	)
	button_group.get_buttons()[0].button_pressed = true
	Config.Project.text_show_mode.bind_method(
		func(v):
			if typeof(v) != TYPE_NIL:
				button_group.get_buttons()[int(v)].button_pressed = true
			,
		true
	)
	Config.Project.font_size.bind_method(self.set_text_font_size, true)
	Config.Project.font_size.bind_property(font_size_slider, "value", true)
	Config.Misc.highlight_text.bind_method(
		func(v):
			if v and highlight_text.text != v:
				highlight_text.text = v
			,
		true
	)
	Config.Misc.split_text.bind_property(split_text_line_edit, "text", true)
	Config.Misc.edit_auto_wrap.bind_method(
		func(v): 
			auto_wrap_button.button_pressed = v
			text_edit.wrap_mode = (TextEdit.LINE_WRAPPING_BOUNDARY if v else TextEdit.LINE_WRAPPING_NONE)
			, 
		true
	)


#============================================================
#  自定义
#============================================================
func play_animation(anim_name: String):
	prompt_label_anim_player.play(anim_name)

func stop_animation():
	prompt_label_anim_player.stop()

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
		text_edit.placeholder_text = "没有识别到内容"
		return
	
	var demo_str = result.get_string("demo")
	var timestamp_str = result.get_string("timestamp")
	
	var mode : String = button_group.get_pressed_button().text
	match mode:
		"文本":
			text_edit.text = demo_str 
		
		"段落":
			if split_text_line_edit.text != "":
				paragraph_regex.compile(
					"(.*?)[%s]" % split_text_line_edit.text
				)
				var paragraphs = paragraph_regex.search_all(demo_str)
				text_edit.text = "\n".join(paragraphs.map(func(item): return item.get_string() ))
			else:
				text_edit.text = demo_str
		
		"时间":
			var paragraphs = paragraph_regex.search_all(demo_str)
			var timestamp : Array = JSON.parse_string(timestamp_str)
			#timestamp.push_front([0, timestamp[0][0]])
			paragraphs = paragraphs.map(func(item: RegExMatch): return item.get_string())
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
	Config.Project.font_size.update(value)


#============================================================
#  连接信号
#============================================================
func _on_line_edit_text_submitted(new_text: String) -> void:
	var line = text_edit.get_caret_line()
	var column = text_edit.get_caret_column()
	text_edit.set_search_flags(TextEdit.SEARCH_BACKWARDS)
	text_edit.set_search_text(new_text)
	text_edit.queue_redraw()

func _on_highlight_text_text_changed(new_text: String) -> void:
	Config.Misc.highlight_text.update(new_text)

func _on_split_text_line_edit_text_changed(new_text: String) -> void:
	Config.Misc.split_text.update(new_text)

func _on_auto_wrap_button_toggled(toggled_on: bool) -> void:
	Config.Misc.edit_auto_wrap.update(toggled_on)
