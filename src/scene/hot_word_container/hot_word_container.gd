#============================================================
#    Hot Word Container
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-24 18:25:57
# - version: 4.3.0.dev5
#============================================================
extends MarginContainer


@onready var hot_word_tree: Tree = %HotWordTree
@onready var word_line_edit: LineEdit = %WordLineEdit

var root : TreeItem
var dict : Dictionary = {}
var changed : bool = false  # 内容发生改变


#============================================================
#  内置
#============================================================
func _ready() -> void:
	root = hot_word_tree.create_item()
	var list = FileUtil.read_as_lines(Global.hot_word_path)
	for item in list:
		add_hot_word(item)


func _exit_tree() -> void:
	if changed:
		var list = root.get_children().map(
			func(item): return item.get_metadata(0)
		)
		var text = "\n".join(list)
		FileUtil.write_as_string(Global.hot_word_path, text)


#============================================================
#  自定义
#============================================================
func add_hot_word(word: String) -> bool:
	if dict.has(word) or word == "":
		return false 
	dict[word] = null
	changed = true
	
	var item = hot_word_tree.create_item(root)
	item.set_text(0, word)
	item.add_button(0, Icons.get_icon("Remove"))
	item.set_metadata(0, word)
	return true


#============================================================
#  连接信号
#============================================================
func _on_add_hot_word_button_pressed() -> void:
	if add_hot_word( word_line_edit.text.strip_edges() ):
		word_line_edit.text = ""


func _on_hot_word_tree_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	if id == 0:
		var mouse_pos_item = hot_word_tree.get_item_at_position( hot_word_tree.get_local_mouse_position() )
		if mouse_pos_item != item:
			return
		changed = true
		dict.erase(item.get_metadata(0))
		root.remove_child(item)


func _on_word_line_edit_text_submitted(new_text: String) -> void:
	_on_add_hot_word_button_pressed()


func _on_hot_word_tree_item_activated() -> void:
	var item = hot_word_tree.get_selected()
	word_line_edit.text = item.get_metadata(0)
