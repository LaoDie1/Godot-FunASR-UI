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
	pass
	
	FFMpegUtil.ffmpeg_path = "C:/Users/z/AppData/Local/Microsoft/WinGet/Packages/Gyan.FFmpeg.Essentials_Microsoft.Winget.Source_8wekyb3d8bbwe/ffmpeg-7.0-essentials_build/bin/ffmpeg.exe"
	var path = FFMpegUtil.generate_video_preview_image(r"C:\Users\z\Videos\带货\火鸡面\YEGQ5953.MP4")
	print(FileAccess.file_exists(path))
	
