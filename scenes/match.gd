extends Node2D

# ---------------------------
# 节点引用
# ---------------------------
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var area_match: Area2D = %Area_Match
@onready var area_box_top: Area2D = %Area_Box_Top
@onready var area_match_load: Area2D = %Area_MatchLoad
@onready var coll_box: CollisionShape2D = %Coll_Box
@onready var coll_match: CollisionShape2D = %Coll_Match
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D

#微笑动画
@onready var anim_smile: AnimatedSprite2D = $AnimSmile

# ---------------------------
# 初始化
# ---------------------------
func _ready() -> void:
	area_match.input_pickable = false
	coll_match.disabled = true
	area_match_load.visible = false
	area_match_load.input_pickable = false
	collision_shape_2d.disabled = true

	
# ---------------------------
# 点击顶部区域 → 播放旋转+打开动画
# ---------------------------
func _on_area_box_top_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if not animation_player.is_playing():
			animation_player.play("Box_Open")
			AudioManager.play_sfx("boxOpen1",5.0)
			anim_smile.queue_free()

# ---------------------------
# 点击火柴区域 → 播放火柴盒消失动画
# ---------------------------
func _on_area_match_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if not animation_player.is_playing():
			animation_player.play("Box_Visible")
			AudioManager.play_sfx("pop")


func _on_area_match_load_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		await SceneManager.instance.change_scene("res://scenes/switch.tscn")
	pass # Replace with function body.
