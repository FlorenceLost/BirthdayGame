extends Control

# -------------------------
# 配置参数
# -------------------------

# 要显示的完整文本
@export var full_text: String = "未来的日子里，你依旧能笑得像今天一样明亮。生日快乐匿名，愿你被生活温柔以待。"

# 每个字出现的间隔时间（秒）
@export var char_interval: float = 0.3

# 打字完成后要切换的场景路径
@export var next_scene_path: String = ""

# 整个 Control 的淡出时长（秒）
@export var fade_duration: float = 1.5

#背景颜色
@onready var color_rect: ColorRect = %ColorRect
#字体
@onready var lab_birthday_card: Label = %LabBirthdayCard

# -------------------------
# 内部变量
# -------------------------
var current_index: int = 0   # 当前已显示字符索引
var is_playing: bool = false # 是否正在播放
var label_node: Label        # 引用 Label 节点
var colorrect_node: ColorRect # 引用背景 ColorRect 节点

# -------------------------
# 节点准备
# -------------------------
func _ready() -> void:
	# 获取子节点
	label_node = lab_birthday_card
	colorrect_node = color_rect

	# 播放写字音效
	AudioManager.play_sfx("write",8.0)

	# 初始化 Label 文本为空
	label_node.text = ""

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
	label_node.text = ""
	_show_text()

# -------------------------
# 协程实现逐字显示
# -------------------------
func _show_text() -> void:
	while current_index < full_text.length():
		label_node.text = full_text.substr(0, current_index + 1)
		current_index += 1
		await get_tree().create_timer(char_interval).timeout

	# 打字完成
	is_playing = false
	# 开始淡出整个 Control（包括背景 + 文本）
	_fade_out()
	EventBus.emit("BoxSwitch")

# -------------------------
# 整个 UI 渐渐消失
# -------------------------
func _fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration) # 整个 Control 透明度降到 0
	tween.finished.connect(_on_fade_out_finished)

# -------------------------
# 淡出完成后 -> 切换场景并删除自己
# -------------------------
func _on_fade_out_finished() -> void:
	if next_scene_path != "":
		await SceneManager.instance.change_scene(next_scene_path)
	# 删除整个 Control 节点，避免继续阻挡点击
	queue_free()
