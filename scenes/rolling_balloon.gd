extends RigidBody2D

@export var impulse_strength: float = 1500.0   # 点击时施加的冲量大小

func _ready() -> void:
	input_pickable = true

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# 随机一个方向
		var random_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		
		# 直接对质心施加冲量
		apply_central_impulse(random_dir * impulse_strength)

		print("🎈 气球被点击，施加冲量：", random_dir * impulse_strength)
		
		AudioManager.play_sfx("bi",10.0)
