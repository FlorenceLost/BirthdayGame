extends Node2D

@onready var sprite_spring: Sprite2D = %SpriteSpring
@onready var sprite_summer: Sprite2D = %SpriteSummer
@onready var sprite_autumn: Sprite2D = %SpriteAutumn
@onready var sprite_winter: Sprite2D = %SpriteWinter

var last_played_tick: int = -1  # 上次播放的刻度（0,1,2... 对应 0°,30°,60°...）

func _ready() -> void:
	_set_alpha(sprite_spring, 1.0)
	_set_alpha(sprite_summer, 0.0)
	_set_alpha(sprite_autumn, 0.0)
	_set_alpha(sprite_winter, 0.0)

	var clock = get_parent().get_node_or_null("Alarm")
	if clock:
		EventBus.subscribe("hour_rotated", Callable(self, "_on_hour_rotated"))
	else:
		push_warning("Seasons: 找不到 Clock 节点，无法接收信号。")

func _on_hour_rotated(hour_angle: float) -> void:
	# ==== 渐变逻辑 ====
	if hour_angle >= 0.0 and hour_angle < 90.0:
		_fade_to(sprite_spring, sprite_summer, (hour_angle - 0.0) / 90.0)
	elif hour_angle >= 90.0 and hour_angle < 180.0:
		_fade_to(sprite_summer, sprite_autumn, (hour_angle - 90.0) / 90.0)
	elif hour_angle >= 180.0 and hour_angle < 270.0:
		_fade_to(sprite_autumn, sprite_winter, (hour_angle - 180.0) / 90.0)
	else:
		_fade_to(sprite_winter, sprite_spring, (hour_angle - 270.0) / 90.0)

	# ==== 音效逻辑 ====
	var tick = int(floor(hour_angle / 30.0))  # 当前所在的 30° 刻度
	if tick != last_played_tick:
		last_played_tick = tick
		AudioManager.play_sfx("clock")  # 只在进入新的刻度时播放一次

	# ==== 切场景 ====
	if hour_angle >= 359.0:
		SceneManager.change_scene("res://scenes/envelope.tscn")

# sprite_from 渐隐，sprite_to 渐显
func _fade_to(sprite_from: Sprite2D, sprite_to: Sprite2D, t: float) -> void:
	t = clamp(t, 0.0, 1.0)
	_set_alpha(sprite_from, 1.0 - t)
	_set_alpha(sprite_to, t)

func _set_alpha(sprite: Sprite2D, alpha: float) -> void:
	var c = sprite.modulate
	c.a = clamp(alpha, 0.0, 1.0)
	sprite.modulate = c
