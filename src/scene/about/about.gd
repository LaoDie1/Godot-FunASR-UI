#============================================================
#    About
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-26 02:35:47
# - version: 4.2.2.stable
#============================================================
extends Control


func _on_rich_text_label_meta_clicked(meta):
	OS.shell_open(meta)
