extends Node2D

@onready var area_2d: Area2D = $Area2D
@onready var sprite_minute: Sprite2D = %SpriteMinute
@onready var sprite_hour: Sprite2D = %SpriteHour

var dragging: bool = false
var previous_angle: float = 0.0 # 记录上一帧的鼠标角度，用于计算差值

# 分别记录时针和分针的累计角度（单位：度）
var total_minute_angle: float = 0.0
var total_hour_angle: float = 0.0

signal minute_rotated(angle: float)

func _ready() -> void:
	area_2d.input_pickable = true
	if not area_2d.input_event.is_connected(_on_area_2d_input_event):
		area_2d.input_event.connect(_on_area_2d_input_event)

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# 鼠标按下：开始拖拽，并记录初始角度
			dragging = true
			var mouse_pos = get_global_mouse_position()
			var dir = (mouse_pos - sprite_minute.global_position).normalized()
			previous_angle = rad_to_deg(dir.angle())
		else:
			# 鼠标释放：停止拖拽
			dragging = false

func _process(delta: float) -> void:
	if not dragging:
		return

	var mouse_pos = get_global_mouse_position()
	var dir = (mouse_pos - sprite_minute.global_position).normalized()
	var current_angle = rad_to_deg(dir.angle())

	# 计算从上一帧到这一帧的角度变化量，处理360°边界
	var delta_angle = current_angle - previous_angle
	if abs(delta_angle) > 180: # 处理跨越360°-0°边界的情况
		if delta_angle > 0:
			delta_angle -= 360.0
		else:
			delta_angle += 360.0
	
	# 累加分针总角度
	total_minute_angle += delta_angle
	sprite_minute.rotation_degrees = total_minute_angle

	# 计算时针角度：分针转12圈，时针转1圈
	# 所以时针角度 = 分针总角度 / 12
	total_hour_angle = total_minute_angle / 12.0
	sprite_hour.rotation_degrees = total_hour_angle

	# 更新上一帧的角度为当前角度，用于下一帧计算
	previous_angle = current_angle

	# 发出信号（可选：如果需要限制在0-360度，可以用fmod）
	EventBus.emit("hour_rotated", fmod(total_hour_angle, 360.0))
