extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_candle: Area2D = $AreaCandle

# 全局蜡烛数量（如果要全局共享，建议改成 GameManager.num_candles）
@export var num := 2

func _ready() -> void:
	# 初始隐藏火焰
	animated_sprite_2d.visible = false

# 当有物体进入蜡烛的区域
func _on_area_candle_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	print("[DEBUG] AreaCandle 碰撞到:", area.name, " 组:", area.get_groups())

	if area.is_in_group("MatchHead"):
		print("[DEBUG] ✅ 检测到火柴头，点燃蜡烛！")
		animated_sprite_2d.visible = true
		AudioManager.play_sfx("bigFire", -10.0)

		## 让蜡烛停止检测（避免重复触发）
		#area_candle.set_deferred("monitoring", false)
#
		## 让火柴头也不再被其他蜡烛检测
		#area.set_deferred("monitorable", false)

		# 如果全部点燃 -> 发事件
		if num <= 1:
			EventBus.emit("CloseLight")
			return
			
				# 减少蜡烛计数
		num -= 1
		print("还剩 %d 个蜡烛待熄灭" % num)
