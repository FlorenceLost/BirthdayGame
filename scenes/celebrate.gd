extends Node2D

# 环境光
@onready var directional_light_2d: DirectionalLight2D = %DirectionalLight2D
# 射灯
@onready var spotlight: PointLight2D = %Spotlight
# 火柴计时器
@onready var timer_match_fire: Timer = %TimerMatchFire
# 蜡烛计时器
@onready var timer_candle: Timer = %TimerCandle
# 火柴节点（整个火柴节点）
@onready var match_fire: Node2D = %MatchFire

@onready var parallax_background: ParallaxBackground = $ParallaxBackground
# 火柴碰撞盒（点击即可显示火柴）
@onready var area_open_match: Area2D = %AreaOpenMatch

#礼物盒
@onready var box: Node2D = %Box

# 存一个 Callable，方便退订
var _close_light_cb: Callable

func _ready() -> void:
	# 将射灯隐藏
	spotlight.visible = false
	# 隐藏火柴
	match_fire.visible = false
	# 显示 GPU 粒子
	parallax_background.visible = true
	
	# 开始默认火柴碰撞盒不运行
	area_open_match.input_pickable = false
	timer_match_fire.start()
	
	#隐藏礼物盒
	box.visible = false
	
	# 订阅点完蜡烛的事件（务必用 Callable）
	_close_light_cb = Callable(self, "CloseLight")
	EventBus.subscribe("CloseLight", _close_light_cb)


func _on_timer_match_fire_timeout() -> void:
	AudioManager.play_sfx("switch")
	# 打开射灯
	spotlight.visible = true
	AudioManager.play_music("BeWithYou")
	
	# 火柴碰撞盒运行（允许点击显示火柴）
	area_open_match.input_pickable = true


# 显示火柴
func _on_area_open_match_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		match_fire.visible = true
		AudioManager.play_sfx("match", 10.0)
		# 火柴碰撞盒停止运行（非销毁）
		area_open_match.input_pickable = false


# 点完蜡烛后执行的逻辑：关掉环境灯 & 删除火柴
func CloseLight() -> void:
	# 关掉环境灯
	if is_instance_valid(directional_light_2d):
		directional_light_2d.visible = false
	# 关掉射灯
	if is_instance_valid(spotlight):
		spotlight.visible = false
		EventBus.emit("ShootSalute")
		
		#打开显示礼物盒
		box.visible = true
	
	# 推荐做法一：完全删除火柴节点（如果你不再需要它）
	if is_instance_valid(match_fire):
		# 用 queue_free() 在下一帧安全删除节点
		match_fire.queue_free()
	
	# 如果你只想删除点击区域（保留视觉），可以改成：
	# if is_instance_valid(area_open_match):
	#     area_open_match.queue_free()
	
	# 如果你是在物理回调里被调用（例如来自 area 信号），并且
	# 想延迟删除某些属性/状态，使用 set_deferred：
	# area_open_match.set_deferred("monitoring", false)
	# match_fire.set_deferred("visible", false)

func _exit_tree() -> void:
	# 退订事件（防止切换场景后回调野指针）
	if _close_light_cb != null:
		EventBus.unsubscribe("CloseLight", _close_light_cb)
