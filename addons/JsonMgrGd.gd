extends Node
class_name JsonMgr

## 🔹 Json 管理器
## 功能：用于保存/读取 JSON 文件，类似 Unity 的 JsonMgr
## 注意：建议把这个脚本设置为 AutoLoad 单例（Project → Project Settings → AutoLoad）

# ----------------------
# 🔹 单例实现
# ----------------------
static var _instance: JsonMgr

## 获取单例实例
static func get_instance() -> JsonMgr:
	if _instance == null:
		_instance = JsonMgr.new()
	return _instance


# ----------------------
# 🔹 保存数据到 JSON
# ----------------------
## @param data 任意可序列化的数据（字典 / 数组）
## @param file_name 文件名（不需要带 .json 后缀）
func save_data(data: Variant, file_name: String) -> void:
	var path = "user://%s.json" % file_name
	var json_str = JSON.stringify(data, "\t")  # 格式化为 JSON 字符串

	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(json_str)
		file.close()
		print("✅ 已保存数据到: %s" % path)


# ----------------------
# 🔹 从 JSON 文件读取数据
# ----------------------
## @param file_name 文件名（不需要带 .json 后缀）
## @return 读取到的对象（字典 / 数组），失败时返回 {}
func load_data(file_name: String) -> Variant:
	# 先从 res://data/json/ 读取（可选：适合内置配置）
	var path = "res://data/json/%s.json" % file_name
	if not FileAccess.file_exists(path):
		# 如果没有，再从 user:// 读取（玩家存档数据）
		path = "user://%s.json" % file_name
		if not FileAccess.file_exists(path):
			push_warning("⚠️ 找不到 JSON 文件: %s" % file_name)
			return {}

	# 打开文件
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	# 解析 JSON
	var result = JSON.parse_string(content)
	if result == null:
		push_error("❌ JSON 解析失败: %s" % file_name)
		return {}

	return result
