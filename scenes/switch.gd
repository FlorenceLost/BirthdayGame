extends Node2D

@onready var sprite_close: Sprite2D = $Area2D/SpriteClose

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#将关灯图片隐藏
	sprite_close.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#开关控制方法
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		AudioManager.play_sfx("switch")
		#将打开图片隐藏
		sprite_close.visible = true
		# 真正加载场景
		await SceneManager.instance.set_scene_immediate("res://scenes/celebrate.tscn")
