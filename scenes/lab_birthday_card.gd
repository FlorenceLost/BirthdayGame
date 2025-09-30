extends Label

# -------------------------
# 配置参数
# -------------------------

# 要显示的完整文本
@export var full_text: String = "亲爱的匿名：\n\n时间悄悄为你增添了一抹新的色彩，而在这一天，你的梦想与笑容一样耀眼。在这个特别的日子里，轮到我为你点亮蜡烛、唱起生日快乐歌……"

# 每个字出现的间隔时间（秒）
@export var char_interval: float = 0.15

# 打字完成后要切换的场景路径
@export var next_scene_path: String = "res://scenes/macaron_blue.tscn"

# -------------------------
# 内部变量
# -------------------------
var current_index: int = 0   # 当前已显示字符索引
var is_playing: bool = false # 是否正在播放

# -------------------------
# 节点准备
# -------------------------
func _ready() -> void:
	# 播放写字音效
	AudioManager.play_sfx("write")
	# 初始化文本为空
	text = ""
	# 启动打字机效果
	start_typing()

# -------------------------
# 开始打字机效果
# -------------------------
func start_typing() -> void:
	if is_playing:
		return
	is_playing = true
	current_index = 0
	text = ""
	# 启动协程
	_show_text()

# -------------------------
# 协程实现逐字显示
# -------------------------
func _show_text() -> void:
	while current_index < full_text.length():
		# 截取字符串前 current_index+1 个字符
		text = full_text.substr(0, current_index + 1)
		current_index += 1

		# 等待一小段时间
		await get_tree().create_timer(char_interval).timeout

	# 打字完成
	is_playing = false

	# -------------------------
	# 打字完成后切换场景
	# -------------------------
	if next_scene_path != "":
		# 使用 SceneManager 淡入淡出切换场景
		await SceneManager.instance.change_scene(next_scene_path)

		# -------------------------
		# 场景切换完成后，删除 UI 根节点
		# -------------------------
		if get_parent():
			get_parent().queue_free()
