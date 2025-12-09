# StanceManager.gd
# 負責管理角色的姿態系統

class_name StanceManager

# 持有此管理器的角色
var character: Character

# 當前姿態
var current_stance: Stance

# 姿態改變時的回調信號
signal stance_changed(old_stance: Stance.Type, new_stance: Stance.Type)

# ==================== 初始化 ====================

func _init(p_character: Character) -> void:
	character = p_character
	# 預設姿態為站立，無時間限制
	current_stance = Stance.new(Stance.Type.STANDING, -1)

# ==================== 姿態改變 ====================

## 改變角色的姿態
func change_stance(new_type: Stance.Type, duration: int = -1) -> void:
	var old_stance_type = current_stance.type
	
	# 建立新的姿態實例
	current_stance = Stance.new(new_type, duration)
	
	var old_name = _get_stance_name(old_stance_type)
	var new_name = _get_stance_name(new_type)
	print("%s 的姿態改變: %s → %s" % [character.name, old_name, new_name])
	
	# 發出信號
	stance_changed.emit(old_stance_type, new_type)

## 恢復到預設的站立姿態
func reset_to_standing() -> void:
	change_stance(Stance.Type.STANDING, -1)

# ==================== 查詢 ====================

## 獲取當前姿態類型
func get_current_stance_type() -> Stance.Type:
	return current_stance.type

## 獲取當前姿態名稱（中文，用於 UI 顯示）
func get_current_stance_name() -> String:
	match current_stance.type:
		Stance.Type.STANDING:
			return "站立"
		Stance.Type.KNOCKED_DOWN:
			return "倒地"
		Stance.Type.AIRBORNE:
			return "滯空"
		Stance.Type.GUARDING:
			return "防禦"
		_:
			return "未知"

## 獲取當前姿態 ID（英文鍵值，用於邏輯檢查）
func get_current_stance_id() -> String:
	match current_stance.type:
		Stance.Type.STANDING:
			return "standing"
		Stance.Type.KNOCKED_DOWN:
			return "knocked_down"
		Stance.Type.AIRBORNE:
			return "airborne"
		Stance.Type.GUARDING:
			return "guarding"
		_:
			return "unknown"

## 獲取當前姿態描述
func get_current_stance_description() -> String:
	match current_stance.type:
		Stance.Type.STANDING:
			return "正常狀態，可以執行所有基礎動作"
		Stance.Type.KNOCKED_DOWN:
			return "被擊倒在地，只能選擇「起身」動作"
		Stance.Type.AIRBORNE:
			return "懸浮在空中，只能執行空中動作"
		Stance.Type.GUARDING:
			return "防禦姿態，防禦力大幅提升但無法攻擊"
		_:
			return ""

## 獲取當前姿態持續時間
func get_remaining_duration() -> int:
	return current_stance.remaining_duration

## 檢查角色是否可以執行特定動作
func can_perform_action(action_tag: String) -> bool:
	match current_stance.type:
		Stance.Type.STANDING:
			return true
		Stance.Type.KNOCKED_DOWN:
			return action_tag == "stand_up"
		Stance.Type.AIRBORNE:
			return action_tag in ["aerial_attack", "aerial_skill"]
		Stance.Type.GUARDING:
			return action_tag in ["guard", "counter_guard"]
		_:
			return false

## 檢查角色是否處於特定姿態
func is_stance(stance_type: Stance.Type) -> bool:
	return current_stance.type == stance_type

# ==================== 屬性修正 ====================

## 根據姿態獲取屬性修正值
func get_stance_stat_modifier(stat: String) -> int:
	match current_stance.type:
		Stance.Type.GUARDING:
			# 防禦姿態提升防禦力
			if stat == "def":
				return 50  # 防禦力提升 50%
			elif stat == "mdef":
				return 25  # 魔法防禦提升 25%
		
		Stance.Type.KNOCKED_DOWN:
			# 倒地狀態防禦力大幅下降
			if stat == "def":
				return -50  # 防禦力降低 50%
		
		Stance.Type.AIRBORNE:
			# 滯空狀態無法地面防禦
			if stat == "def":
				return -30  # 防禦力降低 30%
	
	return 0

# ==================== 回合更新 ====================

## 在回合開始時調用
func on_turn_start() -> void:
	# 姿態在回合開始時可能需要執行的邏輯
	pass

## 在回合結束時調用
func on_turn_end() -> void:
	current_stance.on_turn_end()
	
	# 如果姿態已過期，恢復到站立
	if current_stance.is_expired():
		var stance_name = _get_stance_name(current_stance.type)
		print("%s 的「%s」狀態已結束，恢復站立" % [character.name, stance_name])
		reset_to_standing()

# ==================== 姿態特殊效果 ====================

## 在角色受到傷害時調用，返回是否應該被倒地
func on_take_damage(_damage: int) -> bool:
	# 倒地的觸發邏輯可以在這裡實現
	# 例如：超過一定傷害值時倒地
	return false

## 檢查姿態是否影響行動
func affects_action_execution() -> bool:
	return current_stance.type in [
		Stance.Type.KNOCKED_DOWN,
		Stance.Type.GUARDING
	]

# ==================== 輔助方法 ====================

func _get_stance_name(stance_type: Stance.Type) -> String:
	match stance_type:
		Stance.Type.STANDING:
			return "站立"
		Stance.Type.KNOCKED_DOWN:
			return "倒地"
		Stance.Type.AIRBORNE:
			return "滯空"
		Stance.Type.GUARDING:
			return "防禦"
		_:
			return "未知"
