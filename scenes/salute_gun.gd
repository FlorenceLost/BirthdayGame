extends Node2D

@onready var gpu_particles_2d: GPUParticles2D = %GPUParticles2D
@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var timer: Timer = $Timer


func _ready() -> void:
	EventBus.subscribe("ShootSalute",emit_particle_once)
	timer.wait_time = 2.5
	pass

func emit_particle_once() -> void:
	# 设置为一次性发射
	gpu_particles_2d.one_shot = true
	gpu_particles_2d.emitting = true
	AudioManager.play_sfx("salutePop",10.0)
	# 等待当前发射周期结束
	timer.start()
	
func _on_timer_timeout() -> void:
		#隐藏烟花
	sprite_2d.visible = false
	print("烟花！!!!!!")
	pass # Replace with function body.
