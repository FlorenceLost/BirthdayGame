extends Area2D

# 获取 AnimationTree 节点
@onready var animation_tree: AnimationTree = %AnimationTree
# 获取动画状态机的播放控制器 (Playback)
@onready var state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")

# 两个碰撞盒节点
@onready var colli_open: CollisionShape2D = %Colli_Open   # 打开信封用
@onready var colli_paper: CollisionShape2D = %Colli_Paper # 打开纸张用


func _ready() -> void:
	# 初始化状态机：信封待机
	state.travel("envelope_Idle")

	
	# 初始化碰撞盒：
	# - 信封交互区域启用
	# - 纸张交互区域禁用
	colli_open.disabled = false
	colli_paper.disabled = true


# 处理点击事件（鼠标 / 触屏）
# shape_idx 是 Godot 内部传过来的“形状索引”，需要转换成对应的 CollisionShape2D
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# 只在点击时触发（鼠标左键按下 / 触屏点击）
	if (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed):
		
		# 根据 shape_idx 查找它属于哪个 shape_owner
		var owner_id: int = shape_find_owner(shape_idx)
		# 再通过 owner_id 获取对应的 CollisionShape2D 节点
		var owner_node: Node = shape_owner_get_owner(owner_id)
		
		# 判断点击的是哪一个碰撞盒
		if owner_node == colli_open:
			_open_envelope()
		elif owner_node == colli_paper:
			_open_paper()


# 打开信封的逻辑
func _open_envelope() -> void:
	print("点击了信封，播放开信动画和音效")
	AudioManager.play_sfx("openbook")
	state.travel("envelope_Open")

	# 切换交互区域：
	# - 信封点击完后禁用
	# - 纸张区域启用
	colli_open.disabled = true
	colli_paper.disabled = false

# 打开纸张的逻辑
func _open_paper() -> void:
	print("点击了纸张，执行纸张逻辑")
	#触发文字场景逻辑
	EventBus.emit("Write")
