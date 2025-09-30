extends Node2D

@onready var area_drag: Area2D = $AreaDrag
var is_dragging := false  # 是否正在拖拽

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if is_dragging:
		# 跟随鼠标/手指移动（转到全局坐标再赋值）
		global_position = get_global_mouse_position()

# 点击检测
func _on_area_drag_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			is_dragging = true
		else:
			is_dragging = false
