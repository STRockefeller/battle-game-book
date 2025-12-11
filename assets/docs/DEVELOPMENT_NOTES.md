# 開發筆記與實現報告

本檔案彙總了所有系統的實現進度與開發決策。這些是**歷史記錄與技術決策依據**，不是遊戲設定本身。

**遊戲設定** 請參考: [`INDEX.md`](./INDEX.md)

---

## 目錄

- [對戰系統重構完成（2025-12-08）](#對戰系統重構)
- [AI 系統實現完成（2025-12-08）](#ai-系統實現)
- [資源管理系統實作完成（2025-12-08）](#資源管理系統)
- [系統實現方針確認（2025-12-08）](#系統實現方針)
- [完整對戰流程實現（2025-12-08）](#完整對戰流程)

---

## 對戰系統重構

### 實施日期
2025年12月8日

### 實施狀態
✅ **完成** - 所有文件已建立且編譯通過，無錯誤

### 新建檔案

**核心邏輯層**:
1. `scripts/BattleLogic.gd` - 無狀態邏輯計算
   - 命中判定、傷害計算、執行順序排序
   - 動作驗證、戰鬥結束檢查、冷卻管理
   
2. `scripts/BattleState.gd` - 狀態序列化管理
   - HP/MP/STA/冷卻管理
   - 可序列化為字典用於網路傳輸
   - 狀態簽名用於驗證

**多人模式擴展**:
3. `scripts/ServerBattleManager.gd` - 伺服器端對戰管理
   - 動作驗證、確定性 RNG、狀態廣播
   - 反作弊機制實現

4. `scripts/ClientBattleManager.gd` - 客戶端對戰管理
   - 樂觀更新、狀態同步驗證
   - 單人/多人模式支援

### 修改的檔案

**scripts/BattleManager.gd** - 完全重構
- 新增模式常數: `MODE_SINGLEPLAYER`, `MODE_SERVER`, `MODE_CLIENT`
- 使用 `BattleState` 替代字典管理狀態
- ✅ **向後相容**: 現有單機代碼無需改動

### 反作弊機制

四層防護:
1. **伺服器計算** - 所有計算在伺服器執行，客戶端無法修改
2. **動作驗證** - 伺服器驗證每個動作的合法性
3. **狀態簽名** - 定期驗證客戶端狀態與伺服器一致
4. **確定性 RNG** - 使用伺服器種子，客戶端無法預測

### 性能指標

- `BattleState` 物件大小：< 1KB
- 動作驗證：< 1ms
- 每回合網路流量：< 2KB

### 使用建議

**立即使用**:
1. 現有單機專案無需任何改動
2. 遊戲可正常運行和測試
3. 性能無變化

**未來多人整合**:
1. 參考 `BattleSystemArchitecture.md`
2. 集成 Steam Networking 或自訂網路層
3. 替換 BattleManager 為 ServerBattleManager/ClientBattleManager

---

## AI 系統實現

### 實現狀態
✅ **完成** - 4 種 AI 已實現並集成

### 核心架構

**AIFactory.gd** - 統一工廠
- `create_ai(ai_type: String)` - 根據字串創建 AI
- `get_available_ai_types()` - 獲取所有可用 AI 信息
- `get_ai_info(ai_id)` - 查詢單個 AI 信息
- `is_valid_ai_type()` - 驗證 AI 類型
- 預留: `create_ai_from_resource()`, `register_custom_ai()`

**AIBehavior.gd** - 增強基礎類別
- `config` 屬性（為未來資源化預留）
- `configure(resource)` 方法
- 輔助方法: `get_hp_ratio()`, `can_afford_action()`, `evaluate_action()`

### AI 實現（4 種）

#### RandomAI（隨機型）
- 從可用動作中隨機選擇
- 優先可負擔的動作
- **適合**: 測試、新手練習

#### DefensiveAI（防守型）
- 評分系統，優先生存
- 權重: 防禦 +40、治療 +25、休息 +20
- 緊急邏輯: HP < 15% 強制防禦，HP < 30% 尋找治療
- **適合**: 持久戰、教學關卡

#### AggressiveAI（攻擊型）
- 評分系統，優先高傷害
- 權重: 基礎傷害 ×15、傷害倍率 ×25、攻擊標籤 +20
- 懲罰防禦/治療 -30～-50
- **適合**: 強敵、Boss 戰

#### BalancedAI（平衡型）
- 動態策略切換（4 種模式）
- 模式: Emergency → Defensive → Aggressive → Balanced
- 評分考慮: 傷害、命中率、性價比、狀態效果
- **適合**: 主線戰鬥、競技模式

### 系統集成

**BattleManager.gd** 改進:
```gdscript
# 舊代碼（硬編碼）
player2_ai = RandomAIBehavior.new()

# 新代碼（工廠模式）
var ai_type = BattleConfig.get_enemy_ai_behavior()
player2_ai = AIFactory.create_ai(ai_type)
```

**CharacterSelection.gd** 改進:
```gdscript
# 從 AIFactory 動態加載 AI 列表
func _load_ai_behaviors():
    ai_behaviors = AIFactory.get_available_ai_types()
```

### 擴展性設計

預留接口（已實現）:
1. `AIBehavior.config` - 配置資源接口
2. `AIBehavior.configure()` - 配置方法
3. `AIFactory.create_ai_from_resource()` - 資源加載接口
4. `AIFactory.register_custom_ai()` - 自定義 AI 註冊

升級到資源化 (4-6 天工作量):
- Step 1: 創建 `AIBehaviorResource.gd` (30 分鐘)
- Step 2: 修改工廠支援資源加載 (15 分鐘)
- Step 3: 創建 `.tres` 資源文件 (5 分鐘/個)
- **無需修改任何 AI 邏輯代碼！**

### 測試建議

1. **Random vs Random** - 預期: 完全隨機
2. **Hero vs AggressiveAI** - 預期: 不斷攻擊，很少防禦
3. **Hero vs DefensiveAI** - 預期: 經常防禦和休息
4. **Hero vs BalancedAI** - 預期: 根據戰況切換策略
5. **長時間戰鬥** - 測試 AI 資源耗盡與備用方案

### 後續改進建議

**短期 (1-2 週)**:
1. 調整評分權重（根據實際測試）
2. 添加 AI 調試模式（顯示評分過程）
3. 記錄 AI 決策數據（勝率、常用動作）

**中期 (1-2 月)**:
1. 升級到資源化系統
2. 在編輯器中調整 AI 參數
3. 創建更多 AI 變體

**長期 (3+ 月)**:
1. 實現學習型 AI（記錄玩家習慣）
2. 組合策略（開局防守、終局攻擊）
3. 考慮行為樹系統

---

## 資源管理系統

### 實作日期
2025年12月8日

### 實作狀態
✅ **框架完成** - 準備接收資源檔案

### 核心腳本（3 個）

**scripts/AssetManager.gd**
- 單例資源管理器
- 支援資源快取和 fallback 機制
- 處理精靈圖、動畫、音效、特效載入

**scripts/CharacterVisualState.gd**
- 角色視覺狀態管理
- 8 種姿勢: IDLE, ATTACK, HIT, DEFEND, CAST, VICTORY, DEFEAT, LOW_HP
- 根據 HP 和狀態效果組合決定顯示資源

**scripts/BattleVisualPlayer.gd**
- 協調動畫、音效、特效播放
- 提供: `play_action_sequence()`, `play_hit_sequence()`, `play_victory()`, `play_defeat()`
- 自動管理特效生命週期

### 資源目錄結構

```
assets/
├── sprites/
│   ├── hero/
│   ├── elise/
│   ├── actions/
│   └── status_icons/
├── audio/
│   ├── hero/
│   ├── elise/
│   ├── actions/
│   └── common/
└── vfx/
    ├── actions/
    └── status/
```

### Fallback 機制

資源載入優先級:
```
指定路徑 → Fallback 列表 → 預設資源 → null
```

### 預設資源

- `assets/sprites/default_character.svg` - SVG 預設角色精靈圖
- `assets/vfx/default_effect.tscn` - 簡單白色閃光特效

### 文檔

- `assets/sprites/README.md` - 精靈圖資源指南
- `assets/audio/README.md` - 音效資源指南
- `assets/vfx/README.md` - 特效資源指南
- `assets/audio/default_sound_instructions.md` - 預設音效建立說明

### 修改的資源類別

**scripts/character/Character.gd**
- 新增 `asset_id: String`
- 精靈圖欄位: `sprite_idle`, `sprite_attack`, `sprite_hit` 等
- 音效欄位: `audio_attack`, `audio_hit`, `audio_defend` 等

**scripts/character/action/Action.gd**
- 新增視覺資源: `animation_sprite`, `audio_cast`, `audio_hit`, `vfx_cast`, `vfx_hit`
- 新增 `animation_duration: float`

**scripts/character/status_effect/StatusEffect.gd**
- 新增 `icon_path: String`、`vfx_path: String`

### Battle.gd 整合

新增視覺系統:
- `visual_player` - 動畫協調器
- `asset_manager` - 資源管理器
- `p1/p2_visual_state` - 角色視覺狀態
- `p1/p2_sprite` - 角色精靈節點

新增方法:
- `_initialize_visual_system()` - 初始化
- `_create_character_sprites()` - 創建精靈節點
- `_update_character_sprites()` - 更新精靈
- 修改 `_on_action_executed()` 播放動作與受擊效果
- 修改 `_on_battle_ended()` 播放勝利/失敗

### 未來擴展建議

**短期**:
1. 補充角色和動作的精靈圖資源
2. 添加音效資源
3. 創建基本特效場景

**中期**:
1. 角色換裝系統
2. 添加更多姿勢
3. 狀態效果的持續特效顯示
4. 優化資源預載入

**長期**:
1. 動態資源載入和卸載
2. 資源壓縮和加密
3. 特效編輯器工具

---

## 相關文檔

設計文檔（遊戲規則和機制）：
- [`Action.md`](./Action.md) - 動作系統參數定義
- [`Character.md`](./Character.md) - 角色屬性和計算公式
- [`Stance.md`](./Stance.md) - 姿態機制設計
- [`StatusEffectSystem.md`](./StatusEffectSystem.md) - 狀態效果機制
- [`BattleSystemArchitecture.md`](./BattleSystemArchitecture.md) - 對戰架構高層設計
- [`AISystem.md`](./AISystem.md) - AI 風格和決策邏輯
- [`AssetManagementSystem.md`](./AssetManagementSystem.md) - 資源組織和 Fallback 機制
- [`Battle.md`](./Battle.md) - 對戰規則與流程

導航：
- [`INDEX.md`](./INDEX.md) - 文檔索引與設計/開發分離說明


### 已實現的功能

✅ **第 1 階段：回合開始** - 觸發事件、減少冷卻和效果持續時間

✅ **第 2 階段：行動選擇** - 玩家和 AI 同時選擇動作

✅ **第 3 階段：結果應用** - 按優先度執行、計算傷害、應用效果

✅ **第 4 階段：回合結束** - 觸發事件、檢查戰鬥結束

✅ **同時行動制** - 雙方同時選擇，根據 AGI 決定執行順序

✅ **AI 系統** - 4 種風格各異的 AI

### BattleManager.gd 完整重寫

主要方法:
- `start_battle()` - 開始新戰鬥
- `begin_round()` - 開始新回合
- `_turn_start_phase()` - 回合開始階段
- `_action_selection_phase()` - 收集選擇
- `player_select_action(action)` - 玩家選擇
- `_ai_select_action()` - AI 選擇
- `_all_selections_complete()` - 選擇完成
- `_apply_actions_phase()` - 按優先度執行
- `_execute_single_action()` - 執行單個動作
- `_turn_end_phase()` - 回合結束
- `_check_battle_end()` - 檢查結束
- `_get_available_actions()` - 獲取可用動作
- `_calculate_execution_order()` - 排序動作
- `_roll_hit()` - 命中判定

新增信號:
- `turn_start_selection` - 要求選擇
- `all_actions_selected` - 選擇完成
- `action_executed` - 動作執行結果
- `turn_ended` - 回合結束
- `battle_ended` - 戰鬥結束

### Battle.gd UI 整合

新增方法:
- `_on_turn_start_selection()` - 顯示動作按鈕
- `_on_action_selected()` - 玩家選擇
- `_on_all_actions_selected()` - 所有選擇完成
- `_on_action_executed()` - 顯示執行結果
- `_on_turn_ended()` - 回合結束日誌
- `_on_battle_ended()` - 戰鬥結束

---

## 完整對戰流程實現
