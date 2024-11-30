#============================================================
#    03.upload Git
#============================================================
# - author: zhangxuetu
# - datetime: 2024-11-30 22:08:55
# - version: 4.3.0.stable
#============================================================
## 上传到 Git 上
extends AbstractCustomMenu

var dialog : ConfirmationDialog
var text_edit : TextEdit

func _enter():
	dialog = ConfirmationDialog.new()
	dialog.size = Vector2(700, 400)
	text_edit = TextEdit.new()
	text_edit.placeholder_text = "git 提交描述"
	dialog.add_child(text_edit)
	var root := EditorInterface.get_base_control()
	root.add_child.call_deferred(dialog)
	dialog.get_ok_button().pressed.connect(
		func():
			var commit_text = text_edit.text.strip_edges()
			if commit_text.is_empty():
				commit_text = "update " + Time.get_datetime_string_from_system(false, true)
				commit_text = commit_text.replace("-", "_").replace(":", "_")
			var thread := Thread.new()
			thread.start(
				func():
					print("开始上传：")
					print("    ", " ".join(["git", "add", "."]))
					OS.execute("git", ["add", "."])
					print("    ", " ".join(["git", "commit", "-m", '"%s"' % commit_text]))
					OS.execute("git", ["commit", "-m", '"%s"' % commit_text])
					var error = OK
					var max_count = 4
					for i in max_count:
						print("    git push")
						var output = []
						OS.execute("git", ["push"], output, true)
						var text := str("".join(output))
						if text.begins_with("To") or text.contains("Enumerating objects") or text.contains("Everything up-to-date"):
							error = OK
							text_edit.set_deferred("text", "")
							break
						else:
							error = FAILED
							if i < max_count - 1:
								push_warning("上传失败，重新上传", text)
					thread.wait_to_finish.call_deferred()
					print("上传结束：", error_string(error))
			)
	)

func _exit():
	dialog.queue_free()

func _get_menu_name():
	return "上传到 git"

func _execute():
	dialog.popup_centered()
	text_edit.grab_focus.call_deferred()

func _get_shortcut():
	var shortcut := Shortcut.new()
	var input = InputEventKey.new()
	shortcut.events.append(input)
	input.keycode = KEY_M
	input.ctrl_pressed = true
	input.alt_pressed = true
	return shortcut
