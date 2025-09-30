# EventBus.gd
extends Node

# listeners 用来存储所有事件监听器（订阅者）
# 数据结构是字典套字典：
# {
#   "group_name": {                     # 分组名字（默认 "default"）
#       "event_name": [Callable, ...]   # 某个事件对应的回调列表
#   }
# }
var listeners: Dictionary = {}

# 是否开启调试输出（true 时打印订阅/退订/发射日志）
var debug_enabled: bool = false


# ===================== 订阅 =====================

# 订阅一个事件
# event_name: 事件名（字符串）
# listener:   回调函数（Callable）
# group:      分组名（默认 "default"）
func subscribe(event_name: String, listener: Callable, group: String = "default") -> void:
	if not listeners.has(group):
		listeners[group] = {}  # 先创建分组
	if not listeners[group].has(event_name):
		listeners[group][event_name] = []  # 先创建事件
	var arr: Array = listeners[group][event_name]
	if listener in arr:
		return  # 防止重复订阅
	arr.append(listener)  # 添加回调
	if debug_enabled:
		print("[EventBus] subscribe:", group, "/", event_name, "<-", listener)


# 批量订阅：传入一个字典 { "event_name": Callable, ... }
func batch_subscribe(event_map: Dictionary, group: String = "default") -> void:
	for event_name in event_map.keys():
		var listener: Callable = event_map[event_name]
		subscribe(event_name, listener, group)


# ===================== 退订 =====================

# 退订一个事件
func unsubscribe(event_name: String, listener: Callable, group: String = "default") -> void:
	if listeners.has(group) and listeners[group].has(event_name):
		listeners[group][event_name].erase(listener)
		if debug_enabled:
			print("[EventBus] unsubscribe:", group, "/", event_name, "<-", listener)


# 批量退订
func batch_unsubscribe(event_map: Dictionary, group: String = "default") -> void:
	for event_name in event_map.keys():
		var listener: Callable = event_map[event_name]
		unsubscribe(event_name, listener, group)


# ===================== 发射事件 =====================

# 发射（触发）一个事件
# event_name: 事件名
# args:       参数，可以是 null / 单个参数 / 参数数组
# group:      指定分组，不填则广播到所有分组
func emit(event_name: String, args: Variant = null, group: String = "") -> void:
	var arg_list: Array = []
	if args == null:
		arg_list = []
	elif args is Array:
		arg_list = args
	else:
		arg_list = [args]  # 单个参数转成数组，方便统一处理

	if group != "":
		_emit_to_group(group, event_name, arg_list)  # 只发给某个分组
	else:
		for g in listeners.keys():
			_emit_to_group(g, event_name, arg_list)  # 广播给所有分组


# 内部函数：真正派发给一个分组
func _emit_to_group(group: String, event_name: String, arg_list: Array) -> void:
	if not listeners.has(group):
		return
	if not listeners[group].has(event_name):
		return
	var arr: Array = listeners[group][event_name]
	# 遍历副本，防止回调过程中修改数组（避免崩溃）
	for cb in arr.duplicate():
		if cb.is_valid():
			cb.callv(arg_list)  # 带参数调用回调
		else:
			arr.erase(cb)  # 清理已经无效的回调
	if debug_enabled:
		print("[EventBus] emit:", group, "/", event_name, "args:", arg_list)
