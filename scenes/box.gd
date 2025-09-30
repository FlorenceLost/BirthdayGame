extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var area_2d: Area2D = %Area2D
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite_2d.play("Idle")
	area_2d.monitoring = true
	
	EventBus.subscribe("BoxSwitch",BoxSwitch)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#被鼠标点击时就不会再次被点击
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		animated_sprite_2d.play("Open")
		area_2d.monitoring = false
		collision_shape_2d.disabled = true
		EventBus.emit("End")
		pass # Replace with function body.
		
func BoxSwitch()->void:
	area_2d.monitoring = true
	collision_shape_2d.disabled = false
	
