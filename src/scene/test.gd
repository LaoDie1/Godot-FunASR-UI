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
	var time = Time.get_datetime_string_from_system()
	time = time.replace(":", "_").replace("-", "_").replace("T", "_")
	print(time)
