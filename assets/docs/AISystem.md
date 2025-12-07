# AI 系統設計與資源化建議

## 目前狀況

### 現有架構
```
scripts/ai/
├── AIBehavior.gd          # 基礎類別（extends Node）
└── RandomAIBehavior.gd    # 隨機 AI（extends AIBehavior）
```

### 目前的使用方式
```gdscript
# BattleManager.gd
var player2_ai: AIBehavior
player2_ai = RandomAIBehavior.new()  # 硬編碼創建

# CharacterSelection.gd
var selected_ai_behavior: String = "random"  # 字串標識
```

**問題**：
1. ❌ 新增 AI 需要修改 BattleManager 程式碼
2. ❌ 字串與類別的映射需要手動維護
3. ❌ AI 參數無法在編輯器中調整
4. ❌ 無法在編輯器中預覽 AI 配置

---

## 資源化設計方案

### 方案一：Resource + GDScript 混合（推薦）

#### 優點
- ✅ 在編輯器中配置 AI 參數
- ✅ 程式碼邏輯靈活（可以寫複雜策略）
- ✅ 易於擴展和測試
- ✅ 保持型別安全

#### 結構設計

```
resources/ai/
├── AIRandom.tres           # 隨機 AI 資源
├── AIAggressive.tres       # 攻擊型 AI 資源
├── AIDefensive.tres        # 防守型 AI 資源
└── AIBalanced.tres         # 平衡型 AI 資源

scripts/ai/
├── AIBehaviorResource.gd   # 新增：AI 資源定義
├── AIBehavior.gd          # 保留：基礎類別
├── RandomAI.gd            # 重構：實現類別
├── AggressiveAI.gd        # 新增：攻擊型 AI
├── DefensiveAI.gd         # 新增：防守型 AI
└── BalancedAI.gd          # 新增：平衡型 AI
```

#### 實現細節

##### 1. AIBehaviorResource.gd（資源定義）
```gdscript
# AIBehaviorResource.gd
extends Resource
class_name AIBehaviorResource

## AI 顯示名稱
@export var display_name: String = "未命名 AI"

## AI 描述
@export_multiline var description: String = ""

## AI 行為類別名稱（用於動態加載）
@export var behavior_class_name: String = "RandomAI"

## AI 參數配置
@export_group("通用參數")
@export var aggression: float = 0.5  # 攻擊性 (0-1)
@export var caution: float = 0.5     # 謹慎度 (0-1)
@export var skill_usage: float = 0.5 # 技能使用率 (0-1)

@export_group("高級參數")
@export var hp_threshold_low: float = 0.3   # 低血量閾值
@export var mp_threshold_low: float = 0.2   # 低魔量閾值
@export var prefer_high_damage: bool = true # 優先高傷害動作

## 創建對應的 AI 實例
func create_instance() -> AIBehavior:
	var ai_class = ClassDB.instantiate(behavior_class_name)
	if ai_class == null:
		push_error("無法創建 AI 類別: %s" % behavior_class_name)
		return null
	
	var ai_instance = ai_class as AIBehavior
	if ai_instance:
		ai_instance.configure(self)  # 傳入資源配置
	
	return ai_instance
```

##### 2. AIBehavior.gd（重構基礎類別）
```gdscript
# AIBehavior.gd
extends Node
class_name AIBehavior

## AI 配置資源
var config: AIBehaviorResource

## 配置 AI（從資源加載參數）
func configure(resource: AIBehaviorResource) -> void:
	config = resource

## AI 選擇動作（子類實現）
func choose_action(character: Character, available_actions: Array, opponent: Character, battle_manager: BattleManager) -> Action:
	push_error("choose_action() 未實現")
	return null

## 輔助方法：評估動作優先級（子類可重寫）
func evaluate_action(action: Action, character: Character, opponent: Character, battle_manager: BattleManager) -> float:
	return 0.0

## 輔助方法：檢查角色狀態
func get_hp_ratio(character: Character, battle_manager: BattleManager) -> float:
	return float(battle_manager.get_current_hp(character)) / character.max_hp

func get_mp_ratio(character: Character, battle_manager: BattleManager) -> float:
	return float(battle_manager.get_current_mp(character)) / character.max_mp

func get_sta_ratio(character: Character, battle_manager: BattleManager) -> float:
	var max_sta = character.constitution * 8
	return float(battle_manager.get_current_sta(character)) / max_sta
```

##### 3. RandomAI.gd（重構實現）
```gdscript
# RandomAI.gd
extends AIBehavior
class_name RandomAI

func choose_action(character: Character, available_actions: Array, opponent: Character, battle_manager: BattleManager) -> Action:
	if available_actions.size() == 0:
		return null
	
	# 使用配置參數影響選擇
	if config and config.prefer_high_damage:
		# 有一定機率優先選擇高傷害動作
		if randf() < config.skill_usage:
			var high_damage_actions = available_actions.filter(
				func(a): return a.base_damage > 10
			)
			if high_damage_actions.size() > 0:
				return high_damage_actions[randi() % high_damage_actions.size()]
	
	# 否則完全隨機
	return available_actions[randi() % available_actions.size()]
```

##### 4. AggressiveAI.gd（攻擊型 AI）
```gdscript
# AggressiveAI.gd
extends AIBehavior
class_name AggressiveAI

func choose_action(character: Character, available_actions: Array, opponent: Character, battle_manager: BattleManager) -> Action:
	if available_actions.size() == 0:
		return null
	
	# 優先選擇高傷害動作
	var best_action: Action = null
	var best_score: float = -1.0
	
	for action in available_actions:
		var score = evaluate_action(action, character, opponent, battle_manager)
		if score > best_score:
			best_score = score
			best_action = action
	
	return best_action

func evaluate_action(action: Action, character: Character, opponent: Character, battle_manager: BattleManager) -> float:
	var score = 0.0
	
	# 基礎傷害權重
	score += action.base_damage * 10.0
	
	# 傷害倍率加成
	score += action.damage_multiplier * 20.0
	
	# 優先使用攻擊性標籤的動作
	if "physical" in action.tags or "magic" in action.tags:
		score += 15.0
	
	# 考慮命中率
	score += action.accuracy_modifier * 10.0
	
	# 低血量時稍微降低風險（但仍然攻擊性強）
	var hp_ratio = get_hp_ratio(character, battle_manager)
	if hp_ratio < config.hp_threshold_low:
		score *= 0.8
	
	# 添加隨機性
	score *= randf_range(0.9, 1.1)
	
	return score
```

##### 5. DefensiveAI.gd（防守型 AI）
```gdscript
# DefensiveAI.gd
extends AIBehavior
class_name DefensiveAI

func choose_action(character: Character, available_actions: Array, opponent: Character, battle_manager: BattleManager) -> Action:
	if available_actions.size() == 0:
		return null
	
	var hp_ratio = get_hp_ratio(character, battle_manager)
	var sta_ratio = get_sta_ratio(character, battle_manager)
	
	# 低血量時優先防禦或恢復
	if hp_ratio < config.hp_threshold_low:
		# 尋找防禦動作
		for action in available_actions:
			if "guard" in action.tags:
				return action
		
		# 尋找治療動作
		for action in available_actions:
			if "healing" in action.tags:
				return action
	
	# 低耐力時使用休息
	if sta_ratio < 0.3:
		for action in available_actions:
			if "rest" in action.tags:
				return action
	
	# 其他情況選擇安全的攻擊
	var best_action: Action = null
	var best_score: float = -1.0
	
	for action in available_actions:
		var score = evaluate_action(action, character, opponent, battle_manager)
		if score > best_score:
			best_score = score
			best_action = action
	
	return best_action

func evaluate_action(action: Action, character: Character, opponent: Character, battle_manager: BattleManager) -> float:
	var score = 0.0
	
	# 優先低消耗動作
	score += (10.0 - action.cost_stamina) * 2.0
	score += (20.0 - action.cost_mp) * 1.5
	
	# 高命中率加成
	score += action.accuracy_modifier * 20.0
	
	# 防禦和支援動作加成
	if "guard" in action.tags or "support" in action.tags:
		score += 25.0
	
	# 傷害適中即可
	score += action.base_damage * 5.0
	
	# 添加隨機性
	score *= randf_range(0.9, 1.1)
	
	return score
```

#### 使用方式

##### 創建資源文件
```gdscript
# resources/ai/AIRandom.tres
[gd_resource type="Resource" load_steps=2 format=3]

[ext_resource path="res://scripts/ai/AIBehaviorResource.gd" type="Script" id=1]

[resource]
script = ExtResource("1")
display_name = "隨機 AI"
description = "完全隨機選擇動作，適合測試"
behavior_class_name = "RandomAI"
aggression = 0.5
caution = 0.5
skill_usage = 0.5
prefer_high_damage = false
```

```gdscript
# resources/ai/AIAggressive.tres
[gd_resource type="Resource" load_steps=2 format=3]

[ext_resource path="res://scripts/ai/AIBehaviorResource.gd" type="Script" id=1]

[resource]
script = ExtResource("1")
display_name = "攻擊型 AI"
description = "優先選擇高傷害動作，適合作為強敵"
behavior_class_name = "AggressiveAI"
aggression = 0.9
caution = 0.2
skill_usage = 0.8
prefer_high_damage = true
hp_threshold_low = 0.2
```

##### 在 BattleManager 中使用
```gdscript
# BattleManager.gd

# 從資源加載 AI
func _setup_ai():
	var enemy_ai_type = BattleConfig.get_enemy_ai_behavior()
	var ai_resource: AIBehaviorResource
	
	match enemy_ai_type:
		"random":
			ai_resource = load("res://resources/ai/AIRandom.tres")
		"aggressive":
			ai_resource = load("res://resources/ai/AIAggressive.tres")
		"defensive":
			ai_resource = load("res://resources/ai/AIDefensive.tres")
		_:
			ai_resource = load("res://resources/ai/AIRandom.tres")
	
	if ai_resource:
		player2_ai = ai_resource.create_instance()
	else:
		push_error("無法加載 AI 資源")
		player2_ai = RandomAI.new()
```

##### 動態掃描 AI 資源
```gdscript
# CharacterSelection.gd

func _ready():
	_load_available_ai_behaviors()

func _load_available_ai_behaviors():
	ai_behaviors.clear()
	
	var ai_dir = DirAccess.open("res://resources/ai/")
	if ai_dir:
		ai_dir.list_dir_begin()
		var file_name = ai_dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".tres"):
				var resource_path = "res://resources/ai/" + file_name
				var ai_resource = load(resource_path) as AIBehaviorResource
				
				if ai_resource:
					ai_behaviors.append({
						"id": file_name.get_basename(),
						"name": ai_resource.display_name,
						"description": ai_resource.description,
						"resource": ai_resource
					})
			
			file_name = ai_dir.get_next()
		
		ai_dir.list_dir_end()
```

---

## 方案二：純程式碼策略模式（簡單）

如果不需要在編輯器中調整參數，可以保持目前的架構，只需改進工廠模式：

```gdscript
# AIFactory.gd
class_name AIFactory

static func create_ai(ai_type: String) -> AIBehavior:
	match ai_type:
		"random":
			return RandomAI.new()
		"aggressive":
			return AggressiveAI.new()
		"defensive":
			return DefensiveAI.new()
		"balanced":
			return BalancedAI.new()
		_:
			push_error("未知的 AI 類型: %s" % ai_type)
			return RandomAI.new()

static func get_available_ai_types() -> Array[Dictionary]:
	return [
		{"id": "random", "name": "隨機 AI", "description": "完全隨機選擇動作"},
		{"id": "aggressive", "name": "攻擊型 AI", "description": "優先高傷害動作"},
		{"id": "defensive", "name": "防守型 AI", "description": "注重生存和防禦"},
		{"id": "balanced", "name": "平衡型 AI", "description": "攻防平衡策略"}
	]
```

**優點**：
- ✅ 實現簡單
- ✅ 無需資源文件
- ✅ 集中管理

**缺點**：
- ❌ 無法在編輯器中調參數
- ❌ 擴展需要修改程式碼

---

## 方案三：行為樹（複雜但強大）

使用 Godot 的 BehaviorTree 插件或自行實現：

```
resources/ai/
├── AggressiveBT.tres      # 攻擊型行為樹
└── DefensiveBT.tres       # 防守型行為樹
```

**優點**：
- ✅ 視覺化編輯 AI 邏輯
- ✅ 極其靈活
- ✅ 業界標準方案

**缺點**：
- ❌ 學習曲線陡峭
- ❌ 需要額外插件或實現框架
- ❌ 可能過度設計（簡單回合制不需要）

---

## 推薦方案對比

| 方案 | 複雜度 | 靈活性 | 編輯器支援 | 適用場景 |
| :--- | :--- | :--- | :--- | :--- |
| **方案一：Resource 混合** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ✅ | **推薦**，適合需要調參的項目 |
| **方案二：策略模式** | ⭐ | ⭐⭐⭐ | ❌ | 適合簡單 AI，快速開發 |
| **方案三：行為樹** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ✅ | 適合複雜 AI，大型項目 |

---

## 實施建議

### 階段一：重構現有系統（立即）
1. 創建 `AIFactory.gd` 統一 AI 創建
2. 在 BattleManager 中使用工廠模式
3. 實現 2-3 個不同策略的 AI

### 階段二：資源化（中期）
1. 創建 `AIBehaviorResource.gd`
2. 為每個 AI 創建 `.tres` 資源
3. 重構 AI 類別支援配置
4. 在編輯器中調整參數

### 階段三：優化與擴展（長期）
1. 添加 AI 調試工具
2. 實現 AI 評分可視化
3. 支援自定義權重配置
4. 考慮引入行為樹（如果需要）

---

## 總結

**目前建議**：先使用**方案二（策略模式）**快速實現多種 AI，之後根據需求升級到**方案一（Resource 混合）**進行精細調參。方案三（行為樹）適合大型項目，目前不推薦。
