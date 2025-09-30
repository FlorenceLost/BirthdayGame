extends Node

# -------------------------
# SceneManager 单例
# -------------------------
static var instance: SceneManager

# -------------------------
# 当前加载的场景
# -------------------------
var current_scene: Node = null

# -------------------------
# FadeRect 黑幕（淡入淡出用）
# -------------------------
var fade_rect: ColorRect = null

# -------------------------
# 放置动态加载场景的容器
# -------------------------
var center: Node2D = null

# -------------------------
# 配置参数
# -------------------------
static var default_scene_path: String = ""  # 默认加载场景路径
@export var fade_duration: float = 1.0      # 淡入淡出时间（秒）

# -------------------------
# 控制标记
# -------------------------
var is_changing_scene: bool = false  # 是否正在切换场景
var is_closing: bool = false         # 节点是否正在退出

# -------------------------
# Tween 引用管理
# -------------------------
var active_tweens: Array = []  # 用于存储所有 create_tween 返回的 Tween 对象

# -------------------------
# 单例初始化
# -------------------------
func _enter_tree() -> void:
	if instance and instance != self:
		queue_free()
		return
	instance = self

# -------------------------
# 节点准备完成
# -------------------------
func _ready() -> void:
	var birthday_root = get_tree().current_scene
	if not birthday_root:
		push_error("SceneManager: 当前没有运行场景！")
		return

	center = Node2D.new()
	center.name = "Center"
	center.position = get_viewport().get_visible_rect().size / 2
	birthday_root.add_child(center)

	_create_fade_rect(birthday_root)

	# 延迟两帧再加载默认场景
	if default_scene_path != "":
		await get_tree().process_frame
		await get_tree().process_frame
		if not is_closing:
			await change_scene(default_scene_path, fade_duration)

# -------------------------
# 创建黑幕
# -------------------------
func _create_fade_rect(parent: Node) -> void:
	if not parent:
		push_error("SceneManager: 创建黑幕失败，parent 为 null")
		return

	fade_rect = ColorRect.new()
	fade_rect.name = "FadeRect"
	fade_rect.color = Color.BLACK
	fade_rect.size = get_viewport().get_visible_rect().size
	fade_rect.modulate.a = 1.0
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	parent.add_child(fade_rect)
	parent.move_child(fade_rect, parent.get_child_count() - 1)

# -------------------------
# 切换场景（淡入淡出）
# -------------------------
func change_scene(path: String, duration: float = -1.0) -> void:
	if is_changing_scene or is_closing:
		return

	is_changing_scene = true

	if duration <= 0.0:
		duration = fade_duration

	if not fade_rect:
		_create_fade_rect(get_tree().current_scene)

	# 1. 淡出
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween: Tween = create_tween()
	active_tweens.append(tween)
	tween.tween_property(fade_rect, "modulate:a", 1.0, duration)
	await tween.finished
	if is_closing: return

	# 2. 加载新场景
	_load_scene_immediate(path)

	# 3. 淡入
	tween = create_tween()
	active_tweens.append(tween)
	tween.tween_property(fade_rect, "modulate:a", 0.0, duration)
	await tween.finished
	if is_closing: return

	# 4. 允许点击
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_changing_scene = false

# -------------------------
# 内部方法：立即加载场景
# -------------------------
func _load_scene_immediate(path: String) -> void:
	if current_scene and current_scene.is_inside_tree():
		center.remove_child(current_scene)
		current_scene.queue_free()
		current_scene = null

	var scene_res = load(path)
	if not scene_res:
		push_error("SceneManager: 无法加载场景: " + path)
		return

	current_scene = scene_res.instantiate()
	center.add_child(current_scene)
	current_scene.position = Vector2.ZERO

# -------------------------
# 立即切换场景（无动画）
# -------------------------
func set_scene_immediate(path: String) -> void:
	_load_scene_immediate(path)
	if fade_rect:
		fade_rect.modulate.a = 0.0
		fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

# -------------------------
# 手动淡入淡出
# -------------------------
func fade_out(duration: float = -1.0) -> void:
	if duration <= 0.0:
		duration = fade_duration
	if not fade_rect:
		_create_fade_rect(get_tree().current_scene)

	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween: Tween = create_tween()
	active_tweens.append(tween)
	tween.tween_property(fade_rect, "modulate:a", 1.0, duration)

func fade_in(duration: float = -1.0) -> void:
	if duration <= 0.0:
		duration = fade_duration
	if not fade_rect:
		return

	var tween: Tween = create_tween()
	active_tweens.append(tween)
	tween.tween_property(fade_rect, "modulate:a", 0.0, duration)
	await tween.finished
	if is_closing: return
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

# -------------------------
# 获取当前场景
# -------------------------
func get_current_scene() -> Node:
	return current_scene

# -------------------------
# 节点退出时清理
# -------------------------
func _exit_tree() -> void:
	is_closing = true
	# 安全清理所有 Tween
	for tween in active_tweens:
		if tween and tween.is_valid():
			tween.kill()
	active_tweens.clear()
