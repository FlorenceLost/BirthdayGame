extends Node

## 🎵 全局音频管理器
## 功能：
## 1. 从 audio_list.json 中加载音乐/音效
## 2. 支持淡入淡出播放背景音乐
## 3. 音效池机制（防止多个音效重叠太多）
##
## 使用方法：
## - AudioManager.play_music("florence")
## - AudioManager.play_sfx("write")

# ----------------------------
# 🔹 背景音乐播放器
# ----------------------------
var music_player: AudioStreamPlayer
var music_tracks: Dictionary = {}  # 从 JSON 加载的音乐字典

# ----------------------------
# 🔹 音效播放器池
# ----------------------------
const MAX_SFX_PLAYERS := 8
var sfx_players: Array = []        # 存放多个 AudioStreamPlayer
var sfx_tracks: Dictionary = {}    # 从 JSON 加载的音效字典

# ----------------------------
# 🔹 背景音乐控制
# ----------------------------
var _music_looping: bool = false
var _music_finished_handler: Callable

# ----------------------------
# 🔹 淡入淡出控制
# ----------------------------
var fade_time: float = 1.5   # 淡入淡出总时长（秒）
var fade_timer: float = 0.0
var fading: bool = false
var fade_target: float = 1.0
var fade_start: float = 1.0
var fade_mode: String = ""   # "in" / "out"
var _next_music: String = ""
var _next_loop: bool = true

# ----------------------------
# 🔹 初始化
# ----------------------------
func _ready() -> void:
	# 1. 创建背景音乐播放器
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	add_child(music_player)

	# 2. 创建音效播放器池
	for i in range(MAX_SFX_PLAYERS):
		var p = AudioStreamPlayer.new()
		p.name = "SFXPlayer_%d" % i
		add_child(p)
		sfx_players.append(p)

	_music_finished_handler = Callable(self, "_on_music_finished")

	# 3. 读取 audio_list.json
	_load_audio_from_json()

	# 打印调试信息
	print("[AudioManager] 初始化完成")
	print("[AudioManager] 音乐列表:", music_tracks.keys())
	print("[AudioManager] 音效列表:", sfx_tracks.keys())


# ----------------------------
# 🔹 从 JSON 加载音频
# ----------------------------
func _load_audio_from_json() -> void:
	var json_mgr = JsonMgr.get_instance()
	var data = json_mgr.load_data("audio_list")  # 读取 audio_list.json

	# 加载音乐
	if data.has("music"):
		for path in data["music"]:
			if ResourceLoader.exists(path): # 防止路径错误
				var key = path.get_file().get_basename()
				music_tracks[key] = load(path)
				print("[AudioManager] 添加音乐:", key, "->", path)

	# 加载音效
	if data.has("sfx"):
		for path in data["sfx"]:
			if ResourceLoader.exists(path):
				var key = path.get_file().get_basename()
				sfx_tracks[key] = load(path)
				print("[AudioManager] 添加音效:", key, "->", path)


# ----------------------------
# 🔹 背景音乐播放
# ----------------------------
func play_music(name: String, loop: bool = true, fade: bool = true) -> void:
	if not music_tracks.has(name):
		push_error("[AudioManager] 未找到音乐: %s" % name)
		return

	if fade and music_player.playing:
		# 如果正在播放音乐，就先淡出，等淡出完成后立刻切换
		_next_music = name
		_next_loop = loop
		_fade_out()
	else:
		# 没有正在播音乐 → 直接开始
		_start_music(name, loop)
		if fade:
			_fade_in()


## 🔹 启动一首音乐
func _start_music(name: String, loop: bool) -> void:
	music_player.stream = music_tracks[name]
	music_player.play()
	music_player.volume_db = 0.0
	if loop:
		if not music_player.finished.is_connected(_music_finished_handler):
			music_player.finished.connect(_music_finished_handler)
		_music_looping = true
	else:
		if music_player.finished.is_connected(_music_finished_handler):
			music_player.finished.disconnect(_music_finished_handler)
		_music_looping = false

## 🔹 当音乐自然播完
func _on_music_finished() -> void:
	if _music_looping and music_player.stream != null:
		music_player.play()

## 🔹 停止音乐
func stop_music(fade: bool = true) -> void:
	if fade:
		_next_music = ""   # 停止时没有下一首
		_fade_out()
	else:
		music_player.stop()


# ----------------------------
# 🔹 淡入淡出控制
# ----------------------------
func _fade_in():
	fade_mode = "in"
	fade_start = -40.0          # 从很小音量开始
	fade_target = 0.0           # 到正常音量
	fade_timer = 0.0
	fading = true

func _fade_out():
	fade_mode = "out"
	fade_start = music_player.volume_db
	fade_target = -40.0         # 淡出到静音
	fade_timer = 0.0
	fading = true

## 🔹 每帧更新淡入淡出
func _process(delta: float) -> void:
	if fading:
		fade_timer += delta
		var t = clamp(fade_timer / fade_time, 0.0, 1.0)
		var vol = lerp(fade_start, fade_target, t)
		music_player.volume_db = vol

		if t >= 1.0:
			fading = false
			if fade_mode == "out":
				# 淡出完成 → 立刻切换下一首
				if _next_music != "":
					_start_music(_next_music, _next_loop)
					_fade_in()
				else:
					music_player.stop()


# ----------------------------
# 🔹 音效播放
# ----------------------------
func play_sfx(name: String, volume_db: float = 0.0) -> void:
	if not sfx_tracks.has(name):
		push_error("[AudioManager] 未找到音效: %s" % name)
		return

	for p in sfx_players:
		if not p.playing:
			p.stream = sfx_tracks[name]
			p.volume_db = volume_db
			p.play()
			print("[AudioManager] 播放音效:", name, "成功")
			return

	print("[AudioManager] 音效池已满，丢弃:", name)


# ----------------------------
# 🔹 调试方法
# ----------------------------
func debug_sfx(name: String) -> void:
	if sfx_tracks.has(name):
		print("[AudioManager Debug] 音效可播放:", name)
	else:
		print("[AudioManager Debug] 音效不存在:", name)
