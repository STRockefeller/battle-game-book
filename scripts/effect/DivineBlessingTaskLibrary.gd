# DivineBlessingTaskLibrary.gd
# 神恩任務工廠 - 依神明與難度生成 DivineBlessingTask

class_name DivineBlessingTaskLibrary
extends RefCounted

## 為指定神明和難度創建任務
static func create_task(deity_id: String, difficulty: int) -> DivineBlessingTask:
	match deity_id:
		"god_of_war":
			return _create_god_of_war_task(difficulty)
		"goddess_of_wisdom":
			return _create_goddess_of_wisdom_task(difficulty)
		"god_of_commerce":
			return _create_god_of_commerce_task(difficulty)
		"goddess_of_life":
			return _create_goddess_of_life_task(difficulty)
		"god_of_deceit":
			return _create_god_of_deceit_task(difficulty)
		"god_of_balance":
			return _create_god_of_balance_task(difficulty)

	return null

# ==================== 戰神 - 攻擊導向 ====================

static func _create_god_of_war_task(difficulty: int) -> DivineBlessingTask:
	var task: DivineBlessingTask
	match difficulty:
		0:  # 簡單
			task = DivineBlessingTask.new("god_of_war", 0, "初試鋒芒")
			task.requirement = "前 3 回合中至少進行 1 次攻擊行動"
			task.blessing_effects = [
				Effect.new("damage_bonus", "add", 0.15)
			]
			task.condition_params = {
				"action_tags": ["attack"],
				"min_count": 1,
				"window_turns": 3
			}
		1:  # 標準
			task = DivineBlessingTask.new("god_of_war", 1, "連貫進攻")
			task.requirement = "前 5 回合中至少進行 3 次攻擊行動"
			task.blessing_effects = [
				Effect.new("damage_bonus", "add", 0.30)
			]
			task.condition_params = {
				"action_tags": ["attack"],
				"min_count": 3,
				"window_turns": 5
			}
		2:  # 困難
			task = DivineBlessingTask.new("god_of_war", 2, "不懈戰士")
			task.requirement = "整場戰鬥中攻擊行動不少於 50% 的總行動數"
			task.blessing_effects = [
				Effect.new("damage_bonus", "add", 0.50)
			]
			task.condition_params = {
				"action_tags": ["attack"],
				"min_percentage": 0.5
			}
		_:
			return null
	return task

# ==================== 智慧女神 - 防禦導向 ====================

static func _create_goddess_of_wisdom_task(difficulty: int) -> DivineBlessingTask:
	var task: DivineBlessingTask
	match difficulty:
		0:  # 簡單
			task = DivineBlessingTask.new("goddess_of_wisdom", 0, "初試防禦")
			task.requirement = "前 4 回合中至少進行 1 次防禦行動"
			task.blessing_effects = [
				Effect.new("damage_reduction", "add", 0.12)
			]
			task.condition_params = {
				"action_tags": ["defend"],
				"min_count": 1,
				"window_turns": 4
			}
		1:  # 標準
			task = DivineBlessingTask.new("goddess_of_wisdom", 1, "堅壁清野")
			task.requirement = "前 6 回合中至少進行 3 次防禦行動"
			task.blessing_effects = [
				Effect.new("damage_reduction", "add", 0.25)
			]
			task.condition_params = {
				"action_tags": ["defend"],
				"min_count": 3,
				"window_turns": 6
			}
		2:  # 困難
			task = DivineBlessingTask.new("goddess_of_wisdom", 2, "不破之堡")
			task.requirement = "10 回合內防禦成功（敵方未命中）10 次以上"
			task.blessing_effects = [
				Effect.new("damage_reduction", "add", 0.40)
			]
			task.condition_params = {
				"action_tags": ["defend"],
				"min_success": 10
			}
		_:
			return null
	return task

# ==================== 商業之神 - 資源導向 ====================

static func _create_god_of_commerce_task(difficulty: int) -> DivineBlessingTask:
	var task: DivineBlessingTask
	match difficulty:
		0:  # 簡單
			task = DivineBlessingTask.new("god_of_commerce", 0, "初嘗獲利")
			task.requirement = "5 回合內使用 3 個不同行動"
			task.blessing_effects = [
				Effect.new("stamina_recovery_speed", "multiply", 1.20)
			]
			task.condition_params = {
				"unique_actions": 3,
				"window_turns": 5
			}
		1:  # 標準
			task = DivineBlessingTask.new("god_of_commerce", 1, "精打細算")
			task.requirement = "整場戰鬥中行動多樣性達 70%"
			task.blessing_effects = [
				Effect.new("stamina_cost_reduction", "multiply", 0.20)
			]
			task.condition_params = {
				"min_diversity_percentage": 0.70
			}
		2:  # 困難
			task = DivineBlessingTask.new("god_of_commerce", 2, "商業帝國")
			task.requirement = "耐力始終在 80% 以上且使用所有可用行動"
			task.blessing_effects = [
				Effect.new("stamina_cost_reduction", "multiply", 0.40)
			]
			task.condition_params = {
				"min_stamina_percentage": 0.80,
				"all_actions_required": true
			}
		_:
			return null
	return task

# ==================== 生命女神 - 保護導向 ====================

static func _create_goddess_of_life_task(difficulty: int) -> DivineBlessingTask:
	var task: DivineBlessingTask
	match difficulty:
		0:  # 簡單
			task = DivineBlessingTask.new("goddess_of_life", 0, "初次庇護")
			task.requirement = "保持 HP 高於最大值 60% 持續 4 回合"
			task.blessing_effects = [
				Effect.new("hp_recovery_per_turn", "add", 5.0)
			]
			task.condition_params = {
				"min_hp_percentage": 0.60,
				"window_turns": 4
			}
		1:  # 標準
			task = DivineBlessingTask.new("goddess_of_life", 1, "精心呵護")
			task.requirement = "HP 始終高於 50%，且使用恢復類行動 2 次"
			task.blessing_effects = [
				Effect.new("hp_recovery_per_turn", "add", 15.0)
			]
			task.condition_params = {
				"min_hp_percentage": 0.50,
				"healing_actions": 2
			}
		2:  # 困難
			task = DivineBlessingTask.new("goddess_of_life", 2, "永恆守護")
			task.requirement = "HP 始終高於 70%"
			task.blessing_effects = [
				Effect.new("hp_recovery_per_turn", "add", 30.0)
			]
			task.condition_params = {
				"min_hp_percentage": 0.70
			}
		_:
			return null
	return task

# ==================== 欺詐之神 - 特殊導向 ====================

static func _create_god_of_deceit_task(difficulty: int) -> DivineBlessingTask:
	var task: DivineBlessingTask
	match difficulty:
		0:  # 簡單
			task = DivineBlessingTask.new("god_of_deceit", 0, "初露端倪")
			task.requirement = "前 3 回合中改變姿態 1 次"
			task.blessing_effects = [
				Effect.new("action_speed_bonus", "add", 1.0)
			]
			task.condition_params = {
				"stance_changes": 1,
				"window_turns": 3
			}
		1:  # 標準
			task = DivineBlessingTask.new("god_of_deceit", 1, "虛實交錯")
			task.requirement = "出其不意 3 次"
			task.blessing_effects = [
				Effect.new("dodge_on_hit", "add", 0.30)
			]
			task.condition_params = {
				"unpredictable_actions": 3
			}
		2:  # 困難
			task = DivineBlessingTask.new("god_of_deceit", 2, "大師欺瞞")
			task.requirement = "保持行動不可預測性"
			task.blessing_effects = [
				Effect.new("enemy_accuracy_reduction", "add", 0.30)
			]
			task.condition_params = {
				"max_same_actions": 2,
				"check_window": 5
			}
		_:
			return null
	return task

# ==================== 平衡之神 - 均衡導向 ====================

static func _create_god_of_balance_task(difficulty: int) -> DivineBlessingTask:
	var task: DivineBlessingTask
	match difficulty:
		0:  # 簡單
			task = DivineBlessingTask.new("god_of_balance", 0, "尋求平衡")
			task.requirement = "行動類型相對均衡"
			task.blessing_effects = [
				Effect.new("damage_bonus", "add", 0.10),
				Effect.new("damage_reduction", "add", 0.10)
			]
			task.condition_params = {
				"required_action_types": ["attack", "defend", "special"],
				"min_each": 1
			}
		1:  # 標準
			task = DivineBlessingTask.new("god_of_balance", 1, "完美協調")
			task.requirement = "攻防特行動次數差異不超過 1"
			task.blessing_effects = [
				Effect.new("damage_bonus", "add", 0.20),
				Effect.new("damage_reduction", "add", 0.15)
			]
			task.condition_params = {
				"balanced_distribution": true,
				"max_difference": 1
			}
		2:  # 困難
			task = DivineBlessingTask.new("god_of_balance", 2, "天地平衡")
			task.requirement = "HP 與耐力管理完美"
			task.blessing_effects = [
				Effect.new("all_damage_bonus", "multiply", 0.25),
				Effect.new("all_defense_bonus", "multiply", 0.25)
			]
			task.condition_params = {
				"hp_range": Vector2(0.40, 0.90),
				"stamina_range": Vector2(0.30, 0.90)
			}
		_:
			return null
	return task
