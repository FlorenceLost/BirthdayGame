extends Control

# 获取 AnimationTree 节点
@onready var animation_tree: AnimationTree = %AnimationTree
# 获取动画状态机的播放控制器 (Playback)
@onready var state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")

func _ready() -> void:
	# 初始播放信封 idle 动画
	state.travel("envelope_Idle")
	# 播放背景音乐
	AudioManager.play_music("florence") 


func _on_texture_button_pressed() -> void:
	#当钮被按下时，鼠标和手指按下，就会换动画
	state.travel("envelope_Open")
	AudioManager.play_sfx("openbook",10.0)
	pass # Replace with function body.
