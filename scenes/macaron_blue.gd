extends Node2D

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var puzzle_manager: PuzzleManager = $PuzzleManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("Dish_Move")
	AudioManager.play_sfx("pop")
	puzzle_manager.next_scene_path = "res://scenes/macaron_red.tscn"
	pass # Replace with function body.
