extends RefCounted
class_name CharacterVisualState

## CharacterVisualState 負責管理角色的視覺狀態
## 包括姿勢、生命值、狀態效果等，用於決定顯示哪些資源

# 姿勢枚舉
enum Pose {
	IDLE,      # 待機
	ATTACK,    # 攻擊
	HIT,       # 受擊
	DEFEND,    # 防禦
	CAST,      # 施法
	VICTORY,   # 勝利
	DEFEAT,    # 失敗
	LOW_HP     # 低血量待機
}

# 視覺狀態數據
var character_id: String = ""
var current_pose: Pose = Pose.IDLE
var hp_percentage: float = 1.0  # 0.0 到 1.0
var active_status_effects: Array[String] = []  # 狀態效果ID列表
var is_knocked_down: bool = false

## 建構函式
func _init(char_id: String = ""):
	character_id = char_id

## 更新角色生命值百分比
func update_hp(current_hp: int, max_hp: int) -> void:
	if max_hp > 0:
		hp_percentage = float(current_hp) / float(max_hp)
	else:
		hp_percentage = 0.0

## 設定姿勢
func set_pose(pose: Pose) -> void:
	current_pose = pose

## 添加狀態效果
func add_status_effect(status_id: String) -> void:
	if not active_status_effects.has(status_id):
		active_status_effects.append(status_id)

## 移除狀態效果
func remove_status_effect(status_id: String) -> void:
	var index = active_status_effects.find(status_id)
	if index >= 0:
		active_status_effects.remove_at(index)

## 清除所有狀態效果
func clear_status_effects() -> void:
	active_status_effects.clear()

## 設定擊倒狀態
func set_knocked_down(knocked_down: bool) -> void:
	is_knocked_down = knocked_down

## 取得當前應該顯示的精靈圖路徑（帶fallback）
## @param character_assets: 角色資源定義
## @return 精靈圖路徑列表（優先級從高到低）
func get_sprite_paths(character_assets) -> Array[String]:
	var paths: Array[String] = []
	
	# 如果沒有資源定義，返回空列表
	if not character_assets:
		return paths
	
	# 如果是擊倒狀態，優先使用擊倒精靈圖
	if is_knocked_down:
		var knockdown_path = character_assets.sprite_defeat
		if not knockdown_path.is_empty():
			paths.append(knockdown_path)
	
	# 低血量時的特殊精靈圖
	if hp_percentage < 0.3 and current_pose == Pose.IDLE:
		var low_hp_path = character_assets.sprite_low_hp
		if not low_hp_path.is_empty():
			paths.append(low_hp_path)
	
	# 添加當前姿勢的精靈圖
	var pose_path = character_assets.get_sprite_path(current_pose)
	if not pose_path.is_empty():
		paths.append(pose_path)
	
	# Fallback到idle
	if current_pose != Pose.IDLE:
		var idle_path = character_assets.sprite_idle
		if not idle_path.is_empty():
			paths.append(idle_path)
	
	return paths

## 取得當前應該播放的音效路徑（帶fallback）
## @param character_assets: 角色資源定義
## @return 音效路徑列表（優先級從高到低）
func get_audio_paths(character_assets) -> Array[String]:
	var paths: Array[String] = []
	
	# 如果沒有資源定義，返回空列表
	if not character_assets:
		return paths
	
	# 根據當前姿勢添加對應的音效
	match current_pose:
		Pose.ATTACK:
			if not character_assets.audio_attack.is_empty():
				paths.append(character_assets.audio_attack)
		Pose.HIT:
			if not character_assets.audio_hit.is_empty():
				paths.append(character_assets.audio_hit)
		Pose.DEFEND:
			if not character_assets.audio_defend.is_empty():
				paths.append(character_assets.audio_defend)
		Pose.VICTORY:
			if not character_assets.audio_victory.is_empty():
				paths.append(character_assets.audio_victory)
		Pose.DEFEAT:
			if not character_assets.audio_defeat.is_empty():
				paths.append(character_assets.audio_defeat)
	
	return paths

## 取得當前應該顯示的狀態效果圖示路徑列表
## @param active_status_assets: 活躍的狀態效果資源列表
## @return 狀態效果圖示路徑陣列
func get_status_icon_paths(active_status_assets) -> Array[String]:
	var paths: Array[String] = []
	
	for status_assets in active_status_assets:
		if status_assets and not status_assets.icon_path.is_empty():
			paths.append(status_assets.icon_path)
	
	return paths

## 取得當前應該播放的狀態效果VFX路徑列表
## @param active_status_assets: 活躍的狀態效果資源列表
## @return 狀態效果VFX路徑陣列
func get_status_vfx_paths(active_status_assets) -> Array[String]:
	var paths: Array[String] = []
	
	for status_assets in active_status_assets:
		if status_assets and not status_assets.vfx_path.is_empty():
			paths.append(status_assets.vfx_path)
	
	return paths

## 判斷是否處於低血量狀態
func is_low_hp() -> bool:
	return hp_percentage < 0.3

## 判斷是否處於危險狀態（瀕死）
func is_critical_hp() -> bool:
	return hp_percentage < 0.15

## 序列化為字典（用於網路同步）
func to_dict() -> Dictionary:
	return {
		"character_id": character_id,
		"current_pose": current_pose,
		"hp_percentage": hp_percentage,
		"active_status_effects": active_status_effects.duplicate(),
		"is_knocked_down": is_knocked_down
	}

## 從字典反序列化
static func from_dict(data: Dictionary) -> CharacterVisualState:
	var state = CharacterVisualState.new()
	state.character_id = data.get("character_id", "")
	state.current_pose = data.get("current_pose", Pose.IDLE)
	state.hp_percentage = data.get("hp_percentage", 1.0)
	
	var status_array = data.get("active_status_effects", [])
	for status in status_array:
		state.active_status_effects.append(status)
	
	state.is_knocked_down = data.get("is_knocked_down", false)
	
	return state
