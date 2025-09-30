extends Area2D
class_name Piece    # 定义拼图碎片类，方便在编辑器里直接用 Piece 类型

# -------------------------
# 自定义信号
# -------------------------
signal snapped_attempt(piece: Piece)   
# 当玩家尝试拼接时发出的信号，是否成功交由 PuzzleManager 判断

# -------------------------
# 可导出变量
# -------------------------
@export var correct_zone_path: NodePath      # 正确拼接区域的节点路径（在编辑器里拖）
@export var snap_threshold: float = 50.0     # 吸附判定阈值，越大越容易吸附

# -------------------------
# 成员变量
# -------------------------
var dragging: bool = false                   # 是否正在拖动
var click_played: bool = false               # 点击音效是否已播放
var start_pos: Vector2                       # 拼图初始位置
var correct_zone: Node2D                     # 正确拼接区域
var drag_offset: Vector2                     # 鼠标点击点与拼图中心的偏移量
var is_locked: bool = false                  # 是否已经锁定（拼好）

# -------------------------
# 生命周期：节点准备完成
# -------------------------
func _ready() -> void:
	start_pos = global_position                     # 记录初始位置
	correct_zone = get_node(correct_zone_path)      # 获取正确拼接区域
	self.input_event.connect(_on_input_event)       # 监听点击/拖动事件

# -------------------------
# 输入事件处理（鼠标 + 触屏）
# -------------------------
func _on_input_event(viewport, event: InputEvent, shape_idx: int) -> void:
	if is_locked:
		return  # 已拼好 → 不再响应输入

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# 鼠标按下 → 开始拖动
			dragging = true
			drag_offset = global_position - event.position
			# 播放点击音效（只播一次）
			if not click_played:
				AudioManager.play_sfx("bo")
				click_played = true
		else:
			# 鼠标松开 → 停止拖动，尝试拼接
			dragging = false
			click_played = false
			_check_snap()

	elif event is InputEventScreenTouch:
		if event.pressed:
			dragging = true
			drag_offset = global_position - event.position
			if not click_played:
				AudioManager.play_sfx("bo")
				click_played = true
		else:
			dragging = false
			click_played = false
			_check_snap()

# -------------------------
# 拖动逻辑：实时跟随鼠标
# -------------------------
func _process(delta: float) -> void:
	if dragging and not is_locked:
		global_position = get_global_mouse_position() + drag_offset

# -------------------------
# 尝试拼接（只发信号，不做判断）
# -------------------------
func _check_snap() -> void:
	if global_position.distance_to(correct_zone.global_position) < snap_threshold:
		# 如果进入阈值范围 → 发射拼接尝试信号
		emit_signal("snapped_attempt", self)
	else:
		_reset_position()

# -------------------------
# 复位函数（PuzzleManager 调用）
# -------------------------
func _reset_position() -> void:
	AudioManager.play_sfx("bi") # 播放拼对音效
	global_position = start_pos
	

# -------------------------
# 锁定函数（PuzzleManager 调用）
# -------------------------
func lock_to_correct() -> void:
	global_position = correct_zone.global_position
	is_locked = true                # 标记拼好
	dragging = false                # 防止还在拖动状态
	set_process(false)              # 停止 _process 更新
	AudioManager.play_sfx("pupupu") # 播放拼对音效
