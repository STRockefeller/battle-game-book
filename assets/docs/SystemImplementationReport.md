# 系統實現方針確認報告

## 📋 檢查結果

### ✅ Stance 系統 - 程式碼寫死（符合方針）

#### 實現方式
- **Stance.gd**: 
  - 枚舉定義 `enum Type { STANDING, KNOCKED_DOWN, AIRBORNE, GUARDING }`
  - 靜態方法提供姿態信息查詢
  - 實例持有姿態類型和持續時間

- **StanceManager.gd**:
  - 每個角色持有一個管理器實例
  - 使用 `match` 語句處理姿態邏輯
  - 提供屬性修正和動作過濾

- **文檔**:
  - `assets/docs/Stance.md` 正確描述為「程式碼實現（枚舉 + 狀態機）」
  - `resources/README.md` 已移除姿態資源化建議

#### 狀態
✅ **完全符合程式碼寫死方針**
- 無外部資源文件
- 所有邏輯在 GDScript 中實現
- 使用枚舉和狀態機模式

---

### ⚠️ AI 系統 - 目前程式碼寫死（待改進）

#### 目前實現
```
scripts/ai/
├── AIBehavior.gd          # 基礎類別（extends Node）
└── RandomAIBehavior.gd    # 隨機 AI

BattleManager.gd:
- player2_ai = RandomAIBehavior.new()  # 硬編碼創建
```

#### 問題
1. ❌ 新增 AI 需要修改 BattleManager
2. ❌ 字串與類別映射手動維護
3. ❌ 無法在編輯器中調整 AI 參數
4. ❌ 擴展性差

---

## 💡 AI 系統資源化建議

### 推薦方案：Resource + GDScript 混合

#### 優點
- ✅ 在編輯器中配置 AI 參數
- ✅ 程式碼邏輯保持靈活
- ✅ 易於擴展和測試
- ✅ 保持型別安全
- ✅ 動態掃描和加載

#### 架構設計
```
resources/ai/
├── AIRandom.tres           # 隨機 AI 資源
├── AIAggressive.tres       # 攻擊型 AI 資源
├── AIDefensive.tres        # 防守型 AI 資源
└── AIBalanced.tres         # 平衡型 AI 資源

scripts/ai/
├── AIBehaviorResource.gd   # 新增：資源定義
├── AIBehavior.gd          # 重構：基礎類別 + 配置支援
├── RandomAI.gd            # 重構：隨機策略
├── AggressiveAI.gd        # 新增：攻擊型策略
├── DefensiveAI.gd         # 新增：防守型策略
└── BalancedAI.gd          # 新增：平衡型策略
```

#### 核心概念

**1. AIBehaviorResource（資源定義）**
```gdscript
class_name AIBehaviorResource
extends Resource

@export var display_name: String = "未命名 AI"
@export var behavior_class_name: String = "RandomAI"

# 可調參數
@export var aggression: float = 0.5      # 攻擊性
@export var caution: float = 0.5         # 謹慎度
@export var skill_usage: float = 0.5     # 技能使用率
@export var hp_threshold_low: float = 0.3

func create_instance() -> AIBehavior:
    var ai = ClassDB.instantiate(behavior_class_name)
    ai.configure(self)  # 傳入配置
    return ai
```

**2. AIBehavior（重構基礎類別）**
```gdscript
class_name AIBehavior
extends Node

var config: AIBehaviorResource

func configure(resource: AIBehaviorResource) -> void:
    config = resource

func choose_action(...) -> Action:
    # 子類實現，可以使用 config 中的參數
    pass
```

**3. 具體策略實現**
- **RandomAI**: 隨機選擇（可配置傾向）
- **AggressiveAI**: 評分系統，優先高傷害
- **DefensiveAI**: 評分系統，優先防禦和恢復
- **BalancedAI**: 混合策略

#### 使用方式

**創建資源**（在 Godot 編輯器中）：
```
1. 在 resources/ai/ 創建新的 Resource
2. 設置腳本為 AIBehaviorResource
3. 配置參數：
   - display_name: "攻擊型 AI"
   - behavior_class_name: "AggressiveAI"
   - aggression: 0.9
   - caution: 0.2
4. 保存為 AIAggressive.tres
```

**在代碼中使用**：
```gdscript
# BattleManager.gd
func _setup_ai():
    var ai_resource = load("res://resources/ai/AIAggressive.tres")
    player2_ai = ai_resource.create_instance()
```

**動態掃描**：
```gdscript
# CharacterSelection.gd
func _load_ai_behaviors():
    var dir = DirAccess.open("res://resources/ai/")
    # 掃描所有 .tres 文件
    # 顯示在 UI 選單中
```

---

## 📊 方案對比

| 特性 | 目前方式 | 策略模式（簡單） | Resource 混合（推薦） | 行為樹（複雜） |
| :--- | :---: | :---: | :---: | :---: |
| **實現複雜度** | ⭐ | ⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **擴展性** | ❌ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **編輯器支援** | ❌ | ❌ | ✅ | ✅ |
| **參數可調** | ❌ | ❌ | ✅ | ✅ |
| **學習曲線** | ✅ | ✅ | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| **適用場景** | 原型 | 簡單項目 | **中大型項目** | 大型 AAA |

---

## 🎯 實施建議

### 方案 A：立即資源化（推薦）
**適合**：計劃長期開發，需要多種 AI 類型

1. **階段一**（1-2 天）：
   - 創建 `AIBehaviorResource.gd`
   - 重構 `AIBehavior.gd` 支援配置
   - 重構 `RandomAI.gd` 使用配置

2. **階段二**（2-3 天）：
   - 實現 `AggressiveAI.gd`
   - 實現 `DefensiveAI.gd`
   - 實現 `BalancedAI.gd`
   - 創建對應的 `.tres` 資源

3. **階段三**（1 天）：
   - 在 BattleManager 中集成
   - 在 CharacterSelection 中動態掃描
   - 測試和調參

### 方案 B：先簡化再升級
**適合**：快速開發，暫時不需要複雜 AI

1. **立即**：創建 `AIFactory.gd` 統一創建
2. **短期**：實現 2-3 個基本策略
3. **中期**：根據需求升級到資源化

---

## 📝 文檔更新

已完成的文檔更新：
- ✅ `resources/README.md` - 移除 Stance 資源化建議
- ✅ `resources/README.md` - 添加 AI 設計建議鏈接
- ✅ `assets/docs/AISystem.md` - 完整的 AI 資源化設計文檔（新增）

無需更新的文檔：
- ✅ `assets/docs/Stance.md` - 已正確描述為程式碼實現

---

## 🤔 決策建議

### 如果你希望...

**快速開發，短期項目**：
→ 選擇**方案 B**（策略模式）
- 創建 AIFactory
- 2-3 個基本 AI 即可

**中長期項目，需要豐富 AI**：
→ 選擇**方案 A**（Resource 混合）⭐
- 投入 4-6 天實現完整系統
- 獲得極大的靈活性和擴展性
- 可在編輯器中輕鬆調整 AI 行為

**複雜策略遊戲，AI 是核心**：
→ 考慮**行為樹**
- 但需要更多學習時間
- 目前可能過度設計

---

## 總結

1. **Stance 系統**：✅ 已完全符合程式碼寫死方針
2. **AI 系統**：⚠️ 目前是寫死的，建議資源化以提升擴展性
3. **推薦方案**：Resource + GDScript 混合（方案 A）
4. **替代方案**：策略模式（方案 B）適合快速開發

詳細設計請參考：`assets/docs/AISystem.md`
