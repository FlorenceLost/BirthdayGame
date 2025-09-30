@tool
extends Node

# 输出文件路径
@export var output_file: String = "res://data/json/audio_list.json"

# 点击按钮时执行
@export var generate: bool:
	set(value):
		if value:
			generate_audio_list()

# 扫描的目录
var music_dir := "res://audio/music"
var sfx_dir := "res://audio/sfx"

func generate_audio_list():
	var data := {
		"music": scan_folder(music_dir),
		"sfx": scan_folder(sfx_dir)
	}

	var json_text := JSON.stringify(data, "\t") # \t 缩进更好看

	var file := FileAccess.open(output_file, FileAccess.WRITE)
	if file:
		file.store_string(json_text)
		file.close()
		print("✅ audio_list.json 已生成:", output_file)
	else:
		push_error("❌ 无法写入 " + output_file)


# 扫描指定文件夹，返回文件名数组
func scan_folder(path: String) -> Array:
	var result: Array = []
	var dir := DirAccess.open(path)
	if not dir:
		push_error("⚠️ 找不到目录: " + path)
		return result

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir(): # 只要文件
			if file_name.ends_with(".ogg") or file_name.ends_with(".wav") or file_name.ends_with(".mp3"):
				result.append(path + "/" + file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	return result
