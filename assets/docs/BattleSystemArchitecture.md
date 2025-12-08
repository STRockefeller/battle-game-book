# 對戰系統架構文檔

## 概述

重構後的對戰系統支援單機和多人模式，通過分離邏輯層、狀態層和UI層，實現了易於擴展和維護的架構。

## 核心組件

### 1. BattleLogic（無狀態邏輯層）
位置: `scripts/BattleLogic.gd`

- **職責**: 純計算函數，輸入相同則輸出必定相同
- **特點**: 無狀態、完全確定性、可用於伺服器驗證和客戶端預測
- **主要方法**:
  - `calculate_hit()`: 命中判定
  - `calculate_damage_result()`: 傷害計算
  - `calculate_execution_order()`: 執行順序
  - `validate_action()`: 動作驗證
  - `is_battle_ended()`: 戰鬥結束檢查

**使用例**:
```gdscript
# 客戶端預測傷害
var predicted_damage = BattleLogic.calculate_damage_result(atk, def, multiplier)

# 伺服器驗證動作
var validation = BattleLogic.validate_action(
    current_sta, current_mp, max_sta, max_mp,
    action, cooldowns
)
```

### 2. BattleState（狀態序列化層）
位置: `scripts/BattleState.gd`

- **職責**: 管理對戰狀態的序列化和驗證
- **特點**: 可轉換為字典，便於網路傳輸；提供狀態簽名用於驗證
- **主要功能**:
  - HP/MP/STA 管理
  - 冷卻追蹤
  - 序列化/反序列化（to_dict/from_dict）
  - 狀態哈希用於驗證

**使用例**:
```gdscript
# 建立狀態
var state = BattleState.new(p1_max_hp, p1_max_mp, p1_max_sta,
                            p2_max_hp, p2_max_mp, p2_max_sta)

# 序列化為字典用於網路傳輸
var state_dict = state.to_dict()

# 驗證狀態一致性
var hash = state.calculate_hash()
```

### 3. BattleManager（基礎對戰管理）
位置: `scripts/BattleManager.gd`

- **職責**: 核心對戰邏輯，管理回合流程和信號
- **模式**: 單機模式預設
- **信號**:
  - `turn_start_selection`: 要求玩家選擇動作
  - `all_actions_selected`: 所有選擇完成
  - `action_executed`: 單個動作完成
  - `turn_ended`: 回合結束
  - `battle_ended`: 戰鬥結束

**單機使用（現有功能）**:
```gdscript
# 場景中的 BattleManager 節點
battle_manager.start_battle()

# 玩家選擇動作
battle_manager.player_select_action(action)

# AI 自動決策（內部 _ai_select_action）
```

### 4. ServerBattleManager（伺服器對戰管理）
位置: `scripts/ServerBattleManager.gd`

- **繼承**: BattleManager
- **職責**: 多人遊戲中的伺服器邏輯
- **關鍵功能**:
  - 動作驗證（validate_player_action）
  - 確定性 RNG 管理
  - 狀態廣播

**多人伺服器使用**:
```gdscript
# 初始化
var battle_manager = ServerBattleManager.new()
battle_manager.setup_multiplayer(player1_peer_id, player2_peer_id)
battle_manager.start_battle()

# 接收客戶端動作（來自 RPC）
func server_player_submit_action(peer_id: int, action_id: String):
    battle_manager.server_player_submit_action(peer_id, action_id)

# 廣播結果
battle_manager.broadcast_turn_execution(execution_order, results)
```

### 5. ClientBattleManager（客戶端對戰管理）
位置: `scripts/ClientBattleManager.gd`

- **繼承**: BattleManager
- **職責**: 客戶端的玩家輸入和結果顯示
- **特點**: 樂觀更新、狀態同步驗證

**多人客戶端使用**:
```gdscript
# 初始化
var battle_manager = ClientBattleManager.new()
battle_manager.setup_client_connection(local_player_id, server_peer_id)
battle_manager.start_battle()

# 玩家提交動作（樂觀更新）
func on_action_button_pressed(action: Action):
    battle_manager.submit_action_to_server(action)

# 接收伺服器結果（來自 RPC）
func receive_turn_execution(broadcast_data: Dictionary):
    battle_manager.receive_turn_execution(broadcast_data)
```

## 工作流程

### 單機模式

```
┌─────────────────────────────────────────────────┐
│  BattleManager（單機）                          │
├─────────────────────────────────────────────────┤
│                                                 │
│  1. player_select_action(action)  <- UI 呼叫   │
│     └→ pending_selections[player1] = action    │
│                                                 │
│  2. _ai_select_action()             <- 自動    │
│     └→ pending_selections[player2] = action    │
│                                                 │
│  3. _apply_actions_phase()                      │
│     └→ BattleLogic 計算結果                     │
│     └→ 發送 action_executed 信號                │
│                                                 │
│  4. _turn_end_phase()                           │
│     └→ 發送 turn_ended 信號                     │
│                                                 │
│  5. begin_round() <- 下一回合                   │
│                                                 │
└─────────────────────────────────────────────────┘
```

### 多人模式（伺服器端）

```
┌──────────────────────────────────────────────────────────┐
│  ServerBattleManager                                      │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  1. server_player_submit_action(peer_id, action_id)      │
│     └→ validate_player_action(peer_id, action)           │
│        └→ BattleLogic.validate_action()                  │
│     └→ pending_selections[player] = action               │
│                                                           │
│  2. 等待雙方都提交（selections_completed >= 2）          │
│     └→ _all_selections_complete()                        │
│                                                           │
│  3. _apply_actions_phase()                               │
│     └→ _execute_single_action() 使用確定性 RNG           │
│     └→ 記錄 RNG 種子用於驗證                             │
│                                                           │
│  4. broadcast_turn_execution(...)                        │
│     └→ 發送結果和 RNG 種子給雙方客戶端                   │
│                                                           │
│  5. begin_round() <- 下一回合                            │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

### 多人模式（客戶端）

```
┌──────────────────────────────────────────────────────────┐
│  ClientBattleManager                                      │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  1. UI 玩家選擇動作                                       │
│     └→ submit_action_to_server(action)                   │
│        ├→ 樂觀更新：pending_selections[local] = action   │
│        └→ RPC 發送到伺服器                               │
│                                                           │
│  2. 等待伺服器結果...                                     │
│                                                           │
│  3. receive_turn_execution(broadcast_data)               │
│     ├→ state.from_dict(broadcast_data["state"])          │
│     ├→ 驗證狀態哈希                                       │
│     ├→ 發送 turn_ended 信號                               │
│     └→ UI 播放動畫                                        │
│                                                           │
│  4. begin_round() <- 下一回合                            │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

## 使用指南

### 在既有項目中保持單機功能

**現有代碼完全相容：**
- 場景中的 BattleManager 節點保持不變
- Battle.gd 的 UI 綁定保持不變
- 單機遊玩完全正常

```gdscript
# Battle.gd 中現有代碼無需改動
@onready var battle_manager: BattleManager = $BattleManager

func _ready():
    battle_manager.connect("turn_start_selection", Callable(self, "_on_turn_start_selection"))
    # ... 其他信號連接
    battle_manager.start_battle()
```

### 轉換到多人模式

**伺服器端（主機）**:
```gdscript
# 將 BattleManager 改為 ServerBattleManager
@onready var battle_manager: ServerBattleManager = $BattleManager

func _ready():
    battle_manager.setup_multiplayer(player1_peer, player2_peer)
    battle_manager.start_battle()

# 設置 RPC 接收
@rpc("any_peer")
func server_player_submit_action(peer_id: int, action_id: String):
    battle_manager.server_player_submit_action(peer_id, action_id)
```

**客戶端**:
```gdscript
# 將 BattleManager 改為 ClientBattleManager
@onready var battle_manager: ClientBattleManager = $BattleManager

func _ready():
    battle_manager.setup_client_connection(local_player_id, server_peer_id)
    battle_manager.start_battle()

# 提交動作
func _on_action_button_pressed(action: Action):
    battle_manager.submit_action_to_server(action)

# 接收伺服器結果
@rpc("authority")
func receive_turn_execution(broadcast_data: Dictionary):
    battle_manager.receive_turn_execution(broadcast_data)
```

## 反作弊機制

### 1. 伺服器驗證
所有關鍵計算都在伺服器執行，客戶端無法修改：
- 傷害計算
- 命中判定
- 冷卻檢查
- 資源扣除

### 2. 動作驗證
客戶端提交的動作必須通過伺服器驗證：
```gdscript
# 伺服器端
var validation = BattleLogic.validate_action(
    current_sta, current_mp, max_sta, max_mp,
    action, cooldowns
)
if not validation["valid"]:
    # 拒絕動作
    return
```

### 3. 狀態簽名
定期驗證客戶端狀態：
```gdscript
# 伺服器
var server_hash = state.calculate_hash()
# 客戶端定期發送其狀態哈希
if not state.verify_hash(client_hash):
    # 檢測到狀態不一致，強制覆蓋
    state.from_dict(server_state)
```

### 4. 確定性 RNG
使用伺服器種子計數器確保隨機數無法被篡改：
```gdscript
# 伺服器廣播 RNG 種子
broadcast_data["rng_seeds"] = rng_seeds.duplicate()

# 客戶端可驗證計算：
var result = BattleLogic.calculate_hit_static(acc, eva, seed)
```

## 擴展指南

### 添加新的對戰模式

創建新的類繼承 BattleManager：
```gdscript
# CustomBattleManager.gd
extends BattleManager
class_name CustomBattleManager

func _ready():
    battle_mode = "custom"
    super._ready()

# 覆寫所需方法
func _execute_single_action(user, target, action):
    # 自訂邏輯
    pass
```

### 添加新的計算邏輯

在 BattleLogic 中添加靜態方法：
```gdscript
# BattleLogic.gd
static func calculate_custom_effect(base: int, multiplier: float) -> int:
    return int(base * multiplier)
```

### 自訂 AI 行為

現有 AI 系統保持不變，可繼續使用：
```gdscript
# AIBehavior 及其子類完全相容
var ai = AIFactory.create_ai("balanced")
var action = ai.choose_action(character, available_actions, opponent, battle_manager)
```

## 性能考慮

### 網路流量
- 每回合需要傳輸：玩家選擇（小）+ 完整狀態（中等）
- 建議：對於 Steam Networking，每秒最多 1 次完整狀態同步

### 計算開銷
- BattleLogic 計算都是 O(n) 複雜度，其中 n = 動作數（通常 ≤ 10）
- 伺服器端驗證每個動作成本：< 1ms

### 內存使用
- BattleState 對象大小：< 1KB
- 歷史追蹤（可選）：每回合 + 1KB

## 已知限制和未來改進

### 當前限制
- RPC 實現需要根據網路框架自行完成
- 暫無重連機制
- 暫無回放功能

### 未來改進計劃
- [ ] 完整的 Steam Networking 集成
- [ ] 玩家重連和狀態恢復
- [ ] 戰鬥回放和分析
- [ ] 表情符號和聲音效果的網路同步
- [ ] 排行榜和對戰記錄
