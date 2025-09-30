extends Node

@onready var canvas_layer: CanvasLayer = %CanvasLayer
#加载文字场景
const CONT_BLACK_OVERLAY = preload("res://scenes/cont_black_overlay.tscn")
const CONT_LAB_END = preload("res://scenes/cont_lab_end.tscn")
@onready var music_load: Node = %MusicLoad

func _ready() -> void:
	##订阅文字场景
	EventBus.subscribe("Write", Callable(self, "openBlackOverlay"))

	
		# 播放背景音乐
	AudioManager.play_music("florence") 
	
	#change_photo
	# 设置默认场景
	SceneManager.default_scene_path = "res://scenes/change_photo.tscn"

	# 真正加载默认场景
	await SceneManager.instance.change_scene(SceneManager.default_scene_path)
	EventBus.subscribe("End",openLabEnd)
	pass

##文字场景实例化
func openBlackOverlay():
	var Cont_BlackOverlay = CONT_BLACK_OVERLAY.instantiate()
	canvas_layer.add_child(Cont_BlackOverlay)
	
func openLabEnd():
	var labEnd = CONT_LAB_END.instantiate()
	canvas_layer.add_child(labEnd)
