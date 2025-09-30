extends Node2D
## 🎈 单个气球逻辑
## 功能：
## - 通过 blow() 被外部打气
## - 缩放到最大时，气球向上飞走
## - 飞走时发出 balloon_finished 信号

signal balloon_finished   # 气球飞走时通知外部（管理器）

@onready var sprite_2d: Sprite2D = %Sprite2D          # 气球外观
@onready var rigid_body_2d: RigidBody2D = %RigidBody2D # 气球物理体

# 缩放参数
var start_scale: Vector2 = Vector2(0.25, 0.25)  # 初始大小
var max_scale: Vector2 = Vector2(1, 1)          # 最大大小
var inflate_step: Vector2 = Vector2(0.1, 0.1)   # 每次打气的缩放步长

func _ready() -> void:
	# 初始化缩放
	sprite_2d.scale = start_scale
	# 初始不受重力影响
	rigid_body_2d.gravity_scale = 0

## 🎈 外部调用打气方法
func blow() -> void:
	if sprite_2d.scale < max_scale:
		# 每次打气增加一定缩放
		sprite_2d.scale += inflate_step
		# 防止超过最大值
		if sprite_2d.scale > max_scale:
			sprite_2d.scale = max_scale

	# 如果达到最大缩放，则启动飞走逻辑
	if sprite_2d.scale == max_scale:
		_launch()

## 🎈 气球飞走
func _launch() -> void:
	# 设置为反重力，让气球往上飞
	rigid_body_2d.gravity_scale = -1
	# 发射信号，告诉管理器“我飞走了”
	emit_signal("balloon_finished")
	AudioManager.play_sfx("bi",10.0)
