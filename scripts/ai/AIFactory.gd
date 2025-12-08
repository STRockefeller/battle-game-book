# AIFactory.gd
# AI 工廠 - 統一創建和管理所有 AI 類型
class_name AIFactory

# ==================== AI 創建 ====================

## 根據類型字串創建對應的 AI 實例
static func create_ai(ai_type: String) -> AIBehavior:
	match ai_type.to_lower():
		"random":
			return RandomAI.new()
		"aggressive":
			return AggressiveAI.new()
		"defensive":
			return DefensiveAI.new()
		"balanced":
			return BalancedAI.new()
		_:
			push_warning("未知的 AI 類型: %s，使用預設的隨機 AI" % ai_type)
			return RandomAI.new()

# ==================== AI 信息查詢 ====================

## 獲取所有可用的 AI 類型信息
static func get_available_ai_types() -> Array[Dictionary]:
	return [
		{
			"id": "random",
			"name": "隨機 AI",
			"description": "完全隨機選擇動作，適合測試和新手",
			"difficulty": 1
		},
		{
			"id": "aggressive",
			"name": "攻擊型 AI",
			"description": "優先選擇高傷害動作，攻擊性強",
			"difficulty": 3
		},
		{
			"id": "defensive",
			"name": "防守型 AI",
			"description": "注重生存，優先防禦和恢復動作",
			"difficulty": 2
		},
		{
			"id": "balanced",
			"name": "平衡型 AI",
			"description": "根據戰況靈活調整策略，攻防兼備",
			"difficulty": 4
		}
	]

## 根據 ID 獲取 AI 信息
static func get_ai_info(ai_id: String) -> Dictionary:
	for ai_info in get_available_ai_types():
		if ai_info["id"] == ai_id:
			return ai_info
	return {}

## 檢查 AI 類型是否存在
static func is_valid_ai_type(ai_type: String) -> bool:
	var valid_types = ["random", "aggressive", "defensive", "balanced"]
	return ai_type.to_lower() in valid_types

# ==================== 擴展接口（為未來資源化預留）====================

## 從資源創建 AI（預留接口）
## 目前返回 null，未來可以加載 .tres 資源
static func create_ai_from_resource(_resource_path: String) -> AIBehavior:
	# 預留給未來資源化使用
	# var resource = load(resource_path) as AIBehaviorResource
	# if resource:
	#     return resource.create_instance()
	push_warning("create_ai_from_resource 功能尚未實現")
	return null

## 註冊自定義 AI 類型（預留接口）
## 未來可以支援動態註冊新的 AI 類型
static var _custom_ai_registry: Dictionary = {}

static func register_custom_ai(ai_id: String, ai_class: GDScript, ai_info: Dictionary) -> void:
	_custom_ai_registry[ai_id] = {
		"class": ai_class,
		"info": ai_info
	}
	print("已註冊自定義 AI: %s" % ai_id)

static func create_custom_ai(ai_id: String) -> AIBehavior:
	if ai_id in _custom_ai_registry:
		var ai_class = _custom_ai_registry[ai_id]["class"]
		return ai_class.new()
	return null
