#============================================================
#    Test
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-25 18:41:49
# - version: 4.3.0.dev5
#============================================================
@tool
extends EditorScript


func _run() -> void:
	var var_regex := RegEx.new()
	var_regex.compile("(?<indent>\\s*)static\\s+var\\s+(?<var_name>[^: ]+)")
	
	var r = var_regex.search("static var font_size: BindPropertyItem")
	print(r.get_string("var_name"))
	
