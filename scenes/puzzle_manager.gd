extends Node
class_name PuzzleManager

# -------------------------
# 可导出变量
# -------------------------
@export var piece_order: Array[String] = ["Bot", "Mid", "Top", "Fruit"]  
# 拼图顺序（名字要和 Piece 节点名一致）

# -------------------------
# 成员变量
# -------------------------
var current_index: int = 0   # 当前应拼接的索引位置
@onready var pieces: Node2D = %Pieces   # 存放所有拼图碎片的根节点（在编辑器里拖）

# 打字完成后要切换的场景路径
var next_scene_path: String = ""

# -------------------------
# 生命周期：准备完成
# -------------------------
func _ready() -> void:
	# 遍历所有碎片，并连接它们的 snapped_attempt 信号
	for piece in pieces.get_children():
		if piece is Piece:
			piece.snapped_attempt.connect(_on_piece_attempt)

# -------------------------
# 处理拼接尝试
# -------------------------
func _on_piece_attempt(piece: Piece) -> void:
	var expected_name = piece_order[current_index]

	if piece.name == expected_name:
		# ✅ 当前拼图是正确顺序 → 锁定到位
		piece.lock_to_correct()
		current_index += 1
		print("拼对:", piece.name, " 进度:", current_index, "/", piece_order.size())

		if current_index == piece_order.size():
			print("拼图完成！🎉")
			_on_fade_out_finished()
	else:
		# ❌ 顺序错误 → 只让这个被拖动的碎片回到初始点
		# 注意：不会影响之前已经拼对并锁定的碎片
		piece._reset_position()
		
# -------------------------
# 淡出完成后 -> 切换场景并删除自己
# -------------------------
func _on_fade_out_finished() -> void:
	if next_scene_path != "":
		await SceneManager.instance.set_scene_immediate(next_scene_path)
	# 删除整个 Control 节点，避免继续阻挡点击
	queue_free()
