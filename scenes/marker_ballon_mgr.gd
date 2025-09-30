extends Marker2D
## 🎈 气球管理器
## 功能：
## - 扫描子节点中的气球
## - 顺序管理气球充气
## - 每次只显示当前可打气的气球
## - 气球飞走后不销毁也不隐藏，继续显示在场景中
## - 当所有气球飞走时发 all_balloons_finished 信号

signal all_balloons_finished   # 所有气球完成时发出的信号

var balloons: Array = []        # 保存所有气球的引用
var current_index: int = 0      # 当前气球索引

func _ready() -> void:
	_scan_balloons()
	# 初始化：只显示第一个气球
	_update_visible_balloons()

## 🔎 扫描子节点，把能 blow() 的节点加入管理
func _scan_balloons() -> void:
	balloons.clear()
	for child in get_children():
		if child.has_method("blow"):
			balloons.append(child)
			# 监听气球飞走事件
			child.connect("balloon_finished", Callable(self, "_on_balloon_finished"))
	print("🎈 已找到 %d 个气球" % balloons.size())

## 🎈 给当前气球打气
func pump_current_balloon() -> void:
	if current_index < balloons.size():
		balloons[current_index].blow()

## 🎈 气球飞走时
func _on_balloon_finished() -> void:
	print("✅ 气球 %d 已飞走" % current_index)
	# 让下一个气球出现
	current_index += 1
	_update_visible_balloons()

	# 如果所有气球都完成
	if current_index >= balloons.size():
		print("🎉 全部气球飞走，切换场景！")
		emit_signal("all_balloons_finished")

## 👀 更新气球的显示状态
## - 已经飞走的气球保持显示（不隐藏）
## - 当前要打气的气球显示出来
## - 还没轮到的气球先隐藏
func _update_visible_balloons() -> void:
	for i in range(balloons.size()):
		if i < current_index:
			# ✅ 之前的气球：已经飞走 → 保持显示（不隐藏）
			balloons[i].visible = true
		elif i == current_index:
			# 🎯 当前气球：可打气 → 显示
			balloons[i].visible = true
		else:
			# ⏳ 还没开始的气球 → 隐藏
			balloons[i].visible = false
