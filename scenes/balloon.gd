extends Node2D
## 🎈 打气筒逻辑
## 功能：
## - 管理 SpriteUp / SpriteDown 显示（打气效果）
## - 检测点击输入，通知气球管理器给当前气球打气
## - 当所有气球完成时，切换场景

@onready var sprite_up: Sprite2D = %SpriteUp
@onready var sprite_down: Sprite2D = %SpriteDown
@onready var marker_ballon_mgr: Marker2D = %MarkerBallonMgr

func _ready() -> void:
	# 初始状态：显示上图，隐藏下图
	sprite_up.visible = true
	sprite_down.visible = false
	# 监听所有气球完成的事件
	marker_ballon_mgr.connect("all_balloons_finished", Callable(self, "_on_all_balloons_finished"))

## 🔘 鼠标交互：点击充气区域
func _on_area_pump_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			# 鼠标按下：显示“下图”，隐藏“上图”
			sprite_up.visible = false
			sprite_down.visible = true
			# 通知管理器给当前气球打气
			marker_ballon_mgr.pump_current_balloon()
			AudioManager.play_sfx("inflate",-10.0)
		else:
			# 鼠标抬起：恢复“上图”
			sprite_up.visible = true
			sprite_down.visible = false

## 🎮 所有气球完成后的回调
func _on_all_balloons_finished() -> void:
	# 切换场景，这里替换成你的目标场景路径
	await SceneManager.instance.change_scene("res://scenes/match.tscn")
	print("66666")
